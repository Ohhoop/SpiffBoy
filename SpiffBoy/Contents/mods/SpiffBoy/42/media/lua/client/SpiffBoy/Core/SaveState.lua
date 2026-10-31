require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Core/GameErrors"
require"SpiffBoy/Core/GameBase"

SpiffBoy.SaveState=SpiffBoy.SaveState or{}
local c=SpiffBoy.SaveState

c.FORMAT=1
c.MAX_NODES=20000

local J=4
local u=6
local K={"frame","period","from","duty"}
local j="SpiffBoy"
local L="Game"
local M={
{"SpiffBoyRandom"},
{"SpiffBoyBootScreen"},
{"SpiffBoyGameBase"},
{j,"ChipBank"},
{j,"Cartridges"},
}
local N=31
local O=2147483647
local P=4096
local k={number=1,string=2,boolean=3}
local v="nan"
local w="inf"
local x="-inf"

local function y(a,b)
return a<b
end

local function l(list,before)
local g=#list
if g<2 then
return list
end
local a,h=list,{}
local i=1
while i<g do
local f=1
while f<=g do
local m=math.min(f+i,g+1)
local n=math.min(f+2*i,g+1)
local d,e,b=f,m,f
while d<m and e<n do
if before(a[e],a[d])then
h[b]=a[e]
e=e+1
else
h[b]=a[d]
d=d+1
end
b=b+1
end
while d<m do
h[b]=a[d]
d=d+1
b=b+1
end
while e<n do
h[b]=a[e]
e=e+1
b=b+1
end
f=f+2*i
end
a,h=h,a
i=i*2
end
if a~=list then
for b=1,g do
list[b]=a[b]
end
end
return list
end

function c.NO_PACE()
end

local function o(message)
SpiffBoy.trace("save state: "..message)
end

function c.rootsOf(gameName)
local d={}
for b,a in ipairs(M)do
d[#d+1]=a
end
if type(gameName)=="string"then
for a,b in pairs(_G)do
if type(a)=="string"and type(b)=="table"and a~=j and string.sub(gameName,1,string.len(a))==a then
d[#d+1]={a}
end
end
local a=string.match(gameName,"^"..j.."(.+)"..L.."$")
if a and type(rawget(SpiffBoy,a))=="table"then
d[#d+1]={j,a}
end
end
l(d,function(a,b)
return table.concat(a,".")<table.concat(b,".")
end)
return d
end

local function Q(t)
local a,b={},{}
for d,e in pairs(t)do
if type(d)=="string"then
b[#b+1]=d
elseif SpiffBoy.isInteger(d)then
a[#a+1]=d
end
end
l(a,y)
l(b,y)
for d=1,#b do
a[#a+1]=b[d]
end
return a
end

local function z(path,count)
local a=_G
for d=1,count do
local b=SpiffBoy.listItem(path,d)
if type(a)~="table"or(type(b)~="string"and not SpiffBoy.isInteger(b))then
return nil
end
a=a[b]
end
return a
end

local function R(roots,pace)
local a={}
local b={}
for h,d in ipairs(roots)do
local e=z(d,#d)
if type(e)=="table"then
local f={}
for g=1,#d do
f[g]=d[g]
end
b[#b+1]={value=e,path=f,depth=#d}
end
end
local g=1
local i,m=0,0
while g<=#b do
pace()
local d=b[g]
g=g+1
local h=d.value
if a[h]==nil then
i=i+1
a[h]=d.path
for q,n in ipairs(Q(h))do
m=m+1
local e=rawget(h,n)
local f={}
for p=1,#d.path do
f[p]=d.path[p]
end
f[#f+1]=n
if type(e)=="function"and a[e]==nil then
a[e]=f
elseif type(e)=="table"and d.depth<J and a[e]==nil then
b[#b+1]={value=e,path=f,depth=d.depth+1}
end
end
end
end
return a,i,m
end

local function S(gameName,pace)
local e=getTimestampMs()
local a=c.rootsOf(gameName)
local b=getTimestampMs()
local f,g,h=R(a,pace)
local d={}
for i,m in ipairs(a)do
d[i]=table.concat(m,".")
end
o("roots of "..tostring(gameName).." in "..tostring(b-e).." ms: "..table.concat(d," ").."; global paths in "..tostring(getTimestampMs()-b).." ms, "..tostring(g).." tables, "..tostring(h).." keys")
return{roots=a,paths=f}
end

local function A(modId)
local a=modId and getModInfoByID(modId)
return a and a:getModVersion()
end

local function B(definition)
return{
id=definition and definition.id,
mod=definition and definition.mod,
modVersion=definition and A(definition.mod),
core=A(SpiffBoy.MOD_ID),
}
end

local function T(a,b)
return type(a)=="table"and a.id==b.id and a.mod==b.mod and a.modVersion==b.modVersion and a.core==b.core
end

function c.namedArt(loader,names)
return function(name)
local a=loader(name)
if a~=nil then
names[a]=name
end
return a
end
end

local function U(t)
local d={}
for a,b in pairs(t)do
if k[type(a)]then
d[#d+1]=a
end
end
l(d,function(a,b)
local e,f=k[type(a)],k[type(b)]
if e~=f then
return e<f
end
if type(a)=="boolean"then
return(not a)and b
end
return a<b
end)
return d
end

local function V(t)
local a={}
for b,d in pairs(t)do
if not k[type(b)]then
a[#a+1]=b
end
end
return a
end

local function C(parent,key)
if parent==nil then
if key=="game"then
return"self"
end
return tostring(key)
end
if type(key)=="string"and string.match(key,"^[%a_][%w_]*$")then
return parent.."."..key
end
if type(key)=="table"then
return parent.."[a table]"
end
return parent.."["..tostring(key).."]"
end

local function W(meta)
local a=rawget(meta,"Type")
if type(a)=="string"then
return"the class "..a
end
return"a class"
end

local function X(tokens,artNames,paths)
return{
tokens=tokens,
artNames=artNames,
paths=paths,
order={},
indexOf={},
nameOf={},
plainOf={},
cost={keys=0,biggest=0,biggestTable=nil},
}
end

local function g(encoder,value)
return type(value)=="table"and encoder.tokens[value]==nil and encoder.artNames[value]==nil and encoder.paths[value]==nil
end

local function h(encoder,t,parent,key)
if not encoder.indexOf[t]then
local a=encoder.order
a[#a+1]=t
encoder.indexOf[t]=#a
if parent~=nil or key~=nil then
encoder.nameOf[t]={parent=parent,key=key}
end
end
end

local function d(encoder,t)
local a=encoder.nameOf[t]
if a==nil then
return nil
end
return C(d(encoder,a.parent),a.key)
end

local function p(encoder,t)
local a=encoder.plainOf[t]
if not a then
a=U(t)
encoder.plainOf[t]=a
local b=encoder.cost
b.keys=b.keys+#a
if#a>b.biggest then
b.biggest=#a
b.biggestTable=t
end
end
return a
end

local function D(encoder,value)
if encoder.tokens[value]~=nil then
return"j:"..encoder.tokens[value]
end
if encoder.artNames[value]~=nil then
return"a:"..encoder.artNames[value]
end
local a=encoder.paths[value]
if a then
return"p:"..table.concat(a,".")
end
return nil
end

local function Y(encoder,t)
local a={}
local b=getmetatable(t)
if type(b)=="table"and encoder.paths[b]then
a[1]=table.concat(encoder.paths[b],".")
end
for i,e in ipairs(p(encoder,t))do
local f=rawget(t,e)
if k[type(f)]then
a[#a+1]=tostring(e).."="..tostring(f)
end
end
return table.concat(a,",")
end

local function E(encoder,t)
local e=V(t)
if#e==0 then
return e
end
local f={}
for b,a in ipairs(e)do
if encoder.indexOf[a]then
f[a]={1,encoder.indexOf[a]}
elseif D(encoder,a)then
f[a]={2,D(encoder,a)}
else
f[a]={3,Y(encoder,a)}
end
end
l(e,function(a,b)
local i,m=f[a],f[b]
if i[1]~=m[1]then
return i[1]<m[1]
end
return i[2]<m[2]
end)
return e
end

local function q(encoder,value,owner,key)
local a=type(value)
if a=="string"or a=="boolean"then
return value
end
if a=="number"then
if value~=value then
return{f=v}
end
if value==math.huge then
return{f=w}
end
if value==-math.huge then
return{f=x}
end
return value
end
local b=encoder.tokens[value]
if b then
return{j=b}
end
local e=encoder.artNames[value]
if e then
return{a=e}
end
if a=="table"then
local f=encoder.paths[value]
if f then
return{p=SpiffBoy.wireList(f)}
end
return{r=encoder.indexOf[value]}
end
local f=owner and C(d(encoder,owner),key)or"the console"
if a=="function"then
local i=encoder.paths[value]
if i then
return{p=SpiffBoy.wireList(i)}
end
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the game keeps in "..tostring(f).." a function that has no global name")
end
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the game keeps in "..tostring(f).." a "..a.." that is no texture of its art")
end

local function Z(root,tokens,artNames,paths,pace)
local a=X(tokens,artNames,paths)
local e=a.order
local r=getTimestampMs()
if g(a,root)then
h(a,root,nil,nil)
end
local f=1
while f<=#e do
pace()
local b=e[f]
f=f+1
for n,i in ipairs(p(a,b))do
local m=rawget(b,i)
if g(a,m)then
h(a,m,b,i)
end
end
for n,i in ipairs(E(a,b))do
if g(a,i)then
h(a,i,b,"a key")
end
local m=rawget(b,i)
if g(a,m)then
h(a,m,b,i)
end
end
end
r=getTimestampMs()-r

local _=getTimestampMs()
local t={}
for aa,b in ipairs(e)do
pace()
local i={}
local m=getmetatable(b)
if m~=nil then
if type(m)~="table"then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the game keeps in "..tostring(d(a,b)).." a table that hides its metatable, so its class cannot be named")
end
local n=paths[m]
if not n then
SpiffBoy.GameErrors.raise("SB-STATE-CLASS","the game keeps in "..tostring(d(a,b)).." a table of "..W(m).." that has no global name")
end
i.c=SpiffBoy.wireList(n)
end
local F=p(a,b)
local n={}
for s=1,#F do
n[s]=F[s]
end
for G,s in ipairs(E(a,b))do
n[#n+1]=s
end
local G,H={},{}
for I,s in ipairs(n)do
G[I]=q(a,s,b,"a key")
H[I]=q(a,rawget(b,s),b,s)
end
i.k=SpiffBoy.wireList(G)
i.v=SpiffBoy.wireList(H)
t[aa]=i
end
local b=a.cost
o("encoding: numbering in "..tostring(r).." ms, nodes in "..tostring(getTimestampMs()-_).." ms; "..tostring(#e).." tables, "..tostring(b.keys).." plain keys; biggest table "..tostring(b.biggestTable and d(a,b.biggestTable)).." with "..tostring(b.biggest).." keys")
return q(a,root,nil,nil),t
end

local function F(path,count,roots)
for f,a in ipairs(roots)do
if count>=#a then
local b=true
for e=1,#a do
if SpiffBoy.listItem(path,e)~=a[e]then
b=false
end
end
if b then
return true
end
end
end
return false
end

local function r(path,roots)
local a=SpiffBoy.listCount(path)
if a<1 or not F(path,a,roots)then
return nil
end
return z(path,a)
end

local function i(decoder,encoded)
local a=type(encoded)
if a=="string"or a=="boolean"or a=="number"then
return encoded
end
if a~="table"then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a "..a)
end
if encoded.r~=nil then
local b=SpiffBoy.isInteger(encoded.r)and decoder.tables[encoded.r]
if not b then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state refers to a table it does not hold")
end
return b
end
if encoded.j~=nil then
local b=decoder.tokens[encoded.j]
if b==nil then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state names a part of the console it cannot have: "..tostring(encoded.j))
end
return b
end
if encoded.p~=nil then
local b=r(encoded.p,decoder.roots)
if b==nil then
SpiffBoy.GameErrors.raise("SB-STATE-CLASS","the state names a global that this machine does not have")
end
return b
end
if encoded.a~=nil then
if type(encoded.a)~="string"then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state names a texture by something else than a text")
end
return decoder.artLoad(encoded.a)
end
if encoded.f==v then
return 0/0
end
if encoded.f==w then
return math.huge
end
if encoded.f==x then
return-math.huge
end
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a value it cannot read")
end

local function G(data,tokens,artLoad,roots,pace)
local b=data.nodes
local a=SpiffBoy.listCount(b)
if a>c.MAX_NODES then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds "..a.." tables, more than "..c.MAX_NODES)
end
local e={}
for f=1,a do
pace()
local m=SpiffBoy.listItem(b,f)
if type(m)~="table"or SpiffBoy.listCount(m.k)~=SpiffBoy.listCount(m.v)then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the table "..f.." of the state is malformed")
end
e[f]={}
end
local f={tables=e,tokens=tokens,artLoad=artLoad,roots=roots}
for m=1,a do
pace()
local n=SpiffBoy.listItem(b,m)
local H=e[m]
for s=1,SpiffBoy.listCount(n.k)do
local t=i(f,SpiffBoy.listItem(n.k,s))
if t==nil then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the table "..m.." of the state has a key this machine cannot make")
end
H[t]=i(f,SpiffBoy.listItem(n.v,s))
end
end
for m=1,a do
pace()
local n=SpiffBoy.listItem(b,m)
if n.c~=nil then
local s=r(n.c,roots)
if type(s)~="table"then
SpiffBoy.GameErrors.raise("SB-STATE-CLASS","the state names a class that this machine does not have")
end
setmetatable(e[m],s)
end
end
return i(f,data.root)
end

local function n(parts,core)
local a={screen=parts.runtime.view,chip=parts.chip}
a.bootLogo=parts.bootLogo
a.art=parts.context and parts.context.art
if core then
a.context=core.context
a.chipView=core.chip
a.sequencerView=core.sequencer
a.link=core.link
a.persist=core.persist
end
return a
end

local function H(tokens)
local a={}
for b,e in pairs(tokens)do
a[e]=b
end
return a
end

local function m(value,depth)
local a=type(value)
if a=="boolean"or a=="string"then
return true
end
if a=="number"then
return SpiffBoy.isFinite(value)
end
if a~="table"or depth<=0 or getmetatable(value)~=nil then
return false
end
for b,e in pairs(value)do
if type(b)~="string"and not SpiffBoy.isInteger(b)then
return false
end
if not m(e,depth-1)then
return false
end
end
return true
end

local function I(runtime)
if not SpiffBoy.isInteger(runtime.tick)or runtime.tick<0 or not SpiffBoy.isFinite(runtime.accumulator)or runtime.accumulator<0 then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a clock out of its range")
end
local a=runtime.crash
if a~=nil and(type(a)~="table"or type(a.stage)~="string"or type(a.message)~="string")then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a malformed crash")
end
end

local function aa(fields,chip)
if not m(fields,u)then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a chip with something else than plain data")
end
for a,b in pairs(fields)do
if a=="listener"or type(chip[a])~=type(b)then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a chip field this chip does not have: "..tostring(a))
end
end
end

local function s(playback)
if type(playback)~="table"or type(playback.name)~="string"or not SpiffBoy.isFinite(playback.position)or type(playback.indexes)~="table"or type(playback.last)~="table"then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a malformed playback")
end
for b,a in pairs(playback.indexes)do
if not SpiffBoy.isInteger(a)then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a playback with an index that is no whole number")
end
end
for b,a in pairs(playback.last)do
if type(a)~="table"or type(a.n)~="string"or not SpiffBoy.isInteger(a.i)then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a playback with a malformed place")
end
end
end

local function ab(snapshot,sequencer)
if not m(snapshot,u)or type(snapshot.effects)~="table"or type(snapshot.owners)~="table"or type(snapshot.channels)~="table"then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a sequencer with something else than plain data")
end
if not SpiffBoy.isFinite(snapshot.musicLevel)or not SpiffBoy.isFinite(snapshot.effectLevel)then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds sequencer levels out of their range")
end
if snapshot.music~=nil then
s(snapshot.music)
end
for b,a in pairs(snapshot.effects)do
s(a)
end
for e,a in pairs(snapshot.channels)do
if sequencer.channels[e]==nil or type(a)~="table"then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a channel this sequencer does not have: "..tostring(e))
end
for f,b in ipairs(K)do
if a[b]~=nil and not SpiffBoy.isFinite(a[b])then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds a channel with a "..b.." that is no number")
end
end
end
for b,a in pairs(snapshot.owners)do
if not SpiffBoy.isInteger(a)or snapshot.effects[a]==nil then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state gives a voice to an effect it does not hold")
end
end
end

local function ac(chip)
local a={}
for b,e in pairs(chip)do
if b~="listener"then
a[b]=e
end
end
return a
end

function c.capture(parts,pace)
local b=parts.context and parts.context.definition
local _=S(b and b.game,pace)
local a=parts.game
local f=nil
if a then
f={context=a.context,chip=a.chip,sequencer=a.sequencer,link=a.link,persist=a.persist}
end
local e=parts.runtime
local ad={
runtime={tick=e.tick,accumulator=e.clock.accumulator,crash=e.crash},
chip=ac(parts.chip),
sequencer=parts.sequencer and parts.sequencer:snapshot(),
game=a,
boot=parts.boot,
console=parts.console,
}
local ae=getTimestampMs()
local af,t=Z(ad,H(n(parts,f)),parts.artNames or{},_.paths,pace)
o("encoded "..tostring(#t).." tables in "..tostring(getTimestampMs()-ae).." ms")
return{format=c.FORMAT,stamp=B(b),root=af,nodes=SpiffBoy.wireList(t)}
end

function c.restore(data,parts,pace)
local e=parts.context and parts.context.definition
if type(data)~="table"or data.format~=c.FORMAT or not T(data.stamp,B(e))then
SpiffBoy.GameErrors.raise("SB-STATE-VERSION","the state comes from another cartridge or another version")
end
local t=c.rootsOf(e and e.game)
local f=nil
if parts.context and parts.context.chip and parts.context.sequencer then
parts.runtime:attach(parts.context)
f=SpiffBoyGameBase.coreParts(parts.runtime,parts.context)
end
local _=parts.context and parts.context.art or function()return nil end
local a=G(data,n(parts,f),_,t,pace)
if type(a)~="table"or type(a.runtime)~="table"or type(a.chip)~="table"then
SpiffBoy.GameErrors.raise("SB-STATE-OBJECT","the state holds no console")
end
I(a.runtime)
aa(a.chip,parts.chip)
if a.sequencer and parts.sequencer then
ab(a.sequencer,parts.sequencer)
end
for b,ad in pairs(a.chip)do
parts.chip[b]=ad
end
if a.sequencer and parts.sequencer then
parts.sequencer:restoreSnapshot(a.sequencer)
end
local b=parts.runtime
if a.game then
b:setGame(a.game)
elseif a.boot then
b:setGame(a.boot)
end
b.tick=a.runtime.tick
b.clock.accumulator=a.runtime.accumulator
b.crash=a.runtime.crash
return a
end

local function b(hasher,piece)
if hasher.started then
piece="|"..piece
else
hasher.started=true
end
local a=hasher.hash
for e=1,string.len(piece)do
hasher.bytes=hasher.bytes+1
if hasher.bytes%P==0 then
hasher.pace()
end
a=(a*N+string.byte(piece,e))%O
end
hasher.hash=a
end

local function f(hasher,encoded)
local e=type(encoded)
if e~="table"then
b(hasher,e..":"..tostring(encoded))
return
end
for t,a in ipairs({"r","j","a","f"})do
if encoded[a]~=nil then
b(hasher,a..":"..tostring(encoded[a]))
return
end
end
if encoded.p~=nil then
local a={}
for t=1,SpiffBoy.listCount(encoded.p)do
a[t]=tostring(SpiffBoy.listItem(encoded.p,t))
end
b(hasher,"p:"..table.concat(a,"."))
end
end

function c.fingerprint(data,trace,pace)
local a={hash=0,bytes=0,started=false,pace=pace}
f(a,data.root)
for _=1,SpiffBoy.listCount(data.nodes)do
pace()
local e=SpiffBoy.listItem(data.nodes,_)
b(a,"n")
if e.c~=nil then
f(a,{p=e.c})
end
for t=1,SpiffBoy.listCount(e.k)do
f(a,SpiffBoy.listItem(e.k,t))
f(a,SpiffBoy.listItem(e.v,t))
end
end
for e=1,#trace do
b(a,trace[e])
end
return a.hash
end

function c.chipTrace(trace)
return{
onChipWrite=function(_,register,value)
trace[#trace+1]="w"..register.."="..value
end,
onChipWave=function(_,name)
trace[#trace+1]="v"..name
end,
}
end
