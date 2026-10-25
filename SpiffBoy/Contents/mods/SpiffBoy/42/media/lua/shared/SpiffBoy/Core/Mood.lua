require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Core/Sandbox"

SpiffBoy.Mood=SpiffBoy.Mood or{}
local a=SpiffBoy.Mood

a.BOREDOM_PER_SECOND=0.04
a.UNHAPPINESS_PER_SECOND=0.02

function a.ease(playerObj)
if not SpiffBoy.Sandbox.playingEasesMood()then
return false
end
local b=playerObj:getStats()
b:remove(CharacterStat.BOREDOM,a.BOREDOM_PER_SECOND)
b:remove(CharacterStat.UNHAPPINESS,a.UNHAPPINESS_PER_SECOND)
return true
end

function a.applySecond(playerObj)
if not SpiffBoy.Sandbox.playingEasesMood()then
return
end
if isClient()then
sendClientCommand(playerObj,SpiffBoy.COMMAND_MODULE,SpiffBoy.COMMAND_EASE_MOOD,{})
return
end
a.ease(playerObj)
end
