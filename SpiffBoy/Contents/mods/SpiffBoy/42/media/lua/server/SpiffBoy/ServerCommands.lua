require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Core/SaveData"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Handheld/ConsoleLocator"
require"SpiffBoy/ConsoleHosts"
require"SpiffBoy/Core/Mood"

local y=SpiffBoy.COMMAND_MODULE
local z=1000
local A=40
local B=5000
local C=1000
local D=10
local i=1000
local E=3000
local q=1000

local r={}
local s={}
local t={}
local F=SyncPlayerStatsPacket.getBitMaskForStat(CharacterStat.BOREDOM)+SyncPlayerStatsPacket.getBitMaskForStat(CharacterStat.UNHAPPINESS)
local j={}
local d={}
local u=0

local function G(player,command,args)
sendServerCommand(player,y,command,args)
end

local function k(value)
if SpiffBoy.isFinite(value)then
return value
end
return nil
end

local function H(player)
local b=player:getOnlineID()
local c=getTimestampMs()
local a=s[b]
if not a or c-a.startMs>=C then
a={startMs=c,count=0}
s[b]=a
end
a.count=a.count+1
return a.count<=D
end

local function I(player,id,args)
return tostring(player:getOnlineID())..":"..tostring(id)..":"..tostring(args.x)..":"..tostring(args.y)..":"..tostring(args.z)..":"..tostring(args.v)
end

local function J(now)
if now<u then
return
end
u=now+q
for a,b in pairs(d)do
if now>=b.untilMs then
d[a]=nil
end
end
end

local function v(player,id,args,fresh,hostId)
local f=SpiffBoy.ConsoleHosts.carriedBy(player,id)
if f then
return f,player
end
if hostId~=player:getOnlineID()then
return nil
end
local c=I(player,id,args)
local e=getTimestampMs()
J(e)
local a=d[c]
if a and not fresh and e<a.untilMs then
return a.item,a.source
end
local b,g=SpiffBoy.ConsoleLocator.findAtPlace(args,id)
if not b or not SpiffBoy.Handheld.isConsole(b)then
d[c]=nil
return nil
end
d[c]={item=b,source=g,untilMs=e+q}
return b,g
end

local function K(player,id)
local a=player:getOnlineID()
if SpiffBoy.ConsoleHosts.of(id)~=a and SpiffBoy.ConsoleHosts.handedFrom(id)~=a then
return nil
end
local b,c=SpiffBoy.ConsoleHosts.otherCarrier(player,id)
return c,b
end

local function L(console,args)
local a=k(args.battery)
local b=SpiffBoy.Handheld.getBattery(console)
if a==nil or b==nil or a>b then
return
end
SpiffBoy.Handheld.setBattery(console,SpiffBoy.clamp(a,0,1))
end

local function M(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.itemId)then
return
end
if not H(player)then
SpiffBoy.trace("save of player "..tostring(player:getOnlineID()).." refused by the rate")
return
end
if args.save~=nil then
local a=SpiffBoy.SaveData.check(args.save)
if a then
SpiffBoy.log("save of player "..tostring(player:getOnlineID()).." refused: "..a)
return
end
end
local a,b=v(player,args.itemId,args,true,SpiffBoy.ConsoleHosts.of(args.itemId))
if not a then
return
end
if b~=player then
L(a,args)
return
end
SpiffBoy.Handheld.applySaved(a,args.save,k(args.battery),k(args.volume))
syncItemModData(player,a)
end

local function N(player,consoleId)
local c=player:getOnlineID()
local e=getTimestampMs()
local a=r[c]
if not a or e-a.startMs>=z then
a={startMs=e,counts={},consoles=0}
r[c]=a
end
local b=a.counts[consoleId]
if not b then
if a.consoles>=SpiffBoy.MAX_SOUNDING then
return false
end
a.consoles=a.consoles+1
b=0
end
a.counts[consoleId]=b+1
return b+1<=A
end

local function b(player,outcome,listeners)
if not SpiffBoy.isDevBuild()then
return
end
local c=player:getOnlineID()
local e=getTimestampMs()
local a=j[c]
if not a then
a={startMs=e,relayed=0,listeners=0,size=0,rate=0,empty=0,place=0}
j[c]=a
end
a[outcome]=a[outcome]+1
a.listeners=a.listeners+(listeners or 0)
if e-a.startMs>=B then
SpiffBoy.log("chip relay: player "..tostring(c).." in "..tostring(e-a.startMs).." ms, relayed "..a.relayed.." to "..a.listeners.." listeners in all, refused size "..a.size..", rate "..a.rate..", empty "..a.empty..", place "..a.place)
j[c]=nil
end
end

local function O(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.t)or not SpiffBoy.isInteger(args.i)then
return
end
if not SpiffBoy.isInteger(args.m)or args.m<0 or args.m>SpiffBoy.MAX_ENCLOSURES then
return
end
if not SpiffBoy.isInteger(args.r)or args.r<0 or args.r>SpiffBoy.MAX_REACH then
return
end
if not SpiffBoy.isInteger(args.b)or args.b<args.r or args.b>SpiffBoy.MAX_REACH then
return
end
if not SpiffBoy.isInteger(args.n)or args.n<0 or args.n>args.m then
return
end
local l=SpiffBoy.listCount(args.e)
if l<1 or l>SpiffBoy.CHIP_MAX_EVENTS then
b(player,"size")
return
end
if not N(player,args.i)then
b(player,"rate")
return
end
local m=player:getOnlineID()
local g=SpiffBoy.ConsoleHosts.of(args.i)
if g and g~=m and SpiffBoy.ConsoleHosts.handedFrom(args.i)~=m and not SpiffBoy.ConsoleHosts.sameMachine(g,m)then
b(player,"place")
return
end
local n,a=v(player,args.i,args,false,g)
local e=nil
if not n then
n,e=K(player,args.i)
a=e
end
if not n then
b(player,"place")
return
end
local h={}
for f=1,l do
local c=SpiffBoy.cleanChipEvent(SpiffBoy.listItem(args.e,f))
if c then
h[#h+1]=c
end
end
if#h==0 then
b(player,"empty")
return
end
local c={i=args.i,p=player:getOnlineID(),t=args.t,e=SpiffBoy.wireList(h),m=args.m,r=args.r}
if e then
c.p=e:getOnlineID()
elseif a~=player and SpiffBoy.isInteger(args.v)then
c.v=args.v
elseif a~=player then
SpiffBoy.ConsoleLocator.writePlace(c,{x=args.x,y=args.y,z=args.z})
end
local P=SpiffBoy.ConsoleLocator.spaceOf(a)
local w=getOnlinePlayers()
local o=0
for Q=0,w:size()-1 do
local f=w:get(Q)
if(f~=player or e)and SpiffBoy.withinHearing(f,a,args.b)then
local p,x=args.r,args.m
if SpiffBoy.ConsoleLocator.spaceOf(f)==P then
p,x=args.b,args.n
end
if SpiffBoy.withinHearing(f,a,p)then
c.r=p
c.m=x
G(f,SpiffBoy.COMMAND_CHIP,c)
o=o+1
end
end
end
b(player,"relayed",o)
end

local function f(player)
local e=player:getOnlineID()
local c=getTimestampMs()
local a=t[e]
if not a then
a={ms=i,atMs=c}
t[e]=a
end
a.ms=math.min(E,a.ms+c-a.atMs)
a.atMs=c
if a.ms<i then
return false
end
a.ms=a.ms-i
return true
end

local function a(player)
if not f(player)then
return
end
if player:getInventory():getAllTypeRecurse(SpiffBoy.CONSOLE_ITEM):isEmpty()then
return
end
if SpiffBoy.Mood.ease(player)then
syncPlayerStats(player,F)
end
end

SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_SAVE_HANDHELD,M)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_EASE_MOOD,a)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CHIP,O)

Events.OnClientCommand.Add(SpiffBoy.Commands.onClientCommand)
Events.OnTick.Add(SpiffBoy.Mood.releaseIdle)
