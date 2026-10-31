require"SpiffBoy/Games/QuickStart/Base"
require"SpiffBoy/Games/QuickStart/Maps/Circuits"
require"SpiffBoy/Games/QuickStart/Art"

local j=SpiffBoy.QuickStart

local a={}
j.Tracks=a

local l=j.TILE
local m=string.byte
local b=math.floor

a.ROAD="road"
a.OFFROAD="offroad"
a.MUD="mud"
a.WATER="water"
a.WALL="wall"
a.BOOST="boost"
a.RAMP="ramp"

a.DECOR_CELL=64
a.SOLID_CELL=32
a.SOLID_MARGIN=4
a.UNIT=256

a.CHECKER=-1
a.STRIPES=-2

local g=a.CHECKER
local d=a.STRIPES

local k,q,v,w,r,z,A=a.ROAD,a.OFFROAD,a.MUD,a.WATER,a.WALL,a.BOOST,a.RAMP

local function e(clear,sky,shades,surfaces)
local c,f={},{}
for h,i in pairs(shades)do
c[m(h)]=i
end
for h,i in pairs(surfaces)do
f[m(h)]=i
end
return{clear=m(clear),sky=sky,shades=c,surfaces=f}
end

local B={["#"]=k,c=k,k=k,f=k,w=k,s=k,b=z,r=A,o=v,["~"]=w,["="]=r,["."]=q}

local function f(changes)
local c={}
for h,i in pairs(B)do
c[h]=i
end
for h,i in pairs(changes or{})do
c[h]=i
end
return c
end

a.STYLES={
town=e(".","sky_town",{["."]=3,["#"]=2,c=4,w=4,o=2,s=g,b=d,r=1},f()),
docks=e("~","sky_docks",{["~"]=1,["."]=2,["#"]=3,w=4,o=2,s=g,b=d,r=1},f()),
woods=e(".","sky_woods",{["."]=1,["#"]=3,k=4,f=1,o=2,s=g,b=d,r=2},f()),
farm=e(".","sky_farm",{["."]=3,["#"]=4,w=2,["~"]=1,s=g,b=d,r=2},f()),
mall=e(".","sky_mall",{["."]=2,["#"]=3,c=4,w=4,s=g,b=d,r=1},f({w=q})),
prison=e(".","sky_prison",{["."]=4,["#"]=2,k=1,f=4,["="]=1,s=g,b=d,r=1},f()),
highway=e(".","sky_highway",{["."]=3,["#"]=1,c=4,w=2,s=g,b=d,r=2},f()),
military=e(".","sky_military",{["."]=4,["#"]=2,k=1,f=4,w=3,["="]=1,s=g,b=d,r=1},f()),
station=e("#","sky_station",{["#"]=2,["="]=4,w=4,c=3,o=1,b=d,["."]=3},f({w=r})),
lot=e("#","sky_lot",{["#"]=2,["="]=4,w=4,["."]=3,b=d},f()),
}

a.DECOR={
house={art="house",radius=10},tree={art="tree",radius=4},lamp={art="lamp",radius=2},
mailbox={art="mailbox",radius=2},car={art="car",radius=7},bollard={art="bollard",radius=2},
crate_stack={art="crate_stack",radius=6},barrel={art="barrel",radius=3},boat={art="boat",radius=0},
buoy={art="buoy",radius=0},pine={art="pine",radius=4},stump={art="stump",radius=3},
rock={art="rock",radius=5},fence={art="fence",radius=3},hay={art="hay",radius=5},
scarecrow={art="scarecrow",radius=2},corn={art="corn",radius=3},barn={art="barn",radius=20},
silo={art="silo",radius=10},cart={art="cart",radius=3},cone={art="cone",radius=2},
sign={art="sign",radius=2},fencepost={art="fencepost",radius=2},light={art="light",radius=2},
tower={art="tower",radius=8},bench={art="bench",radius=3},guardrail={art="guardrail",radius=3},
billboard={art="billboard",radius=4},sandbag={art="sandbag",radius=5},tank={art="tank",radius=12},
barracks={art="barracks",radius=18},jeep={art="jeep",radius=7},pump={art="pump",radius=4},
house2={art="house2",radius=10},
garage_house={art="garage_house",radius=12},
picket={art="picket",radius=3},
hydrant={art="hydrant",radius=2},
trashcans={art="trashcans",radius=2},
busstop={art="busstop",radius=6},
policecar={art="policecar",radius=7},
warehouse={art="warehouse",radius=16},
container={art="container",radius=7},
quaycrane={art="quaycrane",radius=6},
forklift={art="forklift",radius=4},
pallets={art="pallets",radius=4},
shack={art="shack",radius=5},
cabin={art="cabin",radius=9},
logpile={art="logpile",radius=5},
fallenlog={art="fallenlog",radius=6},
bush={art="bush",radius=3},
camp={art="camp",radius=5},
deerstand={art="deerstand",radius=3},
tractor={art="tractor",radius=5},
windmill={art="windmill",radius=3},
well={art="well",radius=3},
coop={art="coop",radius=4},
pumpkins={art="pumpkins",radius=0},
wagon={art="wagon",radius=6},
van={art="van",radius=7},
pickup={art="pickup",radius=7},
cartcorral={art="cartcorral",radius=5},
planter={art="planter",radius=3},
mallsign={art="mallsign",radius=3},
barricade={art="barricade",radius=4},
barbed={art="barbed",radius=3},
prisonbus={art="prisonbus",radius=12},
hoop={art="hoop",radius=2},
weights={art="weights",radius=3},
booth={art="booth",radius=4},
searchlight={art="searchlight",radius=2},
pillar={art="pillar",radius=4},
jersey={art="jersey",radius=6},
truck={art="truck",radius=12},
burningcar={art="burningcar",radius=7},
bus={art="bus",radius=13},
exitsign={art="exitsign",radius=2},
helipad={art="helipad",radius=10},
humvee={art="humvee",radius=7},
ammo={art="ammo",radius=3},
armytent={art="armytent",radius=8},
radar={art="radar",radius=3},
flagpole={art="flagpole",radius=1},
carwash={art="carwash",radius=0},
icebox={art="icebox",radius=4},
propane={art="propane",radius=4},
tires={art="tires",radius=3},
statue={art="statue",radius=4},
drivethru={art="drivethru",radius=2},
picnic={art="picnic",radius=4},
storefront={art="storefront",radius=0},
spiffos={art="spiffos",radius=0},
dumpster={art="dumpster",radius=5},
}

local function C(objects,extent)
local i=a.DECOR_CELL
local c=math.ceil(extent/i)
local n={}
for h=1,c*c do
n[h]={}
end
for x,h in ipairs(objects)do
if a.DECOR[h.kind]then
local o="decor_"..h.kind
local s={art=o,entry=j.Atlas[o],x=h.x,y=h.y}
local t=math.min(c-1,math.max(0,b(h.x/i)))
local u=math.min(c-1,math.max(0,b(h.y/i)))
local p=n[u*c+t+1]
p[#p+1]=s
end
end
return n,c
end

local function D(objects,extent)
local i=a.SOLID_CELL
local h=math.ceil(extent/i)
local p={}
for c=1,h*h do
p[c]={}
end
for H,c in ipairs(objects)do
local n=a.DECOR[c.kind]
if n and n.radius>0 then
local t={x=c.x*a.UNIT,y=c.y*a.UNIT,radius=n.radius*a.UNIT}
local o=n.radius+a.SOLID_MARGIN+1
local u,x=math.max(0,b((c.x-o)/i)),math.min(h-1,b((c.x+o)/i))
local y,E=math.max(0,b((c.y-o)/i)),math.min(h-1,b((c.y+o)/i))
for F=y,E do
for G=u,x do
local s=p[F*h+G+1]
s[#s+1]=t
end
end
end
end
return p,h
end

function a.solidsNear(track,x,y)
local n=a.SOLID_CELL*a.UNIT
local c,h=b(x/n),b(y/n)
local i=track.solidCount
if c<0 or h<0 or c>=i or h>=i then
return track.noSolids
end
return track.solidCells[h*i+c+1]
end

local function E(row,cells,base,size,mirrored,id)
local c=0
local i,p=1,#row
while i<=p do
local s=m(row,i)
local h=i+1
local n=0
while h<=p do
local o=m(row,h)-48
if o<0 or o>9 then
break
end
n=n*10+o
h=h+1
end
for t=1,n do
local o=c+t-1
local u=mirrored and(size-1-o)or o
cells[base+u+1]=s
end
c=c+n
i=h
end
if c~=size then
error("QuickStart: a row of map "..id.." decodes to "..c.." tiles instead of "..size)
end
end

local function o(list,extent,mirrored)
local h={}
for i,c in ipairs(list or{})do
h[i]={x=mirrored and(extent-c[1])or c[1],y=c[2]}
end
return h
end

local function F(list,extent,mirrored)
local h={}
for i,c in pairs(list or{})do
h[i]={points=o(c.points,extent,mirrored),loopFrom=c.loop[1],loopLength=c.loop[2]}
end
return h
end

local function G(id,mirrored)
local c=j.Maps[id]
if not c then
error("QuickStart: no map named "..tostring(id))
end
local i=c.size
local s={}
for h=1,i do
E(c.rows[h],s,(h-1)*i,i,mirrored,id)
end
local h=i*l
local p={}
for t,n in ipairs(c.objects)do
p[t]={kind=n[1],x=mirrored and(h-n[2])or n[2],y=n[3]}
end
local n=a.STYLES[c.style]
if not n then
error("QuickStart: map "..id.." has no style "..tostring(c.style))
end
local x,y=C(p,h)
local H,I=D(p,h)
local t={}
local J=n.shades[n.clear]
for u=1,i*i do
t[u]=n.shades[s[u]]or J
end
return{
id=id,kind=c.kind,mirrored=mirrored,size=i,extent=h,cells=s,style=n,shadeGrid=t,
decorCells=x,decorCount=y,solidCells=H,solidCount=I,noSolids={},
waypoints=o(c.waypoints,h,mirrored),spawns=o(c.spawns,h,mirrored),
targets=o(c.targets,h,mirrored),paths=F(c.paths,h,mirrored),objects=p,
}
end

local n="m"
local p="n"

j.LoadedTracks=setmetatable({},{
__index=function(loaded,key)
local c,i=string.match(key,"^(.*)|([mn])$")
if not c then
return nil
end
local h=G(c,i==n)
rawset(loaded,key,h)
return h
end,
})

function a.load(id,mirrored)
local c=p
if mirrored then
c=n
end
return j.LoadedTracks[id.."|"..c]
end

function a.at(track,x,y)
local c,h=b(x/l),b(y/l)
local i=track.size
if c<0 or h<0 or c>=i or h>=i then
return track.style.clear
end
return track.cells[h*i+c+1]
end

function a.surfaceAt(track,x,y)
local c,h=b(x/l),b(y/l)
local i=track.size
if c<0 or h<0 or c>=i or h>=i then
return r
end
return track.style.surfaces[track.cells[h*i+c+1]]or q
end
