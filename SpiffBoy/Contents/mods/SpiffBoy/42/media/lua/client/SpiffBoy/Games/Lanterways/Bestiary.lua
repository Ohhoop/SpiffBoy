require"SpiffBoy/Games/Lanterways/Base"
require"SpiffBoy/Games/Lanterways/Window"
require"SpiffBoy/Games/Lanterways/Class"

local e=SpiffBoyLanterwaysGame
local a=SpiffBoy.Lanterways
local b=a.Window
local f=a.Party
local h=a.Enemies

local n=3
local s={"atk","def","mag","res"}
local k=1.2
local l=0.8
local t={1,2,3,4}
local g="???"

local function c(index)
return 2+(index-1)*b.LINE
end

function e:bestiaryEnemy(enemyId)
return h.get(enemyId,f.enemyBonus(self.state))
end

function e:bestiaryElementText(enemyId,fact)
local d=fact=="weak"and"Weak"or"Resist"
if not f.knows(self.state,enemyId,fact)then
return a.text(d.."Unknown")
end
local i=self:bestiaryEnemy(enemyId)[fact]
if not i then
return a.text(d.."None")
end
return a.text(d.."_"..i)
end

function e:bestiarySpoilText(enemyId,fact)
local d=fact=="drop"and"BestiaryDrop"or"BestiaryRare"
if not f.knows(self.state,enemyId,fact)then
return a.text(d,g)
end
local i=self:bestiaryEnemy(enemyId)[fact]
if not i then
return a.text(d,a.text("BestiaryNone"))
end
return a.text(d,a.text("Item_"..i[1]))
end

function e:bestiaryLeanings(enemyId)
local i=h.LIST[enemyId]
local d={}
for o,j in ipairs(s)do
local m=i[j]or 1
if m>=k then
d[#d+1]=a.text("LeanHigh",a.text("Stat_"..j))
elseif m<=l then
d[#d+1]=a.text("LeanLow",a.text("Stat_"..j))
end
end
local j=i.spd or 1
if j>=k then
d[#d+1]=a.text("LeanFast")
elseif j<=l then
d[#d+1]=a.text("LeanSlow")
end
local m=i.hp or 1
if m>=k then
d[#d+1]=a.text("LeanTough")
elseif m<=l then
d[#d+1]=a.text("LeanFrail")
end
if#d==0 then
return a.text("LeanEven")
end
return table.concat(d,", ")
end

function e:bestiaryTechniques(enemyId)
local i=h.techniques(enemyId)
if#i==0 then
return a.text("BestiaryAttacksOnly")
end
local d={}
for j,m in ipairs(i)do
if f.knows(self.state,enemyId,"act",m)then
d[j]=a.text("Skill_"..m)
else
d[j]=g
end
end
return table.concat(d,", ")
end

function e:openBestiaryCard()
local d=self.menu
d.screen="bestiaryCard"
d.cardPage=1
end

function e:tickBestiaryCard(pressed)
local d=self.menu
local i=a.horizontalStep(pressed)
if i~=0 then
d.cardPage=a.wrap(d.cardPage+i,n)
self:effect("cursor")
end
if pressed.a or pressed.b then
d.screen="bestiary"
self:effect("cancel")
end
end

function e:drawBestiaryFight(screen,enemyId)
local j=self:bestiaryEnemy(enemyId)
local m=h.SIZES[j.size]
local o=a.WIDTH-6-m[1]
screen:layers(self:art("enemy_"..enemyId),0,m[1],m[2],o,c(2),t)
local d=6
local i=o-d-4
local p=g
if f.knows(self.state,enemyId,"level")then
p=tostring(j.level)
end
local q=g
if f.knows(self.state,enemyId,"hp")then
q=tostring(j.hp)
end
local r=g
if f.knows(self.state,enemyId,"leanings")then
r=self:bestiaryLeanings(enemyId)
end
b.pages(screen,self.artUi,{{text=a.text("Level").." "..p}},d,c(2),i,self.clock)
b.pages(screen,self.artUi,{{text=a.text("BestiaryHp",q)}},d,c(3),i,self.clock)
b.pages(screen,self.artUi,{{text=self:bestiaryElementText(enemyId,"weak")}},d,c(4),i,self.clock)
b.pages(screen,self.artUi,{{text=self:bestiaryElementText(enemyId,"resist")}},d,c(5),i,self.clock)
b.paragraph(screen,r,d,c(6),a.WIDTH-12,1,self.clock,a.DARK)
end

function e:drawBestiaryMoves(screen,enemyId)
local d,j=6,a.WIDTH-12
b.text(screen,a.text("BestiaryTechniques"),d,c(2),a.DARK)
b.paragraph(screen,self:bestiaryTechniques(enemyId),d,c(3),j,2,self.clock)
b.text(screen,a.text("BestiaryWeakPoints"),d,c(5),a.DARK)
local m=h.LIST[enemyId].parts or{}
if#m==0 then
b.text(screen,a.text("BestiaryNone"),d,c(6))
return
end
for p,i in ipairs(m)do
local o=g
if f.knows(self.state,enemyId,"part",i.kind)then
o=a.text("BestiaryPart",a.text("Part_"..i.kind),a.text("PartEffect_"..i.kind))
end
b.pages(screen,self.artUi,{{text=o}},d,c(5+p),j,self.clock)
end
end

function e:drawBestiarySpoils(screen,enemyId)
local j=self:bestiaryEnemy(enemyId)
local d,i=6,a.WIDTH-12
local m=f.knows(self.state,enemyId,"level")
b.text(screen,a.text("BestiarySpoils"),d,c(2),a.DARK)
b.pages(screen,self.artUi,{{text=self:bestiarySpoilText(enemyId,"drop")}},d,c(3),i,self.clock)
b.pages(screen,self.artUi,{{text=self:bestiarySpoilText(enemyId,"rare")}},d,c(4),i,self.clock)
b.pages(screen,self.artUi,{{text=a.text("BestiaryXp",m and j.xp or g)}},d,c(5),i,self.clock)
b.pages(screen,self.artUi,{{text=a.text("BestiaryGold",m and j.gold or g)}},d,c(6),i,self.clock)
end

function e:drawBestiaryCard(screen)
local d=self.menu
local i=self.artUi
local j=d.rows[d.list].id
b.frame(screen,i,0,0,a.WIDTH,a.HEIGHT)
local m=d.cardPage.."/"..n
local o=screen:textWidth(m)
b.pages(screen,i,{{text=a.text("Enemy_"..j)}},6,c(1),a.WIDTH-18-o,self.clock)
b.textRight(screen,m,a.WIDTH-6,c(1),a.DARK)
if d.cardPage==1 then
self:drawBestiaryFight(screen,j)
elseif d.cardPage==2 then
self:drawBestiaryMoves(screen,j)
else
self:drawBestiarySpoils(screen,j)
end
b.icon(screen,i,"arrowLeft",2,a.HEIGHT-10,{1})
b.icon(screen,i,"arrowRight",a.WIDTH-9,a.HEIGHT-10,{1})
end
