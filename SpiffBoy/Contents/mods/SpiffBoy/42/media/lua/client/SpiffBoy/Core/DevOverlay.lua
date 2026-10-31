require"SpiffBoy/Core/Core"

SpiffBoy.DevOverlay=SpiffBoy.DevOverlay or{}
local m=SpiffBoy.DevOverlay

local j=8
local n=14

local function a(value,decimals)
local b=10^decimals
return tostring(math.floor(value*b)/b)
end

local function f(stats,stat,decimals)
return a(stats:get(stat),decimals).."/"..tostring(stat:getMaximumValue())
end

function m.draw(window)
if not SpiffBoy.isDevBuild()then
return
end
local c=window.instance
local d=c.runtime
local k=window.shell
local g=c.screen.calls
if k then
g=g+k.calls
end
local b={
"frame "..a(d.frameMs,1).." ms  ticks "..tostring(d.ticksThisFrame).."  tick "..tostring(d.tick),
"calls "..tostring(g).."  scale "..tostring(c.screen.scale),
"mode "..tostring(d.game and d.game.mode),
}
if window.veil~=nil then
local h=window.playerObj:getCurrentSquare()
local e="light "..a(window.light,3).."  veil "..a(window.veil,3)
if h then
e=e.."  darkMulti "..a(h:getDarkMulti(window.playerNum),3)
end
e=e.."  daylight "..a(getClimateManager():getDayLightStrength(),3)
b[#b+1]=e
end
local h=c.chip
if h then
for i=1,#h.voices do
local e=h.voices[i]
local l="voice "..tostring(i).." off"
if e.on then
l="voice "..tostring(i).." "..tostring(e.sound).."  pitch "..a(e.pitch,3).."  gain "..a(e.gain,2)
end
b[#b+1]=l
end
end
if c:isPlaying()then
local e=window.playerObj:getStats()
b[#b+1]="boredom "..f(e,CharacterStat.BOREDOM,1).."  stress "..f(e,CharacterStat.STRESS,2).."  unhappiness "..f(e,CharacterStat.UNHAPPINESS,1)
end
for e=1,#b do
window:drawText(b[e],j-window:getX(),j-window:getY()+(e-1)*n,0.4,1,0.4,1,UIFont.Small)
end
end
