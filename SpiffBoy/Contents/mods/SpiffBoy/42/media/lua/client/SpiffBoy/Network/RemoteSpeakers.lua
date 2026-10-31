require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Core/Clock"
require"SpiffBoy/Framework/Cartridges"
require"SpiffBoy/Core/Chip"
require"SpiffBoy/Core/Speaker"
require"SpiffBoy/Core/Sequencer"
require"SpiffBoy/Core/Tunes"

SpiffBoy.RemoteSpeakers=SpiffBoy.RemoteSpeakers or{}
local e=SpiffBoy.RemoteSpeakers
local n=SpiffBoyChip
local o=SpiffBoy.Tunes
local B=SpiffBoy.ChipBank

local j=12
local C=60
local D=30
local E=6000
local F=SpiffBoy.MAX_FRAME_MS
local G=SpiffBoy.CHIP_MAX_EVENTS

local H=1000
local k=2
local p=0.5
local I=SpiffBoy.MUFFLE

local d={}
local f=0
local h=nil

local function c(message)
if SpiffBoy.isDevBuild()then
SpiffBoy.log("remote speaker: "..message)
end
end

local function l(x,y)
local a=nil
for i=0,getNumActivePlayers()-1 do
local b=getSpecificPlayer(i)
if b then
local g=math.sqrt((x-b:getX())^2+(y-b:getY())^2)
if a==nil or g<a then
a=g
end
end
end
return a
end

local function q(mirror)
if mirror.place then
return mirror.place.x+p,mirror.place.y+p
end
if mirror.vehicle then
local a=getVehicleById(mirror.vehicle)
if a then
return a:getX(),a:getY()
end
return nil
end
local a=getPlayerByOnlineID(mirror.host)
if a then
return a:getX(),a:getY()
end
return nil
end

local function J(mirror)
local a,g=q(mirror)
if not a then
return nil
end
local b=l(a,g)
if not b then
return nil
end
return math.floor(b*10+0.5)/10
end

local function r(distance,reach)
if distance==nil or distance>=reach then
return 0
end
if distance<=k then
return 1
end
return 1-(distance-k)/(reach-k)
end

function e.gainAt(x,y,reach)
return r(l(x,y),reach)
end

local function m(event)
return SpiffBoy.Cartridges.get(event.c)
end

local function s(mirror,name)
return mirror.sequencer~=nil and o.find(mirror.sequencer.set,name)~=nil
end

local function t(mirror,definition,volume)
mirror.speaker:setVolume(volume)
if mirror.definition==definition then
return
end
mirror.definition=definition
mirror.frozen=false
mirror.chip:boot()
mirror.sequencer=SpiffBoySequencer.new(mirror.chip,o.set(definition.id))
end

local function K(mirror)
mirror.frozen=false
mirror.chip:halt()
mirror.sequencer=nil
mirror.definition=nil
end

local function L(mirror,event)
local a=mirror.sequencer
if event.n==nil then
if a:isPlaying()then
a:stop()
end
return
end
if not s(mirror,event.n)then
return
end
local b,g=a:state()
local i=b~=event.n or math.abs(g-event.p)>D
c("beat of "..tostring(mirror.id)..": console "..tostring(event.n).." at "..tostring(event.p)..", mirror "..tostring(b).." at "..tostring(g)..", resync "..tostring(i))
if i then
a:resume(event.n,event.p)
end
end

local function u(method)
return function(mirror,event)
if s(mirror,event.n)then
method(mirror.sequencer,event.n)
end
end
end

local M={
[SpiffBoy.CHIP_EVENT_ON]=function(mirror,event)
local a=m(event)
if a then
t(mirror,a,event.v)
end
end,
[SpiffBoy.CHIP_EVENT_OFF]=function(mirror,event)
c("off received from "..tostring(mirror.id))
K(mirror)
end,
[SpiffBoy.CHIP_EVENT_VOLUME]=function(mirror,event)
mirror.speaker:setVolume(event.v)
end,
[SpiffBoy.CHIP_EVENT_PLAY]=u(SpiffBoySequencer.play),
[SpiffBoy.CHIP_EVENT_STOP]=function(mirror,event)
c("music stop received from "..tostring(mirror.id))
if mirror.sequencer then
mirror.sequencer:stop()
end
end,
[SpiffBoy.CHIP_EVENT_EFFECT]=u(SpiffBoySequencer.effect),
[SpiffBoy.CHIP_EVENT_WRITE]=function(mirror,event)
if mirror.sequencer and n.isRegister(event.r)then
mirror.chip:apply(event.r,event.v)
end
end,
[SpiffBoy.CHIP_EVENT_WAVE]=function(mirror,event)
if mirror.sequencer and B.WAVE[event.n]then
mirror.chip:applyWave(event.n)
end
end,
[SpiffBoy.CHIP_EVENT_MIX]=function(mirror,event)
if mirror.sequencer then
mirror.sequencer:setMix(event.m,event.f)
end
end,
[SpiffBoy.CHIP_EVENT_FREEZE]=function(mirror,event)
c("freeze received from "..tostring(mirror.id))
if mirror.sequencer then
mirror.frozen=true
end
end,
[SpiffBoy.CHIP_EVENT_BEAT]=function(mirror,event)
local a=m(event)
if not a then
return
end
if not mirror.sequencer then
t(mirror,a,event.v)
else
mirror.speaker:setVolume(event.v)
end
mirror.sequencer:setMix(event.m,event.f)
mirror.frozen=event.z
L(mirror,event)
end,
}

local function N(id,event)
if event.k~=SpiffBoy.CHIP_EVENT_ON and event.k~=SpiffBoy.CHIP_EVENT_BEAT then
return nil
end
if not m(event)then
return nil
end
local a={
id=id,
chip=n.new(),
speaker=SpiffBoySpeaker.new(true),
sequencer=nil,
definition=nil,
queue={},
tick=event.t-j,
clock=SpiffBoyClock.new(),
frozen=false,
sounding=false,
lastSeenMs=0,
resyncs=0,
resyncTraceMs=0,
}
d[id]=a
f=f+1
c("opened for "..tostring(id)..", cartridge "..tostring(event.c))
return a
end

local function O(mirror,event)
if event.t-mirror.tick>C or event.t<mirror.tick then
mirror.queue={}
mirror.resyncs=mirror.resyncs+1
local a=getTimestampMs()
if a-mirror.resyncTraceMs>=H then
c("clock of "..tostring(mirror.id).." moved from "..tostring(mirror.tick).." to "..tostring(event.t-j)..", "..tostring(mirror.resyncs).." moves since the last line")
mirror.resyncTraceMs=a
mirror.resyncs=0
end
mirror.tick=event.t-j
end
mirror.queue[#mirror.queue+1]=event
end

local function P(mirror)
local a=mirror.queue
while#a>0 and a[1].t<=mirror.tick do
local b=table.remove(a,1)
M[b.k](mirror,b)
mirror.sounding=true
end
end

function e.isHeard(id)
local a=d[id]
return a~=nil and a.sounding==true
end

local function v(id)
local a=SpiffBoyConsoleInstance.instances[id]
return a~=nil and not a.transferring and not a.sending
end

local function w(id,reason)
local a=d[id]
if not a then
return
end
c("closed for "..tostring(id)..": "..reason..", distance "..tostring(J(a)))
a.speaker:destroy()
d[id]=nil
f=f-1
end

local function Q(args)
if SpiffBoy.isInteger(args.x)and SpiffBoy.isInteger(args.y)and SpiffBoy.isInteger(args.z)then
return{x=args.x,y=args.y,z=args.z}
end
return nil
end

function e.handle(args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoy.isInteger(args.p)then
return
end
if not SpiffBoy.isInteger(args.m)or args.m<0 or args.m>SpiffBoy.MAX_ENCLOSURES then
return
end
if args.v~=nil and not SpiffBoy.isInteger(args.v)then
return
end
if not SpiffBoy.isInteger(args.r)or args.r<0 or args.r>SpiffBoy.MAX_REACH then
return
end
local g=SpiffBoy.listCount(args.e)
if g>G then
return
end
if v(args.i)then
w(args.i,"runs here")
return
end
local a=d[args.i]
for i=1,g do
local b=SpiffBoy.cleanChipEvent(SpiffBoy.listItem(args.e,i))
if b then
if not a then
a=N(args.i,b)
end
if a then
O(a,b)
end
end
end
if a then
a.lastSeenMs=getTimestampMs()
a.host=args.p
a.place=Q(args)
a.vehicle=args.v
a.enclosures=args.m
a.reach=args.r
end
end

function e.update()
if f==0 then
h=nil
return
end
local i=getTimestampMs()
local x=0
if h then
x=math.min(i-h,F)
end
h=i
local R=isGamePaused()
local S=SpiffBoy.consoleRate()
local b=nil
for y,a in pairs(d)do
local T=getPlayerByOnlineID(a.host)
local U=a.place==nil and a.vehicle==nil
local g=nil
if v(y)then
g="runs here"
elseif U and not T then
g="player not found"
elseif i-a.lastSeenMs>E then
g="nothing received for "..tostring(i-a.lastSeenMs).." ms"
end
if g then
b=b or{}
b[#b+1]={id=y,reason=g}
else
if not R then
local z=a.clock:advance(x,S)
for A=1,z do
a.tick=a.tick+1
P(a)
if not a.frozen then
if a.sequencer then
a.sequencer:step()
end
a.chip:step()
end
end
end
local z,V=q(a)
local A=0
if z then
A=r(l(z,V),a.reach)*I.gain^a.enclosures
end
a.speaker:setDistanceGain(A)
a.speaker:play(a.chip)
end
end
if b then
for a=1,#b do
w(b[a].id,b[a].reason)
end
end
end

Events.OnTick.Add(e.update)
