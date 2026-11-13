-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"ISUI/ISPanel"
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Sandbox"
require"SpiffBoy/Framework/Cartridges"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Core/Runtime"
require"SpiffBoy/Core/Input"
require"SpiffBoy/Core/Audio"
require"SpiffBoy/Core/Textures"
require"SpiffBoy/Core/PlayerGuard"
require"SpiffBoy/Core/DevOverlay"
require"SpiffBoy/Core/CameraShift"
require"SpiffBoy/Core/ConsolePosition"
require"SpiffBoy/Handheld/ConsoleInstance"
require"SpiffBoy/Handheld/PlayHandheldAction"
require"SpiffBoy/Menus/CartridgeMenu"
require"SpiffBoy/Menus/HeadphonesMenu"
require"SpiffBoy/Menus/LinkMenu"
require"SpiffBoy/Handheld/WornHeadphonesClient"
require"SpiffBoy/UI/ZoomLock"
require"SpiffBoy/UI/JackGrip"
require"SpiffBoy/UI/CartridgeGrip"
require"SpiffBoy/UI/LinkGrip"
require"SpiffBoy/UI/ShellLayout"
require"SpiffBoy/UI/GuideWindow"
require"SpiffBoy/UI/AnnouncementWindow"

SpiffBoyHandheldWindow=ISPanel:derive("SpiffBoyHandheldWindow")
SpiffBoyHandheldWindow.windows={}

local b=SpiffBoy.ShellLayout
local ar=SpiffBoyConsoleInstance.ART
local q=b.SHELL_WIDTH
local s=b.SHELL_HEIGHT
local as=b.SCREEN_X
local at=b.SCREEN_Y
local au=b.GLASS_BORDER
local av=0.62
local Q=24
local k=b.DPAD
local t=b.DPAD_COLUMNS
local C=b.BUTTON_A
local D=b.BUTTON_B
local v=b.BUTTON_W
local z=b.BUTTON_H
local p=b.START
local R=4
local S=0
local r=b.LED
local E=b.LED_LIT
local T=b.LED_DIM
local U=b.LED_OFF
local i=b.POWER
local A=b.CRISP_BORDER
local F=b.SIDE_TUCK
local g=b.VOLUME
local V=i.x-i.hitMargin
local aw=g.x+g.w+g.hitMargin
local ax=SpiffBoyConsoleInstance.VOLUME_STEPS
local ay=2
local az=0.15
local d=SpiffBoy.Cartridges.SHADES[4]
local f=SpiffBoy.Cartridges.SHADES[1]
local aA=b.SCREEN_OFF
local aB=b.BLINK_MS
local W=-1
local aC=0
local X=0.95
local aD=0.75
local Y=ArrayList.new()
local aE=0.135
local aF=0.15
local aG=0.08
local e={size=32,strength=0.6,curve=3,red=0.45,dim=0.5}
local aH=1
local aI=60
local aJ=0.95
local aK={width=150,padding=6}
local Z={delayMs=1000,margin=8,barWidth=100,barHeight=7,gap=4}
local _={}
local G=b.SHELL_ART
local aa=b.POWER_SWITCH_ART
local ab=b.LED_ART
local ac="led_glow_edge"
local ad="led_glow_red"
local ae=b.BUTTON_START_ART
local aL={x=128,y=0,w=128,h=8}
local c=b.SLOT
local l=b.JACK
local n=b.LINK
local m={travel=40,snap=1,ease=1.5,start=0.10,reach=0.90,gone=0.90}
local aM="SpiffBoy_PartClick"
local aN="SpiffBoyPlugHeadphonesAction"
local aO="SpiffBoyUnplugHeadphonesAction"
local aP="SpiffBoyPlugCableAction"
local aQ="SpiffBoyUnplugCableAction"
local aR="SpiffBoyConnectCableAction"
local aS="SpiffBoyDisconnectCableAction"
local aT="SpiffBoyInsertCartridgeAction"
local aU=SpiffBoyConsoleInstance.REMOVE_ACTION
local aV=600
local j={
name="cartridge",
x=c.x+3,
w=119,
h=100,
mouth=6,
label={x=11,y=29,w=97,h=53,file="label.png",inset=3},
}
local aW={r=238/255,g=232/255,b=214/255}
local aX={r=52/255,g=44/255,b=60/255}
local H={r=96/255,g=62/255,b=116/255}
local af=b.DPAD_FRAMES
local I=b.BUTTON_FRAMES
local ag=b.VOLUME_FRAMES
local o={G,c.empty,c.full,j.name,aa,ab,ac,ad,ae,l.empty.name,n.empty.name,n.plugged.name,n.slide.name}

for a=0,t*t-1 do
o[#o+1]=af[a]
end
for a=0,ax do
o[#o+1]=ag[a]
end
for h,a in pairs(I)do
o[#o+1]=a[0]
o[#o+1]=a[1]
end
for u,a in pairs({l.plugs,l.slides})do
for w,h in pairs(a)do
o[#o+1]=h.name
end
end

local function aY(art)
local a={}
for u=1,#o do
local h=o[u]
a[h]=art(h)
end
return a
end

local function J(itemType)
return SpiffBoy.Handheld.HEADPHONES[itemType].kind
end

local function ah(shell,veil,texture,x,y,w,h)
shell:sprite(texture,x,y,w,h)
end

local function ai(shell,veil,texture,x,y,w,h)
shell:tinted(texture,x,y,w,h,0,0,0,veil)
end

local function K(shell,veil,texture,sx,sy,w,h,x,y)
shell:sheet(texture,sx,sy,w,h,x,y)
end

local function L(shell,veil,texture,sx,sy,w,h,x,y)
shell:tintedSheet(texture,sx,sy,w,h,x,y,0,0,0,veil)
end

local function aZ(window,veil,itemType,x,y)
window:drawCartridgeLabel(itemType,x,y)
end

local function a_(window,veil,itemType,x,y)
local a=j.label
window.shell:rect(x+a.x,y+a.y,a.w,a.h,0,0,0,veil)
end

local function a0(input,action)
input:tap(action)
end

local function a1(held,action)
held[action]=true
end

local function aj(x,y,centre)
local a=x-centre.x
local h=y-centre.y
local u=v/2
return a*a+h*h<=u*u
end

local function M(x,y,powered)
local a=i.offY
if powered then
a=i.onY
end
if x>=i.x-i.hitMargin and x<i.x+i.w+i.hitMargin and y>=a and y<a+i.h then
return"power"
end
if x>=g.x-g.hitMargin and x<g.x+g.w+g.hitMargin and y>=g.y and y<g.y+g.h then
return"volume"
end
local h=k.size/2
if math.abs(x-k.x)<=h and math.abs(y-k.y)<=h then
return"dpad"
end
if aj(x,y,C)then
return"a"
end
if aj(x,y,D)then
return"b"
end
if math.abs(x-p.x)<=p.w/2+R and math.abs(y-p.y)<=p.h/2+R then
return"start"
end
return nil
end

local function a2(x,y)
local a=k.size/t
local h=k.x-k.size/2
local u=k.y-k.size/2
local w=math.max(0,math.min(t-1,math.floor((x-h)/a)))
local B=math.max(0,math.min(t-1,math.floor((y-u)/a)))
return w-1,B-1
end

local function ak(control,x,y,visitor,target)
if control~="dpad"then
visitor(target,control)
return
end
local a,h=a2(x,y)
if a<0 then
visitor(target,"left")
elseif a>0 then
visitor(target,"right")
end
if h<0 then
visitor(target,"up")
elseif h>0 then
visitor(target,"down")
end
end

local function a3(x,y,zone)
return x>=zone.x and x<zone.x+zone.w and y>=zone.y and y<zone.y+zone.h
end

local function B(x,y,port,art)
local a=port.zone
return x>=a.x and x<a.x+a.w and y>=a.y and y<port.y+art.reach
end

local function al(progress,travel)
if progress<m.start then
return nil
end
local a=math.min(1,(progress-m.start)/(m.reach-m.start))
return m.snap+(travel-m.snap)*(1-a)^m.ease
end

local function am(progress,travel)
if progress>=m.gone then
return nil
end
return m.snap+(travel-m.snap)*(progress/m.gone)^m.ease
end

local function an(progress,plugging,unplugging,slide)
if plugging then
local a=al(progress,m.travel)
if a then
return{art=slide,drop=a}
end
return nil
end
if unplugging then
local a=am(progress,m.travel)
return{art=a and slide,drop=a or 0}
end
return nil
end

function SpiffBoyHandheldWindow:openShellMenu(fill)
local a=ISContextMenu.get(self.playerNum,getMouseX(),getMouseY())
a:removeFromUIManager()
a:addToUIManager()
a:setAlwaysOnTop(true)
fill(a,function(label,target,onSelect,...)
return a:addOption(label,target,onSelect,...)
end)
if a.numOptions<=1 then
a:setVisible(false)
end
self:traceMouse("menu opened with "..tostring(a.numOptions-1).." options, visible "..tostring(a:getIsVisible()).." at "..a:getX()..","..a:getY())
end

function SpiffBoyHandheldWindow:openJackMenu()
self:openShellMenu(function(context,add)
SpiffBoy.HeadphonesMenu.addOptions(context,self.playerObj,self.instance.console,add)
end)
end

function SpiffBoyHandheldWindow:openLinkMenu()
self:openShellMenu(function(context,add)
SpiffBoy.LinkMenu.addOptions(context,self.playerObj,self.instance.console,add)
end)
end

function SpiffBoyHandheldWindow:onRightMouseUp(x,y)
local a,h=self.shell:toLocal(x,y)
local u=a3(a,h,aL)
local w=B(a,h,l,self:jackArt())
local N=B(a,h,n,self:linkArt())
self:traceMouse("right up at "..x..","..y.." shell "..a..","..h.." inside "..tostring(u).." jack "..tostring(w).." link "..tostring(N).." paused "..tostring(isGamePaused()))
if isGamePaused()then
return self:isWantMouseEvents()
end
if w then
self:openJackMenu()
elseif N then
self:openLinkMenu()
elseif u then
self:openCartridgeMenu()
end
return self:isWantMouseEvents()
end

function SpiffBoyHandheldWindow:openCartridgeMenu()
self:openShellMenu(function(context,add)
SpiffBoy.CartridgeMenu.addOptions(context,self.playerObj,self.instance.console,add,true)
end)
end

function SpiffBoyHandheldWindow:traceMouse(message)
if SpiffBoy.isDevBuild()then
SpiffBoy.log("handheld mouse: "..message)
end
end

function SpiffBoyHandheldWindow:onRightMouseDown(x,y)
self:traceMouse("right down at "..x..","..y.." on frame "..tostring(self:isOnFrame(x,y)))
if self:putAwayOutsideFrame(x,y)then
return false
end
return self:isWantMouseEvents()
end

function SpiffBoyHandheldWindow:onRightMouseUpOutside(x,y)
self:traceMouse("right up outside at "..x..","..y)
end

function SpiffBoyHandheldWindow:slotArt()
if self.instance.seated then
return self.textures[c.full]
end
return self.textures[c.empty]
end

function SpiffBoyHandheldWindow:paintSlot(paintArea,paintPart,paintLabelOf,veil,rows,bottom)
local h=self.shell
local a=self.slotMotion
if not a then
paintArea(h,veil,self:slotArt(),0,0,c.w,rows,c.x,c.y)
return
end
paintArea(h,veil,self.textures[c.empty],0,0,c.w,rows,c.x,c.y)
if not a.lift then
return
end
local u=c.y-math.floor(a.lift+0.5)
self:clipAbove(u,bottom)
paintPart(h,veil,self.textures[j.name],j.x,u,j.w,j.h)
paintLabelOf(self,veil,a.itemType,j.x,u)
self:clearStencilRect()
end

function SpiffBoyHandheldWindow:drawSlot()
self:paintSlot(K,ah,aZ,0,c.h,c.y+j.mouth+1)
local a=self.slotMotion
if a and a.lift then
self.shell:rect(j.x+1,c.y+j.mouth,j.w-2,1,H.r,H.g,H.b,1)
end
end

function SpiffBoyHandheldWindow:drawSlotVeil(veil)
self:paintSlot(L,ai,a_,veil,-c.y,0)
end

function SpiffBoyHandheldWindow:cartridgeTravel()
local a=self.shell
local h=math.ceil((self:getY()+a.y)/a.scale)
return c.y+j.h+h
end

function SpiffBoyHandheldWindow:clipAbove(top,bottom)
local h=self.shell
local a=h.scale
self:setStencilRect(h.x+j.x*a,h.y+top*a,j.w*a,(bottom-top)*a)
end

function SpiffBoyHandheldWindow:drawCartridgeLabel(itemType,x,y)
local u=self.shell
local a=j.label
local w,N=x+a.x,y+a.y
local h=itemType and SpiffBoy.Cartridges.get(itemType)
local ao=h and h.art and SpiffBoy.Textures.get(SpiffBoy.Textures.cartridgeFolder(h),h.art..a.file,true)
if ao then
u:sprite(ao,w,N,a.w,a.h)
return
end
local O,P=aW,aX
u:rect(w,N,a.w,a.h,O.r,O.g,O.b,1)
local ap=u:lineHeight()
local a4=h and h.title or getItemNameFromFullType(itemType)
local aq=u:wrapText(a4,a.w-2*a.inset)
local a5=N+math.floor((a.h-#aq*ap)/2)
for a6,a7 in ipairs(aq)do
u:textCentre(a7,w+math.floor(a.w/2),a5+(a6-1)*ap,P.r,P.g,P.b,1)
end
end

function SpiffBoyHandheldWindow:clickOnRise(flag,condition)
if condition and not self[flag]then
SpiffBoy.Audio.playSound(aM)
end
self[flag]=condition
end

function SpiffBoyHandheldWindow:refreshHardware()
local a=self.instance
a:readHardware()
self:clickOnRise("headphonesIn",a.headphonesType~=nil)
if self.guestCable and not a.guestCable and not self.cableLeaving then
self.pullOutStartMs=getTimestampMs()
end
self.guestCable=a.guestCable
self:clickOnRise("cableSeated",a.cableIn)
end

function SpiffBoyHandheldWindow:pullOutProgress()
if not self.pullOutStartMs then
return nil
end
local a=(getTimestampMs()-self.pullOutStartMs)/aV
if a>=1 then
self.pullOutStartMs=nil
return nil
end
return a
end

function SpiffBoyHandheldWindow:updateSlotMotion(current,progress)
local a=self.instance.seated~=nil
self:clickOnRise("cartridgeIn",a)
local h=current~=nil and current.Type==aU and a
self:clickOnRise("cartridgeLeaving",h)
self.slotMotion=nil
if current and current.Type==aT and current.item and not a then
local u=al(progress,self:cartridgeTravel())
if u then
self.slotMotion={lift=u,itemType=current.item:getFullType()}
end
elseif h then
self.slotMotion={lift=am(progress,self:cartridgeTravel()),itemType=self.instance.seated.type}
end
end

function SpiffBoyHandheldWindow:updateJackMotion(current,progress)
local a=current~=nil and current.Type==aO and self.instance.headphonesType~=nil
self:clickOnRise("headphonesLeaving",a)
local u=current~=nil and current.Type==aN and SpiffBoy.Handheld.isHeadphones(current.item)
local h=nil
if u then
h=l.slides[J(current.item:getFullType())]
elseif a then
h=l.slides[J(self.instance.headphonesType)]
end
self.jackMotion=an(progress,u,a,h)
end

function SpiffBoyHandheldWindow:updateLinkMotion(current,progress)
local a=current and current.Type
local h=self:pullOutProgress()
local u=((a==aQ or a==aS)and self.instance.cableIn)or h~=nil
self:clickOnRise("cableLeaving",u)
local w=(a==aP and SpiffBoy.Handheld.isCable(current.item))or(a==aR and not self.instance.cableIn)
self.linkMotion=an(h or progress,w,u,n.slide)
end

function SpiffBoyHandheldWindow:paintPort(paint,veil,port,motion,art)
local u=self.shell
if not motion then
paint(u,veil,self.textures[art.name],0,0,art.w,art.h,port.x,port.y)
return
end
local h=port.empty
paint(u,veil,self.textures[h.name],0,0,h.w,h.h,port.x,port.y)
local a=motion.art
if not a then
return
end
local x=port.y+h.h
local y=x-(a.pin-1)+math.floor(motion.drop+0.5)
local w=math.max(0,x-y)
paint(u,veil,self.textures[a.name],0,w,a.w,a.h-w,port.x+a.dx,y+w)
end

function SpiffBoyHandheldWindow:syncWornHeadphones()
local a=nil
if not self.closing and self.instance.headphonesType then
a=SpiffBoy.Handheld.HEADPHONES[self.instance.headphonesType].worn
end
if a~=self.wornHeadphones then
self.wornHeadphones=a
SpiffBoy.WornHeadphones.wear(self.playerObj,a)
end
end

function SpiffBoyHandheldWindow:syncGrip(grip,wanted,x,y,w,h)
if wanted==grip.shown then
return
end
grip.shown=wanted
if not wanted then
grip:removeFromUIManager()
return
end
local u=self.shell
local a=u.scale
grip:setX(self:getX()+u.x+x*a)
grip:setY(self:getY()+u.y+y*a)
grip:setWidth(w*a)
grip:setHeight(h*a)
grip:initialise()
grip:addToUIManager()
grip:setAlwaysOnTop(true)
end

function SpiffBoyHandheldWindow:syncGrips()
local a=not self.closing
self:syncGrip(self.jackGrip,a and self.instance.headphonesType~=nil,l.x,l.y,l.empty.w,self:jackArt().reach)
self:syncGrip(self.linkGrip,a and self.instance.cableIn,n.x,n.y,n.empty.w,self:linkArt().reach)
self:syncGrip(self.cartridgeGrip,a and self.instance.seated~=nil,c.x,c.y,c.w,-c.y)
end

function SpiffBoyHandheldWindow:jackArt()
if self.instance.headphonesType then
return l.plugs[J(self.instance.headphonesType)]
end
return l.empty
end

function SpiffBoyHandheldWindow:linkArt()
if self.instance.cableIn then
return n.plugged
end
return n.empty
end

function SpiffBoyHandheldWindow:drawPorts()
self:paintPort(K,0,l,self.jackMotion,self:jackArt())
self:paintPort(K,0,n,self.linkMotion,self:linkArt())
end

function SpiffBoyHandheldWindow:drawPortsVeil(veil)
self:paintPort(L,veil,l,self.jackMotion,self:jackArt())
self:paintPort(L,veil,n,self.linkMotion,self:linkArt())
end

function SpiffBoyHandheldWindow.forPlayer(playerNum)
return SpiffBoyHandheldWindow.windows[playerNum]
end

function SpiffBoyHandheldWindow.anyShown()
for h,a in pairs(SpiffBoyHandheldWindow.windows)do
return a
end
return nil
end

function SpiffBoyHandheldWindow.hiddenOn(console)
local a=SpiffBoyConsoleInstance.runningOn(console)
if a and not a.window then
return a
end
return nil
end

function SpiffBoyHandheldWindow.reveal(instance)
instance:wake()
local a=SpiffBoyHandheldWindow:new(instance)
a:show()
a:takeUp()
a.guidePending=true
end

function SpiffBoyHandheldWindow.open(playerObj,console)
local a=playerObj:getPlayerNum()
if SpiffBoyHandheldWindow.forPlayer(a)or SpiffBoyConsoleInstance.playability(console,a)then
return
end
local h=SpiffBoyHandheldWindow.hiddenOn(console)
if h then
if h.playerNum==a then
SpiffBoyHandheldWindow.reveal(h)
end
return
end
if SpiffBoy.ConsoleHandover.claim(playerObj,console)then
return
end
SpiffBoyHandheldWindow.start(playerObj,console)
end

function SpiffBoyHandheldWindow.start(playerObj,console)
local a=playerObj:getPlayerNum()
if SpiffBoyHandheldWindow.forPlayer(a)or SpiffBoyConsoleInstance.runningOn(console)or SpiffBoyConsoleInstance.playability(console,a)then
return
end
SpiffBoy.Textures.refresh()
local h=SpiffBoyConsoleInstance.new(playerObj,console)
SpiffBoy.ConsoleHandover.started(h)
SpiffBoyHandheldWindow.reveal(h)
end

function SpiffBoyHandheldWindow.shownOn(console)
local a=SpiffBoyConsoleInstance.runningOn(console)
if a and a.window then
return a.window
end
return nil
end

function SpiffBoyHandheldWindow:new(instance)
local a=ISPanel:new(0,0,getCore():getScreenWidth(),getCore():getScreenHeight())
setmetatable(a,self)
self.__index=self
a.background=false
a.wantKeyEvents=true
a.instance=instance
a.playerObj=instance.playerObj
a.playerNum=instance.playerNum
a.closing=false
a.exitPressed=false
a.cartridgeIn=instance.seated~=nil
a.cartridgeLeaving=false
a.headphonesIn=instance.headphonesType~=nil
a.headphonesLeaving=false
a.cableSeated=instance.cableIn
a.guestCable=instance.guestCable
a.pullOutStartMs=nil
a.cableLeaving=false
a.jackGrip=SpiffBoyJackGrip:new(a)
a.linkGrip=SpiffBoyLinkGrip:new(a)
a.cartridgeGrip=SpiffBoyCartridgeGrip:new(a)
a.shell=SpiffBoyScreen.new(a,q,s)
a.art=SpiffBoy.Textures.folder(SpiffBoy.Textures.commonFolder(SpiffBoy.MOD_ID),ar)
a.textures=aY(a.art)
a.veil=nil
a.light=nil
a.veilTarget=nil
a.nextLightLogMinutes=0
a.volumeDrag=nil
a.mouseControl=nil
instance.screen.owner=a
a:layoutShell()
return a
end

function SpiffBoyHandheldWindow:show()
self:initialise()
self:addToUIManager()
self:setAlwaysOnTop(true)
SpiffBoyHandheldWindow.windows[self.playerNum]=self
self.instance.window=self
self.instance.lastShownMs=getTimestampMs()
SpiffBoy.PlayerGuard.hold(self.playerObj,self)
SpiffBoyZoomLock.engage()
end

function SpiffBoyHandheldWindow:dismiss()
SpiffBoy.PlayerGuard.release(self.playerObj)
SpiffBoyZoomLock.release()
self:setVisible(false)
self:removeFromUIManager()
if SpiffBoyHandheldWindow.windows[self.playerNum]==self then
SpiffBoyHandheldWindow.windows[self.playerNum]=nil
end
if self.instance.window==self then
self.instance.window=nil
self.instance.screen.owner=nil
end
end

function SpiffBoyHandheldWindow:fitTo(x,y,width,height)
self:setWidth(width)
self:setHeight(height)
self:setX(x)
self:setY(y)
end

local function P(playerNum,right)
local a=UIManager.getMoodleUI(playerNum)
if a and a:isVisible()then
return math.min(right,a:getX())
end
return right
end

local function aq(playerNum,left)
local a=getPlayerData(playerNum).equipped
if a and a:isVisible()then
return math.max(left,a:getRight())
end
return left
end

function SpiffBoyHandheldWindow:layoutShell()
local h=self.playerNum
local w,ao=getPlayerScreenLeft(h),getPlayerScreenTop(h)
local x,O=getPlayerScreenWidth(h),getPlayerScreenHeight(h)
local a=math.floor(math.min(x*av/q,O*aJ/s))
a=math.max(1,a)
local y=q*a
self.position=SpiffBoy.ConsolePosition.get()
local u
if self.position==SpiffBoy.ConsolePosition.LEFT then
u=math.min(w+x-y,aq(h,w)+Q)
elseif self.position==SpiffBoy.ConsolePosition.CENTRE then
u=w+math.floor((x-y)/2)
else
u=math.max(w,P(h,w+x)-y-Q)
end
local ap=ao+math.floor((O-s*a)/2)
local N=u+V*a
self:fitTo(N,ap,(aw-V)*a,s*a)
self.shell:setPlacement(u-N,0,a)
self.instance.screen:setPlacement(u-N+as*a,at*a,a)
end

function SpiffBoyHandheldWindow:prerender()
if self.closing then
return
end
self:holdNormalSpeed()
self:holdZoomIn()
self.instance:step()
self:showGuideOnceTaken()
end

function SpiffBoyHandheldWindow:showGuideOnceTaken()
if not self.guidePending or not SpiffBoy.CameraShift.settled()then
return
end
self.guidePending=false
SpiffBoyGuideWindow.onConsoleShown(self)
SpiffBoyAnnouncementWindow.onConsoleShown(self)
end

function SpiffBoyHandheldWindow:holdNormalSpeed()
if SpiffBoy.Sandbox.fastForwardWhilePlaying()then
return
end
if getGameSpeed()>1 then
setGameSpeed(1)
end
end

function SpiffBoyHandheldWindow:holdZoomIn()
local a=getCore()
if a:getNextZoom(self.playerNum,W)~=a:getNextZoom(self.playerNum,aC)then
a:doZoomScroll(self.playerNum,W)
end
end

function SpiffBoyHandheldWindow:render()
if self.closing then
return
end
SpiffBoy.DevOverlay.draw(self)
end

function SpiffBoyHandheldWindow:takeUp()
self:shiftCamera()
self:resetVeil()
self.poseAction=SpiffBoyPlayHandheldAction.startFor(self.playerObj,self)
end

function SpiffBoyHandheldWindow:putDown()
SpiffBoy.CameraShift.finish()
SpiffBoyPlayHandheldAction.stopFor(self.poseAction)
self.poseAction=nil
end

function SpiffBoyHandheldWindow:hide()
if self.closing then
return
end
self.closing=true
self.exitPressed=false
self.mouseControl=nil
self.volumeDrag=nil
self:syncWornHeadphones()
self:syncGrips()
self:putDown()
self:dismiss()
end

function SpiffBoyHandheldWindow:putAway()
if self.instance.powered or self.instance.transferring then
self:hide()
else
self.instance:close()
end
end

function SpiffBoyHandheldWindow:putAwayOutsideFrame(x,y)
if self:isOnFrame(x,y)then
return false
end
self:putAway()
return true
end

function SpiffBoyHandheldWindow:usesKeyboard()
return self.playerObj:getJoypadBind()<0 or getNumActivePlayers()==1
end

function SpiffBoyHandheldWindow:isKeyConsumed(key)
return self:usesKeyboard()and SpiffBoy.Input.isConsumedKey(key)
end

function SpiffBoyHandheldWindow:onKeyPress(key)
if isGamePaused()or not self:usesKeyboard()then
return
end
if key==SpiffBoy.Input.EXIT_KEY then
self.exitPressed=true
return
end
local a=SpiffBoy.Input.actionForKey(key)
if a then
self.instance.input:tap(a)
end
end

function SpiffBoyHandheldWindow:onKeyRelease(key)
if key==SpiffBoy.Input.EXIT_KEY and self.exitPressed then
self.exitPressed=false
self:putAway()
end
end

function SpiffBoyHandheldWindow:onKeyRepeat(key)
end

function SpiffBoyHandheldWindow:tapJoypad(action)
if isGamePaused()then
return
end
self.instance.input:tap(action)
end

function SpiffBoyHandheldWindow:onJoypadDown(button)
if button==Joypad.AButton then
self:tapJoypad("a")
elseif button==Joypad.BButton then
self:tapJoypad("b")
elseif button==Joypad.Start then
self:tapJoypad("start")
end
end

function SpiffBoyHandheldWindow:onJoypadDirUp()
self:tapJoypad("up")
end

function SpiffBoyHandheldWindow:onJoypadDirDown()
self:tapJoypad("down")
end

function SpiffBoyHandheldWindow:onJoypadDirLeft()
self:tapJoypad("left")
end

function SpiffBoyHandheldWindow:onJoypadDirRight()
self:tapJoypad("right")
end

function SpiffBoyHandheldWindow:readDevices(input)
local a=self.playerObj:getJoypadBind()
if a>=0 then
SpiffBoy.Input.readJoypad(a,input)
end
if self:usesKeyboard()then
SpiffBoy.Input.readKeyboard(input)
SpiffBoy.Input.readRunExit(input)
end
end

function SpiffBoyHandheldWindow:shiftCamera()
local a=self.playerNum
local u,w=getPlayerScreenLeft(a),getPlayerScreenWidth(a)
local y=getPlayerScreenTop(a)+getPlayerScreenHeight(a)/2
local x=self:getX()+self.shell.x
local h
if self.position==SpiffBoy.ConsolePosition.LEFT then
h=(x+q*self.shell.scale+P(a,u+w))/2
elseif self.position==SpiffBoy.ConsolePosition.CENTRE then
h=u+w/2
else
h=(u+x)/2
end
SpiffBoy.CameraShift.begin(self.playerObj,h,y)
end

function SpiffBoyHandheldWindow:isOnFrame(x,y)
local a,h=self.shell:toLocal(x,y)
if a>=0 and a<q and h>=0 and h<s then
return true
end
if B(a,h,l,self:jackArt())or B(a,h,n,self:linkArt())then
return true
end
return M(a,h,self.instance.switchOn)~=nil
end

function SpiffBoyHandheldWindow:onMouseDown(x,y)
if self:putAwayOutsideFrame(x,y)then
return false
end
if isGamePaused()then
return self:isWantMouseEvents()
end
local u,h=self.shell:toLocal(x,y)
local a=M(u,h,self.instance.switchOn)
if a=="power"then
self.mouseControl=nil
self.instance:togglePower()
return self:isWantMouseEvents()
end
if a=="volume"then
self.mouseControl=nil
self.volumeDrag={startY=h,startStep=self.instance:wheelStep(),moved=false}
return self:isWantMouseEvents()
end
self.mouseControl=a
if a then
ak(a,u,h,a0,self.instance.input)
end
return self:isWantMouseEvents()
end

function SpiffBoyHandheldWindow:releaseMouse()
self.mouseControl=nil
self:releaseVolume()
end

function SpiffBoyHandheldWindow:onMouseUp(x,y)
self:releaseMouse()
return self:isWantMouseEvents()
end

function SpiffBoyHandheldWindow:onMouseUpOutside(x,y)
self:releaseMouse()
end

function SpiffBoyHandheldWindow:dragVolume()
local a=self.volumeDrag
if not a then
return
end
if not isMouseButtonDown(S)then
self:releaseVolume()
return
end
local w,u=self.shell:toLocal(self:getMouseX(),self:getMouseY())
local h=math.floor((a.startY-u)/ay)
if h~=0 then
a.moved=true
end
self.instance:setVolumeStep(a.startStep+h)
end

function SpiffBoyHandheldWindow:releaseVolume()
local a=self.volumeDrag
if not a then
return
end
self.volumeDrag=nil
if a.moved then
return
end
if a.startY<g.y+g.h/2 then
self.instance:turnVolume(1)
else
self.instance:turnVolume(-1)
end
end

function SpiffBoyHandheldWindow:readMouse(input)
local a=self.mouseControl
if not a then
return
end
if not isMouseButtonDown(S)then
self.mouseControl=nil
return
end
local h,u=self.shell:toLocal(self:getMouseX(),self:getMouseY())
ak(a,h,u,a1,input.held)
end

function SpiffBoyHandheldWindow:readInput()
SpiffBoy.Input.refreshProfile()
local a=self.instance.input
a:clearHeld()
if isGamePaused()then
self.mouseControl=nil
self.volumeDrag=nil
return
end
self:readDevices(a)
self:readMouse(a)
self:dragVolume()
end

function SpiffBoyHandheldWindow:drawGlass()
local a=self.instance.screen
local h=aA
if self.instance.powered or self.instance.flickerFrames>0 then
h=d
end
local w=a.scale
local u=math.floor(w*au)
self.shell.calls=self.shell.calls+1
self:drawRect(a.x-u,a.y-u,a.width*w+2*u,a.height*w+2*u,1,h.r,h.g,h.b)
end

function SpiffBoyHandheldWindow:onMouseWheel(delta)
if isGamePaused()then
return false
end
local a,h=self.shell:toLocal(self:getMouseX(),self:getMouseY())
if M(a,h,self.instance.switchOn)~="volume"then
return false
end
self.instance:turnVolume(-delta)
return true
end

function SpiffBoyHandheldWindow:frame(draw)
local a=self.instance.screen
a:beginFrame()
draw(self,a)
a:endFrame()
end

local function ao(window,screen)
screen:clear(d.r,d.g,d.b)
end

local function a4(window,screen)
screen:clear(d.r,d.g,d.b)
local a=screen:lineHeight()
screen:textCentre(getText("UI_SpiffBoy_GameMissing"),screen.width/2,(screen.height-a)/2,f.r,f.g,f.b,1)
end

local function a5(window,screen)
local u=SpiffBoy.Cartridges.SHADES
for w,a in ipairs(window.instance.glitch)do
local h=u[a.shade]
screen:rect(a.x,a.y,a.w,a.h,h.r,h.g,h.b,1)
end
end

local function a6(window,screen)
local a=Z
screen:clear(d.r,d.g,d.b)
local u=screen:lineHeight()
local h=_[screen.width]
if not h then
h=screen:wrapText(getText("UI_SpiffBoy_ReceivingGame"),screen.width-a.margin*2)
_[screen.width]=h
end
local O=#h*u+a.gap+a.barHeight
local y=math.floor((screen.height-O)/2)
for w=1,#h do
screen:textCentre(h[w],screen.width/2,y+(w-1)*u,f.r,f.g,f.b,1)
end
local w=math.floor((screen.width-a.barWidth)/2)
local x=y+#h*u+a.gap
screen:rect(w,x,a.barWidth,a.barHeight,f.r,f.g,f.b,1)
screen:rect(w+1,x+1,a.barWidth-2,a.barHeight-2,d.r,d.g,d.b,1)
local N=math.floor((a.barWidth-4)*window.instance:transferProgress())
if N>0 then
screen:rect(w+2,x+2,N,a.barHeight-4,f.r,f.g,f.b,1)
end
end

local function a7(window,screen)
local a=aK
local y=screen:lineHeight()
local w=screen:wrapText(getText("UI_SpiffBoy_LinkLost"),a.width-a.padding*2)
local h=#w*y+a.padding*2
local x=math.floor((screen.width-a.width)/2)
local u=math.floor((screen.height-h)/2)
screen:rect(x,u,a.width,h,f.r,f.g,f.b,1)
screen:rect(x+1,u+1,a.width-2,h-2,d.r,d.g,d.b,1)
screen:rect(x+2,u+2,a.width-4,h-4,f.r,f.g,f.b,1)
for N=1,#w do
screen:textCentre(w[N],screen.width/2,u+a.padding+(N-1)*y,d.r,d.g,d.b,1)
end
end

function SpiffBoyHandheldWindow:drawScreen()
local a=self.instance.runtime
if self.instance.transferring then
if getTimestampMs()-self.instance.transferStartMs>=Z.delayMs then
self:frame(a6)
else
self:frame(ao)
end
return
end
if a.crash then
self:frame(ao)
elseif a.game then
a:draw()
elseif self.instance.gameMissing then
self:frame(a4)
end
if self.instance.glitch then
self:frame(a5)
end
if self.instance.linkLost then
self:frame(a7)
end
end

function SpiffBoyHandheldWindow:blinkOn()
return math.floor(getTimestampMs()/aB)%2==0
end

function SpiffBoyHandheldWindow:drawControls()
local a=self.shell
local h=self.textures
local u=self.instance.input.held
local N,O=self.instance.input:axes()
local ap=(O+1)*t+(N+1)
a:sprite(h[af[ap]],k.x-k.size/2,k.y-k.size/2,k.size,k.size)
local w=0
if u.a then
w=1
end
local x=0
if u.b then
x=1
end
a:sprite(h[I.a[w]],C.x-v/2,C.y-z/2,v,z)
a:sprite(h[I.b[x]],D.x-v/2,D.y-z/2,v,z)
local y=0
if u.start then
y=1
end
a:sheet(h[ae],y*p.w,0,p.w,p.h,p.x-p.w/2,p.y-p.h/2)
self:drawLed(self:ledFrame())
end

function SpiffBoyHandheldWindow:ledFrame()
if self.instance.powered then
if self.instance.battery<=az and not self:blinkOn()then
return T
end
return E
end
if self.instance.flickerFrames>0 then
return E
end
return U
end

function SpiffBoyHandheldWindow:drawLed(frame)
self.shell:sheet(self.textures[ab],frame*r.size,0,r.size,r.size,r.x-r.size/2,r.y-r.size/2)
end

local function a8(playerObj)
local a=playerObj:getVehicle()
return a~=nil and(a:isEngineRunning()or a:getBatteryCharge()>0)
end

local function ap(playerObj)
Y:clear()
return playerObj:getActiveLightItems(Y):size()>0
end

function SpiffBoyHandheldWindow:ambientLight(square)
local a=square:getLightLevel(self.playerNum)
if self.playerObj:hasTrait(CharacterTrait.NIGHT_VISION)then
a=a+aF
end
if a8(self.playerObj)or ap(self.playerObj)then
a=math.max(a,aD)
end
return SpiffBoy.clamp(a,0,1)
end

local function a9()
return getGameTime():getWorldAgeHours()*aI
end

function SpiffBoyHandheldWindow:logLight(square)
if not SpiffBoy.isDevBuild()then
return
end
local h=a9()
if h<self.nextLightLogMinutes then
return
end
self.nextLightLogMinutes=h+aH
local a=self.playerObj:getVehicle()
local u="none"
if a then
u="engine "..tostring(a:isEngineRunning()).." battery "..tostring(a:getBatteryCharge())
end
SpiffBoy.log("light "..tostring(self.light).." target "..tostring(self.veilTarget).." veil "..tostring(self.veil).." raw "..tostring(square:getLightLevel(self.playerNum)).." setting "..tostring(SandboxVars.NightDarkness).." room "..tostring(square:isInARoom()).." vehicle "..u.." carried light "..tostring(ap(self.playerObj)).." hour "..tostring(getGameTime():getTimeOfDay()))
end

function SpiffBoyHandheldWindow:measureLight()
local a=self.playerObj:getCurrentSquare()
if not a then
return false
end
local h=self:ambientLight(a)
self.light=h
self.veilTarget=SpiffBoy.clamp((X-h)/(X-aE),0,1)
self:logLight(a)
return true
end

function SpiffBoyHandheldWindow:resetVeil()
if self:measureLight()then
self.veil=self.veilTarget
end
end

function SpiffBoyHandheldWindow:updateVeil()
self:measureLight()
if self.veilTarget==nil then
return
end
if self.veil==nil then
self.veil=self.veilTarget
return
end
self.veil=self.veil+(self.veilTarget-self.veil)*aG
end

function SpiffBoyHandheldWindow:drawVeil()
self:updateVeil()
local a=self.veil
if a==nil or a<=0 then
return
end
local w=self.shell
self:drawSideControlsWith(ai,a)
local u=self.textures[G]
local x=r.x-e.size/2
local h=r.y-e.size/2
local y=x+e.size
local N=h+e.size
w:tintedSheet(u,0,0,q,h,0,0,0,0,0,a)
w:tintedSheet(u,0,N,q,s-N,0,N,0,0,0,a)
w:tintedSheet(u,0,h,x,e.size,0,h,0,0,0,a)
w:tintedSheet(u,y,h,q-y,e.size,y,h,0,0,0,a)
self:drawSlotVeil(a)
self:drawPortsVeil(a)
local O=self:ledFrame()
self:drawLampLight(u,O,a,x,h)
if O~=U then
self:drawLed(O)
end
end

function SpiffBoyHandheldWindow:drawLampLight(face,frame,veil,left,top)
local h=self.shell
local a=0
if frame==E then
a=e.strength*veil^e.curve
elseif frame==T then
a=e.strength*e.dim*veil^e.curve
end
local u=veil*(1-a)
local w=0
if u<1 then
w=1-(1-veil)/(1-u)
end
h:tintedSheet(face,left,top,e.size,e.size,left,top,0,0,0,u)
if w>0 then
h:sprite(self.textures[ac],left,top,e.size,e.size,w)
end
if a>0 then
h:sprite(self.textures[ad],left,top,e.size,e.size,e.red*a/e.strength)
end
end

function SpiffBoyHandheldWindow:drawSideControls()
self:drawSideControlsWith(ah,0)
end

function SpiffBoyHandheldWindow:drawSideControlsWith(paint,veil)
local a=self.shell
local h=i.offY
if self.instance.switchOn then
h=i.onY
end
paint(a,veil,self.textures[aa],i.x-A,h-A,i.w+F+2*A,i.h+2*A)
paint(a,veil,self.textures[ag[self.instance:wheelStep()]],g.x-F,g.y,g.w+F,g.h)
end

function SpiffBoyHandheldWindow:followConsole(current,progress)
self:updateJackMotion(current,progress)
self:updateLinkMotion(current,progress)
self:updateSlotMotion(current,progress)
self:syncWornHeadphones()
self:syncGrips()
end

function SpiffBoyHandheldWindow:drawConsole()
local h=self.shell
local a=self.instance
h.calls=0
self:drawSideControls()
h:sprite(self.textures[G],0,0,q,s)
self:drawSlot()
self:drawPorts()
self:drawGlass()
self:drawScreen()
self:drawControls()
self:drawVeil()
if a.flickerFrames>0 then
a.flickerFrames=a.flickerFrames-1
end
end

local function a()
for u,h in pairs(SpiffBoyHandheldWindow.windows)do
if h.playerObj:getJoypadBind()<0 then
if SpiffBoy.isDevBuild()then
SpiffBoy.log("play window put away by a press the interface did not take")
end
h:putAway()
end
end
end

Events.OnMouseDown.Add(a)
Events.OnRightMouseDown.Add(a)
