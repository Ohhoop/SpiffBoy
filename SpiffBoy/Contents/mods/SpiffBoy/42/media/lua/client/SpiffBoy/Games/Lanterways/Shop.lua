require"SpiffBoy/Games/Lanterways/Base"
require"SpiffBoy/Games/Lanterways/Window"
require"SpiffBoy/Games/Lanterways/Class"

local d=SpiffBoyLanterwaysGame
local a=SpiffBoy.Lanterways
local c=a.Window
local e=a.Party
local f=a.Items
local t=a.Characters

local g={listRows=3,listY=20,boxY=74,boxH=46,lineY=6,nameRoom=102,tabX=11,tabRoom=89,arrowLeftX=2,arrowRightX=102}
local u={"ShopBuy","ShopSell","ShopLeave"}
local v={"ShopBuy","ShopSell","ShopCraft","ShopLeave"}
local w={"weapon","armor","charm","use","loot"}
local x={heal="heart",sp="lampIcon"}
local y={none=true}

local function n(value)
if value>0 then
return"+"..value
end
return tostring(value)
end

local function o(value)
return math.floor(value*100+0.5).."%"
end

function d:shopChoices()
if a.Recipes[self.shop.id]then
return v
end
return u
end

function d:canCraft(recipe)
if self.state.gold<recipe.gold then
return false
end
for h,b in ipairs(recipe.needs)do
if e.count(self.state,b[1])<b[2]then
return false
end
end
return true
end

function d:shopRecipeRows()
local h={}
for k,b in ipairs(a.Recipes[self.shop.id])do
local i=a.text("Item_"..b.item)
if b.count>1 then
i=i.." x"..b.count
end
local j=nil
if b.gold>0 then
j=tostring(b.gold)
end
h[#h+1]={id=b.item,recipe=k,label=i,right=j,disabled=not self:canCraft(b)}
end
return h
end

function d:craft(recipe)
for h,b in ipairs(recipe.needs)do
e.takeItem(self.state,b[1],b[2])
end
e.addGold(self.state,-recipe.gold)
e.addItem(self.state,recipe.item,recipe.count)
self:effect("buy")
end

function d:recipeNeeds(recipe)
local b={}
for i,h in ipairs(recipe.needs)do
b[#b+1]=h[2].." x "..a.text("Item_"..h[1])
end
return a.text("CraftNeeds",table.concat(b,", "))
end

function d:shopAllRows(screen)
if screen=="buy"then
return self:shopWares()
end
return self:shopSellRows()
end

function d:shopTabs(screen)
if screen=="craft"then
return{}
end
local h={}
for i,b in ipairs(self:shopAllRows(screen))do
h[f.get(b.id).kind]=true
end
local b={}
for j,i in ipairs(w)do
if h[i]then
b[#b+1]=i
end
end
return b
end

function d:shopTab(screen)
local b=self:shopTabs(screen)
if#b==0 then
return nil
end
return b[SpiffBoy.clamp(self.shop.tab,1,#b)]
end

function d:shopRows(screen)
if screen=="craft"then
return self:shopRecipeRows()
end
local i=self:shopTab(screen)
local b={}
for j,h in ipairs(self:shopAllRows(screen))do
if f.get(h.id).kind==i then
b[#b+1]=h
end
end
return b
end

function d:wornCount(itemId)
local b=0
for k,i in ipairs(self.state.order)do
local h=self.state.members[i]
if h then
for l,j in ipairs(e.SLOTS)do
if h.equip[j]==itemId then
b=b+1
end
end
end
end
return b
end

function d:compareText(member,item)
local i=a.text("Name_"..member.id)
if member.equip[item.kind]==item.id then
return i.."  "..a.text("WornHere")
end
local k=e.stats(member)
local l=e.statsWith(member,item.id)
local b={i}
for m,h in ipairs(e.STATS)do
local j=l[h]-k[h]
if j~=0 then
b[#b+1]=a.text("Stat_"..h)..n(j)
end
end
if#b==1 then
b[2]="="
end
return table.concat(b,"  ")
end

function d:wearerPages(item)
local b={}
for j,h in ipairs(self.state.order)do
local i=self.state.members[h]
if i and f.fits(t.BY_ID[h],item)then
b[#b+1]={text=self:compareText(i,item)}
end
end
if#b==0 then
b[1]={text=a.text("NoWearer"),shade=a.DARK}
end
return b
end

function d:effectParts(item)
local b=item.effect
if b=="heal"or b=="sp"then
return{n(item.power)}
elseif b=="revive"then
return{o(item.power),a.text("UseRevive")}
elseif b=="cure"and item.status then
return{a.text("UseCure",a.text("StatusName_"..item.status))}
elseif b=="cure"then
return{a.text("UseCureAll")}
elseif b=="buff"then
return{a.text("UseStatus_"..item.status)}
elseif b=="debuff"then
return{o(item.chance),a.text("UseStatus_"..item.status)}
elseif b=="damage"then
local h={a.text("UseDamage",item.power,a.text("Element_"..item.element))}
if item.status then
h[2]=a.text("UseRider",o(item.chance),a.text("StatusName_"..item.status))
end
return h
elseif b=="glow"then
return{a.text("UseGlow",n(item.power))}
end
return{}
end

function d:effectPage(item)
local b=self:effectParts(item)
if y[item.target]then
b[#b+1]=a.text("Effect_"..item.effect)
else
b[#b+1]=a.text("Target_"..item.target)
end
return{icon=x[item.effect],text=table.concat(b,"  ")}
end

function d:gearText(item)
if item.element then
return a.text("GearStrikes",a.text("Element_"..item.element))
elseif item.ward then
return a.text("GearHalves",a.text("Element_"..item.ward))
elseif item.guard then
return a.text("GearBlocks",a.text("StatusName_"..item.guard))
end
return nil
end

function d:itemPages(item)
if f.isEquipment(item)then
local b=self:wearerPages(item)
local h=self:gearText(item)
if h then
b[#b+1]={text=h}
end
return b
elseif item.kind=="use"then
return{self:effectPage(item)}
end
return{{text=a.text("Kind_"..item.kind)}}
end

function d:statPages(item)
if item.kind=="use"then
return{self:effectPage(item)}
end
local b={}
for i,h in ipairs(e.STATS)do
if item[h]then
b[#b+1]=a.text("Stat_"..h).." "..item[h]
end
end
b[#b+1]=self:gearText(item)
if#b==0 then
return{}
end
return{{text=table.concat(b,"  ")}}
end

function d:ownedText(item)
local b=e.count(self.state,item.id)
local h=self:wornCount(item.id)
if h>0 then
return a.text("OwnedWorn",b,h)
end
return a.text("Owned",b)
end

function d:wearerNames(itemId)
local b={}
for k,h in ipairs(self.state.order)do
local i=self.state.members[h]
if i then
for l,j in ipairs(e.SLOTS)do
if i.equip[j]==itemId then
b[#b+1]=a.text("Name_"..h)
end
end
end
end
if#b==0 then
return nil
end
return table.concat(b,", ")
end

function d:openShop(shopId)
local b=a.Shops[shopId]
if not b then
error("Lanterways: no shop named "..tostring(shopId))
end
self.shop={id=shopId,screen="choose",choice=1,list=1,top=1,tab=1,amount=1}
self.mode=d.MODE_SHOP
self:effect("open")
end

function d:shopWares()
local h={}
for j,b in ipairs(a.Shops[self.shop.id])do
if e.meets(self.state,b.when)then
local i=f.get(b.item)
h[#h+1]={id=b.item,label=a.text("Item_"..b.item),right=tostring(i.price),disabled=i.price>self.state.gold}
end
end
return h
end

function d:shopSellRows()
local b={}
for j,h in ipairs(e.bagList(self.state))do
local i=f.sellPrice(f.get(h))
if i>0 then
b[#b+1]={id=h,label=a.text("Item_"..h),right=tostring(i)}
end
end
return b
end

function d:closeShop()
self.shop=nil
self.mode=d.MODE_FIELD
self:effect("cancel")
end

function d:tickShop(input)
if self.dialog then
self:tickDialog(input)
return
end
if not input then
return
end
local b=self.shop
local h=input.pressed
if b.screen=="choose"then
local i=self:shopChoices()
local j=a.verticalStep(h)
if j~=0 then
b.choice=a.wrap(b.choice+j,#i)
self:effect("cursor")
end
if h.b then
self:closeShop()
elseif h.a then
local k=i[b.choice]
if k=="ShopLeave"then
self:closeShop()
return
end
b.screen=({ShopBuy="buy",ShopSell="sell",ShopCraft="craft"})[k]
b.list,b.top,b.tab=1,1,1
self:effect("confirm")
end
return
end
if b.screen=="details"then
if h.b or h.start then
b.screen=b.detailsBack
self:effect("cancel")
end
return
end
if b.screen=="amount"then
local i=a.horizontalStep(h)+a.verticalStep(h)*-10
if i~=0 then
b.amount=SpiffBoy.clamp(b.amount+i,1,b.maxAmount)
self:effect("cursor")
end
if h.b then
b.screen=b.back
self:effect("cancel")
elseif h.a then
self:closeDeal()
end
return
end
local k=self:shopTabs(b.screen)
local m=a.horizontalStep(h)
if m~=0 and#k>1 then
b.tab=a.wrap(SpiffBoy.clamp(b.tab,1,#k)+m,#k)
b.list,b.top=1,1
self:effect("cursor")
end
b.tab=SpiffBoy.clamp(b.tab,1,math.max(1,#k))
local j=self:shopRows(b.screen)
local p=a.verticalStep(h)
if p~=0 and#j>0 then
b.list=a.wrap(b.list+p,#j)
b.top=c.scroll(b.list,b.top,g.listRows,#j)
self:effect("cursor")
end
b.list=SpiffBoy.clamp(b.list,1,#j)
if h.b then
b.screen="choose"
self:effect("cancel")
return
end
local i=j[b.list]
if h.start and i then
b.detailsBack=b.screen
b.item=i.id
b.screen="details"
self:effect("confirm")
return
end
if h.a and i and b.screen=="craft"then
if i.disabled then
self:effect("buzz")
else
self:craft(a.Recipes[b.id][i.recipe])
end
return
end
if h.a and i then
local q=f.get(i.id)
if b.screen=="buy"then
local l=math.floor(self.state.gold/q.price)
l=math.min(l,f.MAX_STACK-e.count(self.state,i.id))
if l<=0 then
self:effect("buzz")
return
end
b.maxAmount=l
else
b.maxAmount=e.count(self.state,i.id)
end
b.item=i.id
b.amount=1
b.back=b.screen
b.screen="amount"
self:effect("confirm")
end
end

function d:closeDeal()
local b=self.shop
local h=f.get(b.item)
if b.back=="buy"then
e.addGold(self.state,-h.price*b.amount)
e.addItem(self.state,b.item,b.amount)
else
e.takeItem(self.state,b.item,b.amount)
e.addGold(self.state,f.sellPrice(h)*b.amount)
end
self:effect("buy")
b.screen=b.back
end

function d:drawShopHeader(screen,listScreen)
local b=self.artUi
c.frame(screen,b,0,0,a.WIDTH,18)
local h={}
if listScreen then
h=self:shopTabs(listScreen)
end
if#h>1 then
c.icon(screen,b,"arrowLeft",g.arrowLeftX,5,{1})
c.icon(screen,b,"arrowRight",g.arrowRightX,5,{1})
c.pages(screen,b,{{text=a.text("Tab_"..self:shopTab(listScreen))}},g.tabX,0,g.tabRoom,self.clock)
elseif#h==1 then
c.pages(screen,b,{{text=a.text("Tab_"..h[1])}},6,0,g.nameRoom,self.clock)
else
c.pages(screen,b,{{text=a.text("Shop_"..self.shop.id)}},6,0,g.nameRoom,self.clock)
end
c.icon(screen,b,"coin",112,4,{1,3})
screen:number(self.state.gold,a.WIDTH-6,6,self.artDigits,"right",0,a.INK)
end

function d:drawShopBox(screen,row)
local b=self.shop
local i=self.artUi
local j,k=6,a.WIDTH-12
local h=g.boxY+g.lineY
local p=h+c.LINE
c.frame(screen,nil,0,g.boxY,a.WIDTH,g.boxH)
if not row then
return
end
if b.screen=="amount"then
local l=f.get(b.item)
local m=b.back=="buy"and l.price or f.sellPrice(l)
c.text(screen,"x"..b.amount,10,h)
c.textRight(screen,tostring(m*b.amount),a.WIDTH-8,h)
c.icon(screen,i,"arrowLeft",2,c.iconBeside(screen,"arrowLeft",h),{1})
c.icon(screen,i,"arrowRight",52,c.iconBeside(screen,"arrowRight",h),{1})
c.pages(screen,i,{{text=self:ownedText(l),shade=a.DARK}},j,p,k,self.clock)
return
end
local l=f.get(row.id)
if b.screen=="craft"then
c.pages(screen,i,self:itemPages(l),j,h,k,self.clock)
local q={}
for z,m in ipairs(a.Recipes[b.id][row.recipe].needs)do
local r=e.count(self.state,m[1])
local s=a.INK
if r<m[2]then
s=a.MID
end
q[#q+1]={text=r.."/"..m[2].." "..a.text("Item_"..m[1]),shade=s}
end
c.pages(screen,i,q,j,p,k,self.clock)
return
end
local m=self:itemPages(l)
local q=self:ownedText(l)
if b.screen=="sell"then
local r=self:wearerNames(l.id)
if r then
table.insert(m,1,{text=a.text("WornBy",r),shade=a.DARK})
end
local s=e.count(self.state,l.id)
q=a.text("AfterSale",s,s-1)
end
c.pages(screen,i,m,j,h,k,self.clock)
c.pair(screen,q,a.text("ShopDetails"),j,p,k,self.clock,a.DARK,a.DARK)
end

function d:drawShopDetails(screen)
local l=self.shop
local k=self.artUi
local b=f.get(l.item)
local h,i=6,a.WIDTH-12
local function j(index)
return 2+(index-1)*c.LINE
end
c.frame(screen,k,0,0,a.WIDTH,a.HEIGHT)
c.pages(screen,k,{{text=a.text("Item_"..b.id)}},h,j(1),i,self.clock)
c.pages(screen,k,{{text=a.text("Kind_"..b.kind),shade=a.DARK}},h,j(2),i,self.clock)
c.paragraph(screen,a.text("ItemDesc_"..b.id),h,j(3),i,2,self.clock)
c.pages(screen,k,self:statPages(b),h,j(5),i,self.clock)
if f.isEquipment(b)then
c.pages(screen,k,self:wearerPages(b),h,j(6),i,self.clock)
end
local m=""
if l.detailsBack=="buy"then
m=a.text("Price",b.price)
elseif l.detailsBack=="sell"then
m=a.text("Price",f.sellPrice(b))
end
c.pair(screen,self:ownedText(b),m,h,j(7),i,self.clock,a.DARK,a.DARK)
end

function d:drawShop(screen)
local b=self.shop
local h=self.artUi
if b.screen=="details"then
self:drawShopDetails(screen)
return
end
if b.screen=="choose"then
self:drawShopHeader(screen,nil)
local i={}
for j,k in ipairs(self:shopChoices())do
i[j]={label=a.text(k)}
end
c.frame(screen,h,0,20,90,#i*c.LINE+8)
c.list(screen,h,i,2,24,86,#i,b.choice,1,self.clock,true)
return
end
local i=b.screen
if i=="amount"then
i=b.back
end
self:drawShopHeader(screen,i)
local j=self:shopRows(i)
c.frame(screen,h,0,g.listY-2,a.WIDTH,g.listRows*c.LINE+8)
c.list(screen,h,j,2,g.listY+2,a.WIDTH-4,g.listRows,b.list,b.top,self.clock,b.screen~="amount")
self:drawShopBox(screen,j[b.list])
end

function d:travelTargets()
local b={}
for i,h in ipairs(a.TOWNS)do
if e.hasFlag(self.state,"v_"..h.place)and h.map~=self.field.id then
b[#b+1]=h
end
end
return b
end

function d:openTravel()
local h=self:travelTargets()
local b={}
for j,i in ipairs(h)do
b[#b+1]="Map_"..i.place
end
b[#b+1]="Cancel"
self.travel=h
self:openChoice("TravelAsk",b)
end

function d:finishTravel(picked)
local b=self.travel and self.travel[picked]
self.travel=nil
if b then
self:effect("bell")
self:warp(b.map,b.x,b.y,"down")
end
end
