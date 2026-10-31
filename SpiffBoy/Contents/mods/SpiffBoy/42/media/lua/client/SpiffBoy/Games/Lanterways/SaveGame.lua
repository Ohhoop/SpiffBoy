require"SpiffBoy/Games/Lanterways/Base"
require"SpiffBoy/Games/Lanterways/Party"
require"SpiffBoy/Games/Lanterways/Data/Flags"
require"SpiffBoy/Games/Lanterways/Data/Enemies"
require"SpiffBoy/Games/Lanterways/Field"

local b=SpiffBoy.Lanterways
local f=b.Characters
local e=b.Items
local h=b.Party
local s=b.Flags

local a={}
b.SaveGame=a

a.SLOTS=3
a.VERSION=4
a.VERSION_BEFORE_STUDY=3
a.STUDY_WIDTH=5
a.MAX_NG=99
a.CLEARED_STEP=21
a.CHUNK=120
a.MAX_TIME=359999

local i="0123456789abcdef"

local function c(value,low,high)
return SpiffBoy.isInteger(value)and value>=low and value<=high
end

local function m(set,names)
local j={}
local d=1
while d<=#names do
local g=0
for k=0,3 do
local l=names[d+k]
if l and set[l]then
g=g+2^k
end
end
j[#j+1]=string.sub(i,g+1,g+1)
d=d+4
end
return table.concat(j)
end

local function n(text,names)
if type(text)~="string"or string.find(text,"[^0-9a-f]")then
return nil
end
local g={}
for d=1,string.len(text)do
local l=string.find(i,string.sub(text,d,d),1,true)-1
for j=0,3 do
local k=names[(d-1)*4+j+1]
if k and math.floor(l/2^j)%2==1 then
g[k]=true
end
end
end
return g
end

local function F(bonds)
local d={}
for j,g in ipairs(b.Skills.DUOS)do
d[#d+1]=bonds[g]or 0
end
return table.concat(d,",")
end

local function G(text)
if type(text)~="string"then
return nil
end
local j={}
local d=0
for l in string.gmatch(text,"[^,]+")do
d=d+1
local g=tonumber(l)
local k=b.Skills.DUOS[d]
if not k or not c(g,0,b.Skills.BOND_CAP)then
return nil
end
if g>0 then
j[k]=g
end
end
if d~=#b.Skills.DUOS then
return nil
end
return j
end

local t={"weak","resist","drop","rare"}

local function o(set,names)
local d=0
for g,j in ipairs(names)do
if set[j]then
d=d+2^(g-1)
end
end
return d
end

local function p(value,names)
if value>=2^#names then
return nil
end
local d={}
for g,j in ipairs(names)do
if math.floor(value/2^(g-1))%2==1 then
d[j]=true
end
end
return d
end

local function j(value,count)
local d=""
for k=1,count do
local g=value%16
d=string.sub(i,g+1,g+1)..d
value=math.floor(value/16)
end
return d
end

local function k(digits)
local d=0
for g=1,string.len(digits)do
d=d*16+string.find(i,string.sub(digits,g,g),1,true)-1
end
return d
end

local function u(enemyId)
local d={}
for l,g in ipairs(b.Enemies.LIST[enemyId].parts or{})do
d[#d+1]=g.kind
end
return d
end

local function H(study)
local g={}
for q,l in ipairs(b.Enemies.ORDER)do
local d=study[l]or{kills=0,acts={},parts={}}
g[#g+1]=j(d.kills,1)..j(o(d,t),1)
..j(o(d.acts,b.Enemies.techniques(l)),2)..j(o(d.parts,u(l)),1)
end
local l=table.concat(g)
local d={}
for q=1,string.len(l),a.CHUNK do
d[#d+1]=string.sub(l,q,q+a.CHUNK-1)
end
return d
end

local function I(chunks)
if type(chunks)~="table"then
return nil
end
for g,d in ipairs(chunks)do
if type(d)~="string"then
return nil
end
end
local l=table.concat(chunks)
if string.len(l)~=#b.Enemies.ORDER*a.STUDY_WIDTH or string.find(l,"[^0-9a-f]")then
return nil
end
local r={}
for v,q in ipairs(b.Enemies.ORDER)do
local d=string.sub(l,(v-1)*a.STUDY_WIDTH+1,v*a.STUDY_WIDTH)
local w=k(string.sub(d,1,1))
local g=p(k(string.sub(d,2,2)),t)
local x=p(k(string.sub(d,3,4)),b.Enemies.techniques(q))
local y=p(k(string.sub(d,5,5)),u(q))
if w>h.STUDY_KILLS_CAP or not g or not x or not y then
return nil
end
if d~="00000"then
g.kills,g.acts,g.parts=w,x,y
r[q]=g
end
end
return r
end

function a.encodeFlags(flags)
return m(flags,s.NAMES)
end

function a.decodeFlags(text)
return n(text,s.NAMES)
end

local function q(id)
if not id then
return 0
end
return e.get(id).code
end

local function J(code)
if code==0 then
return nil
end
return e.CODES[code]or false
end

local function v(member)
return table.concat({
member.level,member.xp,member.hp,member.sp,
q(member.equip.weapon),q(member.equip.armor),q(member.equip.charm),
},",")
end

local function w(id,text)
if type(text)~="string"then
return nil
end
local d={}
for l in string.gmatch(text,"[^,]+")do
local g=tonumber(l)
if not g then
return nil
end
d[#d+1]=g
end
if#d~=7 then
return nil
end
local r,x,y,z=d[1],d[2],d[3],d[4]
if not c(r,1,b.LEVEL_CAP)or not c(x,0,99999999)or not c(y,0,99999)or not c(z,0,99999)then
return nil
end
local D=f.BY_ID[id]
local g={}
for A,B in ipairs(h.SLOTS)do
if not c(d[4+A],0,#e.ORDER)then
return nil
end
local l=J(d[4+A])
if l==false then
return nil
end
if l then
local C=e.get(l)
if C.kind~=B or not e.fits(D,C)then
return nil
end
end
g[B]=l
end
if not g.weapon or not g.armor then
return nil
end
local l={id=id,level=r,xp=x,hp=y,sp=z,equip=g}
h.clamp(l)
return l
end

local function K(items)
local g={}
local d=""
for y,x in ipairs(e.ORDER)do
local l=items[x]
if l and l>0 then
local r=e.get(x).code..":"..l
if d~=""and string.len(d)+string.len(r)+1>a.CHUNK then
g[#g+1]=d
d=""
end
if d==""then
d=r
else
d=d..","..r
end
end
end
if d~=""then
g[#g+1]=d
end
return g
end

local function L(chunks)
if type(chunks)~="table"then
return nil
end
local d={}
for A,g in ipairs(chunks)do
if type(g)~="string"then
return nil
end
for x,y in string.gmatch(g,"(%d+):(%d+)")do
local z,l=tonumber(x),tonumber(y)
local r=e.CODES[z]
if not r or not c(l,1,e.MAX_STACK)then
return nil
end
d[r]=l
end
end
return d
end

function a.encode(state)
local g={}
local d=""
for x,l in ipairs(state.order)do
local r=f.BY_ID[l]
g[r.code]=v(state.members[l])
d=d..r.code
end
local l={}
for r,x in pairs(state.carry)do
l[f.BY_ID[r].code]=v(x)
end
local r={
v=a.VERSION,
step=state.step,
map=state.map,
x=state.x,
y=state.y,
d=state.dir,
gold=state.gold,
time=math.min(a.MAX_TIME,math.floor(state.time)),
flags=a.encodeFlags(state.flags),
order=d,
m=g,
items=K(state.items),
seen=m(state.seen,b.Enemies.ORDER),
known=m(state.known,b.Enemies.ORDER),
study=H(state.study),
bonds=F(state.bonds),
ng=state.ng,
c=l,
}
if state.inn then
r.inn=state.inn.map..","..state.inn.x..","..state.inn.y
end
return r
end

function a.decode(slot)
if type(slot)~="table"or(slot.v~=a.VERSION and slot.v~=a.VERSION_BEFORE_STUDY)then
return nil
end
local l={}
if slot.v==a.VERSION then
l=I(slot.study)
if not l then
return nil
end
end
if not c(slot.step,0,999)or type(slot.map)~="string"or not b.Maps[slot.map]then
return nil
end
local r=b.Field.prepare(b.Maps[slot.map])
if not c(slot.x,0,r.width-1)or not c(slot.y,0,r.height-1)or not c(slot.d,1,4)then
return nil
end
if not c(slot.gold,0,h.GOLD_CAP)or not c(slot.time,0,a.MAX_TIME)or not c(slot.ng,0,a.MAX_NG)then
return nil
end
local x=a.decodeFlags(slot.flags)
local y=L(slot.items)
local z=n(slot.seen,b.Enemies.ORDER)
local A=n(slot.known,b.Enemies.ORDER)
local B=G(slot.bonds)
if not x or not y or not z or not A or not B or type(slot.order)~="string"or type(slot.m)~="table"or type(slot.c)~="table"then
return nil
end
local d={
step=slot.step,flags=x,gold=slot.gold,items=y,members={},order={},
glow=0,map=slot.map,x=slot.x,y=slot.y,dir=slot.d,time=slot.time,
seen=z,known=A,study=l,bonds=B,ng=slot.ng,carry={},
}
for C,E in pairs(slot.c)do
local g=type(C)=="string"and f.BY_CODE[C]
if not g then
return nil
end
local D=w(g.id,E)
if not D then
return nil
end
d.carry[g.id]=D
end
for C=1,string.len(slot.order)do
local D=string.sub(slot.order,C,C)
local g=f.BY_CODE[D]
if not g or d.members[g.id]then
return nil
end
local E=w(g.id,slot.m[D])
if not E then
return nil
end
d.members[g.id]=E
d.order[#d.order+1]=g.id
end
if d.order[1]~="pell"then
return nil
end
for g in pairs(d.carry)do
if d.members[g]then
return nil
end
end
if slot.inn~=nil then
if type(slot.inn)~="string"then
return nil
end
local g,C,D=string.match(slot.inn,"^(%a+),(%d+),(%d+)$")
if not g or not b.Maps[g]then
return nil
end
d.inn={map=g,x=tonumber(C),y=tonumber(D)}
end
return d
end

function a.summary(slot)
local d=a.decode(slot)
if not d then
return nil
end
return{level=d.members.pell.level,map=d.map,time=d.time,step=d.step,order=d.order,cleared=a.cleared(d)}
end

function a.cleared(state)
return state.step>=a.CLEARED_STEP
end
