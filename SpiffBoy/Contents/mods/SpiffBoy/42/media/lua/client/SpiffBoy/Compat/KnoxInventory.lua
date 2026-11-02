require"ISUI/ISToolTipInv"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Handheld/ConsoleStatus"
require"SpiffBoy/Handheld/ConsoleInstance"
require"SpiffBoy/Handheld/OpenHandheldAction"

local q=ISToolTipInv.render
require"SpiffBoy/Handheld/ConsoleTooltip"
local r=ISToolTipInv.render
local s=KnoxTheme~=nil
local l=SpiffBoy.Handheld.isConsole

local t={
{module="tooltips",exposesGap=true},
{module="ingame",gap=8},
}
local u={"on","ensure","fontH","measure","rect","text"}
local v={"window","border","good","warn"}
local w=3
local z=0.31
local A={Large=1.15,Medium=1.05,Small=1}
local B=0.9
local C=8
local D=24
local f=4
local g=16
local E=4
local F=6
local G=0.45
local H=0.97
local I=12
local J=20
local K=6
local L=0.5
local M=0.25

local m=false
local b=nil

local function c(hex)
return{
r=math.floor(hex/65536)/255,
g=math.floor(hex/256)%256/255,
b=hex%256/255,
}
end

local j=c(0x4a4f4f)
local N=c(0xb9b6a8)
local O=c(0x3c4141)
local P=c(0x262a2a)
local Q=c(0xd98a7c)

local function R()
local a=KnoxTheme.modules
if type(a)~="table"then
return nil
end
for e,d in ipairs(t)do
if a[d.module]~=nil then
return d
end
end
return nil
end

local function S(line)
local a={}
for e,d in ipairs(u)do
if type(KnoxTheme[d])~="function"then
table.insert(a,"KnoxTheme."..d)
end
end
local d=KnoxTheme.color
for h,e in ipairs(v)do
if type(d)~="table"or type(d[e])~="table"then
table.insert(a,"KnoxTheme.color."..e)
end
end
if line.exposesGap and(KnoxTooltip==nil or type(KnoxTooltip.GAP)~="number")then
table.insert(a,"KnoxTooltip.GAP")
end
if#a>0 then
return a
end
KnoxTheme.ensure()
if type(KnoxTheme.cell)~="number"then
table.insert(a,"KnoxTheme.cell")
end
if KnoxTheme.fontText==nil then
table.insert(a,"KnoxTheme.fontText")
end
return a
end

local function T(line)
if line.exposesGap then
return KnoxTooltip.GAP
end
return line.gap
end

local function U(tip)
local a=tip.item
if not instanceof(a,"InventoryItem")or not l(a)then
return false
end
return not(ISContextMenu.instance and ISContextMenu.instance.visibleCheck)
end

local function V(console)
local a=SpiffBoy.Handheld
local d={{label=getText("IGUI_invpanel_Remaining")..": ",charge=SpiffBoy.ConsoleStatus.charge(console)}}
local e=a.getHeadphones(console)
if e then
local h=a.getHeadphonesName(console)or getItemNameFromFullType(e)
table.insert(d,{label=getText("UI_SpiffBoy_HeadphonesPlugged",h)})
end
if a.hasCable(console)then
table.insert(d,{label=getText("UI_SpiffBoy_CablePlugged")})
end
return d
end

local function W()
KnoxTheme.ensure()
local a=A[getCore():getOptionTooltipFont()]
local d=KnoxTheme.cell*z*a
return math.max(C,math.floor(d*B+0.5))
end

local function n()
local a=KnoxTheme.fontH(KnoxTheme.fontText)
return a+w,a
end

local function X(rows)
local a,d=n()
return 1+b+#rows*a-(a-d)+b
end

local function Y(tip,blockH)
local h,a=tip:getX(),tip:getY()
local k=tip:getWidth()
local d=tip:getHeight()+blockH
local o=getCore():getScreenHeight()
a=math.max(0,math.min(a,o-d-1))
local i,e=getMouseX(),getMouseY()
local p=i>=h-f and i<h+k+f
and e>=a-f and e<a+d+f
if p then
if i-k-g>=0 then
h=i-k-g
elseif e-d-g>=0 then
a=e-d-g
else
a=math.min(o-d-1,e+D)
end
end
return h,a
end

local function Z(tip,baseRender)
tip:setStencilRect(0,0,0,0)
baseRender(tip)
tip:clearStencilRect()
end

local function _(tip,baseRender,x,y)
local a,d=tip.followMouse,tip.anchorBottomLeft
tip.followMouse,tip.anchorBottomLeft=false,nil
tip:setX(x)
tip:setY(y)
baseRender(tip)
tip.followMouse,tip.anchorBottomLeft=a,d
end

local function x(fraction)
if fraction>=L then
return KnoxTheme.color.good
end
if fraction>=M then
return KnoxTheme.color.warn
end
return Q
end

local function y(tip,label,fraction,left,top,right)
local a=KnoxTheme
local k=a.fontH(a.fontText)
local d=left+a.measure(a.fontText,label)+I
local e=right-d
if e<J then
return
end
local o=math.max(0,math.min(1,fraction))
local h=math.max(K,math.floor(k/3))
local i=top+math.floor((k-h)/2)
a.rect(tip,d,i,e,h,O)
a.rect(tip,d+1,i+1,e-2,h-2,P)
local p=math.floor((e-2)*o)
if p>0 then
a.rect(tip,d+1,i+1,p,h-2,x(o))
end
end

local function p(tip,rows,blockH)
local a=KnoxTheme
local d,e=tip:getWidth(),tip:getHeight()
local o=e+blockH
tip:drawRect(E,e+F,d,blockH,G,0,0,0)
a.rect(tip,0,e-1,d,blockH+1,a.color.window,H)
tip:drawRectBorder(0,0,d,o,1,j.r,j.g,j.b)
a.rect(tip,b,e,d-b*2,1,a.color.border)
tip:setHeight(o)
local k=W()
local aa=n()
local h=e+1+b
for ab,i in ipairs(rows)do
a.text(tip,i.label,k,h,N,a.fontText)
if i.charge then
y(tip,i.label,i.charge,k,h,d-k)
end
h=h+aa
end
end

local function d(tip,baseRender)
if not U(tip)then
baseRender(tip)
return
end
local a=V(tip.item)
local e=X(a)
Z(tip,baseRender)
local h,i=Y(tip,e)
_(tip,baseRender,h,i)
p(tip,a,e)
end

function ISToolTipInv:render()
if m then
d(self,q)
return
end
r(self)
end

local function h()
if KnoxGridView==nil then
return
end
local e=KnoxGridView.onDoubleClick
if type(e)~="function"then
SpiffBoy.log("Knox Inventory compatibility: this Knox version lacks KnoxGridView.onDoubleClick")
return
end
function KnoxGridView:onDoubleClick(entity)
local a=entity.item
if not(instanceof(a,"InventoryItem")and l(a)and a:isInPlayerInventory())then
e(self,entity)
return
end
if SpiffBoyConsoleInstance.playability(a,self.playerNum)==nil then
SpiffBoyOpenHandheldAction.playFor(getSpecificPlayer(self.playerNum),a)
end
end
end

local function i()
if KnoxTheme==nil then
return
end
local a=R()
if a==nil then
SpiffBoy.log("Knox Inventory compatibility off: this Knox version has no known tooltip module")
return
end
if not KnoxTheme.on(a.module)then
return
end
local e=S(a)
if#e>0 then
SpiffBoy.log("Knox Inventory compatibility off: this Knox version lacks "..table.concat(e,", "))
return
end
b=T(a)
m=true
if s then
return
end
local k=ISToolTipInv.render
function ISToolTipInv:render()
d(self,k)
end
end

Events.OnGameStart.Add(h)
Events.OnGameStart.Add(i)
