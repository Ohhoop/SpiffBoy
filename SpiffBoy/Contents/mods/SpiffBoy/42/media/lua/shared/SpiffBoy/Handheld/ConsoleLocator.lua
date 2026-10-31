require"SpiffBoy/Core/Core"

SpiffBoy.ConsoleLocator=SpiffBoy.ConsoleLocator or{}
local a=SpiffBoy.ConsoleLocator

a.PLAYER="player"
a.VEHICLE="vehicle"
a.SQUARE="square"
a.REACH=2

local k="EngineDoor"

local function f(square)
return{kind=a.SQUARE,x=square:getX(),y=square:getY(),z=square:getZ(),inRoom=square:getRoom()~=nil}
end

local function l(item)
local b=0
local e=item
while e do
local h=e:getWorldItem()
if h then
return f(h:getSquare()),b
end
local c=e:getContainer()
if not c then
return nil,b
end
local i=c:getContainingItem()
if i then
b=b+1
e=i
else
local d=c:getParent()
if d and instanceof(d,"IsoGameCharacter")then
return{kind=a.PLAYER,character=d},b
end
local g=c:getVehiclePart()
if g then
if g:getContainerSeatNumber()<0 then
b=b+1
end
local j=g:getVehicle()
return{kind=a.VEHICLE,vehicle=j,id=j:getId()},b
end
b=b+1
if d then
local j=d:getSquare()
if not j then
return nil,b
end
return f(j),b
end
local j=c:getSourceGrid()
if j then
return f(j),b
end
return nil,b
end
end
return nil,b
end

function a.anchorOf(item)
local b,c=l(item)
return b,math.min(c,SpiffBoy.MAX_ENCLOSURES)
end

function a.spaceOf(object)
local b=nil
if instanceof(object,"BaseVehicle")then
b=object
elseif instanceof(object,"IsoGameCharacter")then
b=object:getVehicle()
end
if b then
if a.isShut(b)then
return b
end
return SpiffBoy.buildingOf(b:getSquare())
end
return SpiffBoy.buildingOf(object)
end

function a.isShut(vehicle)
local c=0
for g=0,vehicle:getPartCount()-1 do
local b=vehicle:getPartByIndex(g)
local e=b:getDoor()
if e and b:getId()~=k and(e:isOpen()or not b:getInventoryItem())then
return false
end
local d=b:getWindow()
if d then
if d:isOpen()or d:isDestroyed()or not b:getInventoryItem()then
return false
end
c=c+1
end
end
return c>0
end

function a.placeOf(anchor)
if anchor.kind==a.SQUARE then
return{x=anchor.x,y=anchor.y,z=anchor.z}
end
if anchor.kind==a.VEHICLE then
return{v=anchor.id}
end
return nil
end

function a.writePlace(args,place)
if not place then
return
end
args.x=place.x
args.y=place.y
args.z=place.z
args.v=place.v
end

function a.findAtPlace(args,id)
if SpiffBoy.isInteger(args.v)then
local b=getVehicleById(args.v)
if not b then
return nil
end
local c=a.findInVehicle(b,id)
if c then
return c,b
end
return nil
end
if not(SpiffBoy.isInteger(args.x)and SpiffBoy.isInteger(args.y)and SpiffBoy.isInteger(args.z))then
return nil
end
local b=getCell():getGridSquare(args.x,args.y,args.z)
if not b then
return nil
end
local c=a.findOnSquare(b,id)
if c then
return c,b
end
return nil
end

local function c(container,id)
if not container then
return nil
end
return container:getItemWithIDRecursiv(id)
end

function a.findOnSquare(square,id)
local d=square:getWorldObjects()
for g=0,d:size()-1 do
local b=d:get(g):getItem()
if b then
if b:getID()==id then
return b
end
if instanceof(b,"InventoryContainer")then
local e=c(b:getInventory(),id)
if e then
return e
end
end
end
end
local b=square:getObjects()
for h=0,b:size()-1 do
local e=b:get(h)
for i=0,e:getContainerCount()-1 do
local g=c(e:getContainerByIndex(i),id)
if g then
return g
end
end
end
local e=square:getVehicleContainer()
if e then
return a.findInVehicle(e,id)
end
return nil
end

function a.findInVehicle(vehicle,id)
for d=0,vehicle:getPartCount()-1 do
local b=c(vehicle:getPartByIndex(d):getItemContainer(),id)
if b then
return b
end
end
return nil
end

function a.findAround(x,y,z,id)
local e=getCell()
for g=-a.REACH,a.REACH do
for h=-a.REACH,a.REACH do
local b=e:getGridSquare(x+h,y+g,z)
if b then
local d=a.findOnSquare(b,id)
if d then
return d,b
end
end
end
end
return nil
end
