#{{{1 setup
t0 = + new Date()
width = canvas.width
height = canvas.width
size = 60
radius = size * .40
ctx = canvas.getContext "2d"
boxesPerLine = 3
#{{{1 data

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
  ctx.fillStyle = "rgba(255,255,255,0.8)"
  ctx.fill()
  ctx.strokeStyle = hashcolor.intToColor hashcolor.val key
  ctx.stroke()
  ctx.font= "#{size/2}px ubuntu"
  ctx.fillStyle = "#000"
  ctx.fillText key, val.x + size *.35, val.y + size * .65

t1 = + new Date()
console.log "Time:", t1-t0
