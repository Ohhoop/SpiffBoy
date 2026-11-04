require"ISUI/ISToolTipInv"
require"SpiffBoy/Compat/CompatVersion"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Handheld/ConsoleStatus"
require"SpiffBoy/Handheld/ConsoleInstance"
require"SpiffBoy/Handheld/OpenHandheldAction"

local r=ISToolTipInv.render
require"SpiffBoy/Handheld/ConsoleTooltip"
local s=ISToolTipInv.render
local t=KnoxTheme~=nil
local l=SpiffBoy.Handheld.isConsole

local m="Knox Inventory"
local u={"KnoxInventory","KnoxInventoryBeta"}
local v={
KnoxInventory={{from="0.9.8.7",module="ingame",gap=8}},
KnoxInventoryBeta={{from="1.0-beta",module="tooltips",exposesGap=true}},
}
local w={"on","ensure","fontH","measure","rect","text"}
local z={"window","border","good","warn"}
local A=3
local B=0.31
local C={Large=1.15,Medium=1.05,Small=1}
local D=0.9
local E=8
local F=24
local f=4
local g=16
local G=4
local H=6
local I=0.45
local J=0.97
local K=12
local L=20
local M=6
local N=0.5
local O=0.25

local n=false
local b=nil

local function c(hex)
return{
r=math.floor(hex/65536)/255,
g=math.floor(hex/256)%256/255,
b=hex%256/255,
}
end

local j=c(0x4a4f4f)
local P=c(0xb9b6a8)
local Q=c(0x3c4141)
local R=c(0x262a2a)
local S=c(0xd98a7c)

local function T()
local d=SpiffBoy.CompatVersion
local a=d.activeMod(u)
if a==nil then
SpiffBoy.log(m.." compatibility off: the game runs none of the Knox Inventory mods it knows")
return nil
end
return d.branch(m,a,d.installed(a),v[a])
end

local function U(line)
local a={}
for e,d in ipairs(w)do
if type(KnoxTheme[d])~="function"then
table.insert(a,"KnoxTheme."..d)
end
end
local d=KnoxTheme.color
for h,e in ipairs(z)do
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

local function V(line)
if line.exposesGap then
return KnoxTooltip.GAP
end
return line.gap
end

local function W(tip)
local a=tip.item
if not instanceof(a,"InventoryItem")or not l(a)then
return false
end
return not(ISContextMenu.instance and ISContextMenu.instance.visibleCheck)
end

local function X(console)
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

local function Y()
KnoxTheme.ensure()
local a=C[getCore():getOptionTooltipFont()]
local d=KnoxTheme.cell*B*a
return math.max(E,math.floor(d*D+0.5))
end

local function o()
local a=KnoxTheme.fontH(KnoxTheme.fontText)
return a+A,a
end

local function Z(rows)
local a,d=o()
return 1+b+#rows*a-(a-d)+b
end

local function _(tip,blockH)
local h,a=tip:getX(),tip:getY()
local k=tip:getWidth()
local d=tip:getHeight()+blockH
local p=getCore():getScreenHeight()
a=math.max(0,math.min(a,p-d-1))
local i,e=getMouseX(),getMouseY()
local q=i>=h-f and i<h+k+f
and e>=a-f and e<a+d+f
if q then
if i-k-g>=0 then
h=i-k-g
elseif e-d-g>=0 then
a=e-d-g
else
a=math.min(p-d-1,e+F)
end
end
return h,a
end

local function aa(tip,baseRender)
tip:setStencilRect(0,0,0,0)
baseRender(tip)
tip:clearStencilRect()
end

local function ab(tip,baseRender,x,y)
local a,d=tip.followMouse,tip.anchorBottomLeft
tip.followMouse,tip.anchorBottomLeft=false,nil
tip:setX(x)
tip:setY(y)
baseRender(tip)
tip.followMouse,tip.anchorBottomLeft=a,d
end

local function x(fraction)
if fraction>=N then
return KnoxTheme.color.good
end
if fraction>=O then
return KnoxTheme.color.warn
end
return S
end

local function y(tip,label,fraction,left,top,right)
local a=KnoxTheme
local k=a.fontH(a.fontText)
local d=left+a.measure(a.fontText,label)+K
local e=right-d
if e<L then
return
end
local p=math.max(0,math.min(1,fraction))
local h=math.max(M,math.floor(k/3))
local i=top+math.floor((k-h)/2)
a.rect(tip,d,i,e,h,Q)
a.rect(tip,d+1,i+1,e-2,h-2,R)
local q=math.floor((e-2)*p)
if q>0 then
a.rect(tip,d+1,i+1,q,h-2,x(p))
end
end

local function q(tip,rows,blockH)
local a=KnoxTheme
local d,e=tip:getWidth(),tip:getHeight()
local p=e+blockH
tip:drawRect(G,e+H,d,blockH,I,0,0,0)
a.rect(tip,0,e-1,d,blockH+1,a.color.window,J)
tip:drawRectBorder(0,0,d,p,1,j.r,j.g,j.b)
a.rect(tip,b,e,d-b*2,1,a.color.border)
tip:setHeight(p)
local k=Y()
local ac=o()
local h=e+1+b
for ad,i in ipairs(rows)do
a.text(tip,i.label,k,h,P,a.fontText)
if i.charge then
y(tip,i.label,i.charge,k,h,d-k)
end
h=h+ac
end
end

local function d(tip,baseRender)
if not W(tip)then
baseRender(tip)
return
end
local a=X(tip.item)
local e=Z(a)
aa(tip,baseRender)
local h,i=_(tip,e)
ab(tip,baseRender,h,i)
q(tip,a,e)
end

function ISToolTipInv:render()
if n then
d(self,r)
return
end
s(self)
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

local function e(line)
if not KnoxTheme.on(line.module)then
return
end
local a=U(line)
if#a>0 then
SpiffBoy.log("Knox Inventory compatibility off: this Knox version lacks "..table.concat(a,", "))
return
end
b=V(line)
n=true
if t then
return
end
local i=ISToolTipInv.render
function ISToolTipInv:render()
d(self,i)
end
end

local function i()
if KnoxTheme==nil then
return
end
local a=T()
if a==nil then
return
end
h()
e(a)
end

Events.OnGameStart.Add(i)
