-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"ISUI/ISCollapsableWindow"
require"ISUI/ISButton"
require"ISUI/ISTickBox"
require"ISUI/ISModalDialog"
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Textures"
require"SpiffBoy/Core/ConsolePosition"
require"SpiffBoy/Core/Announcements"
require"SpiffBoy/UI/GuideWindow"

SpiffBoyAnnouncementWindow=ISCollapsableWindow:derive("SpiffBoyAnnouncementWindow")

local c=SpiffBoy.Announcements

local d=UIFont.Small
local p=19
local e=388
local n=212
local q=180
local r=120
local j=2
local b=20
local g=10
local z=24
local A=6
local s=0.95
local k=0
local B=1
local o=0.7
local t=" "
local C=0x0E00
local D={
[0x0E30]=true,[0x0E31]=true,[0x0E32]=true,[0x0E33]=true,[0x0E34]=true,[0x0E35]=true,[0x0E36]=true,[0x0E37]=true,[0x0E38]=true,[0x0E39]=true,[0x0E3A]=true,
[0x0E45]=true,[0x0E46]=true,[0x0E47]=true,[0x0E48]=true,[0x0E49]=true,[0x0E4A]=true,[0x0E4B]=true,[0x0E4C]=true,[0x0E4D]=true,[0x0E4E]=true,
[0x3001]=true,[0x3002]=true,[0xFF01]=true,[0xFF09]=true,[0xFF0C]=true,[0xFF1A]=true,[0xFF1B]=true,[0xFF1F]=true,
[0x300D]=true,[0x300F]=true,[0x0029]=true,[0x0021]=true,[0x003F]=true,[0x002C]=true,[0x002E]=true,
}
local E={
[0x0E40]=true,[0x0E41]=true,[0x0E42]=true,[0x0E43]=true,[0x0E44]=true,
[0x0028]=true,[0xFF08]=true,[0x300C]=true,[0x300E]=true,
}
local F=350
local u=150
local v=40
local G="YES"
local H="https://steamcommunity.com/sharedfiles/filedetails/?id="

local function I()
return math.max(1,math.floor(getTextManager():getFontHeight(d)/p))
end

local function f(text)
return getTextManager():MeasureStringX(d,text)
end

local function J(word)
for a=1,string.len(word)do
if string.byte(word,a)>=C then
return true
end
end
return false
end

local function K(lines,word,width)
for h=1,string.len(word)do
local i=string.sub(word,h,h)
local a=lines[#lines]
if a~=""and f(a..i)>width and not D[string.byte(word,h)]and not E[string.byte(a,string.len(a))]then
lines[#lines+1]=i
else
lines[#lines]=a..i
end
end
end

local function L(text,width)
local a={""}
for h in string.gmatch(text,"[^ ]+")do
local i=a[#a]
local l=h
if i~=""then
l=i..t..h
end
if f(l)<=width then
a[#a]=l
elseif J(h)or f(h)>width then
if i~=""then
a[#a]=i..t
end
K(a,h,width)
else
a[#a+1]=h
end
end
return a
end

function SpiffBoyAnnouncementWindow:new(game,scale)
local a=ISCollapsableWindow.new(self,0,0,e,n)
setmetatable(a,self)
self.__index=self
a.resizable=false
a.title=getText("UI_SpiffBoy_Announce_Title")
a.game=game
a.scale=scale
local h=SpiffBoy.Textures.commonFolder(SpiffBoy.MOD_ID)
a.label=SpiffBoy.Textures.get(h,c.artPath(game,c.LABEL),true)
a.shots={}
for i,l in ipairs(game.shots)do
a.shots[i]=SpiffBoy.Textures.get(h,c.artPath(game,l),true)
end
return a
end

function SpiffBoyAnnouncementWindow:createChildren()
ISCollapsableWindow.createChildren(self)
self.collapseButton:setVisible(false)
self.pinButton:setVisible(false)
local a=getTextManager():getFontHeight(d)+A
self.getButton=ISButton:new(0,0,e,a,getText("UI_SpiffBoy_Announce_Get"),self,SpiffBoyAnnouncementWindow.onGet)
self.getButton:initialise()
self.getButton:instantiate()
self.getButton:setFont(d)
self.getButton:enableAcceptColor()
self:addChild(self.getButton)
self.laterButton=ISButton:new(0,0,e,a,getText("UI_SpiffBoy_Announce_Later"),self,SpiffBoyAnnouncementWindow.close)
self.laterButton:initialise()
self.laterButton:instantiate()
self.laterButton:setFont(d)
self:addChild(self.laterButton)
self.muteTick=ISTickBox:new(0,0,e,a,"",self,SpiffBoyAnnouncementWindow.onMuteTicked)
self.muteTick:setFont(d)
self.muteTick:initialise()
self.muteTick:addOption(getText("UI_SpiffBoy_Announce_Mute"),nil)
self.muteTick:setWidthToFit()
self.muteTick:setSelected(1,not c.isOn())
self:addChild(self.muteTick)
self:layout()
end

function SpiffBoyAnnouncementWindow:columnWidth()
local a=math.max(f(self.getButton.title),f(self.laterButton.title))+z
local h=math.floor(e*getTextManager():getFontHeight(d)/p)
return math.max(h,e*self.scale,a,self.muteTick:getWidth())
end

function SpiffBoyAnnouncementWindow:addLines(text,y,width,shade)
local a=getTextManager():getFontHeight(d)
for i,h in ipairs(L(text,width))do
self.lines[#self.lines+1]={text=h,y=y,shade=shade}
y=y+a
end
return y
end

function SpiffBoyAnnouncementWindow:layout()
local l=self.scale
local h=self:columnWidth()
local i=self:titleBarHeight()+b
local x,y=q*j*l,r*j*l
local w=#self.shots*y+(#self.shots-1)*g
self.labelX=b+math.floor((h-e*l)/2)
self.labelY=i
self.lines={}
local a=i+n*l+g
a=self:addLines(getText(c.textKey(self.game,"Genre")),a,h,B)
a=self:addLines(getText(c.textKey(self.game,"Pitch")),a,h,o)+g
for M,m in ipairs({self.getButton,self.laterButton})do
m:setX(b)
m:setY(a)
m:setWidth(h)
a=m:getBottom()+g
end
a=self:addLines(getText("UI_SpiffBoy_Announce_Once"),a,h,o)+g
a=self:addLines(getText("UI_SpiffBoy_Announce_Trailer"),a,h,o)+g
local m=math.max(a,i+w-self.muteTick:getHeight())
self.muteTick:setX(b)
self.muteTick:setY(m)
self.shotsX=b+h+b
self.shotsY=i
local M=self.shotsX+x+b
local N=f(self.title)+2*self:titleBarHeight()+2*b
self:setWidth(math.max(M,N))
self:setHeight(math.max(m+self.muteTick:getHeight(),i+w)+b)
end

function SpiffBoyAnnouncementWindow:render()
ISCollapsableWindow.render(self)
local h=self.scale
for i,a in ipairs(self.lines)do
self:drawText(a.text,b,a.y,a.shade,a.shade,a.shade,1,d)
end
if self.label then
self:drawTextureScaled(self.label,self.labelX,self.labelY,e*h,n*h,1,1,1,1)
end
local i,a=q*j*h,r*j*h
for l,m in ipairs(self.shots)do
self:drawTextureScaled(m,self.shotsX,self.shotsY+(l-1)*(a+g),i,a,1,1,1,1)
end
end

function SpiffBoyAnnouncementWindow:onGet()
if isSteamOverlayEnabled()then
activateSteamOverlayToWorkshopItem(self.game.workshop)
else
openUrl(H..self.game.workshop)
end
self:close()
end

function SpiffBoyAnnouncementWindow:onMuteTicked(index,selected)
if not selected then
c.setOn(true)
return
end
local i=getText("UI_SpiffBoy_Announce_MuteAsk").."\n"..getText("UI_SpiffBoy_Announce_MuteOnce")
local h=math.max(F,f(getText("UI_SpiffBoy_Announce_MuteAsk"))+v,f(getText("UI_SpiffBoy_Announce_MuteOnce"))+v)
local l=self:getX()+math.floor((self:getWidth()-h)/2)
local m=self:getY()+math.floor((self:getHeight()-u)/2)
local a=ISModalDialog:new(l,m,h,u,i,true,self,SpiffBoyAnnouncementWindow.onMuteAnswered)
a:initialise()
a:addToUIManager()
a:setAlwaysOnTop(true)
a.moveWithMouse=true
end

function SpiffBoyAnnouncementWindow:onMuteAnswered(button)
if button.internal==G then
c.setOn(false)
return
end
self.muteTick:setSelected(1,false)
end

function SpiffBoyAnnouncementWindow:close()
self:setVisible(false)
self:removeFromUIManager()
if SpiffBoyAnnouncementWindow.instance==self then
SpiffBoyAnnouncementWindow.instance=nil
end
end

function SpiffBoyAnnouncementWindow:placeInside(x,y,left,top,width,height)
self:setX(math.max(left,math.min(x,left+width-self:getWidth())))
self:setY(math.max(top,math.min(y,top+height-self:getHeight())))
end

function SpiffBoyAnnouncementWindow.open(game,left,top,width,height)
local a=SpiffBoyAnnouncementWindow:new(game,I())
a:initialise()
a:addToUIManager()
while a.scale>1 and(a:getWidth()>width*s or a:getHeight()>height*s)do
a.scale=a.scale-1
a:layout()
end
a:setAlwaysOnTop(true)
a:placeInside(left+math.floor((width-a:getWidth())/2),top+math.floor((height-a:getHeight())/2),left,top,width,height)
SpiffBoyAnnouncementWindow.instance=a
return a
end

local function h(left,top,width,height)
if SpiffBoyAnnouncementWindow.instance then
return nil
end
local a=c.pending()
if not a then
return nil
end
c.markSeen(a)
return SpiffBoyAnnouncementWindow.open(a,left,top,width,height)
end

local function y()
local a=getCore()
h(0,0,a:getScreenWidth(),a:getScreenHeight())
end

function SpiffBoyAnnouncementWindow.onConsoleShown(consoleWindow)
if SpiffBoyGuideWindow.instance or consoleWindow.playerObj:getJoypadBind()>=0 then
return
end
local i,l=getPlayerScreenLeft(k),getPlayerScreenTop(k)
local m,w=getPlayerScreenWidth(k),getPlayerScreenHeight(k)
local a=h(i,l,m,w)
if not a then
return
end
local x=consoleWindow:getX()-b-a:getWidth()
if consoleWindow.position==SpiffBoy.ConsolePosition.LEFT then
x=consoleWindow:getRight()+b
end
a:placeInside(x,a:getY(),i,l,m,w)
end

Events.OnMainMenuEnter.Add(y)
