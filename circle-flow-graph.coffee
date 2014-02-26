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
ctx.fillRect(0,0,1000,1000)

nodes = {}
fns = {}
nodeCount = 0


#{{{1 code
if true

  #{{{2 Node Class
  Node = (prev, op, inputs) -> #{{{3
    @op = op
    @id = nodeCount
    ++nodeCount
    if prev != undefined
      @prev = prev.id
      nodes[@prev].next = @id
    @in = inputs
    @out = []
    for i in @in
      nodes[i].out.push @id
    nodes[@id] = this
    @val = this.eval()
  
  Node.prototype.drawShadow = -> #{{{3
    if @mark
      ctx.setShadow(0,0,radius*1, hashcolor.light "" + @val)
      ctx.beginPath()
      ctx.arc @x, @y, radius+1, 0, Math.PI*2
      ctx.fillStyle = "#000"
      ctx.fill()
      ctx.clearShadow()

    nodes[@next].drawShadow() if @next != undefined

  Node.prototype.drawObj = -> #{{{3
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
    nodes[@next].drawObj() if @next != undefined

  Node.prototype.outPoint = -> #{{{3
    d = Math.SQRT1_2 * radius
    [@x + d, @y + d, @x + d*curveness, @y+d*curveness]
  Node.prototype.inPoint = (i) ->
    t = radius * Math.sqrt .5
    w = 2
    a = Math.PI *1.25 + w * (i+1)/(@in.length+1) - w/2
    y = Math.sin(a)
    x = Math.cos(a)
    [@x + x*radius, @y + y*radius, @x + x*radius*curveness, @y+y*radius*curveness]


  Node.prototype.drawLines = -> #{{{3
    for i in [0..@in.length-1] by 1
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

  Node.prototype.layout = (x, y) -> #{{{3
    @x = x
    @y = y
    x += size
    if x > width - size/2
      x -= width - size/2
      y += size * hspace
      x += size if x < size/2
    nodes[@next].layout x, y if @next != undefined

  Node.prototype.eval = () -> #{{{3
    if typeof @op == "number"
      return @op
    else if typeof fns[@op] == "function"
      return fns[@op].apply null, @in.map (o) -> nodes[o].eval()
    else
      throw @op


  #{{{2 atual execution
  fns["+"] = (a,b) -> a+b
  fns["-"] = (a,b) -> a-b
  fns["xor"] = (a,b) -> a^b
  fns["&"] = (a,b) -> a&b
  fns["or"] = (a,b) -> a|b
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
    prev.mark = true if Math.random() < .2

  t0 = Date.now()
  root.layout size/2, size/2
  root.drawShadow()
  console.log "time:", Date.now() - t0; t0 = Date.now()
  root.drawLines()
  console.log "time:", Date.now() - t0; t0 = Date.now()
  root.drawObj()
  console.log "time:", Date.now() - t0; t0 = Date.now()



