require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Handheld/WornHeadphones"

local a=SpiffBoy.WornHeadphones

local e=1000000000
local f=tostring(getTimestampMs()).."-"..tostring(ZombRand(e))
local b=0
local c={}

function a.wear(playerObj,wornType)
c[playerObj:getPlayerNum()]=wornType
local d=a.apply(playerObj,wornType)
if SpiffBoy.isDevBuild()then
SpiffBoy.log("worn headphones "..tostring(wornType)..", changed "..tostring(d))
end
if isClient()then
b=b+1
sendClientCommand(playerObj,SpiffBoy.COMMAND_MODULE,a.COMMAND,{type=wornType,session=f,sequence=b})
end
end

local function g(playerNum,playerObj)
a.wear(playerObj,nil)
end

local function h(playerObj)
if not playerObj:isLocalPlayer()then
return
end
local d=c[playerObj:getPlayerNum()]
if a.apply(playerObj,d)and SpiffBoy.isDevBuild()then
SpiffBoy.log("worn headphones put back to "..tostring(d).." over a look received from the server")
end
end

Events.OnCreatePlayer.Add(g)
Events.OnPlayerUpdate.Add(h)
