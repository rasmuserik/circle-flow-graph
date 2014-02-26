#{{{1 setup
t0 = + new Date()
height = canvas.width
size = 80
count = 20
hspace = 1.3
width = size * 5
radius = size * .40
ctx = canvas.getContext "2d"
ctx.lineWidth = 2
circlesPerLine = 3
curveness = 1.9
#{{{1 code
#ctx.fillRect(0,0,1000,1000)

nodes = {}
fns = {}
nodeCount = 0


if true

  Node = (prev, op, inputs) ->
    @op = op
    @id = nodeCount
    ++nodeCount
    if prev != undefined
      console.log prev
      @prev = prev.id
      nodes[@prev].next = @id
    @in = inputs
    @out = []
    for i in @in
      nodes[i].out.push @id
    nodes[@id] = this
    @val = this.eval()
  
  Node.prototype.drawObj = ->
    ctx.beginPath()
    ctx.arc @x, @y, radius, 0, Math.PI*2
    ctx.fillStyle = "rgba(255,255,255,0.8)"
    ctx.fill()
    ctx.strokeStyle = hashcolor.intToColor hashcolor.val "" + @val
    ctx.stroke()
    ctx.font = "#{size/3}px ubuntu"
    ctx.fillStyle = "#000"
    ctx.fillText @op, @x - size * .2, @y - size * .05
    ctx.fillText @val, @x - size * .2, @y + size * .25
    console.log @next
    nodes[@next].drawObj() if @next != undefined

  Node.prototype.outPoint = ->
    d = Math.SQRT1_2 * radius
    [@x + d, @y + d, @x + d*curveness, @y+d*curveness]
  Node.prototype.inPoint = (i) ->
    t = radius * Math.sqrt .5
    w = 2
    a = Math.PI *1.25 + w * (i+1)/(@in.length+1) - w/2
    y = Math.sin(a)
    x = Math.cos(a)
    [@x + x*radius, @y + y*radius, @x + x*radius*curveness, @y+y*radius*curveness]


  Node.prototype.drawLines = ->
    for i in [0..@in.length-1] by 1
      console.log i, @in[i], nodes[@in[i]]
      src = nodes[@in[i]]
      [x0, y0, cx0, cy0] = src.outPoint()
      [x1, y1, cx1, cy1] = @inPoint(i)
      ctx.beginPath()
      ctx.strokeStyle = hashcolor.intToColor hashcolor.val "" + src.val
      ctx.moveTo x0, y0
      ctx.quadraticCurveTo cx0, cy0, (cx0+cx1)/2, (cy0+cy1)/2
      ctx.quadraticCurveTo cx1, cy1, x1, y1
      ctx.stroke()
    nodes[@next].drawLines() if @next != undefined

  Node.prototype.layout = (x, y) ->
    @x = x
    @y = y
    x += size
    if x > width - size/2
      x -= width - size/2
      y += size * hspace
      x += size if x < size/2
    nodes[@next].layout x, y if @next != undefined

  Node.prototype.eval = () ->
    if typeof @op == "number"
      return @op
    else if typeof fns[@op] == "function"
      return fns[@op].apply null, @in.map (o) -> nodes[o].eval()
    else
      throw @op


  #{{{2 atual execution
  fns["+"] = (args...) -> args.reduce ((a,b)->a+b), 0
  fns["-"] = (args...) -> args.slice(1).reduce ((a,b)->a-b), args[0]
  fns["xor"] = (args...) -> args.reduce ((a,b)->a^b), 0
  fns["&"] = (args...) -> args.reduce ((a,b)->a&b), 0
  fns["or"] = (args...) -> args.reduce ((a,b)->a|b), 0
  #fns["-"] = (a, b) -> a - b
  #fns["*"] = (a, b) -> a * b
  #fns["/"] = (a, b) -> Math.round(a / b)
  #fns["%"] = (a, b) -> a % b
  fnNames = Object.keys fns

  root = new Node(undefined, 1, [])
  prev = root
  for i in [0..count]
    if Math.random() < .3 || nodeCount < 2
      prev = new Node(prev, 1 + Math.random() * 9 | 0, [])
    else
      length = 1 + Math.random() * Math.random() * 4 | 0
      length = 2
      args = []
      for i in  [0..length-1]
        args.push nodeCount - Math.random() * Math.random() * nodeCount | 0 
      prev = new Node(prev, fnNames[Math.random() * fnNames.length | 0], args)

  root.layout size/2, size/2
  root.drawLines()
  root.drawObj()



#{{{1 old code
else
  #{{{2 graph
  data =
    a: []
    b: []
    c: ["a", "b"]
    d: ["c", "b"]
    e: ["c", "b"]
    f: ["d", "e"]
    g: ["d", "c"]
    h: []
    i: ["f", "g", "h"]
    j: ["c"]
    k: ["d", "c"]
    l: ["f", "g", "h"]
    m: ["d", "c"]
    n: []
    o: ["l", "n", "g"]
    p: ["l", "o"]
    q: ["p"]
    r: ["n", "o"]
    s: ["r", "q", "p"]
    t: ["r", "g"]
    u: ["s"]
    v: ["r", "t"]
    w: ["s", "u"]
    x: ["r", "u", "v", "t", "f", "s"]
    y: ["t", "x"]
    z: ["w"]
  
  
  for key, val of data
    data[key] =
      in: val
      out: []
      id: key
  for key, val of data
    for id in val.in
      data[id].out.push key
  
  x = 0
  y = 0
  odd = false
  
  for key, val of data
    val.x = x
    val.y = y
    x += size
    if x + size > width
      odd = !odd
      x = if odd then size / 2 else 0
      y = y + size*1.2
  
  #{{{2 entry/exitpoints
  exitPoint = (data) ->
    t = radius * Math.sqrt .5
    [data.x + size/2 + t, data.y + size/2 + t]
  
  exitDir = (data) ->
    [data.x + size/2 + radius * 1.5, data.y + size/2 + radius * 1.5]
  
  entryDir= (data, i, n) ->
    [x,y] = entryPoint(data, i, n)
    [x,y] = [x - (data.x+width/2), y - (data.y+width/2)]
    [(data.x+width/2) + 1.15*x, (data.y+width/2) + 1.15*y]
  
  entryPoint = (data, i, n) ->
    t = radius * Math.sqrt .5
    w = 2
    a = Math.PI *1.25 + w * (i+1)/(n+1) - w/2
    y = Math.sin(a)
    x = Math.cos(a)
    console.log data
    console.log x, y, a, w, t, i, n
    [data.x + size/2 - t, data.y + size/2 - t]
    [data.x + size/2 + x*radius, data.y + size/2 + y*radius]
  
  #{{{2 draw
  ctx.lineWidth = 2
  for key, end of data
    for i in [0..end.in.length - 1] by 1
      val = data[end.in[i]]
      console.log val, end
      ctx.beginPath()
      ctx.strokeStyle = hashcolor.intToColor hashcolor.val val.id
      [x0, y0] = exitPoint val
      [cx0, cy0] = exitDir val
      entry = end
      [x1, y1] = entryPoint entry, i, end.in.length
      [cx1, cy1] = entryDir entry, i, end.in.length
      ctx.moveTo x0, y0
      ctx.quadraticCurveTo cx0, cy0, (cx0+cx1)/2, (cy0+cy1)/2
      ctx.quadraticCurveTo cx1, cy1, x1, y1
      ctx.stroke()
  
  for key, val of data
    ctx.beginPath()
    ctx.arc val.x+size/2, val.y+size/2, radius, 0, Math.PI*2
    ctx.fillStyle = "rgba(255,255,255,0.6)"
    ctx.fill()
    ctx.strokeStyle = hashcolor.intToColor hashcolor.val key
    ctx.stroke()
    ctx.font= "#{size/2}px ubuntu"
    ctx.fillStyle = "#000"
    ctx.fillText key, val.x + size *.35, val.y + size * .65
  
  t1 = + new Date()
  console.log "Time:", t1-t0
  
  w = 600
  ctx.beginPath()
  ctx.moveTo w/2,0
  ctx.quadraticCurveTo w,0,w,100
  ctx.quadraticCurveTo w,200,w/2,200
  ctx.quadraticCurveTo 0,200,0,100
  ctx.quadraticCurveTo 0,0,w/2,0
  ctx.stroke()
