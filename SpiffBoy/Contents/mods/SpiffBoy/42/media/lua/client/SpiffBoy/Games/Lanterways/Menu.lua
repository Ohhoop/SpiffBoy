require"SpiffBoy/Games/Lanterways/Base"
require"SpiffBoy/Games/Lanterways/Window"
require"SpiffBoy/Games/Lanterways/Class"

local c=SpiffBoyLanterwaysGame
local a=SpiffBoy.Lanterways
local b=a.Window
local e=a.Party
local l=a.Items
local j=a.Skills
local m=a.Characters
local o=a.SaveGame
local t=a.Music

local C={"MenuItems","MenuSkills","MenuEquip","MenuStatus","MenuOrder","MenuBook","MenuBestiary","MenuBonds","MenuSave","MenuOptions"}
local p={bookPages=true,bookEchoes=true,bookQuests=true}
local g={x=52,y=30,w=75,h=54,step=2,shades={1,2,4},outline=4}
local u={1}
local D={1,3}
local E={1,2,3}
local F={1,2,3,4}
local d={
mainX=0,mainW=74,partyX=74,partyW=106,rowH=26,listX=2,listY=4,listW=176,listRows=5,
descY=86,descH=34,statX=6,statY=22,slotY=4,mainRows=6,panelRows=4,
}
local q={"atk","def","mag","res","spd"}
local n={"weapon","armor","charm"}
local r=(a.WIDTH-2*d.statX)/#q

local function v(index)
return d.statX+math.floor(r*(index-0.5)+0.5)
end

function c:menuEntries()
local f={}
for i,h in ipairs(C)do
if(h~="MenuBook"or e.hasFlag(self.state,"j_book"))and(h~="MenuBonds"or#self:bondRows()>0)then
f[#f+1]=h
end
end
return f
end

function c:openMenu()
self.mode=c.MODE_MENU
self.menu={screen="main",index=1,top=1,mainTop=1,partyTop=1}
self.menu.entries=self:menuEntries()
self:effect("open")
end

function c:closeMenu()
self.mode=c.MODE_FIELD
self.menu=nil
self:effect("cancel")
end

function c:pickMember(purpose,all)
local f=self.menu
f.pickFrom=f.screen
f.screen="pick"
f.purpose=purpose
f.pickAll=all
if purpose=="useItem"or purpose=="castOn"or not f.member then
f.member=1
end
f.partyTop=b.scroll(f.member,f.partyTop,d.panelRows,#self:menuMembers(all))
end

function c:menuMembers(all)
if all then
local f={}
for i,h in ipairs(self.state.order)do
f[#f+1]=self.state.members[h]
end
return f
end
return e.active(self.state)
end

function c:useItemOnMember(itemId,member)
local f=l.get(itemId)
local w=e.stats(member)
local h=false
local k={member}
if f.target=="allies"then
k=e.active(self.state)
end
if f.effect=="heal"then
for x,i in ipairs(k)do
local s=e.stats(i).hp
if i.hp>0 and i.hp<s then
i.hp=math.min(s,i.hp+f.power)
h=true
end
end
elseif f.effect=="sp"then
for x,i in ipairs(k)do
local s=e.stats(i).sp
if i.hp>0 and i.sp<s then
i.sp=math.min(s,i.sp+f.power)
h=true
end
end
elseif f.effect=="revive"and member.hp<=0 then
member.hp=math.max(1,math.floor(w.hp*f.power))
h=true
end
if h then
e.takeItem(self.state,itemId,1)
self:effect("heal")
else
self:effect("buzz")
end
return h
end

function c:useSkillOnMember(caster,skillId,member)
local f=j.get(skillId)
if caster.sp<f.cost or caster.hp<=0 then
self:effect("buzz")
return false
end
local w=e.stats(caster).mag
local s={member}
if f.target=="allies"then
s=e.active(self.state)
end
local i=false
for x,h in ipairs(s)do
local k=e.stats(h).hp
if f.kind=="heal"and h.hp>0 and h.hp<k then
h.hp=math.min(k,h.hp+math.floor(f.power+w*0.8))
i=true
elseif f.kind=="revive"and h.hp<=0 then
h.hp=math.max(1,math.floor(k*f.power))
i=true
end
end
if i then
caster.sp=caster.sp-f.cost
self:effect("heal")
else
self:effect("buzz")
end
return i
end

function c:bagRows()
local h={}
for s,f in ipairs(e.bagList(self.state))do
local k=l.get(f)
local i="x"..e.count(self.state,f)
if k.kind=="key"then
i=nil
end
h[#h+1]={id=f,label=a.text("Item_"..f),right=i}
end
return h
end

function c:skillRowsOf(member)
local f={}
for k,h in ipairs(e.skills(self.state,member))do
local i=j.get(h)
f[#f+1]={id=h,label=a.text("Skill_"..h),right=tostring(i.cost),disabled=not j.usableInField(i)or i.cost>member.sp}
end
return f
end

function c:bestiaryRows()
local h={}
local i=self.state
for s,f in ipairs(a.Enemies.ORDER)do
local k={id=f,label="???"}
if i.seen[f]then
k.label=a.text("Enemy_"..f)
end
if e.knows(i,f,"level")then
k.right=a.text("Level").." "..a.Enemies.get(f,e.enemyBonus(i)).level
end
h[#h+1]=k
end
return h
end

function c:bondRows()
local f={}
local i=self.state.order
for s,k in ipairs(j.DUOS)do
local h=j.get(k).duo
if a.indexOf(i,h[1])and a.indexOf(i,h[2])then
f[#f+1]=self:bondRow(k,h)
end
end
return f
end

function c:bondRow(duoId,pair)
local f={id=duoId,label=a.text("Name_"..pair[1]).." + "..a.text("Name_"..pair[2]),right=e.bond(self.state,duoId).."/"..j.BOND_NEEDED}
if e.duoReady(self.state,duoId)then
f.label=a.text("Skill_"..duoId)
f.right=a.text("Duo")
end
return f
end

function c:bookRows()
local h=self.state
local s,i=a.Lore.pages(),0
for k,f in ipairs(s)do
if e.hasFlag(h,"p_"..f.id)then
i=i+1
end
end
local k=0
for w,f in ipairs(a.Lore.ECHOES)do
if e.hasFlag(h,"e_"..f)then
k=k+1
end
end
local f=0
if self:storyEnded()then
f=1
end
for x,w in ipairs(a.Lore.QUESTS)do
if e.hasFlag(h,w.done)then
f=f+1
end
end
return{
{id="pages",label=a.text("BookPages"),right=i.."/"..#s},
{id="echoes",label=a.text("BookEchoes"),right=k.."/"..#a.Lore.ECHOES},
{id="quests",label=a.text("BookQuests"),right=f.."/"..(#a.Lore.QUESTS+1)},
{id="map",label=a.text("BookMap")},
}
end

function c:bookPageRows()
local h={}
for k,f in ipairs(a.Lore.pages())do
local i=e.hasFlag(self.state,"p_"..f.id)
h[#h+1]={id=f.id,series=f.series,found=i,label=i and a.text("PageTitle_"..f.id)or"???"}
end
return h
end

function c:bookEchoRows()
local f={}
for k,h in ipairs(a.Lore.ECHOES)do
local i=e.hasFlag(self.state,"e_"..h)
f[#f+1]={id=h,found=i,label=i and a.text("EchoTitle_"..h)or"???"}
end
return f
end

function c:questState(quest)
if e.hasFlag(self.state,quest.done)then
return"done"
elseif e.hasFlag(self.state,quest.started)then
return"started"
end
return nil
end

function c:storyEnded()
return self.state.step>=a.Lore.STORY_END
end

function c:storyChapter()
local f=1
for h,i in ipairs(a.Lore.CHAPTER_FLAGS)do
if e.hasFlag(self.state,i)then
f=h+1
end
end
return f
end

function c:mainQuestRow()
local f=self:storyEnded()and"done"or"started"
return{
id="main",
progress=f,
label=a.text("Chapter"..self:storyChapter().."Sub"),
right=a.text("Quest_"..f),
note="QuestNote_main_"..self.state.step,
}
end

function c:bookQuestRows()
local k={self:mainQuestRow()}
for s,f in ipairs(a.Lore.QUESTS)do
local h=self:questState(f)
local i={id=f.id,progress=h,label="???"}
if h then
i.label=a.text("QuestTitle_"..f.id)
i.right=a.text("Quest_"..h)
i.note="QuestNote_"..f.id.."_"..h
end
k[#k+1]=i
end
return k
end

function c:equipRows(member,slot)
local f={}
local i=m.BY_ID[member.id]
if slot=="charm"and member.equip.charm then
f[#f+1]={id=false,label=a.text("Remove")}
end
for k,h in ipairs(e.bagList(self.state,function(item)return item.kind==slot and l.fits(i,item)end))do
f[#f+1]={id=h,label=a.text("Item_"..h),right="x"..e.count(self.state,h)}
end
return f
end

function c:openList(screen,rows)
local f=self.menu
f.screen=screen
f.rows=rows
f.list=1
f.listTop=1
end

function c:visibleRows()
if self.menu.screen=="skills"then
return d.listRows-1
end
return d.listRows
end

function c:stepList(pressed)
local f=self.menu
local h=a.verticalStep(pressed)
if h~=0 and#f.rows>0 then
f.list=a.wrap(f.list+h,#f.rows)
f.listTop=b.scroll(f.list,f.listTop,self:visibleRows(),#f.rows)
self:effect("cursor")
end
end

function c:tickMenu(input)
if self.dialog then
self:tickDialog(input)
return
end
if not input then
return
end
local f=self.menu
if f.finishing and(f.written or f.screen=="main")then
self:openTitle()
return
end
local h=input.pressed
local i=f.screen
if i=="main"then
local k=a.verticalStep(h)
if k~=0 then
local s=f.entries
f.index=a.wrap(f.index+k,#s)
f.mainTop=b.scroll(f.index,f.mainTop,d.mainRows,#s)
self:effect("cursor")
end
if h.b or h.start then
self:closeMenu()
elseif h.a then
self:effect("confirm")
self:openEntry(f.entries[f.index])
end
elseif i=="pick"then
self:tickPick(h)
elseif i=="items"or i=="skills"or i=="equipList"or i=="bestiary"or i=="bonds"or i=="book"or p[i]then
self:tickMenuList(h)
elseif i=="slots"then
local k=a.verticalStep(h)
if k~=0 then
f.slot=a.wrap(f.slot+k,#n)
self:effect("cursor")
end
if h.b then
f.screen="pick"
self:effect("cancel")
elseif h.a then
self:effect("confirm")
self:openList("equipList",self:equipRows(f.target,n[f.slot]))
end
elseif i=="bookMap"then
self:tickBookMap(h)
elseif i=="bestiaryCard"then
self:tickBestiaryCard(h)
elseif i=="status"then
local k=a.horizontalStep(h)+a.verticalStep(h)
local s=self:menuMembers(true)
if k~=0 then
f.statusIndex=a.wrap(f.statusIndex+k,#s)
f.member=f.statusIndex
f.partyTop=b.scroll(f.member,f.partyTop,d.panelRows,#s)
self:effect("cursor")
end
if h.b or h.a then
f.screen="pick"
self:effect("cancel")
end
elseif i=="save"then
self:tickSaveScreen(h)
elseif i=="options"then
self:tickOptionsScreen(h)
end
end

function c:openEntry(entry)
local f=self.menu
f.member=1
if entry=="MenuItems"then
self:openList("items",self:bagRows())
elseif entry=="MenuSkills"then
f.screen="main"
self:pickMember("skills")
elseif entry=="MenuEquip"then
f.screen="main"
self:pickMember("equip",true)
elseif entry=="MenuStatus"then
f.screen="main"
self:pickMember("status",true)
elseif entry=="MenuOrder"then
f.screen="main"
f.swapFrom=nil
self:pickMember("order",true)
elseif entry=="MenuBook"then
self:openList("book",self:bookRows())
elseif entry=="MenuBestiary"then
self:openList("bestiary",self:bestiaryRows())
elseif entry=="MenuBonds"then
self:openList("bonds",self:bondRows())
elseif entry=="MenuSave"then
f.screen="save"
f.slotIndex=self.slot or 1
f.confirm=nil
else
f.screen="options"
f.option=1
end
end

function c:tickPick(pressed)
local f=self.menu
local s=self:menuMembers(f.pickAll)
local w=a.verticalStep(pressed)
if w~=0 then
f.member=a.wrap(f.member+w,#s)
f.partyTop=b.scroll(f.member,f.partyTop,d.panelRows,#s)
self:effect("cursor")
end
if pressed.b then
self:effect("cancel")
if f.purpose=="order"and f.swapFrom then
f.swapFrom=nil
elseif f.purpose=="useItem"then
f.screen="items"
elseif f.purpose=="castOn"then
f.screen="skills"
else
f.screen="main"
end
return
end
if not pressed.a then
return
end
local i=s[f.member]
local h=f.purpose
if h=="skills"then
f.caster=i
self:effect("confirm")
self:openList("skills",self:skillRowsOf(i))
elseif h=="equip"then
f.target=i
f.slot=1
f.screen="slots"
self:effect("confirm")
elseif h=="status"then
f.statusIndex=f.member
f.screen="status"
self:effect("confirm")
elseif h=="useItem"then
local k=f.rows[f.list]
self:useItemOnMember(k.id,i)
if e.count(self.state,k.id)<=0 then
self:openList("items",self:bagRows())
end
elseif h=="castOn"then
local k=f.rows[f.list]
self:useSkillOnMember(f.caster,k.id,i)
f.rows=self:skillRowsOf(f.caster)
if f.caster.sp<j.get(k.id).cost then
f.screen="skills"
end
elseif h=="order"then
if f.member==1 then
self:effect("buzz")
elseif not f.swapFrom then
f.swapFrom=f.member
self:effect("confirm")
else
local k=self.state.order
k[f.swapFrom],k[f.member]=k[f.member],k[f.swapFrom]
f.swapFrom=nil
self.field:refreshParty()
self.field:gatherFollowers()
self:effect("confirm")
end
end
end

function c:tickMenuList(pressed)
local f=self.menu
self:stepList(pressed)
local h=f.rows[f.list]
if pressed.b then
self:effect("cancel")
if f.screen=="bestiary"or f.screen=="bonds"or f.screen=="book"then
f.screen="main"
elseif p[f.screen]then
self:openList("book",self:bookRows())
f.list=f.bookIndex
f.listTop=b.scroll(f.list,1,d.listRows,#f.rows)
elseif f.screen=="equipList"then
f.screen="slots"
elseif f.screen=="skills"then
f.member=a.indexOf(self:menuMembers(false),f.caster)or 1
self:pickMember("skills")
else
f.screen="main"
end
return
end
if not pressed.a or not h then
return
end
if f.screen=="book"then
self:openBookPart(h.id)
elseif f.screen=="bestiary"then
if self.state.seen[h.id]then
self:effect("confirm")
self:openBestiaryCard()
else
self:effect("buzz")
end
elseif f.screen=="bookPages"or f.screen=="bookEchoes"then
if h.found then
self:effect("confirm")
self:openText(nil,self:bookText(f.screen,h.id))
else
self:effect("buzz")
end
elseif f.screen=="items"then
local i=l.get(h.id)
if i.kind=="use"and(i.effect=="heal"or i.effect=="sp"or i.effect=="revive")then
self:effect("confirm")
self:pickMember("useItem")
else
self:effect("buzz")
end
elseif f.screen=="skills"then
if h.disabled then
self:effect("buzz")
else
self:effect("confirm")
self:pickMember("castOn")
end
elseif f.screen=="equipList"then
local i=f.target
if h.id==false then
e.unequipCharm(self.state,i)
else
e.equip(self.state,i,h.id)
end
self:effect("equip")
f.screen="slots"
end
end

function c:openBookPart(part)
local f=self.menu
f.bookIndex=f.list
self:effect("confirm")
if part=="pages"then
self:openList("bookPages",self:bookPageRows())
elseif part=="echoes"then
self:openList("bookEchoes",self:bookEchoRows())
elseif part=="quests"then
self:openList("bookQuests",self:bookQuestRows())
else
f.screen="bookMap"
end
end

function c:bookText(list,id)
if list=="bookPages"then
return a.text("Page_"..id)
end
return a.text("Echo_"..id.."_1").." "..a.text("Echo_"..id.."_2").." "..a.text("Echo_"..id.."_3")
end

function c:tickBookMap(pressed)
if pressed.b or pressed.a then
self:effect("cancel")
self:openList("book",self:bookRows())
self.menu.list=self.menu.bookIndex
end
end

function c:tickSaveScreen(pressed)
local f=self.menu
if f.confirm then
if pressed.up or pressed.down or pressed.left or pressed.right then
f.confirm=f.confirm==1 and 2 or 1
self:effect("cursor")
end
if pressed.b then
f.confirm=nil
self:effect("cancel")
elseif pressed.a then
if f.confirm==1 then
self:writeSlot(f.slotIndex)
else
self:effect("cancel")
end
f.confirm=nil
end
return
end
local i=a.verticalStep(pressed)
if i~=0 then
f.slotIndex=a.wrap(f.slotIndex+i,o.SLOTS)
self:effect("cursor")
end
if pressed.b then
f.screen="main"
self:effect("cancel")
elseif pressed.a then
local h=self.save.slots
if type(h)=="table"and h[f.slotIndex]and o.summary(h[f.slotIndex])then
f.confirm=2
self:effect("confirm")
else
self:writeSlot(f.slotIndex)
end
end
end

function c:writeSlot(slot)
self:saveJourney(slot)
self:effect("save")
self:openText(nil,a.text("Saved",slot))
self.menu.written=true
end

function c:tickOptionsScreen(pressed)
local f=self.menu
local i={"music","effects"}
local k=a.verticalStep(pressed)
if k~=0 then
f.option=a.wrap(f.option+k,#i)
self:effect("cursor")
end
local s=a.horizontalStep(pressed)
if s~=0 then
local h=i[f.option]
local w=SpiffBoy.clamp(self.mix[h]+s,0,t.MIX_STEPS)
if w~=self.mix[h]then
self.mix[h]=w
f.optionsChanged=true
self:applyMix()
self:effect("cursor")
end
end
if pressed.b or pressed.a then
if f.optionsChanged then
self:saveOptions()
f.optionsChanged=false
end
f.screen="main"
self:effect("cancel")
end
end

local function s(screen,x,y,w,share)
b.fill(screen,x,y,w,4,a.INK)
local f=math.floor((w-2)*SpiffBoy.clamp(share,0,1))
if f>0 then
b.fill(screen,x+1,y+1,f,2,a.MID)
end
end

function c:drawMemberRow(screen,member,x,y,w,selected,marked,reserve)
local f=e.stats(member)
if selected then
b.fill(screen,x+1,y,w-2,d.rowH-1,a.MID)
end
if marked then
b.fill(screen,x+1,y,3,d.rowH-1,a.INK)
end
screen:layers(self:art("walk_"..member.id),0,12,16,x+3,y+4,F)
b.text(screen,b.fit(screen,a.text("Name_"..member.id),w-46),x+17,y-2,reserve and a.DARK or a.INK)
local h=e.worn(member,"weapon")
if h.element then
b.icon(screen,self.artUi,b.ELEMENT_ICONS[h.element],x+w-22,y+1,u)
end
screen:number(member.level,x+w-3,y+2,self.artDigits,"right",0,a.INK)
b.icon(screen,self.artUi,"heart",x+16,y+11,D)
s(screen,x+28,y+14,34,member.hp/f.hp)
b.icon(screen,self.artUi,"lampIcon",x+65,y+11,E)
s(screen,x+77,y+14,w-80,member.sp/f.sp)
local k=m.toNext(member.level)
local z=member.level>=a.LEVEL_CAP and 1 or member.xp/k
b.icon(screen,self.artUi,"xp",x+29,y+21,u)
local i=math.floor((w-41)*SpiffBoy.clamp(z,0,1))
if i>0 then
b.fill(screen,x+38,y+22,i,2,a.DARK)
end
end

function c:drawPartyPanel(screen,x,w,members,selected,marked,top)
b.frame(screen,self.artUi,x,0,w,a.HEIGHT)
for h=0,d.panelRows-1 do
local f=top+h
local i=members[f]
if i then
local k=4+h*d.rowH
self:drawMemberRow(screen,i,x+2,k,w-4,f==selected,f==marked,f>a.PARTY_SIZE)
if f==a.PARTY_SIZE and members[f+1]and h<d.panelRows-1 then
b.fill(screen,x+6,k+d.rowH-1,w-12,1,a.INK)
end
end
end
if top>1 then
b.icon(screen,self.artUi,"arrowUp",x+w-10,1,{1})
end
if top+d.panelRows-1<#members then
b.icon(screen,self.artUi,"arrowDown",x+w-10,a.HEIGHT-7,{1})
end
end

function c:drawDescription(screen,key)
b.frame(screen,self.artUi,0,d.descY,a.WIDTH,d.descH)
if key then
b.paragraph(screen,a.text(key),6,d.descY+1,a.WIDTH-12,2,self.clock)
end
end

local function w(seconds)
local f=math.floor(seconds/60)
local i=math.floor(f/60)
f=f%60
local h=tostring(f)
if f<10 then
h="0"..h
end
return i..":"..h
end
c.clockText=w

function c:drawMenu(screen)
local h=self.menu
local k=self.artUi
local y=self.state
local f=h.screen
if self.dialog and p[f]then
self:drawDialog(screen)
return
end
if f=="main"or f=="pick"then
b.frame(screen,k,d.mainX,0,d.mainW,a.HEIGHT)
local x={}
for i,z in ipairs(h.entries)do
x[i]={label=b.fit(screen,a.text(z),d.mainW-16)}
end
b.list(screen,k,x,2,3,d.mainW-4,d.mainRows,h.index,h.mainTop,self.clock,f=="main")
b.icon(screen,k,"coin",4,a.HEIGHT-9,{1,3})
screen:number(y.gold,d.mainW-5,a.HEIGHT-8,self.artDigits,"right",0,a.INK)
local z=self:menuMembers(f=="pick"and h.pickAll)
local A=f=="pick"and h.member or nil
local i=1
if f=="pick"then
i=h.partyTop
end
self:drawPartyPanel(screen,d.partyX,d.partyW,z,A,h.swapFrom,i)
if f=="pick"then
b.cursor(screen,k,d.partyX-5,4+(h.member-i)*d.rowH+9,self.clock)
end
elseif f=="items"or f=="skills"or f=="equipList"or f=="bestiary"or f=="bonds"or f=="book"or p[f]then
local z=d.listRows*b.LINE+8
b.frame(screen,k,0,0,a.WIDTH,z)
b.list(screen,k,h.rows,d.listX,d.listY,d.listW,self:visibleRows(),h.list,h.listTop,self.clock,true)
local i=h.rows[h.list]
if self.dialog then
i=nil
elseif f=="items"then
self:drawDescription(screen,i and("ItemDesc_"..i.id))
elseif f=="skills"then
self:drawDescription(screen,i and("SkillDesc_"..i.id))
local x=d.listY+self:visibleRows()*b.LINE
b.text(screen,a.text("Name_"..h.caster.id),d.listX+10,x,a.DARK)
b.textRight(screen,h.caster.sp.."/"..e.stats(h.caster).sp,d.listX+d.listW-12,x,a.DARK)
elseif f=="bestiary"then
self:drawBestiaryEntry(screen,i.id)
elseif f=="bonds"then
self:drawBondEntry(screen,i.id)
elseif f=="book"then
self:drawDescription(screen,"BookHelp_"..i.id)
elseif f=="bookPages"then
self:drawDescription(screen,i.found and("Series_"..i.series)or"BookUnknown")
elseif f=="bookEchoes"then
self:drawDescription(screen,i.found and"EchoReplay"or"BookUnknown")
elseif f=="bookQuests"then
self:drawDescription(screen,i.note or"BookUnknown")
else
self:drawEquipCompare(screen,h.target,i and i.id)
end
elseif f=="bookMap"then
self:drawBookMap(screen)
elseif f=="bestiaryCard"then
self:drawBestiaryCard(screen)
elseif f=="slots"then
self:drawSlots(screen,h.target,h.slot)
elseif f=="status"then
self:drawStatus(screen,self:menuMembers(true)[h.statusIndex])
elseif f=="save"then
self:drawSaveScreen(screen)
elseif f=="options"then
self:drawOptionsScreen(screen)
end
if self.dialog then
self:drawDialog(screen)
end
end

local G={save=true,options=true}

function c:menuCoversScreen()
return not G[self.menu.screen]or self.dialog~=nil
end

function c:drawBookMap(screen)
local A=self.artUi
b.frame(screen,A,0,0,a.WIDTH,a.HEIGHT)
b.textCentre(screen,a.text("BookMap"),a.WIDTH/2,2)
b.fill(screen,g.x-1,g.y-1,g.w+2,g.h+2,a.DARK)
b.fill(screen,g.x,g.y,g.w,g.h,a.MID)
local k=a.Field.prepare(a.Maps.murksea)
local B=a.Field.wholeIslets(k,self.state)
local x=self:art("minimap")
local H=e.hasFlag(self.state,"q_carto")
for K,f in ipairs(a.MurkSea.islets)do
local h,i=math.floor(f.x/g.step),math.floor(f.y/g.step)
local y=math.floor((f.x+f.w-1)/g.step)-h+1
local z=math.floor((f.y+f.h-1)/g.step)-i+1
if B[f.id]then
for I,J in ipairs(g.shades)do
screen:sheet(x,h,(I-1)*g.h+i,y,z,g.x+h,g.y+i,1,J)
end
elseif H then
screen:sheet(x,h,(g.outline-1)*g.h+i,y,z,g.x+h,g.y+i,1,a.DARK)
end
end
for y,f in ipairs(k.objects)do
if f.kind=="watchlight"and e.hasFlag(self.state,f.flag)then
local h,i=g.x+math.floor((f.x+f.door)/g.step),g.y+math.floor((f.y+1)/g.step)
b.fill(screen,h-2,i,5,1,a.INK)
b.fill(screen,h,i-2,1,5,a.INK)
end
end
if self.field.id=="murksea"and math.floor(self.clock/15)%2==0 then
local f=self.field.player
b.fill(screen,g.x+math.floor(f.x/g.step)-1,g.y+math.floor(f.y/g.step)-1,3,3,a.INK)
end
b.textCentre(screen,a.text("BookMapHint"),a.WIDTH/2,g.y+g.h+2,a.DARK)
end

function c:drawPairLines(screen,lines)
b.frame(screen,self.artUi,0,d.descY,a.WIDTH,d.descH)
for h,f in ipairs(lines)do
local i=d.descY+1+(h-1)*b.LINE
b.pair(screen,f[1]or"",f[2]or"",6,i,a.WIDTH-12,self.clock,a.INK,a.DARK)
end
end

function c:drawBestiaryEntry(screen,enemyId)
local h=self.state
if not h.seen[enemyId]then
local f=0
for k,i in ipairs(a.Enemies.ORDER)do
if h.seen[i]then
f=f+1
end
end
self:drawPairLines(screen,{{a.text("BestiaryCount",f,#a.Enemies.ORDER)}})
return
end
self:drawPairLines(screen,{
{self:bestiaryElementText(enemyId,"weak"),self:bestiaryElementText(enemyId,"resist")},
{self:bestiarySpoilText(enemyId,"drop"),a.text("BestiaryOpen")},
})
end

function c:drawBondEntry(screen,duoId)
if e.duoReady(self.state,duoId)then
self:drawDescription(screen,"SkillDesc_"..duoId)
return
end
self:drawPairLines(screen,{{a.text("BondLocked",e.bond(self.state,duoId),j.BOND_NEEDED)}})
end

function c:drawEquipCompare(screen,member,itemId)
b.frame(screen,self.artUi,0,d.descY,a.WIDTH,d.descH)
local i=e.stats(member)
local h=i
if itemId then
h=e.statsWith(member,itemId)
elseif itemId==false then
local f={id=member.id,level=member.level,equip={weapon=member.equip.weapon,armor=member.equip.armor}}
h=e.stats(f)
end
local x=self.artDigits:getWidth()/10
for y,f in ipairs(q)do
local k=v(y)
b.pagesCentre(screen,a.text("Stat_"..f),k,d.descY+1,r-2,self.clock,a.DARK)
local z=a.INK
if h[f]~=i[f]then
local A=math.ceil(string.len(tostring(h[f]))*x/2)
b.icon(screen,self.artUi,h[f]>i[f]and"arrowUp"or"arrowDown",k+A+1,d.descY+20,{1})
end
screen:number(h[f],k,d.descY+21,self.artDigits,"centre",0,z)
end
end

function c:drawSlots(screen,member,slotIndex)
local h=self.artUi
b.frame(screen,h,0,0,a.WIDTH,58)
local i={}
for y,k in ipairs(n)do
local x=member.equip[k]
local f=a.text("Slot_"..k)..": "
if x then
f=f..a.text("Item_"..x)
else
f=f.."-"
end
i[y]={label=b.fit(screen,f,a.WIDTH-20)}
end
b.list(screen,h,i,2,4,a.WIDTH-4,3,slotIndex,1,self.clock,true)
for x,y in ipairs(n)do
local f=e.worn(member,y)
local k=f and b.gearIcon(f)
if k then
b.icon(screen,h,k,a.WIDTH-13,8+(x-1)*b.LINE,{1,2,3,4})
end
end
self:drawEquipCompare(screen,member,nil)
b.frame(screen,h,0,58,a.WIDTH,28)
b.text(screen,a.text("Name_"..member.id).." - "..a.text("Class_"..m.BY_ID[member.id].class),6,63)
end

function c:drawStatus(screen,member)
local f=self.artUi
local z=m.BY_ID[member.id]
local i=e.stats(member)
b.frame(screen,f,0,0,a.WIDTH,a.HEIGHT)
self:drawRegion(screen,self:art("walk_"..member.id),0,0,12,16,16,6,5,{1,2,3,4},0)
b.text(screen,a.text("Name_"..member.id),22,2)
b.text(screen,a.text("Class_"..z.class),22,17,a.DARK)
b.textRight(screen,a.text("Level").." "..member.level,a.WIDTH-6,2)
local x=m.toNext(member.level)-member.xp
if member.level>=a.LEVEL_CAP then
x=0
end
b.textRight(screen,a.text("Next").." "..x,a.WIDTH-6,17,a.DARK)
b.icon(screen,f,"heart",6,37,{1,3})
b.text(screen,member.hp.."/"..i.hp,18,32)
b.icon(screen,f,"lampIcon",92,37,{1,2,3,4})
b.text(screen,member.sp.."/"..i.sp,104,32)
for y,h in ipairs(q)do
local k=v(y)
b.pagesCentre(screen,a.text("Stat_"..h),k,46,r-2,self.clock,a.DARK)
screen:number(i[h],k,63,self.artDigits,"centre",0,a.INK)
end
for k,A in ipairs(n)do
local h=member.equip[A]
local B=h and a.text("Item_"..h)or"-"
b.text(screen,b.fit(screen,B,a.WIDTH-24),6,70+(k-1)*15,k%2==0 and a.DARK or a.INK)
local y=h and b.gearIcon(l.get(h))
if y then
b.icon(screen,f,y,a.WIDTH-16,74+(k-1)*15,{1,2,3,4})
end
end
b.icon(screen,f,"arrowLeft",2,a.HEIGHT-10,{1})
b.icon(screen,f,"arrowRight",a.WIDTH-9,a.HEIGHT-10,{1})
end

function c:drawSlotList(screen,selected,focused,header)
local x=self.artUi
b.frame(screen,x,0,0,a.WIDTH,a.HEIGHT)
local k=self.save.slots
local y,z,A=4,38,36
if header then
y,z,A=20,33,31
b.textCentre(screen,b.fit(screen,a.text(header),a.WIDTH-12),a.WIDTH/2,1)
end
for h=1,o.SLOTS do
local f=y+(h-1)*z
if h==selected then
b.fill(screen,8,f,a.WIDTH-12,A,a.MID)
if focused then
b.cursor(screen,x,2,f+11,self.clock)
end
end
b.text(screen,a.text("Slot",h),12,f)
local i=type(k)=="table"and k[h]and o.summary(k[h])
if i then
local B=a.text("Map_"..a.Maps[i.map].place)
if i.cleared then
B=a.text("SlotCleared")
end
b.textRight(screen,w(i.time),a.WIDTH-6,f)
b.text(screen,b.fit(screen,B,110),12,f+15,a.DARK)
b.textRight(screen,a.text("Level").." "..i.level,a.WIDTH-6,f+15,a.DARK)
else
b.text(screen,a.text("EmptySlot"),12,f+15,a.DARK)
end
end
end

function c:drawSaveScreen(screen)
local f=self.menu
self:drawSlotList(screen,f.slotIndex,not f.confirm)
if f.confirm then
local x={{label=a.text("Yes")},{label=a.text("No")}}
local i=a.text("Overwrite")
local h=math.max(screen:textWidth(i)+12,70)
local k=(a.WIDTH-h)/2
b.frame(screen,self.artUi,k,30,h,58)
b.textCentre(screen,i,a.WIDTH/2,33)
b.list(screen,self.artUi,x,k+4,52,h-8,2,f.confirm,1,self.clock,true)
end
end

function c:drawOptionsScreen(screen)
local y=self.menu
local h=self.artUi
b.frame(screen,h,0,20,a.WIDTH,70)
local z={"music","effects"}
for i,k in ipairs(z)do
local f=28+(i-1)*28
if i==y.option then
b.cursor(screen,h,4,f+4,self.clock)
end
b.text(screen,a.text(k=="music"and"Music"or"Effects"),14,f)
for x=1,t.MIX_STEPS do
local A=x<=self.mix[k]and a.INK or a.MID
b.fill(screen,96+(x-1)*8,f+4,6,8,A)
end
end
end
