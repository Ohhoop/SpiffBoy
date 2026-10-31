require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Core/GameErrors"
require"SpiffBoy/Core/SaveState"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Handheld/ConsoleLocator"
require"SpiffBoy/Handheld/StateTransfer"
require"SpiffBoy/Core/Textures"
require"SpiffBoy/Core/LocalPlayers"
require"SpiffBoy/Network/RemoteSpeakers"

SpiffBoy.ConsoleHandover=SpiffBoy.ConsoleHandover or{}
local c=SpiffBoy.ConsoleHandover

local d=SpiffBoy.COMMAND_MODULE
local C=15000
local D=5000
local E=4
local F=3000
local G=1000
local H=2000
local I=30
local J=1000
local K=10
local L=1000
local M=10
local N=5000

local f={}
local k={}
local l={}
local m={}
local u={}
local g={}
local j={}
local v=0
local w=SpiffBoy.StateTransfer.newCollector()

local function b(message)
SpiffBoy.trace("console handover: "..message)
end

local function h()
if getTimestampMs()>=v then
coroutine.yield()
end
end

local function q(body,onFailed)
j[#j+1]={routine=coroutine.create(body),onFailed=onFailed}
end

local function O()
for a=#j,1,-1 do
local e=j[a]
v=getTimestampMs()+E
local i,n=coroutine.resume(e.routine)
if not i then
table.remove(j,a)
e.onFailed(n)
elseif coroutine.status(e.routine)=="dead"then
table.remove(j,a)
end
end
end

local function P(instance)
if instance.anchor.kind==SpiffBoy.ConsoleLocator.VEHICLE then
return{v=instance.anchor.id}
end
local a=instance.lastSquare
if a then
return{x=a.x,y=a.y,z=a.z}
end
return{}
end

local function r(kept,places)
for e,a in ipairs(places)do
sendClientCommand(kept.playerObj,d,SpiffBoy.COMMAND_CONSOLE_STATE,kept.chunks[a])
end
kept.sentMs=getTimestampMs()
end

local function x(kept)
local a={}
for e=1,#kept.chunks do
a[e]=e
end
return a
end

local function n(kept)
if SpiffBoyConsoleInstance.instances[kept.consoleId]==kept.instance then
kept.instance:close()
end
end

function c.send(instance)
if instance.sending then
return
end
instance.sending=true
sendClientCommand(instance.playerObj,d,SpiffBoy.COMMAND_CONSOLE_VOLUME,{i=instance.consoleId,v=instance:volume()})
local p=getTimestampMs()
local a=nil
b("console "..tostring(instance.consoleId).." capturing to send")
q(function()
if instance.closing then
return
end
local e=instance:captureState(SpiffBoy.SaveState.NO_PACE)
b("console "..tostring(instance.consoleId).." captured at "..tostring(getTimestampMs()-p).." ms")
a=SpiffBoyConsoleInstance.shadowOf(instance)
a:restoreState(e,h)
local y=a:runAhead(SpiffBoy.VERIFY_TICKS)
local z=a:captureState(h)
a:discard()
a=nil
local i=P(instance)
i.f=SpiffBoy.SaveState.fingerprint(z,y,h)
i.a=SpiffBoy.VERIFY_TICKS
local s=getTimestampMs()
local t=SpiffBoy.StateTransfer.chunks(instance.consoleId,s,e,i)
local o={consoleId=instance.consoleId,instance=instance,data=e,chunks=t,transferId=s,playerObj=instance.playerObj,untilMs=getTimestampMs()+C}
f[instance.consoleId]=o
r(o,x(o))
instance.handedOver=true
b("console "..tostring(instance.consoleId).." sent in "..#t.." chunks at "..tostring(getTimestampMs()-p).." ms")
end,function(problem)
if a then
a:discard()
end
SpiffBoy.log("console "..tostring(instance.consoleId)..": no handover, "..tostring(problem))
instance:close()
end)
end

function c.verifyHost(console)
if not isClient()then
return
end
local a=console:getID()
local e=getTimestampMs()
if e<(u[a]or 0)then
return
end
u[a]=e+N
local i=getPlayer()
if not i then
return
end
local o={i=a}
local p=SpiffBoy.ConsoleLocator.anchorOf(console)
if p then
SpiffBoy.ConsoleLocator.writePlace(o,SpiffBoy.ConsoleLocator.placeOf(p))
end
sendClientCommand(i,d,SpiffBoy.COMMAND_CONSOLE_VERIFY,o)
end

function c.started(instance)
if isClient()then
sendClientCommand(instance.playerObj,d,SpiffBoy.COMMAND_CONSOLE_STARTED,{i=instance.consoleId})
end
end

function c.stopped(instance)
if not isClient()then
return
end
local a={i=instance.consoleId}
SpiffBoy.ConsoleLocator.writePlace(a,SpiffBoy.ConsoleLocator.placeOf(instance.anchor))
sendClientCommand(instance.playerObj,d,SpiffBoy.COMMAND_CONSOLE_STOPPED,a)
end

local function y(playerObj,console)
g[console:getID()]=playerObj
SpiffBoy.Textures.refresh()
local a=SpiffBoyConsoleInstance.new(playerObj,console)
a.transferring=true
a.awaitingGame=true
a.transferStartMs=getTimestampMs()
SpiffBoyHandheldWindow.reveal(a)
end

function c.claim(playerObj,console)
if not isClient()then
return false
end
local a=SpiffBoy.Handheld.getHost(console)
if a==nil or a==playerObj:getOnlineID()then
return false
end
sendClientCommand(playerObj,d,SpiffBoy.COMMAND_CONSOLE_CLAIM,{i=console:getID()})
b("console "..tostring(console:getID()).." asked of player "..tostring(a))
y(playerObj,console)
return true
end

function c.forgetClaim(consoleId)
g[consoleId]=nil
end

local function z(consoleId)
local a=g[consoleId]
g[consoleId]=nil
local e=a and a:getInventory():getItemWithIDRecursiv(consoleId)
if e then
return a,e
end
return nil
end

local function s(consoleId)
local a,e=z(consoleId)
if a then
SpiffBoyHandheldWindow.start(a,e)
end
end

function c.check(instance)
local a=getTimestampMs()
if a<(instance.nextCheckMs or 0)then
return
end
instance.nextCheckMs=a+D
local e={i=instance.consoleId}
SpiffBoy.ConsoleLocator.writePlace(e,SpiffBoy.ConsoleLocator.placeOf(instance.anchor))
sendClientCommand(instance.playerObj,d,SpiffBoy.COMMAND_CONSOLE_CHECK,e)
end

local function Q(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.me)then
return
end
SpiffBoy.StateTransfer.expire(w,getTimestampMs())
local o,A=SpiffBoy.StateTransfer.add(w,tostring(args.i),args)
if not o then
return
end
local e=SpiffBoyConsoleInstance.instances[args.i]
if e and e.sending then
b("console "..tostring(args.i).." still sending from here, closed for the state received")
e:close()
e=nil
end
if e and not e.awaitingGame then
b("console "..tostring(args.i).." already runs here, the state received is left")
return
end
local i=SpiffBoy.LocalPlayers.byOnlineId(args.me)
if not i then
return
end
local p=e and e.console or i:getInventory():getItemWithIDRecursiv(args.i)
if not p then
p=SpiffBoy.ConsoleLocator.findAround(math.floor(i:getX()),math.floor(i:getY()),math.floor(i:getZ()),args.i)
end
if not p then
sendClientCommand(i,d,SpiffBoy.COMMAND_CONSOLE_STOPPED,{i=args.i})
b("console "..tostring(args.i).." received, but this machine no longer knows the item")
return
end
local t=getTimestampMs()
local a=e
if not a then
a=SpiffBoyConsoleInstance.new(i,p)
a.transferStartMs=t
end
a.awaitingGame=false
a.transferring=true
a.transferStage=1
b("console "..tostring(args.i).." received, restoring")
local R=e and e.volumeStep
q(function()
a:restoreState(o,h)
if a.closing then
return
end
a.transferStage=2
b("console "..tostring(args.i).." restored at "..tostring(getTimestampMs()-t).." ms")
local S=a:runAhead(A.a)
local T=a:captureState(h)
a.transferStage=3
local U=SpiffBoy.SaveState.fingerprint(T,S,h)
if a.closing then
return
end
if U~=A.f then
SpiffBoy.GameErrors.warn("SB-STATE-DIFF","the cartridge "..tostring(o.stamp.id).." of the mod "..tostring(o.stamp.mod).." played on differently after the handover, so the console stays off")
a:close()
s(args.i)
return
end
local B=a.pendingVolumeStep or R
a.pendingVolumeStep=nil
if B then
a:takeVolume(B/SpiffBoyConsoleInstance.VOLUME_STEPS)
end
a.transferring=false
c.started(a)
a:announce()
SpiffBoyConsoleInstance.makeRoom(a.playerNum,a)
b("console "..tostring(args.i).." taken over at "..tostring(getTimestampMs()-t).." ms")
z(args.i)
end,function(problem)
SpiffBoy.log("console "..tostring(args.i)..": the save state could not be taken: "..tostring(problem))
a:close()
s(args.i)
end)
end

local function A(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local e=f[args.i]
f[args.i]=nil
if not e or getTimestampMs()>e.untilMs then
return
end
n(e)
if SpiffBoyConsoleInstance.instances[args.i]then
return
end
local i=SpiffBoy.ConsoleLocator.findAtPlace(args,args.i)
if not i then
return
end
local a=SpiffBoyConsoleInstance.new(e.playerObj,i)
a.transferring=true
q(function()
a:restoreState(e.data,h)
if a.closing then
return
end
a.transferring=false
c.started(a)
a:announce()
b("console "..tostring(args.i).." runs again where it was moved")
end,function(problem)
SpiffBoy.log("console "..tostring(args.i)..": the save state could not be taken: "..tostring(problem))
a:close()
end)
end

local function p(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoy.isInteger(args.t)then
return nil
end
local a=f[args.i]
if not a or a.received or a.transferId~=args.t then
return nil
end
return a
end

local function B(args)
local a=p(args)
if not a then
return
end
local e=SpiffBoy.StateTransfer.cleanMissing(args.m,#a.chunks)
if not e then
return
end
r(a,e)
b("console "..tostring(args.i)..": "..#e.." chunks sent again")
end

local function R(args)
local a=p(args)
if a then
a.received=true
end
end

local function S()
local o=getTimestampMs()
local e=nil
for i,a in pairs(f)do
if o>a.untilMs then
e=e or{}
e[#e+1]=i
elseif a.takenMs and(SpiffBoy.RemoteSpeakers.isHeard(i)or o-a.takenMs>=G)then
a.takenMs=nil
n(a)
b("console "..tostring(i).." taken over elsewhere, closed here")
elseif not a.received and o-a.sentMs>F then
r(a,x(a))
b("console "..tostring(i)..": no word from the server, every chunk sent again")
end
end
if e then
for i,a in ipairs(e)do
n(f[a])
f[a]=nil
end
end
end

local function T(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local a=f[args.i]
if a then
a.takenMs=getTimestampMs()
end
end

local function U(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local a=SpiffBoyConsoleInstance.instances[args.i]
if not a or a.transferring or a.sending then
return
end
local e,i=a.playerObj,a.console
a.handedOver=true
a:close()
y(e,i)
b("console "..tostring(args.i).." runs elsewhere, waiting for its game")
end

local function V(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local a=f[args.i]
f[args.i]=nil
if a then
n(a)
end
end

local function W(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local a=SpiffBoyConsoleInstance.instances[args.i]
if a and a.transferring then
b("console "..tostring(args.i).." asked for while its game arrives here, it hands over once in place")
return
end
if a then
c.send(a)
return
end
local e=SpiffBoy.isInteger(args.h)and SpiffBoy.LocalPlayers.byOnlineId(args.h)
if e then
sendClientCommand(e,d,SpiffBoy.COMMAND_CONSOLE_STOPPED,{i=args.i})
b("console "..tostring(args.i).." asked for, but it no longer runs here")
end
end

local function X(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoy.isFinite(args.v)or args.v<0 or args.v>1 then
return
end
local a=SpiffBoyConsoleInstance.instances[args.i]
if a and a.awaitingGame then
a:takeVolume(args.v)
b("console "..tostring(args.i).." volume "..tostring(args.v).." taken ahead of its game")
end
end

local function Y(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
b("console "..tostring(args.i).." is off")
local a=SpiffBoyConsoleInstance.instances[args.i]
if a and a.awaitingGame then
g[args.i]=nil
a.awaitingGame=false
a.transferring=false
c.started(a)
return
end
s(args.i)
end

local function Z(playerNum,playerObj)
if not isClient()then
return
end
local e=playerObj:getInventory():getAllTypeRecurse(SpiffBoy.CONSOLE_ITEM)
for i=0,e:size()-1 do
local a=e:get(i)
if SpiffBoy.Handheld.getHost(a)~=nil and not SpiffBoyConsoleInstance.instances[a:getID()]then
k[a:getID()]={playerObj=playerObj,console=a,tries=0,nextMs=0}
b("console "..tostring(a:getID()).." carried at the start, nothing runs it")
end
end
end

local function _(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoyConsoleInstance.instances[args.i]then
return
end
local a=m[args.i]or{tries=0}
a.nextMs=getTimestampMs()+L
m[args.i]=a
end

local function aa()
local t=getTimestampMs()
local a=nil
for i,e in pairs(m)do
local o=SpiffBoyConsoleInstance.instances[i]
if not o or o.closing or o.transferring then
a=a or{}
a[#a+1]=i
elseif e.nextMs and t>=e.nextMs then
if e.tries>=M then
a=a or{}
a[#a+1]=i
SpiffBoy.log("console "..tostring(i)..": the server never saw it on the player who runs it")
else
e.tries=e.tries+1
e.nextMs=nil
c.started(o)
end
end
end
if a then
for i,e in ipairs(a)do
m[e]=nil
end
end
end

local function ab(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not g[args.i]then
return
end
local a=l[args.i]or{tries=0}
a.nextMs=getTimestampMs()+J
l[args.i]=a
end

local function ac()
local ad=getTimestampMs()
local a=nil
for e,i in pairs(l)do
local o=SpiffBoyConsoleInstance.instances[e]
local t=g[e]
if not t or not o or not o.awaitingGame then
a=a or{}
a[#a+1]=e
elseif i.nextMs and ad>=i.nextMs then
if i.tries>=K then
a=a or{}
a[#a+1]=e
SpiffBoy.log("console "..tostring(e)..": the server never saw it on the player who asked its game")
o:close()
else
i.tries=i.tries+1
i.nextMs=nil
sendClientCommand(t,d,SpiffBoy.COMMAND_CONSOLE_CLAIM,{i=e})
end
end
end
if a then
for i,e in ipairs(a)do
l[e]=nil
end
end
end

local function t()
local o=getTimestampMs()
local e=nil
for i,a in pairs(k)do
if SpiffBoyConsoleInstance.instances[i]or SpiffBoy.Handheld.getHost(a.console)==nil or a.tries>=I then
e=e or{}
e[#e+1]=i
elseif o>=a.nextMs then
sendClientCommand(a.playerObj,d,SpiffBoy.COMMAND_CONSOLE_IDLE,{i=i})
a.tries=a.tries+1
a.nextMs=o+H
end
end
if e then
for i,a in ipairs(e)do
k[a]=nil
end
end
end

local function a(args)
if type(args)=="table"and SpiffBoy.isInteger(args.i)then
k[args.i]=nil
end
end

SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_RESUME,Q)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_MOVED,A)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_GONE,V)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_LOST,W)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_OFF,Y)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_VOLUME,X)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_RESEND,B)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_RECEIVED,R)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_IDLE,a)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_TAKEN,T)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_BUSY,U)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_CLAIM,ab)
SpiffBoy.Commands.fromServer(SpiffBoy.COMMAND_CONSOLE_STARTED,_)
Events.OnCreatePlayer.Add(Z)
Events.OnTick.Add(S)
Events.OnTick.Add(t)
Events.OnTick.Add(ac)
Events.OnTick.Add(aa)
Events.OnPreUIDraw.Add(O)
