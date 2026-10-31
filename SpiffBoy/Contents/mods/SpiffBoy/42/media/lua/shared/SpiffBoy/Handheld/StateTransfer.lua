require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"

SpiffBoy.StateTransfer=SpiffBoy.StateTransfer or{}
local b=SpiffBoy.StateTransfer

b.TIMEOUT_MS=10000

local f={"f","a","x","y","z","v"}
local g={}

function b.chunks(consoleId,transferId,data,header)
local e=SpiffBoy.listCount(data.nodes)
local h=math.max(1,math.ceil(e/SpiffBoy.STATE_CHUNK))
local c={}
for a=1,h do
local d={}
for i=(a-1)*SpiffBoy.STATE_CHUNK+1,math.min(a*SpiffBoy.STATE_CHUNK,e)do
d[#d+1]=SpiffBoy.listItem(data.nodes,i)
end
c[a]={i=consoleId,t=transferId,s=a,n=h,e=SpiffBoy.wireList(d)}
end
local a=c[1]
a.format=data.format
a.stamp=data.stamp
a.root=data.root
for i,d in ipairs(f)do
if header[d]~=nil then
a[d]=header[d]
end
end
return c
end

local function j(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoy.isInteger(args.t)or not SpiffBoy.isInteger(args.s)or not SpiffBoy.isInteger(args.n)then
return false
end
if args.n<1 or args.n>SpiffBoy.STATE_MAX_CHUNKS or args.s<1 or args.s>args.n then
return false
end
local c=SpiffBoy.listCount(args.e)
if c>SpiffBoy.STATE_CHUNK then
return false
end
for d=1,c do
local a=SpiffBoy.listItem(args.e,d)
if type(a)~="table"or SpiffBoy.listCount(a.k)~=SpiffBoy.listCount(a.v)then
return false
end
end
if args.s==1 and(not SpiffBoy.isInteger(args.format)or type(args.stamp)~="table"or not SpiffBoy.isInteger(args.f)or args.a~=SpiffBoy.VERIFY_TICKS)then
return false
end
return true
end

function b.cleanMissing(list,total)
local c=SpiffBoy.listCount(list)
if c<1 or c>total then
return nil
end
local d={}
for e=1,c do
local a=SpiffBoy.listItem(list,e)
if not SpiffBoy.isInteger(a)or a<1 or a>total then
return nil
end
d[e]=a
end
return d
end

function b.newCollector()
return{transfers={}}
end

function b.add(collector,key,args)
local d=getTimestampMs()
if not j(args)then
return nil
end
local a=collector.transfers[key]
if not a or a.id~=args.t or a.total~=args.n then
a={id=args.t,consoleId=args.i,total=args.n,chunks={},received=0,lastMs=d,askedMs=d}
collector.transfers[key]=a
end
a.lastMs=d
if not a.chunks[args.s]then
a.chunks[args.s]=args
a.received=a.received+1
end
if a.received<a.total then
return nil
end
collector.transfers[key]=nil
local c=a.chunks[1]
local e={}
for i=1,a.total do
local h=a.chunks[i].e
for k=1,SpiffBoy.listCount(h)do
e[#e+1]=SpiffBoy.listItem(h,k)
end
end
local h={}
for k,i in ipairs(f)do
h[i]=c[i]
end
return{format=c.format,stamp=c.stamp,root=c.root,nodes=SpiffBoy.wireList(e)},h,a.chunks
end

function b.overdue(collector,waitMs,now)
local c=nil
for h,a in pairs(collector.transfers)do
if now-math.max(a.lastMs,a.askedMs)>waitMs then
a.askedMs=now
local d={}
for e=1,a.total do
if not a.chunks[e]then
d[#d+1]=e
end
end
c=c or{}
c[#c+1]={key=h,consoleId=a.consoleId,id=a.id,missing=SpiffBoy.wireList(d)}
end
end
return c or g
end

function b.expire(collector,now)
local a=nil
for d,c in pairs(collector.transfers)do
if now-c.lastMs>b.TIMEOUT_MS then
a=a or{}
a[#a+1]={key=d,consoleId=c.consoleId,id=c.id}
end
end
if not a then
return g
end
for d,c in ipairs(a)do
collector.transfers[c.key]=nil
end
return a
end
