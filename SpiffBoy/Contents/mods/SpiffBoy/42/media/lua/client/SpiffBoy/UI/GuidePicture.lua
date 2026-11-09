-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"ISUI/ISUIElement"
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Textures"
require"SpiffBoy/Core/Runtime"
require"SpiffBoy/Framework/Cartridges"
require"SpiffBoy/Handheld/BootScreen"
require"SpiffBoy/UI/ShellLayout"

SpiffBoyGuidePicture=ISUIElement:derive("SpiffBoyGuidePicture")

local c=SpiffBoy.ShellLayout

local k=UIFont.Medium
local d={r=1,g=0.15,b=0.15}
local j={pad=3,thickness=2}
local e={length=36,thickness=2}
local f={padding=4,back=0.85,border=0.9}
local m={width=0.7,buttons=0.42,wheel=0.16}
local g={gap=6,rowGap=8}
local E=6
local s=SpiffBoy.Cartridges.SHADES[4]
local z=c.VOLUME_FRAMES[math.floor(c.VOLUME_STEPS/2)]
local F={
c.SHELL_ART,
c.POWER_SWITCH_ART,
c.LED_ART,
c.BUTTON_START_ART,
c.SLOT.empty,
c.JACK.empty.name,
c.LINK.empty.name,
c.DPAD_FRAMES[c.DPAD_REST],
c.BUTTON_FRAMES.a[0],
c.BUTTON_FRAMES.b[0],
z,
}

local function i()
return getTextManager():getFontHeight(k)+2*f.padding
end

local function A(segment)
if segment.cap then
return getTextManager():MeasureStringX(k,segment.cap)+2*f.padding
elseif segment.mouse then
return math.floor(i()*m.width)
end
return getTextManager():MeasureStringX(k,segment.text)
end

local function n(segments)
local a=0
for b,h in ipairs(segments)do
if b>1 then
a=a+g.gap
end
a=a+A(h)
end
return a
end

local function B(page,side)
local a=0
for h,b in ipairs(page.callouts)do
if b.side==side then
a=math.max(a,n(b.label()))
end
end
return a
end

local function G(page,side)
for b,a in ipairs(page.callouts)do
if a.side==side then
return true
end
end
return false
end

local function t(scale)
return E*scale+j.pad+j.thickness
end

local function C()
return e.length+i()+g.rowGap
end

local function D(scale,page)
local a=t(scale)
local h=B(page,"left")
local p=B(page,"right")
local l=h+g.gap+e.length+a
local b=a
if G(page,"above")then
b=b+C()
end
local o=b+c.SHELL_HEIGHT*scale+a
local q=l+c.SHELL_WIDTH*scale+a+e.length+g.gap+p
local r=o+C()+#page.notes*(i()+g.rowGap)
return{left=h,shellX=l,shellY=b,belowY=o,width=q,height=r}
end

function SpiffBoyGuidePicture.fittingScale(page,width,height)
local a=1
while true do
local b=D(a+1,page)
if b.width>width or b.height>height then
return a
end
a=a+1
end
end

function SpiffBoyGuidePicture:new(x,y,scale,page)
local b=D(scale,page)
local a=ISUIElement.new(self,x,y,b.width,b.height)
setmetatable(a,self)
self.__index=self
a.scale=scale
a.page=page
a.left=b.left
a.shellX=b.shellX
a.shellY=b.shellY
a.belowY=b.belowY
a.textures={}
local l=SpiffBoy.Textures.folder(SpiffBoy.MOD_ID,c.ART)
for o,h in ipairs(F)do
a.textures[h]=l(h)
end
a.screen=SpiffBoyScreen.new(a,c.SCREEN_WIDTH,c.SCREEN_HEIGHT)
a.screen:setPalette(SpiffBoy.Cartridges.SHADES)
a.screen:setPlacement(b.shellX+c.SCREEN_X*scale,b.shellY+c.SCREEN_Y*scale,scale)
a.boot=SpiffBoyBootScreen.landed(SpiffBoy.Textures.folder(SpiffBoy.MOD_ID,c.ART,true)(c.BOOT_LOGO))
return a
end

function SpiffBoyGuidePicture:toPicture(x,y)
return self.shellX+x*self.scale,self.shellY+y*self.scale
end

function SpiffBoyGuidePicture:partInPicture(part)
local a,b,h,l=c.partRect(part)
local o,p=self:toPicture(a,b)
return o,p,h*self.scale,l*self.scale
end

function SpiffBoyGuidePicture:drawShellTexture(name,x,y,w,h)
local a,b=self:toPicture(x,y)
self:drawTextureScaled(self.textures[name],a,b,w*self.scale,h*self.scale,1,1,1,1)
end

function SpiffBoyGuidePicture:drawShellSheet(name,sx,sy,sw,sh,x,y)
local a,b=self:toPicture(x,y)
self:drawSubTexture(self.textures[name],sx,sy,sw,sh,a,b,sw*self.scale,sh*self.scale,1,1,1,1)
end

local function H()
if math.floor(getTimestampMs()/c.BLINK_MS)%2==0 then
return c.LED_LIT
end
return c.LED_DIM
end

function SpiffBoyGuidePicture:drawShell()
local u=self.scale
local o,p,q,v=c.POWER,c.VOLUME,c.CRISP_BORDER,c.SIDE_TUCK
self:drawShellTexture(c.POWER_SWITCH_ART,o.x-q,o.onY-q,o.w+v+2*q,o.h+2*q)
self:drawShellTexture(z,p.x-v,p.y,p.w+v,p.h)
self:drawShellTexture(c.SHELL_ART,0,0,c.SHELL_WIDTH,c.SHELL_HEIGHT)
local l=c.SLOT
self:drawShellSheet(l.empty,0,0,l.w,l.h,l.x,l.y)
for h,a in ipairs({c.JACK,c.LINK})do
local b=a.empty
self:drawShellSheet(b.name,0,0,b.w,b.h,a.x,a.y)
end
local b=self.screen
local r=math.floor(u*c.GLASS_BORDER)
self:drawRect(b.x-r,b.y-r,b.width*u+2*r,b.height*u+2*r,1,s.r,s.g,s.b)
b.calls=0
self.boot:draw(b)
for J,a in ipairs({"dpad","a","b"})do
local w,x,y,I=c.partRect(a)
local h=c.DPAD_FRAMES[c.DPAD_REST]
if a~="dpad"then
h=c.BUTTON_FRAMES[a][0]
end
self:drawShellTexture(h,w,x,y,I)
end
local h=c.START
self:drawShellSheet(c.BUTTON_START_ART,0,0,h.w,h.h,h.x-h.w/2,h.y-h.h/2)
local a=c.LED
self:drawShellSheet(c.LED_ART,H()*a.size,0,a.size,a.size,a.x-a.size/2,a.y-a.size/2)
end

function SpiffBoyGuidePicture:drawMark(x,y,w,h)
for b=0,j.thickness-1 do
local a=j.pad+b
self:drawRectBorder(x-a,y-a,w+2*a,h+2*a,1,d.r,d.g,d.b)
end
local a=j.pad+j.thickness
return x-a,y-a,w+2*a,h+2*a
end

function SpiffBoyGuidePicture:drawLine(x1,y1,x2,y2)
local a=e.thickness/2
self:drawRect(math.min(x1,x2)-a,math.min(y1,y2)-a,math.abs(x2-x1)+e.thickness,math.abs(y2-y1)+e.thickness,1,d.r,d.g,d.b)
end

function SpiffBoyGuidePicture:drawMouse(button,x,y,height)
local a=math.floor(height*m.width)
local b=math.floor(height*m.buttons)
local h=math.floor(a/2)
self:drawRect(x,y,a,height,f.back,0,0,0)
if button=="left"then
self:drawRect(x,y,h,b,1,d.r,d.g,d.b)
elseif button=="right"then
self:drawRect(x+h,y,a-h,b,1,d.r,d.g,d.b)
elseif button~="middle"then
error("SpiffBoy: a mouse has no button "..tostring(button))
end
self:drawRectBorder(x,y,a,height,f.border,1,1,1)
self:drawRect(x,y+b,a,1,f.border,1,1,1)
self:drawRect(x+h,y,1,b,f.border,1,1,1)
local l=math.max(2,math.floor(a*m.wheel))
local o=math.floor(b*0.6)
local p=x+h-math.floor(l/2)
local q=y+math.floor((b-o)/2)
if button=="middle"then
self:drawRect(p,q,l,o,1,d.r,d.g,d.b)
else
self:drawRect(p,q,l,o,f.border,1,1,1)
end
end

function SpiffBoyGuidePicture:drawLabel(segments,x,centreY)
local h=i()
local b=centreY-h/2
for o,a in ipairs(segments)do
local l=A(a)
if a.cap then
self:drawRect(x,b,l,h,f.back,0,0,0)
self:drawRectBorder(x,b,l,h,f.border,1,1,1)
self:drawText(a.cap,x+f.padding,b+f.padding,1,1,1,1,k)
elseif a.mouse then
self:drawMouse(a.mouse,x,b,h)
else
self:drawText(a.text,x,b+f.padding,1,1,1,1,k)
end
x=x+l+g.gap
end
end

local function u(entries)
table.sort(entries,function(a,b)
return a.y<b.y
end)
local h=i()+g.rowGap
for b,a in ipairs(entries)do
a.row=a.y
if b>1 then
a.row=math.max(a.y,entries[b-1].row+h)
end
end
return entries
end

function SpiffBoyGuidePicture:drawSide(side)
local l={}
for q,a in ipairs(self.page.callouts)do
if a.side==side then
local b,h,o,p=self:drawMark(self:partInPicture(a.part))
l[#l+1]={x=b,w=o,y=h+p/2,label=a.label()}
end
end
local b=self.left+g.gap
local h=b+e.length/2
if side=="right"then
b=self.shellX+c.SHELL_WIDTH*self.scale+t(self.scale)+e.length
h=b-e.length/2
end
for p,a in ipairs(u(l))do
local o=a.x
if side=="right"then
o=a.x+a.w
end
self:drawLine(o,a.y,h,a.y)
self:drawLine(h,a.y,h,a.row)
self:drawLine(h,a.row,b,a.row)
if side=="left"then
self:drawLabel(a.label,self.left-n(a.label),a.row)
else
self:drawLabel(a.label,b+g.gap,a.row)
end
end
end

function SpiffBoyGuidePicture:drawEnds()
local b=i()/2
for y,a in ipairs(self.page.callouts)do
if a.side=="above"or a.side=="below"then
local v,o,w,x=self:drawMark(self:partInPicture(a.part))
local l=v+w/2
local p=a.label()
local h=self.shellY-t(self.scale)-e.length-b
local q=o
if a.side=="below"then
h=self.belowY+e.length+b
q=o+x
end
local r=h+b
if a.side=="below"then
r=h-b
end
self:drawLine(l,q,l,r)
self:drawLabel(p,l-n(p)/2,h)
end
end
end

function SpiffBoyGuidePicture:drawNotes()
local b=i()+g.rowGap
local h=self.belowY+e.length+i()/2
for l,o in ipairs(self.page.notes)do
local a=o()
self:drawLabel(a,(self.width-n(a))/2,h+l*b)
end
end

function SpiffBoyGuidePicture:render()
self:drawShell()
self:drawSide("left")
self:drawSide("right")
self:drawEnds()
self:drawNotes()
end
