require"SpiffBoy/Core/Core"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Handheld/ConsoleLocator"

SpiffBoy.ConsoleHosts=SpiffBoy.ConsoleHosts or{}
local a=SpiffBoy.ConsoleHosts

local l=50
local f=4

local d={}
local c={}

local function g(player)
return{id=player:getOnlineID(),name=player:getUsername()}
end

local function m(entry)
if entry==nil then
return nil
end
local b=getPlayerByOnlineID(entry.id)
if b and b:getUsername()==entry.name then
return entry.id
end
return nil
end

local function h(map,consoleId)
local b=m(map[consoleId])
if b==nil then
map[consoleId]=nil
end
return b
end

function a.record(consoleId,player)
d[consoleId]=g(player)
end

function a.of(consoleId)
return h(d,consoleId)
end

function a.host(console,carrier)
local b=carrier:getOnlineID()
a.record(console:getID(),carrier)
if SpiffBoy.Handheld.getHost(console)~=b then
SpiffBoy.Handheld.setHost(console,b)
syncItemModData(carrier,console)
end
end

function a.recordHandedFrom(consoleId,player)
c[consoleId]=g(player)
end

function a.handedFrom(consoleId)
return h(c,consoleId)
end

function a.forgetHandedFrom(consoleId)
c[consoleId]=nil
end

local function n(console)
local b=SpiffBoy.ConsoleLocator.anchorOf(console)
if not b then
return
end
if b.kind==SpiffBoy.ConsoleLocator.PLAYER then
if instanceof(b.character,"IsoPlayer")then
syncItemModData(b.character,console)
end
return
end
local i,j=b.x,b.y
if b.kind==SpiffBoy.ConsoleLocator.VEHICLE then
i,j=b.vehicle:getX(),b.vehicle:getY()
end
local k=getOnlinePlayers()
for o=0,k:size()-1 do
local e=k:get(o)
if math.max(math.abs(e:getX()-i),math.abs(e:getY()-j))<=l then
syncItemModData(e,console)
end
end
end

function a.release(consoleId,console)
d[consoleId]=nil
c[consoleId]=nil
if not console or SpiffBoy.Handheld.getHost(console)==nil then
return
end
SpiffBoy.Handheld.setHost(console,nil)
if console:getWorldItem()then
SpiffBoy.Handheld.publishPlacedHost(console,nil)
return
end
n(console)
end

function a.sameMachine(onlineId,otherId)
return math.floor(onlineId/f)==math.floor(otherId/f)
end

function a.carriedBy(player,consoleId)
local b=player:getInventory():getItemWithIDRecursiv(consoleId)
if b and SpiffBoy.Handheld.isConsole(b)then
return b
end
return nil
end

function a.otherCarrier(player,consoleId)
local e=getOnlinePlayers()
for j=0,e:size()-1 do
local b=e:get(j)
if b~=player then
local i=a.carriedBy(b,consoleId)
if i then
return b,i
end
end
end
return nil
end
