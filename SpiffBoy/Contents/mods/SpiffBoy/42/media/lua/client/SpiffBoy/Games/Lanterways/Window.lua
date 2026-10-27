require"SpiffBoy/Games/Lanterways/Base"

local b=SpiffBoy.Lanterways

local a={}
b.Window=a

local e={1}
local l={1,3}
local j={1,2,3}

a.UI_HEIGHT=16
a.CELLS={
flame1={0,6},flame2={6,6},corner={12,7},
attack={19,14},skill={33,14},item={47,14},guard={61,14},run={75,14},
arrowUp={89,7},arrowDown={96,7},arrowLeft={103,7},arrowRight={110,7},
heart={117,11},bang={128,9},ask={137,9},dots={146,9},note={155,9},
coin={164,8},lampIcon={172,11},bell={183,9},glow={192,10},target={202,9},
statusBlind={211,8},statusSleep={219,8},statusSoot={227,8},statusStun={235,8},
statusUp={243,8},statusDown={251,8},statusRegen={259,8},statusVeil={267,8},statusTaunt={275,8},
elemFlame={283,8},elemSound={291,8},elemMurk={299,8},xp={307,7},
heartSmall={314,7},lampSmall={321,7},slash={328,4},
}
a.ELEMENT_ICONS={flame="elemFlame",sound="elemSound",murk="elemMurk"}
a.ICON_HEIGHTS={
heart=10,lampIcon=10,bang=9,run=13,glow=9,note=8,coin=8,arrowLeft=7,arrowRight=7,arrowUp=4,arrowDown=4,
statusBlind=7,statusSleep=7,statusSoot=7,statusStun=7,statusUp=7,statusDown=7,statusRegen=7,statusVeil=7,statusTaunt=7,
elemFlame=7,elemSound=7,elemMurk=7,
}
a.FIGURE_HEIGHT=7

function a.iconBeside(screen,name,y)
local c=screen:lineHeight()-SpiffBoy.FontData.descent
return y+math.floor(c-a.FIGURE_HEIGHT/2-a.ICON_HEIGHTS[name]/2+0.5)
end

function a.gearIcon(item)
if item.element then
return a.ELEMENT_ICONS[item.element]
elseif item.ward then
return a.ELEMENT_ICONS[item.ward]
elseif item.guard then
return"status"..string.upper(string.sub(item.guard,1,1))..string.sub(item.guard,2)
end
return nil
end
a.LINE=16

function a.text(screen,label,x,y,shade)
local c,d,f=b.shade(shade or b.INK)
screen:text(label,x,y,c,d,f,1)
end

function a.textCentre(screen,label,x,y,shade)
local c,d,f=b.shade(shade or b.INK)
screen:textCentre(label,x,y,c,d,f,1)
end

function a.textRight(screen,label,x,y,shade)
local c,d,f=b.shade(shade or b.INK)
screen:textRight(label,x,y,c,d,f,1)
end

function a.fill(screen,x,y,w,h,shade)
local c,d,f=b.shade(shade)
screen:rect(x,y,w,h,c,d,f,1)
end

function a.icon(screen,ui,name,x,y,shades)
local c=a.CELLS[name]
screen:layers(ui,c[1],c[2],a.UI_HEIGHT,x,y,shades)
end

function a.frame(screen,ui,x,y,w,h)
a.fill(screen,x,y,w,h,b.INK)
a.fill(screen,x+1,y+1,w-2,h-2,b.PAPER)
a.fill(screen,x+2,y+h-3,w-4,1,b.MID)
a.fill(screen,x+2,y+2,1,h-5,b.MID)
if ui then
a.icon(screen,ui,"corner",x-2,y-3,e)
a.icon(screen,ui,"corner",x+w-5,y-3,e)
end
end

function a.cursor(screen,ui,x,y,clock)
if math.floor(clock/8)%2==0 then
a.icon(screen,ui,"flame1",x,y,j)
else
a.icon(screen,ui,"flame2",x,y,j)
end
end

function a.scroll(selected,top,visible,count)
if selected<top then
top=selected
elseif selected>top+visible-1 then
top=selected-visible+1
end
return SpiffBoy.clamp(top,1,math.max(1,count-visible+1))
end

function a.list(screen,ui,rows,x,y,w,visible,selected,top,clock,focused)
local k=#rows
local g=0
if k>visible then
g=a.CELLS.arrowUp[2]+2
end
for h=0,visible-1 do
local c=rows[top+h]
if c then
local d=y+h*a.LINE
local f=b.INK
if c.disabled then
f=b.MID
end
if top+h==selected and focused then
a.fill(screen,x+8,d+1,w-10,a.LINE-2,b.MID)
if c.disabled then
f=b.DARK
end
a.cursor(screen,ui,x,d+4,clock)
end
local i=w-12-g
if c.right then
i=i-screen:textWidth(c.right)-4
a.textRight(screen,c.right,x+w-2-g,d,f)
end
a.text(screen,a.fit(screen,c.label,i),x+10,d,f)
end
end
if top>1 then
a.icon(screen,ui,"arrowUp",x+w-8,y,e)
end
if top+visible-1<k then
a.icon(screen,ui,"arrowDown",x+w-8,y+visible*a.LINE-a.ICON_HEIGHTS.arrowDown,e)
end
end

local function g(lines,perPage,clock)
local c=math.max(1,math.ceil(#lines/perPage))
return math.floor(clock/a.PAGE_TICKS)%c
end

a.PAGE_TICKS=150

function a.paragraph(screen,label,x,y,width,lines,clock,shade)
local c=screen:wrapText(label,width)
local h=g(c,lines,clock)*lines
for d=1,lines do
local f=c[h+d]
if f then
a.text(screen,f,x,y+(d-1)*a.LINE,shade)
end
end
end

function a.pages(screen,ui,pages,x,y,width,clock,shade)
local d={}
for i,c in ipairs(pages)do
local f=width
if c.icon then
f=f-a.CELLS[c.icon][2]-2
end
for k,h in ipairs(screen:wrapText(c.text,f))do
d[#d+1]={text=h,icon=c.icon,shade=c.shade}
end
end
if#d==0 then
return
end
local c=d[g(d,1,clock)+1]
local f=x
if c.icon then
a.icon(screen,ui,c.icon,x,a.iconBeside(screen,c.icon,y),l)
f=x+a.CELLS[c.icon][2]+2
end
a.text(screen,c.text,f,y,c.shade or shade)
end

function a.pair(screen,left,right,x,y,width,clock,leftShade,rightShade)
if screen:textWidth(left)+screen:textWidth(right)+6<=width then
a.text(screen,left,x,y,leftShade)
a.textRight(screen,right,x+width,y,rightShade)
return
end
a.pages(screen,nil,{{text=left,shade=leftShade},{text=right,shade=rightShade}},x,y,width,clock)
end

function a.fit(screen,label,width)
if screen:textWidth(label)<=width then
return label
end
local c=screen:wrapText(label,width-8)
return(c[1]or"").."."
end
