require"SpiffBoy/Core/Core"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Core/LocalPlayers"
require"SpiffBoy/Network/ConsoleHandover"

SpiffBoy.ConsoleStatus=SpiffBoy.ConsoleStatus or{}
local a=SpiffBoy.ConsoleStatus

local g=1000

local c=0

function a.charge(console)
local b=SpiffBoyConsoleInstance.runningOn(console)
if b then
return math.max(0,b.battery or 0)
end
return SpiffBoy.Handheld.getBattery(console)or 0
end

function a.isSwitchedOn(console)
local b=SpiffBoyConsoleInstance.runningOn(console)
return b~=nil and b.switchOn
end

function a.runsElsewhere(console)
if SpiffBoyConsoleInstance.runningOn(console)~=nil then
return false
end
local b=SpiffBoy.Handheld.getHost(console)
return b~=nil and SpiffBoy.LocalPlayers.byOnlineId(b)==nil
end

function a.displayName(console)
local b=getItemNameFromFullType(SpiffBoy.CONSOLE_ITEM)
if not a.isSwitchedOn(console)and not a.runsElsewhere(console)then
return b
end
return getText("IGUI_ClothingNaming",getText("Tooltip_activated"),b)
end

function a.refreshName(console)
local b=a.displayName(console)
if console:getName()~=b then
console:setName(b)
end
end

local function h()
local b=getTimestampMs()
if b<c then
return
end
c=b+g
for i=0,getNumActivePlayers()-1 do
local d=getSpecificPlayer(i)
if d then
local e=d:getInventory():getAllTypeRecurse(SpiffBoy.CONSOLE_ITEM)
for j=0,e:size()-1 do
local f=e:get(j)
a.refreshName(f)
SpiffBoy.Handheld.refreshWeight(f)
end
end
end
end

local function e(page,stage)
if stage~="buttonsAdded"then
return
end
for j,f in ipairs(page.backpacks)do
local d=f.inventory:getAllTypeRecurse(SpiffBoy.CONSOLE_ITEM)
for i=0,d:size()-1 do
local b=d:get(i)
a.refreshName(b)
if a.runsElsewhere(b)then
SpiffBoy.ConsoleHandover.verifyHost(b)
end
end
end
end

Events.OnTickEvenPaused.Add(h)
Events.OnRefreshInventoryWindowContainers.Add(e)
