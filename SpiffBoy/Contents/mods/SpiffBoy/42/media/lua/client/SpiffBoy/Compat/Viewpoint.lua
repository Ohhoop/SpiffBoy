require"SpiffBoy/Core/CameraShift"
require"SpiffBoy/UI/HandheldWindow"
require"SpiffBoy/Handheld/HandheldAction"
require"SpiffBoy/Compat/CompatVersion"

local f="Project Viewpoint"
local c="Viewpoint"
local a=0
local g="first"
local h={
{from="0.1.6.1",inventoryScreen=false},
{from="0.1.7-rc2",inventoryScreen=true},
}

local i=SpiffBoy.CameraShift.begin
local j=SpiffBoyHandheldWindow.holdZoomIn
local k=SpiffBoyHandheldAction.new
local l=SpiffBoyHandheldWindow.show

local function b(playerNum)
local d=Viewpoint and Viewpoint.View
return playerNum==a and d~=nil and d.next()~=g
end

local function m()
function SpiffBoy.CameraShift.begin(playerObj,screenTargetX,screenTargetY)
if b(playerObj:getPlayerNum())then
return
end
i(playerObj,screenTargetX,screenTargetY)
end

function SpiffBoyHandheldWindow:holdZoomIn()
if b(self.playerNum)then
return
end
j(self)
end

function SpiffBoyHandheldAction:new(character,console,item)
local d=k(self,character,console,item)
if b(character:getPlayerNum())then
d.stopOnAim=false
end
return d
end
end

local function n()
return ViewpointInventory~=nil and ViewpointInventory.up()
end

local function o()
function SpiffBoyHandheldWindow:show()
l(self)
if self.playerNum==a and n()then
ViewpointInventory.close()
end
end

local function d()
if ViewpointInventory==nil then
return
end
local e=ViewpointInventory.open
function ViewpointInventory.open(how)
if SpiffBoyHandheldWindow.forPlayer(a)~=nil then
return false
end
return e(how)
end
end

Events.OnGameStart.Add(d)
end

local d=SpiffBoy.CompatVersion.installed(c)
local e=d and SpiffBoy.CompatVersion.branch(f,c,d,h)
if e then
m()
if e.inventoryScreen then
o()
end
end
