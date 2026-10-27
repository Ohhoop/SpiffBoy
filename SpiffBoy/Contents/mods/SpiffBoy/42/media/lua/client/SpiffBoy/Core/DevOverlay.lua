require"SpiffBoy/Core/Core"

SpiffBoy.DevOverlay=SpiffBoy.DevOverlay or{}
local l=SpiffBoy.DevOverlay

local i=8
local m=14

local function a(value,decimals)
local b=10^decimals
return tostring(math.floor(value*b)/b)
end

local function e(stats,stat,decimals)
return a(stats:get(stat),decimals).."/"..tostring(stat:getMaximumValue())
end

function l.draw(window)
if not SpiffBoy.isDevBuild()then
return
end
local c=window.runtime
local j=window.shell
local f=window.screen.calls
if j then
f=f+j.calls
end
local b={
"frame "..a(c.frameMs,1).." ms  ticks "..tostring(c.ticksThisFrame).."  tick "..tostring(c.tick),
"calls "..tostring(f).."  scale "..tostring(window.screen.scale),
"mode "..tostring(c.game and c.game.mode),
}
if window.veil~=nil then
local g=window.playerObj:getCurrentSquare()
local d="light "..a(window.light,3).."  veil "..a(window.veil,3)
if g then
d=d.."  darkMulti "..a(g:getDarkMulti(window.playerNum),3)
end
d=d.."  daylight "..a(getClimateManager():getDayLightStrength(),3)
b[#b+1]=d
end
local g=window.chip
if g then
for h=1,#g.voices do
local d=g.voices[h]
local k="voice "..tostring(h).." off"
if d.on then
k="voice "..tostring(h).." "..tostring(d.sound).."  pitch "..a(d.pitch,3).."  gain "..a(d.gain,2)
end
b[#b+1]=k
end
end
if window:isPlaying()then
local d=window.playerObj:getStats()
b[#b+1]="boredom "..e(d,CharacterStat.BOREDOM,1).."  stress "..e(d,CharacterStat.STRESS,2).."  unhappiness "..e(d,CharacterStat.UNHAPPINESS,1)
end
for d=1,#b do
window:drawText(b[d],i-window:getX(),i-window:getY()+(d-1)*m,0.4,1,0.4,1,UIFont.Small)
end
end
