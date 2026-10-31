require"SpiffBoy/Games/Lanterways/Base"
require"SpiffBoy/Games/Lanterways/Party"
require"SpiffBoy/Games/Lanterways/Data/Enemies"

local e=SpiffBoy.Lanterways
local b=e.Party
local h=e.Skills
local q=e.Items
local n=e.Enemies

local a={}
a.__index=a
e.Battle=a

a.GLOW_MAX=100
a.GLOW_ACT=10
a.GLOW_KEPT=3
a.GLOW_WEAK=4
a.GLOW_SHARP=10
a.GLOW_HURT=4
a.CRIT_CHANCE=0.06
a.CRIT_MULT=1.6
a.WEAK_MULT=1.6
a.RESIST_MULT=0.5
a.WARD_MULT=0.5
a.SHARP_MULT=1.25
a.OFF_ELEMENT_MULT=0.1
a.BOSS_STATUS=0.35
a.BOSS_DEBUFF=0.6
a.MISS_CHANCE=0.04
a.BLIND_MISS=0.5
a.EARLY_START=0.2
a.STEAL_CHANCE=0.5
a.STEAL_RARE=0.3
a.AIM_WEAKEST=0.35
a.PHASE_SHARE=0.5
a.BRIGHT_UP=1.4
a.PART_SHARE=0.2
a.PART_BREAK_SHARE=0.5
a.PART_XP=0.25
a.BROKEN={legs={"spd",0.6},arm={"atk",0.7},shell={"def",0.6},core={"mag",0.6}}
a.JAW_ACTS={bite=true,soak=true,tidepull=true,smother=true}
a.MODIFIERS={
atkUp={"atk",1.35},atkDown={"atk",0.7},defUp={"def",1.4},defDown={"def",0.6},
magUp={"mag",1.3},resUp={"res",1.4},resDown={"res",0.6},spdUp={"spd",1.5},spdDown={"spd",0.6},
}
a.OPPOSITE={
atkUp="atkDown",atkDown="atkUp",defUp="defDown",defDown="defUp",resUp="resDown",resDown="resUp",spdUp="spdDown",spdDown="spdUp",
}
a.DURATION={stun=1,sleep=3,blind=3,soot=4,regen=4,veil=3,taunt=3}
a.BUFF_DURATION=4
a.AILMENTS={"blind","sleep","soot","stun","atkDown","defDown","resDown","spdDown"}
a.SOOT_SHARE=0.06
a.REGEN_SHARE=0.08

local function j(speed)
return 1000/(speed+15)
end

function a.new(state,troop,random,options)
local c=setmetatable({},a)
c.state=state
c.random=random
c.options=options
c.combatants={}
c.party={}
c.enemies={}
state.glow=math.floor(state.glow/a.GLOW_KEPT)
for k,d in ipairs(b.active(state))do
if not options.seats or k<=options.seats then
local i=b.stats(d)
local f=b.worn(d,"charm")
local g={
side="party",id=d.id,member=d,name=e.text("Name_"..d.id),
base=i,hp=d.hp,maxHp=i.hp,sp=d.sp,maxSp=i.sp,
statuses={},guard=b.guardOf(d),weapon=b.worn(d,"weapon"),wards=b.wardsOf(d),charm=f,
}
if f and f.glowStart and g.hp>0 and b.glowKnown(state)then
state.glow=math.min(a.GLOW_MAX,state.glow+f.glowStart)
end
if f and f.regenStart and g.hp>0 then
g.statuses.regen=a.DURATION.regen
end
c.party[#c.party+1]=g
c.combatants[#c.combatants+1]=g
end
end
local g={}
local i=b.enemyBonus(state)
if options.levels then
i=i+options.levels
end
for l,d in ipairs(troop)do
local f=n.get(d,i)
if not f then
error("Lanterways: unknown enemy "..tostring(d))
end
b.markSeen(state,d)
g[d]=(g[d]or 0)+1
local k={
side="enemy",id=d,enemy=f,name=e.text("Enemy_"..d),
base=f,hp=f.hp,maxHp=f.hp,sp=0,maxSp=0,statuses={},boss=f.boss,
surveyed=state.known[d]==true,
}
c.enemies[#c.enemies+1]=k
c.combatants[#c.combatants+1]=k
end
c.parts={}
for o,d in ipairs(c.enemies)do
if d.enemy.parts then
d.broken={}
d.partFighters={}
for m,f in ipairs(d.enemy.parts)do
local k=math.floor(d.maxHp*a.PART_SHARE)
local l={
side="enemy",part=f.kind,index=m,owner=d,id=d.id,enemy=d.enemy,
name=e.text("BattleUses",d.name,e.text("Part_"..f.kind)),
base=d.base,hp=k,maxHp=k,sp=0,maxSp=0,statuses={},boss=true,
offset={x=f.x,y=f.y},surveyed=d.surveyed,
}
d.partFighters[#d.partFighters+1]=l
c.parts[#c.parts+1]=l
end
end
end
for l,d in ipairs(c.enemies)do
if g[d.id]>1 then
local f=0
for m,k in ipairs(c.enemies)do
if k.id==d.id then
f=f+1
if k==d then
break
end
end
end
d.name=d.name.." "..string.sub("ABCD",f,f)
end
end
for f,d in ipairs(c.combatants)do
d.ct=j(c:stat(d,"spd"))*(0.3+random:float()*0.7)
if d.charm and d.charm.early then
d.ct=d.ct*a.EARLY_START
end
end
return c
end

function a:stat(fighter,name)
local c=fighter.base[name]
for f,d in pairs(a.MODIFIERS)do
if d[1]==name and fighter.statuses[f]then
c=c*d[2]
end
end
if fighter.broken then
for f,d in pairs(a.BROKEN)do
if d[1]==name and fighter.broken[f]then
c=c*d[2]
end
end
end
return c
end

function a:enemyTargets()
local c={}
for g,d in ipairs(self:standing("enemy"))do
c[#c+1]=d
for i,f in ipairs(d.partFighters or{})do
if f.hp>0 then
c[#c+1]=f
end
end
end
return c
end

function a:breakPart(piece,outcome)
local c=piece.owner
c.broken[piece.part]=true
b.notePart(self.state,c.id,piece.part)
outcome.broken=piece
local d=math.floor(piece.maxHp*a.PART_BREAK_SHARE)
c.hp=math.max(0,c.hp-d)
outcome.ownerDamage=d
if c.hp<=0 then
c.statuses={}
outcome.ownerKo=true
end
end

function a.alive(fighter)
return fighter.hp>0
end

function a:standing(side)
local c={}
local d=self.party
if side=="enemy"then
d=self.enemies
end
for g,f in ipairs(d)do
if f.hp>0 then
c[#c+1]=f
end
end
return c
end

function a:fallen()
local c={}
for f,d in ipairs(self.party)do
if d.hp<=0 then
c[#c+1]=d
end
end
return c
end

function a:nextActor()
local c=nil
for f,d in ipairs(self.combatants)do
if d.hp>0 and(not c or d.ct<c.ct)then
c=d
end
end
local f=c.ct
for g,d in ipairs(self.combatants)do
if d.hp>0 then
d.ct=d.ct-f
end
end
return c
end

function a:requeue(fighter,weight)
fighter.ct=fighter.ct+j(self:stat(fighter,"spd"))*weight
end

function a:timeline(count)
local c={}
for f,d in ipairs(self.combatants)do
if d.hp>0 then
c[#c+1]={fighter=d,ct=d.ct}
end
end
local f={}
while#f<count and#c>0 do
local d=c[1]
for g=2,#c do
if c[g].ct<d.ct then
d=c[g]
end
end
f[#f+1]=d.fighter
d.ct=d.ct+j(self:stat(d.fighter,"spd"))
end
return f
end

function a:addGlow(amount)
if not b.glowKnown(self.state)then
return
end
self.state.glow=math.min(a.GLOW_MAX,self.state.glow+amount)
end

function a:elementMultiplier(target,element)
if target.side=="party"then
if element and target.wards[element]then
return a.WARD_MULT
end
return 1
end
local c=self.options.onlyElement
if c and element~=c then
return a.OFF_ELEMENT_MULT
end
if not element then
return 1
end
if target.enemy.weak==element then
return a.WEAK_MULT
elseif target.enemy.resist==element then
return a.RESIST_MULT
end
return 1
end

function a:noteElement(target,element)
if target.side~="enemy"or not element then
return
end
local c=self.options.onlyElement
if c and element~=c then
return
end
if target.enemy.weak==element then
b.noteFact(self.state,target.id,"weak")
elseif target.enemy.resist==element then
b.noteFact(self.state,target.id,"resist")
end
end

function a:noteSpoil(fighter,itemId)
local c=fighter.enemy
if c.drop and c.drop[1]==itemId then
b.noteFact(self.state,fighter.id,"drop")
end
if c.rare and c.rare[1]==itemId then
b.noteFact(self.state,fighter.id,"rare")
end
end

function a:noteVictory(drops)
for f,c in ipairs(self.enemies)do
if not c.fled then
b.noteDefeat(self.state,c.id)
for g,d in ipairs(drops)do
self:noteSpoil(c,d)
end
end
end
end

local function r(target,element)
return target.side=="enemy"and element~=nil and target.enemy.weak==element and(target.statuses.defDown~=nil or target.statuses.resDown~=nil)
end

local function o(target,element,damage)
local c=r(target,element)
if c then
damage=damage*a.SHARP_MULT
end
if target.statuses.veil then
damage=damage*0.5
end
if target.guarding then
damage=damage*0.5
end
return math.max(1,math.floor(damage)),c
end

function a:physicalDamage(user,target,power,element,critChance)
local f=self:stat(user,"atk")
local g=self:stat(target,"def")
local c=f*power-g*0.5
c=c*(0.9+self.random:float()*0.2)
local d=self.random:chance(critChance)
if d then
c=c*a.CRIT_MULT
end
c=c*self:elementMultiplier(target,element or"phys")
local i,k=o(target,element,c)
return i,d,k
end

function a:magicDamage(user,target,power,element)
local d=self:stat(user,"mag")
local f=self:stat(target,"res")
local c=(power+d)*(0.9+self.random:float()*0.2)-f*0.5
c=c*self:elementMultiplier(target,element)
return o(target,element,c)
end

function a:healAmount(user,target,power,ratio)
if ratio then
return math.floor(target.maxHp*math.min(1,power))
end
return math.floor(power+self:stat(user,"mag")*0.8)
end

function a:hurt(target,damage,outcome)
local c=0
if self.options.fleeBelow and target.side=="enemy"then
c=1
end
target.hp=math.max(c,target.hp-damage)
outcome.damage=(outcome.damage or 0)+damage
if target.statuses.sleep then
target.statuses.sleep=nil
end
if target.side=="party"then
self:addGlow(a.GLOW_HURT)
end
if target.hp<=0 then
outcome.ko=true
target.statuses={}
target.guarding=false
if target.part then
self:breakPart(target,outcome)
end
end
return outcome
end

function a:heal(target,amount,outcome)
local c=target.hp
target.hp=math.min(target.maxHp,target.hp+amount)
outcome.heal=(outcome.heal or 0)+(target.hp-c)
return outcome
end

function a:inflict(target,status,chance)
if target.hp<=0 then
return false
end
if target.guard==status then
return false
end
local d=e.indexOf(a.AILMENTS,status)~=nil
if d then
local c=chance
if target.boss then
if status=="sleep"or status=="stun"then
c=c*a.BOSS_STATUS
else
c=c*a.BOSS_DEBUFF
end
end
if not self.random:chance(c)then
return false
end
end
local c=a.OPPOSITE[status]
if c and target.statuses[c]then
target.statuses[c]=nil
return true
end
local f=a.DURATION[status]or a.BUFF_DURATION
target.statuses[status]=f
return true
end

function a:cure(target,only)
for d,c in ipairs(a.AILMENTS)do
if not only or only==c then
target.statuses[c]=nil
end
end
end

function a:targetsOf(user,kind,chosen)
local c,f="enemy","party"
if user.side=="enemy"then
c,f="party","enemy"
end
if kind=="enemies"then
return self:standing(c)
elseif kind=="allies"then
return self:standing(f)
elseif kind=="self"then
return{user}
elseif kind=="random"then
return self:standing(c)
elseif chosen and(chosen.hp>0 or kind=="fallen")then
return{chosen}
end
local d=self:standing(c)
if kind=="ally"then
d=self:standing(f)
elseif kind=="fallen"then
d=self:fallen()
end
if#d==0 then
return{}
end
return{d[1]}
end

function a:steal(target)
if target.side~="enemy"or target.part or target.stolen then
return nil
end
local c=target.enemy
if not c.drop and not c.rare then
return nil
end
local d=a.STEAL_CHANCE
if target.boss then
d=d*a.BOSS_DEBUFF
end
if not self.random:chance(d)then
return nil
end
target.stolen=true
if c.rare and(not c.drop or self.random:chance(a.STEAL_RARE))then
return c.rare[1]
end
return c.drop[1]
end

function a:strike(user,skill,target,element,outcome)
if skill.kind=="physical"then
local d=user.statuses.blind or(user.broken and user.broken.eye)
if(d and self.random:chance(a.BLIND_MISS))or self.random:chance(a.MISS_CHANCE)then
outcome.miss=true
return
end
local c=a.CRIT_CHANCE
if skill.crit then
c=1
elseif skill.critChance then
c=c+skill.critChance
end
local f,g,i=self:physicalDamage(user,target,skill.power,element,c)
outcome.crit=outcome.crit or g
outcome.sharp=outcome.sharp or i
self:hurt(target,f,outcome)
else
local c,d=self:magicDamage(user,target,skill.power,element)
outcome.sharp=outcome.sharp or d
self:hurt(target,c,outcome)
if skill.drain then
self:heal(user,math.floor(c/2),{target=user})
outcome.drained=math.floor(c/2)
end
end
if target.side=="enemy"and element and target.enemy.weak==element then
outcome.weak=true
end
if skill.kind=="physical"then
self:noteElement(target,element or"phys")
else
self:noteElement(target,element)
end
end

function a:applySkill(user,skill,target)
local c={target=target}
local d=skill.kind
if d=="physical"or d=="magic"then
for g,f in ipairs(skill.elements or{skill.element or false})do
if target.hp>0 and not c.miss then
self:strike(user,skill,target,f or nil,c)
end
end
elseif d=="heal"then
if target.hp>0 or skill.revive then
if target.hp<=0 then
c.revived=true
end
self:heal(target,self:healAmount(user,target,skill.power,skill.ratio),c)
end
elseif d=="revive"then
if target.hp<=0 then
c.revived=true
self:heal(target,math.max(1,math.floor(target.maxHp*skill.power)),c)
end
elseif d=="cure"then
self:cure(target)
c.cured=true
elseif d=="survey"then
target.surveyed=true
c.surveyed=true
b.markKnown(self.state,target.id)
elseif d=="drainSp"then
local f=math.min(target.sp,skill.power+math.floor(user.base.level or 0)/4)
target.sp=target.sp-math.floor(f)
c.spLost=math.floor(f)
elseif d=="steal"then
local f=self:steal(target)
if f then
b.addItem(self.state,f,1)
self:noteSpoil(target,f)
c.stole=f
else
c.miss=true
c.stealMissed=true
end
elseif d=="flee"then
target.hp=0
target.fled=true
c.fled=true
end
local f=target.owner or target
if skill.cure and f.hp>0 then
self:cure(f)
c.cured=true
end
if skill.status and f.hp>0 and not c.miss then
local i={skill.status,skill.also}
c.statuses={}
for k,g in ipairs(i)do
if self:inflict(f,g,skill.chance)then
c.statuses[#c.statuses+1]=g
end
end
end
return c
end

function a:brightOf(fighter)
local f=e.Characters.BY_ID[fighter.id]
local d=h.get(f.bright)
if not b.hasFlag(self.state,"t_"..fighter.id)then
return d
end
local c={}
for g,i in pairs(d)do
c[g]=i
end
c.power=d.power*a.BRIGHT_UP
c.upgraded=true
return c
end

function a:brightReady(fighter)
return b.hasFlag(self.state,"b_"..fighter.id)and self.state.glow>=a.GLOW_MAX
end

function a:duosOf(fighter)
local f={}
for l,g in ipairs(h.DUOS)do
local i=h.get(g)
local c=i.duo
local d=nil
if c[1]==fighter.id then
d=c[2]
elseif c[2]==fighter.id then
d=c[1]
end
if d and b.duoReady(self.state,g)then
for m,k in ipairs(self.party)do
if k.id==d and k.hp>0 then
f[#f+1]=i
end
end
end
end
return f
end

function a:useSkill(user,skill,chosen)
local c={}
if user.side=="enemy"and e.indexOf(n.techniques(user.id),skill.id)then
b.noteAct(self.state,user.id,skill.id)
end
if skill.bright then
self.state.glow=0
elseif skill.duo then
self.state.glow=self.state.glow-h.DUO_GLOW
elseif user.side=="party"then
user.sp=user.sp-skill.cost
end
if skill.target=="random"then
for g=1,skill.hits or 1 do
local d=self:targetsOf(user,"enemies")
if#d==0 then
break
end
local f=d[self.random:int(1,#d)]
c[#c+1]=self:applySkill(user,skill,f)
end
else
local d=self:targetsOf(user,skill.target,chosen)
if skill.revive and skill.target=="allies"then
d=user.side=="party"and self.party or self.enemies
end
for g,f in ipairs(d)do
for i=1,skill.hits or 1 do
if f.hp>0 or skill.target=="fallen"or skill.revive then
c[#c+1]=self:applySkill(user,skill,f)
end
end
end
end
if skill.healParty then
for f,d in ipairs(self:standing(user.side))do
c[#c+1]=self:heal(d,math.floor(d.maxHp*skill.healParty),{target=d})
end
end
if skill.reviveParty then
for f,d in ipairs(self:fallen())do
c[#c+1]=self:heal(d,math.floor(d.maxHp*skill.reviveParty),{target=d,revived=true})
end
end
if skill.partyStatus then
for i,f in ipairs(self:standing(user.side))do
local d={}
for k,g in ipairs({skill.partyStatus,skill.partyAlso})do
self:inflict(f,g,1)
d[#d+1]=g
end
c[#c+1]={target=f,statuses=d}
end
end
if user.side=="party"and not skill.bright and not skill.duo then
self:glowFrom(user,c)
end
return c
end

function a:glowFrom(user,outcomes)
local i,d,f,g=false,false,false,0
for k,c in ipairs(outcomes)do
if c.damage and c.target.side=="enemy"then
i=true
g=g+1
d=d or c.weak==true
f=f or c.sharp==true
end
end
if not i then
return
end
local c=a.GLOW_ACT
if d then
c=c+a.GLOW_WEAK
end
if f then
c=c+a.GLOW_SHARP
end
if user.charm and user.charm.glowHit then
c=c+user.charm.glowHit*g
end
self:addGlow(c)
end

function a.attackSkill(fighter)
local d={id="attack",cost=0,target="enemy",kind="physical",power=1,fx="hit"}
local c=fighter.side=="party"and fighter.weapon
if c then
d.element=c.element
d.critChance=c.crit
if c.onHit then
d.status=c.onHit[1]
d.chance=c.onHit[2]
end
if c.element=="flame"then
d.fx="flame"
elseif c.element=="sound"then
d.fx="ring"
elseif c.element=="murk"then
d.fx="murk"
end
end
return d
end

function a:useItem(user,itemId,chosen)
local d=q.get(itemId)
b.takeItem(self.state,itemId,1)
local i={}
local k=self:targetsOf(user,d.target,chosen)
for p,c in ipairs(k)do
local f={target=c}
local g=d.effect
if g=="heal"and c.hp>0 then
self:heal(c,d.power,f)
elseif g=="sp"and c.hp>0 then
local l=c.sp
c.sp=math.min(c.maxSp,c.sp+d.power)
f.spGained=c.sp-l
elseif g=="revive"and c.hp<=0 then
f.revived=true
self:heal(c,math.max(1,math.floor(c.maxHp*d.power)),f)
elseif g=="cure"then
self:cure(c,d.status)
f.cured=true
elseif g=="glow"then
self:addGlow(d.power)
f.glow=d.power
elseif g=="buff"or g=="debuff"then
f.statuses={}
if self:inflict(c,d.status,d.chance)then
f.statuses[1]=d.status
else
f.resisted=true
end
elseif g=="damage"then
local l,m=self:magicDamage(user,c,d.power,d.element)
f.sharp=m
self:hurt(c,l,f)
self:noteElement(c,d.element)
if d.status and c.hp>0 and self:inflict(c,d.status,d.chance)then
f.statuses={d.status}
end
end
i[#i+1]=f
end
return i
end

function a:tryEscape()
if self.options.noEscape then
return false
end
local function d(list)
local c=0
for g,f in ipairs(list)do
c=c+self:stat(f,"spd")
end
return c/math.max(1,#list)
end
local c=0.55+0.02*(d(self:standing("party"))-d(self:standing("enemy")))
return self.random:chance(SpiffBoy.clamp(c,0.2,0.95))
end

function a:actFits(fighter,act)
local c=act[3]
if not c then
return true
end
if c.below and fighter.hp/fighter.maxHp>=c.below then
return false
end
if c.unless then
if c.foe then
for f,d in ipairs(self:standing("party"))do
if not d.statuses[c.unless]then
return true
end
end
return false
end
return not fighter.statuses[c.unless]
end
return true
end

function a:actLost(fighter,act,acts)
local c=fighter.broken
if not c or act[1]=="attack"then
return false
end
local f=h.get(act[1])
if c.arm and f.kind=="physical"then
return true
end
if c.jaw and a.JAW_ACTS[act[1]]then
return true
end
if c.core and f.kind=="magic"then
local g=0
for k,i in ipairs(acts)do
local d=i[1]~="attack"and h.get(i[1])
if d and d.kind=="magic"and d.power>g then
g=d.power
end
end
return f.power>=g
end
return false
end

function a:enemyAction(fighter)
local f=fighter.enemy.acts
if fighter.enemy.acts2 and fighter.hp<fighter.maxHp*a.PHASE_SHARE then
f=fighter.enemy.acts2
end
if self.options.fleeBelow and fighter.hp<fighter.maxHp*self.options.fleeBelow then
f={{"flee",1}}
end
local c=e.filter(f,function(act)return self:actFits(fighter,act)and not self:actLost(fighter,act,f)end)
if#c==0 then
c={{"attack",1}}
end
local k=0
for g,d in ipairs(c)do
k=k+d[2]
end
local l=self.random:int(1,k)
local m=c[1][1]
for g,d in ipairs(c)do
l=l-d[2]
if l<=0 then
m=d[1]
break
end
end
local d
if m=="attack"then
d=a.attackSkill(fighter)
else
d=h.get(m)
end
if d.kind=="flee"then
return{kind="skill",skill=d,target=fighter}
end
local g=self:standing("party")
local i=g[self.random:int(1,#g)]
if self.random:chance(a.AIM_WEAKEST)then
for s,p in ipairs(g)do
if p.hp<i.hp then
i=p
end
end
end
for s,p in ipairs(g)do
if p.statuses.taunt then
i=p
end
end
return{kind="skill",skill=d,target=i}
end

function a:endTurn(fighter)
local c=nil
if fighter.hp>0 and fighter.statuses.soot then
c={target=fighter}
self:hurt(fighter,math.max(1,math.floor(fighter.maxHp*a.SOOT_SHARE*(fighter.boss and 0.25 or 1))),c)
end
if fighter.hp>0 and fighter.statuses.regen then
c=c or{target=fighter}
self:heal(fighter,math.max(1,math.floor(fighter.maxHp*a.REGEN_SHARE)),c)
end
for d,f in pairs(fighter.statuses)do
if d~="stun"and d~="sleep"then
if f<=1 then
fighter.statuses[d]=nil
else
fighter.statuses[d]=f-1
end
end
end
return c
end

function a:tickSleep(fighter)
local c=fighter.statuses.sleep
if c<=1 then
fighter.statuses.sleep=nil
else
fighter.statuses.sleep=c-1
end
end

function a:outcome()
if#self:standing("enemy")==0 then
return"win"
end
if#self:standing("party")==0 then
return"lose"
end
return nil
end

function a:syncParty()
for d,c in ipairs(self.party)do
c.member.hp=math.max(0,c.hp)
c.member.sp=math.max(0,c.sp)
end
end

function a:spoils()
local d,g,f=0,0,{}
for l,c in ipairs(self.enemies)do
if not c.fled then
d=d+c.enemy.xp
for i in pairs(c.broken or{})do
d=d+math.floor(c.enemy.xp*a.PART_XP)
end
g=g+c.enemy.gold
local i=c.enemy.drop
local k=c.enemy.rare
if k and self.random:chance(k[2])then
f[#f+1]=k[1]
elseif i and not c.stolen and self.random:chance(i[2])then
f[#f+1]=i[1]
end
end
end
return d,g,f
end
