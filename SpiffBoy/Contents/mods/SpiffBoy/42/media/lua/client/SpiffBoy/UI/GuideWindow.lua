require"ISUI/ISCollapsableWindow"
require"ISUI/ISRichTextPanel"
require"ISUI/ISButton"
require"ISUI/ISTickBox"
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/KeyBinds"
require"SpiffBoy/Core/Input"
require"SpiffBoy/Core/ConsolePosition"
require"SpiffBoy/Core/GuideMemory"
require"SpiffBoy/UI/GuidePicture"

SpiffBoyGuideWindow=ISCollapsableWindow:derive("SpiffBoyGuideWindow")

local c=SpiffBoy.KeyBinds
local g=SpiffBoy.GuideMemory

local e=UIFont.Small
local A=UIFont.Medium
local j=360
local a=10
local k=6
local h=12
local B=24
local C=80
local D=30
local b=0
local p=0.9
local m=" <LINE> "
local E=0.3
local q={"{1}","{2}"}

local function r(id)
return getKeyName(getCore():getKey(id))
end

local function i(id)
return{cap=r(id)}
end

local function s(label,text)
local d=string.match(text,"^%s*(.-)%s*$")
if d~=""then
label[#label+1]={text=d}
end
end

local function t(key,inserts)
local l=getText(key,q[1],q[2])
local d={}
local f=1
while true do
local n,o,u=string.find(l,"{(%d)}",f)
if not n then
break
end
s(d,string.sub(l,f,n-1))
d[#d+1]=inserts[tonumber(u)]
f=o+1
end
s(d,string.sub(l,f))
return d
end

local function f(key,inserts)
return function()
return t(key,inserts)
end
end

local function l(bind)
return function()
return{{text=getText("UI_optionscreen_binding_"..bind.id)},i(bind.id)}
end
end

local function F()
local d=c.BINDS
return{{text=getText("UI_SpiffBoy_Tutorial_Dpad")},i(d.up.id),i(d.left.id),i(d.down.id),i(d.right.id)}
end

local function G()
return t("UI_SpiffBoy_Tutorial_PutAway",{{cap=getKeyName(SpiffBoy.Input.EXIT_KEY)},{mouse="left"}})
end

local u={mouse="left"}
local H={mouse="middle"}
local n={mouse="right"}

local v={
callouts={
{part="slot",side="above",label=f("UI_SpiffBoy_Tutorial_Slot",{n})},
{part="led",side="left",label=f("UI_SpiffBoy_Tutorial_Led",{})},
{part="power",side="left",label=f("UI_SpiffBoy_Tutorial_Power",{u})},
{part="dpad",side="left",label=F},
{part="link",side="left",label=f("UI_SpiffBoy_Tutorial_Link",{n})},
{part="volume",side="right",label=f("UI_SpiffBoy_Tutorial_Volume",{H,u})},
{part="b",side="right",label=l(c.BINDS.b)},
{part="a",side="right",label=l(c.BINDS.a)},
{part="jack",side="right",label=f("UI_SpiffBoy_Tutorial_Jack",{n})},
{part="start",side="below",label=l(c.BINDS.start)},
},
notes={G,l(c.BINDS.resume)},
}

local function w()
local d=getText("UI_mainscreen_option")
return{
{
getText("UI_SpiffBoy_Tutorial_Caption"),
getText("UI_SpiffBoy_Tutorial_KeysCaption",d,getText("UI_optionscreen_keybinding")),
getText("UI_SpiffBoy_Tutorial_PositionCaption",d,getText("UI_mainscreen_mods"),getText("UI_SpiffBoy_ModOptions")),
},
{
getText("UI_SpiffBoy_Tutorial_PressKey",r(c.GUIDE.id)),
},
{
getText("UI_SpiffBoy_Tutorial_Sandbox"),
},
{
getText("UI_SpiffBoy_Tutorial_Thanks"),
},
}
end

local function I()
local o=w()
local d=#o-1
for y,x in ipairs(o)do
d=d+#x
end
return d
end

local function J()
local d={}
for o,x in ipairs(w())do
d[o]=table.concat(x,m)
end
return" <CENTRE> <SIZE:medium> "..table.concat(d,m..m)
end

local function K(label)
return math.max(C,getTextManager():MeasureStringX(e,label)+B)
end

local function L()
local d=getTextManager()
local o=d:getFontHeight(e)+k
return d:getFontHeight(UIFont.Small)+1+I()*d:getFontHeight(A)+3*a+o+k+2*a
end

function SpiffBoyGuideWindow:new(scale)
local d=ISCollapsableWindow.new(self,0,0,j,j)
setmetatable(d,self)
self.__index=self
d.resizable=false
d:setWantKeyEvents(true)
d.title=getText("UI_SpiffBoy_Tutorial_Title")
d.scale=scale
return d
end

function SpiffBoyGuideWindow:createChildren()
ISCollapsableWindow.createChildren(self)
local d=getTextManager():getFontHeight(e)+k
self.picture=SpiffBoyGuidePicture:new(a,self:titleBarHeight()+a,self.scale,v)
self.picture:initialise()
self:addChild(self.picture)
self.caption=ISRichTextPanel:new(0,self.picture:getBottom(),j,0)
self.caption:initialise()
self.caption:setMargins(a,a,a,a)
self.caption.background=false
self:addChild(self.caption)
local o=getText("UI_SpiffBoy_Tutorial_DontShowAgain")
self.showTick=ISTickBox:new(a,0,getTextManager():MeasureStringX(e,o)+D,d,"",self,SpiffBoyGuideWindow.onShowTicked)
self.showTick:setFont(e)
self.showTick:initialise()
self.showTick:addOption(o,nil)
self.showTick:setSelected(1,not g.opensWithConsole())
self:addChild(self.showTick)
local x=getText("UI_btn_close")
self.closeGuideButton=ISButton:new(0,0,K(x),d,x,self,SpiffBoyGuideWindow.close)
self.closeGuideButton:initialise()
self.closeGuideButton:instantiate()
self.closeGuideButton:setFont(e)
self.closeGuideButton:enableCancelColor()
self:addChild(self.closeGuideButton)
self:layout()
end

function SpiffBoyGuideWindow:layout()
local x=self.showTick:getWidth()+h+self.closeGuideButton:getWidth()
local d=math.max(j,self.picture:getWidth(),x)+2*a
self:setWidth(d)
self.picture:setX(math.floor((d-self.picture:getWidth())/2))
self.caption:setY(self.picture:getBottom()+a)
self.caption:setWidth(d)
self.caption.text=J()
self.caption:paginate()
local o=self.caption:getBottom()+k
self.showTick:setY(o)
self.closeGuideButton:setX(d-a-self.closeGuideButton:getWidth())
self.closeGuideButton:setY(o)
self:setHeight(o+self.closeGuideButton:getHeight()+a)
end

function SpiffBoyGuideWindow:prerender()
ISCollapsableWindow.prerender(self)
self:drawRect(a,self.caption:getY(),self:getWidth()-2*a,1,E,1,1,1)
end

function SpiffBoyGuideWindow:onShowTicked(index,selected)
g.setOpensWithConsole(not selected)
end

function SpiffBoyGuideWindow:close()
self:setVisible(false)
self:removeFromUIManager()
if SpiffBoyGuideWindow.instance==self then
SpiffBoyGuideWindow.instance=nil
end
end

function SpiffBoyGuideWindow:onKeyRelease(key)
if key==SpiffBoy.Input.EXIT_KEY then
self:close()
end
end

function SpiffBoyGuideWindow:isKeyConsumed(key)
return key==SpiffBoy.Input.EXIT_KEY
end

local function o(consoleWindow)
return consoleWindow.position==SpiffBoy.ConsolePosition.LEFT
end

local function M(consoleWindow)
local x,y=getPlayerScreenLeft(b),getPlayerScreenWidth(b)
local d=getPlayerScreenHeight(b)*p
if not consoleWindow then
return y*p,d
end
if o(consoleWindow)then
return x+y-consoleWindow:getRight()-2*h,d
end
return consoleWindow:getX()-x-2*h,d
end

function SpiffBoyGuideWindow:placeBeside(consoleWindow)
local d
if o(consoleWindow)then
d=consoleWindow:getRight()+h
else
d=consoleWindow:getX()-h-self:getWidth()
end
local x=consoleWindow:getY()+math.floor((consoleWindow:getHeight()-self:getHeight())/2)
self:placeInside(d,x)
end

function SpiffBoyGuideWindow:placeInMiddle()
local d=getPlayerScreenLeft(b)+math.floor((getPlayerScreenWidth(b)-self:getWidth())/2)
local x=getPlayerScreenTop(b)+math.floor((getPlayerScreenHeight(b)-self:getHeight())/2)
self:placeInside(d,x)
end

function SpiffBoyGuideWindow:placeInside(x,y)
local d,z=getPlayerScreenLeft(b),getPlayerScreenTop(b)
local N=d+getPlayerScreenWidth(b)-self:getWidth()
local O=z+getPlayerScreenHeight(b)-self:getHeight()
self:setX(math.max(d,math.min(x,N)))
self:setY(math.max(z,math.min(y,O)))
end

local function x(consoleWindow)
local y,z=M(consoleWindow)
local N=SpiffBoyGuidePicture.fittingScale(v,y-2*a,z-L())
local d=SpiffBoyGuideWindow:new(N)
d:initialise()
d:addToUIManager()
d:setAlwaysOnTop(true)
SpiffBoyGuideWindow.instance=d
if consoleWindow then
d:placeBeside(consoleWindow)
else
d:placeInMiddle()
end
return d
end

function SpiffBoyGuideWindow.onConsoleShown(consoleWindow)
if SpiffBoyGuideWindow.instance then
SpiffBoyGuideWindow.instance:bringToTop()
return
end
if consoleWindow.playerObj:getJoypadBind()>=0 then
return
end
if not g.opensWithConsole()or g.openedInWorld()then
return
end
g.markOpenedInWorld()
x(consoleWindow)
end

local function d(key)
if not getCore():isKey(c.GUIDE.id,key)or not getSpecificPlayer(b)then
return
end
if SpiffBoyGuideWindow.instance then
SpiffBoyGuideWindow.instance:close()
return
end
x(SpiffBoyHandheldWindow.forPlayer(b))
end

Events.OnKeyStartPressed.Add(d)
