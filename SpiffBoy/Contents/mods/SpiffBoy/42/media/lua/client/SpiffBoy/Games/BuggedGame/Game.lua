require"SpiffBoy/Core/Core"
require"SpiffBoy/Framework/Cartridges"
require"SpiffBoy/Core/GameBase"
require"SpiffBoy/Core/Tunes"

SpiffBoyBuggedGameGame=SpiffBoyGameBase:derive("SpiffBoyBuggedGameGame")

local q=SpiffBoy.Cartridges.SHADES
local c=q[4]
local g={1,2,3}
local h=SpiffBoy.Cartridges.SCREEN_WIDTH
local d=SpiffBoy.Cartridges.SCREEN_HEIGHT
local a=8
local i=math.floor(h/a)
local j=math.floor(d/a)
local r=30
local s=2
local k={3,4,6}
local l=24
local t=0.3
local u=0.6
local v=SpiffBoy.TICK_RATE
local w=134
local x=60
local y=4
local z=24
local e=4
local A=12
local B=6
local m="title"
local C="Bugged Game: the next crash is a deliberate test crash of this development cartridge; the mod and the save are fine."
local D="BUGGED GAME DELIBERATE TEST CRASH (development cartridge, nothing is broken)"

SpiffBoy.Tunes.register("BuggedGame",{
[m]={
pulse1="t134 @2 v9 y0 l16 o4 e g b >d <g8 r8 g8 r8 r8 g g g8 r8 g8 r8 g4",
pulse2="t134 @2 v12 y0 l16 o4 g b >d f+ g8 r8 g8 r8 r8 g g g8 r8 g8 r8 g4",
wave="t134 @12 v2 l16 o4 g r <d r >g r8. g r8. r8 g g g r8. g r8. g4",
},
})

local function E()
local b=v*x/w
return math.floor(b*z/y+0.5)+B
end

function SpiffBoyBuggedGameGame:init()
self.ticks=0
self.title=self.context.art("title")
self.swaps={}
self.progress=0
self.bands={}
local b=0
while b<d do
local f=math.min(k[self.random:int(1,#k)],d-b)
self.bands[#self.bands+1]={y=b,height=f,shift=self.random:int(-l,l),threshold=self.random:float()}
b=b+f
end
self.tuneStart=e
self.corruptStart=e+A
self.crashAt=e+E()
end

function SpiffBoyBuggedGameGame:corruptTile()
local b=self.random
local f=b:int(1,s)
self.swaps[#self.swaps+1]={
sx=b:int(0,i-f)*a,
sy=b:int(0,j-1)*a,
dx=b:int(0,i-f)*a,
dy=b:int(0,j-1)*a,
width=f*a,
}
end

function SpiffBoyBuggedGameGame:tick(inputs,tick)
self.ticks=self.ticks+1
if self.ticks==self.tuneStart then
self.sequencer:play(m)
end
if self.ticks>=self.corruptStart then
local b=math.min(1,(self.ticks-self.corruptStart)/(self.crashAt-self.corruptStart))
self.progress=b
local f=math.floor(r*math.sqrt(b))
while#self.swaps<f do
self:corruptTile()
end
end
if self.ticks>=self.crashAt then
SpiffBoy.log(C)
error(D)
end
end

function SpiffBoyBuggedGameGame:draw(screen)
screen:clear(c.r,c.g,c.b)
local f=self.title
local n=self.progress
for F,b in ipairs(self.bands)do
local o=0
if b.threshold<t+u*n then
o=math.floor(b.shift*n)
end
for G,p in ipairs(g)do
screen:sheet(f,0,(p-1)*d+b.y,h,b.height,o,b.y,1,p)
end
end
for p,b in ipairs(self.swaps)do
screen:rect(b.dx,b.dy,b.width,a,c.r,c.g,c.b,1)
for F,o in ipairs(g)do
screen:sheet(f,b.sx,(o-1)*d+b.sy,b.width,a,b.dx,b.dy,1,o)
end
end
end
