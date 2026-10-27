require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Core/Sandbox"

SpiffBoy.Mood=SpiffBoy.Mood or{}
local a=SpiffBoy.Mood

a.BOREDOM_PER_SECOND=0.04
a.UNHAPPINESS_PER_SECOND=0.02
a.READING_HOLD_MS=3000
a.RELEASE_CHECK_MS=1000

local c={}
local f=0

local function g(playerObj)
local b=c[playerObj]
if not playerObj:isReading()then
playerObj:setReading(true)
if not b then
b={}
c[playerObj]=b
SpiffBoy.trace("mood: player "..tostring(playerObj:getOnlineID()).." marked as reading")
end
end
if b then
b.lastMs=getTimestampMs()
end
end

local function h(playerObj,reader,now)
if playerObj:isDead()then
return true
end
return now-reader.lastMs>=a.READING_HOLD_MS and playerObj:getCharacterActions():isEmpty()
end

function a.ease(playerObj)
if not SpiffBoy.Sandbox.playingEasesMood()then
return false
end
g(playerObj)
local b=playerObj:getStats()
b:remove(CharacterStat.BOREDOM,a.BOREDOM_PER_SECOND)
b:remove(CharacterStat.UNHAPPINESS,a.UNHAPPINESS_PER_SECOND)
return true
end

function a.releaseIdle()
local d=getTimestampMs()
if d<f then
return
end
f=d+a.RELEASE_CHECK_MS
local b=nil
for e,i in pairs(c)do
if h(e,i,d)then
b=b or{}
b[#b+1]=e
end
end
if b then
for i=1,#b do
local e=b[i]
c[e]=nil
e:setReading(false)
SpiffBoy.trace("mood: player "..tostring(e:getOnlineID()).." no longer marked as reading")
end
end
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
