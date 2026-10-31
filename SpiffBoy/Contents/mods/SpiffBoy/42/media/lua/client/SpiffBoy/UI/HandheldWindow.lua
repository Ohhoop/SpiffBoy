require"ISUI/ISPanel"
require"SpiffBoy/Core/Core"
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

SpiffBoyHandheldWindow=ISPanel:derive("SpiffBoyHandheldWindow")
SpiffBoyHandheldWindow.windows={}

local ap=SpiffBoyConsoleInstance.ART
local p=384
local q=252
local aq=102
local ar=60
local as=0.5
local at=0.62
local R=24
local j={x=47.5,y=125.5,size=72}
local s=3
local C={x=336,y=157}
local D={x=336,y=95}
local u=40
local z=40
local o={x=192,y=228,w=24,h=8}
local S=4
local T=0
local r={x=30,y=30,size=8}
local E=0
local U=1
local V=2
local g={x=-4,w=4,h=20,onY=41,offY=47,hitMargin=4}
local A=1/4
local F=1
local f={x=p,w=4,h=22,y=43,hitMargin=4}
local W=g.x-g.hitMargin
local au=f.x+f.w+f.hitMargin
local av=SpiffBoyConsoleInstance.VOLUME_STEPS
local aw=2
local ax=0.15
local c=SpiffBoy.Cartridges.SHADES[4]
local e=SpiffBoy.Cartridges.SHADES[1]
local ay={r=132/255,g=146/255,b=138/255}
local az=500
local X=-1
local aA=0
local Y=0.95
local aB=0.135
local aC=0.15
local aD=0.08
local d={size=32,strength=0.6,curve=3,red=0.45,dim=0.5}
local aE=1
local aF=60
local aG=0.95
local aH={width=150,padding=6}
local Z={delayMs=1000,margin=8,barWidth=100,barHeight=7,gap=4}
local _={}
local G="shell"
local aa="power_switch"
local ab="led"
local ac="led_glow_edge"
local ad="led_glow_red"
local ae="button_start"
local aI={x=128,y=0,w=128,h=8}
local b={x=130,y=-3,w=125,h=9,empty="slot_empty",full="slot_cartridge"}
local k={
x=322,
y=q,
zone={x=318,y=232,w=24},
empty={name="jack_empty",w=16,h=3,reach=3},
plugs={
headphones={name="jack_plugged",w=24,h=58,reach=38},
earbuds={name="jack_plugged_earbuds",w=24,h=52,reach=32},
},
slides={
headphones={name="plug_headphones",w=24,h=79,pin=25,dx=0},
earbuds={name="plug_earbuds",w=24,h=73,pin=25,dx=0},
},
}
local m={
x=56,
y=q,
zone={x=55,y=232,w=24},
empty={name="link_empty",w=22,h=3,reach=3},
plugged={name="link_plugged",w=22,h=56,reach=36},
slide={name="plug_link",w=24,h=60,pin=8,dx=-1},
}
local l={travel=40,snap=1,ease=1.5,start=0.10,reach=0.90,gone=0.90}
local aJ="SpiffBoy_PartClick"
local aK="SpiffBoyPlugHeadphonesAction"
local aL="SpiffBoyUnplugHeadphonesAction"
local aM="SpiffBoyPlugCableAction"
local aN="SpiffBoyUnplugCableAction"
local aO="SpiffBoyConnectCableAction"
local aP="SpiffBoyDisconnectCableAction"
local aQ="SpiffBoyInsertCartridgeAction"
local aR=SpiffBoyConsoleInstance.REMOVE_ACTION
local aS=600
local i={
name="cartridge",
x=b.x+3,
w=119,
h=100,
mouth=6,
label={x=11,y=29,w=97,h=53,file="label.png",inset=3},
}
local aT={r=238/255,g=232/255,b=214/255}
local aU={r=52/255,g=44/255,b=60/255}
local H={r=96/255,g=62/255,b=116/255}
local I={}
local J={a={[0]="button_a_0",[1]="button_a_1"},b={[0]="button_b_0",[1]="button_b_1"}}
local K={}
local n={G,b.empty,b.full,i.name,aa,ab,ac,ad,ae,k.empty.name,m.empty.name,m.plugged.name,m.slide.name}

for a=0,s*s-1 do
I[a]="dpad_"..a
n[#n+1]=I[a]
end
for a=0,av do
K[a]="volume_wheel_"..a
n[#n+1]=K[a]
end
for h,a in pairs(J)do
n[#n+1]=a[0]
n[#n+1]=a[1]
end
for t,a in pairs({k.plugs,k.slides})do
for v,h in pairs(a)do
n[#n+1]=h.name
end
end

local function aV(art)
local a={}
for t=1,#n do
local h=n[t]
a[h]=art(h)
end
return a
end

local function L(itemType)
return SpiffBoy.Handheld.HEADPHONES[itemType].kind
end

local function af(shell,veil,texture,x,y,w,h)
shell:sprite(texture,x,y,w,h)
end

local function ag(shell,veil,texture,x,y,w,h)
shell:tinted(texture,x,y,w,h,0,0,0,veil)
end

local function M(shell,veil,texture,sx,sy,w,h,x,y)
shell:sheet(texture,sx,sy,w,h,x,y)
end

local function N(shell,veil,texture,sx,sy,w,h,x,y)
shell:tintedSheet(texture,sx,sy,w,h,x,y,0,0,0,veil)
end

local function aW(window,veil,itemType,x,y)
window:drawCartridgeLabel(itemType,x,y)
end

local function aX(window,veil,itemType,x,y)
local a=i.label
window.shell:rect(x+a.x,y+a.y,a.w,a.h,0,0,0,veil)
end

local function aY(input,action)
input:tap(action)
end

local function aZ(held,action)
held[action]=true
end

local function ah(x,y,centre)
local a=x-centre.x
local h=y-centre.y
local t=u/2
return a*a+h*h<=t*t
end

local function O(x,y,powered)
local a=g.offY
if powered then
a=g.onY
end
if x>=g.x-g.hitMargin and x<g.x+g.w+g.hitMargin and y>=a and y<a+g.h then
return"power"
end
if x>=f.x-f.hitMargin and x<f.x+f.w+f.hitMargin and y>=f.y and y<f.y+f.h then
return"volume"
end
local h=j.size/2
if math.abs(x-j.x)<=h and math.abs(y-j.y)<=h then
return"dpad"
end
if ah(x,y,C)then
return"a"
end
if ah(x,y,D)then
return"b"
end
if math.abs(x-o.x)<=o.w/2+S and math.abs(y-o.y)<=o.h/2+S then
return"start"
end
return nil
end

local function a_(x,y)
local a=j.size/s
local h=j.x-j.size/2
local t=j.y-j.size/2
local v=math.max(0,math.min(s-1,math.floor((x-h)/a)))
local w=math.max(0,math.min(s-1,math.floor((y-t)/a)))
return v-1,w-1
end

local function ai(control,x,y,visitor,target)
if control~="dpad"then
visitor(target,control)
return
end
local a,h=a_(x,y)
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

local function a0(x,y,zone)
return x>=zone.x and x<zone.x+zone.w and y>=zone.y and y<zone.y+zone.h
end

local function B(x,y,port,art)
local a=port.zone
return x>=a.x and x<a.x+a.w and y>=a.y and y<port.y+art.reach
end

local function aj(progress,travel)
if progress<l.start then
return nil
end
local a=math.min(1,(progress-l.start)/(l.reach-l.start))
return l.snap+(travel-l.snap)*(1-a)^l.ease
end

local function ak(progress,travel)
if progress>=l.gone then
return nil
end
return l.snap+(travel-l.snap)*(progress/l.gone)^l.ease
end

local function al(progress,plugging,unplugging,slide)
if plugging then
local a=aj(progress,l.travel)
if a then
return{art=slide,drop=a}
end
return nil
end
if unplugging then
local a=ak(progress,l.travel)
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
local t=a0(a,h,aI)
local v=B(a,h,k,self:jackArt())
local w=B(a,h,m,self:linkArt())
self:traceMouse("right up at "..x..","..y.." shell "..a..","..h.." inside "..tostring(t).." jack "..tostring(v).." link "..tostring(w).." paused "..tostring(isGamePaused()))
if isGamePaused()then
return self:isWantMouseEvents()
end
if v then
self:openJackMenu()
elseif w then
self:openLinkMenu()
elseif t then
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
return self.textures[b.full]
end
return self.textures[b.empty]
end

function SpiffBoyHandheldWindow:paintSlot(paintArea,paintPart,paintLabelOf,veil,rows,bottom)
local h=self.shell
local a=self.slotMotion
if not a then
paintArea(h,veil,self:slotArt(),0,0,b.w,rows,b.x,b.y)
return
end
paintArea(h,veil,self.textures[b.empty],0,0,b.w,rows,b.x,b.y)
if not a.lift then
return
end
local t=b.y-math.floor(a.lift+0.5)
self:clipAbove(t,bottom)
paintPart(h,veil,self.textures[i.name],i.x,t,i.w,i.h)
paintLabelOf(self,veil,a.itemType,i.x,t)
self:clearStencilRect()
end

function SpiffBoyHandheldWindow:drawSlot()
self:paintSlot(M,af,aW,0,b.h,b.y+i.mouth+1)
local a=self.slotMotion
if a and a.lift then
self.shell:rect(i.x+1,b.y+i.mouth,i.w-2,1,H.r,H.g,H.b,1)
end
end

function SpiffBoyHandheldWindow:drawSlotVeil(veil)
self:paintSlot(N,ag,aX,veil,-b.y,0)
end

function SpiffBoyHandheldWindow:cartridgeTravel()
local a=self.shell
local h=math.ceil((self:getY()+a.y)/a.scale)
return b.y+i.h+h
end

function SpiffBoyHandheldWindow:clipAbove(top,bottom)
local h=self.shell
local a=h.scale
self:setStencilRect(h.x+i.x*a,h.y+top*a,i.w*a,(bottom-top)*a)
end

function SpiffBoyHandheldWindow:drawCartridgeLabel(itemType,x,y)
local t=self.shell
local a=i.label
local v,w=x+a.x,y+a.y
local h=itemType and SpiffBoy.Cartridges.get(itemType)
local am=h and h.art and SpiffBoy.Textures.get(h.mod,h.art..a.file,true)
if am then
t:sprite(am,v,w,a.w,a.h)
return
end
local P,Q=aT,aU
t:rect(v,w,a.w,a.h,P.r,P.g,P.b,1)
local an=t:lineHeight()
local a1=h and h.title or getItemNameFromFullType(itemType)
local ao=t:wrapText(a1,a.w-2*a.inset)
local a2=w+math.floor((a.h-#ao*an)/2)
for a3,a4 in ipairs(ao)do
t:textCentre(a4,v+math.floor(a.w/2),a2+(a3-1)*an,Q.r,Q.g,Q.b,1)
end
end

function SpiffBoyHandheldWindow:clickOnRise(flag,condition)
if condition and not self[flag]then
SpiffBoy.Audio.playSound(aJ)
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
local a=(getTimestampMs()-self.pullOutStartMs)/aS
if a>=1 then
self.pullOutStartMs=nil
return nil
end
return a
end

function SpiffBoyHandheldWindow:updateSlotMotion(current,progress)
local a=self.instance.seated~=nil
self:clickOnRise("cartridgeIn",a)
local h=current~=nil and current.Type==aR and a
self:clickOnRise("cartridgeLeaving",h)
self.slotMotion=nil
if current and current.Type==aQ and current.item and not a then
local t=aj(progress,self:cartridgeTravel())
if t then
self.slotMotion={lift=t,itemType=current.item:getFullType()}
end
elseif h then
self.slotMotion={lift=ak(progress,self:cartridgeTravel()),itemType=self.instance.seated.type}
end
end

function SpiffBoyHandheldWindow:updateJackMotion(current,progress)
local a=current~=nil and current.Type==aL and self.instance.headphonesType~=nil
self:clickOnRise("headphonesLeaving",a)
local t=current~=nil and current.Type==aK and SpiffBoy.Handheld.isHeadphones(current.item)
local h=nil
if t then
h=k.slides[L(current.item:getFullType())]
elseif a then
h=k.slides[L(self.instance.headphonesType)]
end
self.jackMotion=al(progress,t,a,h)
end

function SpiffBoyHandheldWindow:updateLinkMotion(current,progress)
local a=current and current.Type
local h=self:pullOutProgress()
local t=((a==aN or a==aP)and self.instance.cableIn)or h~=nil
self:clickOnRise("cableLeaving",t)
local v=(a==aM and SpiffBoy.Handheld.isCable(current.item))or(a==aO and not self.instance.cableIn)
self.linkMotion=al(h or progress,v,t,m.slide)
end

function SpiffBoyHandheldWindow:paintPort(paint,veil,port,motion,art)
local t=self.shell
if not motion then
paint(t,veil,self.textures[art.name],0,0,art.w,art.h,port.x,port.y)
return
end
local h=port.empty
paint(t,veil,self.textures[h.name],0,0,h.w,h.h,port.x,port.y)
local a=motion.art
if not a then
return
end
local w=port.y+h.h
local x=w-(a.pin-1)+math.floor(motion.drop+0.5)
local v=math.max(0,w-x)
paint(t,veil,self.textures[a.name],0,v,a.w,a.h-v,port.x+a.dx,x+v)
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
local t=self.shell
local a=t.scale
grip:setX(self:getX()+t.x+x*a)
grip:setY(self:getY()+t.y+y*a)
grip:setWidth(w*a)
grip:setHeight(h*a)
grip:initialise()
grip:addToUIManager()
grip:setAlwaysOnTop(true)
end

function SpiffBoyHandheldWindow:syncGrips()
local a=not self.closing
self:syncGrip(self.jackGrip,a and self.instance.headphonesType~=nil,k.x,k.y,k.empty.w,self:jackArt().reach)
self:syncGrip(self.linkGrip,a and self.instance.cableIn,m.x,m.y,m.empty.w,self:linkArt().reach)
self:syncGrip(self.cartridgeGrip,a and self.instance.seated~=nil,b.x,b.y,b.w,-b.y)
end

function SpiffBoyHandheldWindow:jackArt()
if self.instance.headphonesType then
return k.plugs[L(self.instance.headphonesType)]
end
return k.empty
end

function SpiffBoyHandheldWindow:linkArt()
if self.instance.cableIn then
return m.plugged
end
return m.empty
end

function SpiffBoyHandheldWindow:drawPorts()
self:paintPort(M,0,k,self.jackMotion,self:jackArt())
self:paintPort(M,0,m,self.linkMotion,self:linkArt())
end

function SpiffBoyHandheldWindow:drawPortsVeil(veil)
self:paintPort(N,veil,k,self.jackMotion,self:jackArt())
self:paintPort(N,veil,m,self.linkMotion,self:linkArt())
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
a.shell=SpiffBoyScreen.new(a,p,q)
a.art=SpiffBoy.Textures.folder(SpiffBoy.MOD_ID,ap)
a.textures=aV(a.art)
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

local function Q(playerNum,right)
local a=UIManager.getMoodleUI(playerNum)
if a and a:isVisible()then
return math.min(right,a:getX())
end
return right
end

local function an(playerNum,left)
local a=getPlayerData(playerNum).equipped
if a and a:isVisible()then
return math.max(left,a:getRight())
end
return left
end

function SpiffBoyHandheldWindow:layoutShell()
local h=self.playerNum
local v,am=getPlayerScreenLeft(h),getPlayerScreenTop(h)
local w,P=getPlayerScreenWidth(h),getPlayerScreenHeight(h)
local a=math.floor(math.min(w*at/p,P*aG/q))
a=math.max(1,a)
local x=p*a
self.position=SpiffBoy.ConsolePosition.get()
local t
if self.position==SpiffBoy.ConsolePosition.LEFT then
t=math.min(v+w-x,an(h,v)+R)
elseif self.position==SpiffBoy.ConsolePosition.CENTRE then
t=v+math.floor((w-x)/2)
else
t=math.max(v,Q(h,v+w)-x-R)
end
local ao=am+math.floor((P-q*a)/2)
local y=t+W*a
self:fitTo(y,ao,(au-W)*a,q*a)
self.shell:setPlacement(t-y,0,a)
self.instance.screen:setPlacement(t-y+aq*a,ar*a,a)
end

function SpiffBoyHandheldWindow:prerender()
if self.closing then
return
end
if getGameSpeed()>1 then
setGameSpeed(1)
end
self:holdZoomIn()
self.instance:step()
end

function SpiffBoyHandheldWindow:holdZoomIn()
local a=getCore()
if a:getNextZoom(self.playerNum,X)~=a:getNextZoom(self.playerNum,aA)then
a:doZoomScroll(self.playerNum,X)
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
local t,v=getPlayerScreenLeft(a),getPlayerScreenWidth(a)
local x=getPlayerScreenTop(a)+getPlayerScreenHeight(a)/2
local w=self:getX()+self.shell.x
local h
if self.position==SpiffBoy.ConsolePosition.LEFT then
h=(w+p*self.shell.scale+Q(a,t+v))/2
elseif self.position==SpiffBoy.ConsolePosition.CENTRE then
h=t+v/2
else
h=(t+w)/2
end
SpiffBoy.CameraShift.begin(self.playerObj,h,x)
end

function SpiffBoyHandheldWindow:isOnFrame(x,y)
local a,h=self.shell:toLocal(x,y)
if a>=0 and a<p and h>=0 and h<q then
return true
end
if B(a,h,k,self:jackArt())or B(a,h,m,self:linkArt())then
return true
end
return O(a,h,self.instance.switchOn)~=nil
end

function SpiffBoyHandheldWindow:onMouseDown(x,y)
if self:putAwayOutsideFrame(x,y)then
return false
end
if isGamePaused()then
return self:isWantMouseEvents()
end
local t,h=self.shell:toLocal(x,y)
local a=O(t,h,self.instance.switchOn)
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
ai(a,t,h,aY,self.instance.input)
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
if not isMouseButtonDown(T)then
self:releaseVolume()
return
end
local v,t=self.shell:toLocal(self:getMouseX(),self:getMouseY())
local h=math.floor((a.startY-t)/aw)
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
if a.startY<f.y+f.h/2 then
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
if not isMouseButtonDown(T)then
self.mouseControl=nil
return
end
local h,t=self.shell:toLocal(self:getMouseX(),self:getMouseY())
ai(a,h,t,aZ,input.held)
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
local h=ay
if self.instance.powered or self.instance.flickerFrames>0 then
h=c
end
local v=a.scale
local t=math.floor(v*as)
self.shell.calls=self.shell.calls+1
self:drawRect(a.x-t,a.y-t,a.width*v+2*t,a.height*v+2*t,1,h.r,h.g,h.b)
end

function SpiffBoyHandheldWindow:onMouseWheel(delta)
if isGamePaused()then
return false
end
local a,h=self.shell:toLocal(self:getMouseX(),self:getMouseY())
if O(a,h,self.instance.switchOn)~="volume"then
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

local function am(window,screen)
screen:clear(c.r,c.g,c.b)
end

local function ao(window,screen)
screen:clear(c.r,c.g,c.b)
local a=screen:lineHeight()
screen:textCentre(getText("UI_SpiffBoy_GameMissing"),screen.width/2,(screen.height-a)/2,e.r,e.g,e.b,1)
end

local function a1(window,screen)
local t=SpiffBoy.Cartridges.SHADES
for v,a in ipairs(window.glitch)do
local h=t[a.shade]
screen:rect(a.x,a.y,a.w,a.h,h.r,h.g,h.b,1)
end
end

local function a2(window,screen)
local a=Z
screen:clear(c.r,c.g,c.b)
local t=screen:lineHeight()
local h=_[screen.width]
if not h then
h=screen:wrapText(getText("UI_SpiffBoy_ReceivingGame"),screen.width-a.margin*2)
_[screen.width]=h
end
local P=#h*t+a.gap+a.barHeight
local x=math.floor((screen.height-P)/2)
for v=1,#h do
screen:textCentre(h[v],screen.width/2,x+(v-1)*t,e.r,e.g,e.b,1)
end
local v=math.floor((screen.width-a.barWidth)/2)
local w=x+#h*t+a.gap
screen:rect(v,w,a.barWidth,a.barHeight,e.r,e.g,e.b,1)
screen:rect(v+1,w+1,a.barWidth-2,a.barHeight-2,c.r,c.g,c.b,1)
local y=math.floor((a.barWidth-4)*window.instance:transferProgress())
if y>0 then
screen:rect(v+2,w+2,y,a.barHeight-4,e.r,e.g,e.b,1)
end
end

local function a3(window,screen)
local a=aH
local x=screen:lineHeight()
local v=screen:wrapText(getText("UI_SpiffBoy_LinkLost"),a.width-a.padding*2)
local h=#v*x+a.padding*2
local w=math.floor((screen.width-a.width)/2)
local t=math.floor((screen.height-h)/2)
screen:rect(w,t,a.width,h,e.r,e.g,e.b,1)
screen:rect(w+1,t+1,a.width-2,h-2,c.r,c.g,c.b,1)
screen:rect(w+2,t+2,a.width-4,h-4,e.r,e.g,e.b,1)
for y=1,#v do
screen:textCentre(v[y],screen.width/2,t+a.padding+(y-1)*x,c.r,c.g,c.b,1)
end
end

function SpiffBoyHandheldWindow:drawScreen()
local a=self.instance.runtime
if self.instance.transferring then
if getTimestampMs()-self.instance.transferStartMs>=Z.delayMs then
self:frame(a2)
else
self:frame(am)
end
return
end
if a.crash then
self:frame(am)
elseif a.game then
a:draw()
elseif self.instance.gameMissing then
self:frame(ao)
end
if self.instance.glitch then
self:frame(a1)
end
if self.instance.linkLost then
self:frame(a3)
end
end

function SpiffBoyHandheldWindow:blinkOn()
return math.floor(getTimestampMs()/az)%2==0
end

function SpiffBoyHandheldWindow:drawControls()
local a=self.shell
local h=self.textures
local t=self.instance.input.held
local y,P=self.instance.input:axes()
local a4=(P+1)*s+(y+1)
a:sprite(h[I[a4]],j.x-j.size/2,j.y-j.size/2,j.size,j.size)
local v=0
if t.a then
v=1
end
local w=0
if t.b then
w=1
end
a:sprite(h[J.a[v]],C.x-u/2,C.y-z/2,u,z)
a:sprite(h[J.b[w]],D.x-u/2,D.y-z/2,u,z)
local x=0
if t.start then
x=1
end
a:sheet(h[ae],x*o.w,0,o.w,o.h,o.x-o.w/2,o.y-o.h/2)
self:drawLed(self:ledFrame())
end

function SpiffBoyHandheldWindow:ledFrame()
if self.instance.powered then
if self.instance.battery<=ax and not self:blinkOn()then
return U
end
return E
end
if self.instance.flickerFrames>0 then
return E
end
return V
end

function SpiffBoyHandheldWindow:drawLed(frame)
self.shell:sheet(self.textures[ab],frame*r.size,0,r.size,r.size,r.x-r.size/2,r.y-r.size/2)
end

function SpiffBoyHandheldWindow:ambientLight(square)
local a=square:getLightLevel(self.playerNum)
if self.playerObj:hasTrait(CharacterTrait.NIGHT_VISION)then
a=a+aC
end
return SpiffBoy.clamp(a,0,1)
end

local function a4()
return getGameTime():getWorldAgeHours()*aF
end

function SpiffBoyHandheldWindow:logLight(square)
if not SpiffBoy.isDevBuild()then
return
end
local a=a4()
if a<self.nextLightLogMinutes then
return
end
self.nextLightLogMinutes=a+aE
SpiffBoy.log("light "..tostring(self.light).." target "..tostring(self.veilTarget).." veil "..tostring(self.veil).." raw "..tostring(square:getLightLevel(self.playerNum)).." setting "..tostring(SandboxVars.NightDarkness).." room "..tostring(square:isInARoom()).." hour "..tostring(getGameTime():getTimeOfDay()))
end

function SpiffBoyHandheldWindow:measureLight()
local a=self.playerObj:getCurrentSquare()
if not a then
return false
end
local h=self:ambientLight(a)
self.light=h
self.veilTarget=SpiffBoy.clamp((Y-h)/(Y-aB),0,1)
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
self.veil=self.veil+(self.veilTarget-self.veil)*aD
end

function SpiffBoyHandheldWindow:drawVeil()
self:updateVeil()
local a=self.veil
if a==nil or a<=0 then
return
end
local v=self.shell
self:drawSideControlsWith(ag,a)
local t=self.textures[G]
local w=r.x-d.size/2
local h=r.y-d.size/2
local x=w+d.size
local y=h+d.size
v:tintedSheet(t,0,0,p,h,0,0,0,0,0,a)
v:tintedSheet(t,0,y,p,q-y,0,y,0,0,0,a)
v:tintedSheet(t,0,h,w,d.size,0,h,0,0,0,a)
v:tintedSheet(t,x,h,p-x,d.size,x,h,0,0,0,a)
self:drawSlotVeil(a)
self:drawPortsVeil(a)
local P=self:ledFrame()
self:drawLampLight(t,P,a,w,h)
if P~=V then
self:drawLed(P)
end
end

function SpiffBoyHandheldWindow:drawLampLight(face,frame,veil,left,top)
local h=self.shell
local a=0
if frame==E then
a=d.strength*veil^d.curve
elseif frame==U then
a=d.strength*d.dim*veil^d.curve
end
local t=veil*(1-a)
local v=0
if t<1 then
v=1-(1-veil)/(1-t)
end
h:tintedSheet(face,left,top,d.size,d.size,left,top,0,0,0,t)
if v>0 then
h:sprite(self.textures[ac],left,top,d.size,d.size,v)
end
if a>0 then
h:sprite(self.textures[ad],left,top,d.size,d.size,d.red*a/d.strength)
end
end

function SpiffBoyHandheldWindow:drawSideControls()
self:drawSideControlsWith(af,0)
end

function SpiffBoyHandheldWindow:drawSideControlsWith(paint,veil)
local a=self.shell
local h=g.offY
if self.instance.switchOn then
h=g.onY
end
paint(a,veil,self.textures[aa],g.x-A,h-A,g.w+F+2*A,g.h+2*A)
paint(a,veil,self.textures[K[self.instance:wheelStep()]],f.x-F,f.y,f.w+F,f.h)
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
h:sprite(self.textures[G],0,0,p,q)
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
for t,h in pairs(SpiffBoyHandheldWindow.windows)do
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
