-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/Core"

SpiffBoy.CameraShift=SpiffBoy.CameraShift or{}
local d=SpiffBoy.CameraShift

local i=0.018
local w="dragCamera"
local x=0
local y=150
local j=-1
local k=1
local c=0
local z=0.001
local A=0.015
local B=1.5

local g=nil
local a=nil

local function C()
if not g then
g=DebugChunkState.new()
end
return g
end

local function l(worldX,worldY)
C():fromLua2(w,-worldX,-worldY)
end

local function D(playerObj,pixelsX,pixelsY)
local b=playerObj:getX()
local e=playerObj:getY()
local f=playerObj:getZ()
local m=IsoUtils.XToScreen(b,e,f,0)
local n=IsoUtils.YToScreen(b,e,f,0)
local o=IsoUtils.XToScreen(b+1,e,f,0)-m
local p=IsoUtils.XToScreen(b,e+1,f,0)-m
local q=IsoUtils.YToScreen(b+1,e,f,0)-n
local r=IsoUtils.YToScreen(b,e+1,f,0)-n
local h=o*r-p*q
if h==0 then
return 0,0
end
return(pixelsX*r-p*pixelsY)/h,(o*pixelsY-q*pixelsX)/h
end

local function E(playerNum)
local b=getCore()
while b:getNextZoom(playerNum,k)~=b:getNextZoom(playerNum,c)do
b:doZoomScroll(playerNum,k)
end
local e={b:getNextZoom(playerNum,c)}
while b:getNextZoom(playerNum,j)~=b:getNextZoom(playerNum,c)do
b:doZoomScroll(playerNum,j)
e[#e+1]=b:getNextZoom(playerNum,c)
end
return e
end

local function m(playerNum,value)
local e=getCore()
local b=e:getNextZoom(playerNum,c)
if b==value then
return
end
if value<b then
setZoomLevels(b,value)
e:doZoomScroll(playerNum,j)
else
setZoomLevels(value,b)
e:doZoomScroll(playerNum,k)
end
end

local function f(state)
m(state.playerNum,state.zoomTo)
setZoomLevels(unpack(state.levels))
state.zooming=false
end

function d.begin(playerObj,screenTargetX,screenTargetY)
local b=playerObj:getPlayerNum()
if b~=x then
return
end
if a and a.zooming then
f(a)
end
local r=getCore()
local e=r:getNextZoom(b,c)
local n=E(b)
local h=n[#n]
m(b,e)
local o=math.abs(e-h)>=z
local p=i
local q=a and a.progress or 0
if o then
local s=B*math.max(e,h)*math.abs(math.log(h/e))
p=math.min(i,A/s)
q=0
end
a={
player=playerObj,
playerNum=b,
screenTargetX=screenTargetX,
screenTargetY=screenTargetY,
progress=q,
step=p,
levels=n,
zoomFrom=e,
zoomTo=h,
zooming=o,
closing=false,
ticks=0,
}
end

function d.settled()
return a==nil or(a.settled==true and not a.closing)
end

function d.finish()
if not a then
return
end
if a.zooming then
f(a)
end
a.step=i
a.closing=true
end

function d.reset()
if a and a.zooming then
f(a)
end
a=nil
if g then
l(0,0)
end
end

local function F()
if not a then
return
end
local s=a.player
if s:isDead()then
d.reset()
return
end
if a.settled and not a.closing then
return
end
if a.closing then
a.progress=a.progress-a.step
if a.progress<=0 then
d.reset()
return
end
elseif a.progress<1 then
a.progress=math.min(1,a.progress+a.step)
end
local e=a.progress
local h=e*e*(3-2*e)
local n=h
local b=a.playerNum
if a.zooming then
m(b,a.zoomFrom*(a.zoomTo/a.zoomFrom)^h)
local o=1-e
n=1-o*o*o
if e>=1 then
f(a)
end
end
local o=IsoCamera.getScreenWidth(b)
local p=IsoCamera.getScreenHeight(b)
if o<=0 or p<=0 then
return
end
local G=IsoCamera.getOffscreenWidth(b)/o
local H=IsoCamera.getOffscreenHeight(b)/p
local t=(IsoCamera.getScreenLeft(b)+o/2-a.screenTargetX)*G*n
local u=(IsoCamera.getScreenTop(b)+p/2-a.screenTargetY)*H*n
local q,r=D(s,t,u)
l(q,r)
a.ticks=a.ticks+1
if SpiffBoy.isDevBuild()and a.ticks<=y then
SpiffBoy.log("camera shift tick "..tostring(a.ticks).." zoom "..tostring(getCore():getZoom(b)).." aim "..tostring(getCore():getNextZoom(b,c)).." progress "..tostring(a.progress).." eased "..tostring(h).." pixels "..tostring(t)..","..tostring(u).." world "..tostring(q)..","..tostring(r))
end
if e>=1 and not a.closing then
local v=getCore()
a.settled=v:getZoom(b)==v:getNextZoom(b,c)
if a.settled and SpiffBoy.isDevBuild()then
SpiffBoy.log("camera shift settled at tick "..tostring(a.ticks).." world "..tostring(q)..","..tostring(r))
end
end
end

local function b()
a=nil
l(0,0)
end

Events.OnTickEvenPaused.Add(F)
Events.OnGameStart.Add(b)
