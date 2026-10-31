require"TimedActions/ISTimedActionQueue"
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/KeyBinds"
require"SpiffBoy/UI/HandheldWindow"

local e=SpiffBoy.KeyBinds

local function f(playerObj)
if ISTimedActionQueue.isPlayerDoingAction(playerObj)then
return false
end
local a=playerObj:getVehicle()
if a then
return not a:isDriver(playerObj)
end
return not playerObj:isPlayerMoving()
end

local function g(key)
if isGamePaused()or not getCore():isKey(e.BINDS.resume.id,key)then
return
end
local b={}
for h,a in pairs(SpiffBoyConsoleInstance.instances)do
local c=a.playerObj
if not a.window and a.switchOn and c:getJoypadBind()<0 and c:getInventory():getItemWithIDRecursiv(a.consoleId)then
local d=b[a.playerNum]
if not d or a.lastShownMs>d.lastShownMs then
b[a.playerNum]=a
end
end
end
for c,a in pairs(b)do
if not SpiffBoyHandheldWindow.forPlayer(a.playerNum)and f(a.playerObj)then
SpiffBoyHandheldWindow.reveal(a)
end
end
end

Events.OnKeyStartPressed.Add(g)
