require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Core/SaveData"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Core/Mood"

local m=SpiffBoy.COMMAND_MODULE
local n=1000
local o=40
local p=5000
local q=1000
local r=10
local d=1000
local s=3000

local h={}
local i={}
local j={}
local t=SyncPlayerStatsPacket.getBitMaskForStat(CharacterStat.BOREDOM)+SyncPlayerStatsPacket.getBitMaskForStat(CharacterStat.UNHAPPINESS)
local e={}

local function u(player,command,args)
sendServerCommand(player,m,command,args)
end

local function k(value)
if SpiffBoy.isFinite(value)then
return value
end
return nil
end

local function v(player)
local b=player:getOnlineID()
local c=getTimestampMs()
local a=i[b]
if not a or c-a.startMs>=q then
a={startMs=c,count=0}
i[b]=a
end
a.count=a.count+1
return a.count<=r
end

local function w(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.itemId)then
return
end
if not v(player)then
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
local a=player:getInventory():getItemWithIDRecursiv(args.itemId)
if not a or not SpiffBoy.Handheld.isConsole(a)then
return
end
SpiffBoy.Handheld.applySaved(a,args.save,k(args.battery),k(args.volume))
syncItemModData(player,a)
end

local function x(player)
local b=player:getOnlineID()
local c=getTimestampMs()
local a=h[b]
if not a or c-a.startMs>=n then
a={startMs=c,count=0}
h[b]=a
end
a.count=a.count+1
return a.count<=o
end

local function b(player,outcome,listeners)
if not SpiffBoy.isDevBuild()then
return
end
local c=player:getOnlineID()
local f=getTimestampMs()
local a=e[c]
if not a then
a={startMs=f,relayed=0,listeners=0,size=0,rate=0,empty=0}
e[c]=a
end
a[outcome]=a[outcome]+1
a.listeners=a.listeners+(listeners or 0)
if f-a.startMs>=p then
SpiffBoy.log("chip relay: player "..tostring(c).." in "..tostring(f-a.startMs).." ms, relayed "..a.relayed.." to "..a.listeners.." listeners in all, refused size "..a.size..", rate "..a.rate..", empty "..a.empty)
e[c]=nil
end
end

local function y(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.t)then
return
end
local c=SpiffBoy.listCount(args.e)
if c<1 or c>SpiffBoy.CHIP_MAX_EVENTS then
b(player,"size")
return
end
if not x(player)then
b(player,"rate")
return
end
local a={}
for g=1,c do
local f=SpiffBoy.cleanChipEvent(SpiffBoy.listItem(args.e,g))
if f then
a[#a+1]=f
end
end
if#a==0 then
b(player,"empty")
return
end
local z={id=player:getOnlineID(),t=args.t,e=SpiffBoy.wireList(a)}
local l=getOnlinePlayers()
local f=0
for A=0,l:size()-1 do
local g=l:get(A)
if g~=player and SpiffBoy.withinHearing(g,player)then
u(g,SpiffBoy.COMMAND_CHIP,z)
f=f+1
end
end
b(player,"relayed",f)
end

local function g(player)
local f=player:getOnlineID()
local c=getTimestampMs()
local a=j[f]
if not a then
a={ms=d,atMs=c}
j[f]=a
end
a.ms=math.min(s,a.ms+c-a.atMs)
a.atMs=c
if a.ms<d then
return false
end
a.ms=a.ms-d
return true
end

local function a(player)
if not g(player)then
return
end
if player:getInventory():getAllTypeRecurse(SpiffBoy.CONSOLE_ITEM):isEmpty()then
return
end
if SpiffBoy.Mood.ease(player)then
syncPlayerStats(player,t)
end
end

SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_SAVE_HANDHELD,w)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_EASE_MOOD,a)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CHIP,y)

Events.OnClientCommand.Add(SpiffBoy.Commands.onClientCommand)
Events.OnTick.Add(SpiffBoy.Mood.releaseIdle)
