require"luautils"
require"SpiffBoy/Core/Random"

SpiffBoy=SpiffBoy or{}

SpiffBoy.API_VERSION=1
SpiffBoy.COMMAND_MODULE="SpiffBoy"
SpiffBoy.MOD_ID="SpiffBoy"
SpiffBoy.MOD_DATA_KEY="SpiffBoy"
SpiffBoy.CONSOLE_ITEM="Base.VideoGame"
SpiffBoy.BATTERY_ITEM="Base.Battery"
SpiffBoy.CABLE_ITEM="SpiffBoy.LinkCable"
SpiffBoy.TICK_RATE=60
SpiffBoy.TICK_MS=1000/SpiffBoy.TICK_RATE
SpiffBoy.MAX_FRAME_MS=100
SpiffBoy.REACH={base=8,roomShare=0.4,roomFloor=3,outsideFloor=5}
SpiffBoy.MAX_REACH=SpiffBoy.REACH.outsideFloor+SpiffBoy.REACH.base
SpiffBoy.HEAR_LEVELS=1
SpiffBoy.MUFFLE={gain=0.5,range=0.5}
SpiffBoy.MAX_HOSTED=3
SpiffBoy.MAX_SOUNDING=SpiffBoy.MAX_HOSTED*2
SpiffBoy.MAX_PAUSED=5
SpiffBoy.MAX_ENCLOSURES=4
SpiffBoy.BYTE_MAX=255

local b="-DEV"

function SpiffBoy.isDevBuild()
return luautils.stringEnds(SpiffBoy.MOD_ID,b)
end

local c={[5]=2,[20]=4,[40]=6}
local d=1

function SpiffBoy.consoleRate()
return c[getGameTime():getTrueMultiplier()]or d
end

function SpiffBoy.log(message)
print("SpiffBoy: "..tostring(message))
end

function SpiffBoy.trace(message)
if SpiffBoy.isDevBuild()then
SpiffBoy.log(message)
end
end

function SpiffBoy.clamp(value,low,high)
return math.max(low,math.min(high,value))
end

function SpiffBoy.buildingOf(object)
local a=nil
if instanceof(object,"IsoGridSquare")then
a=object
elseif instanceof(object,"IsoGameCharacter")then
a=object:getCurrentSquare()
end
if not a then
return nil
end
return a:getBuilding()
end

function SpiffBoy.withinHearing(listener,source,reach)
if math.abs(math.floor(listener:getZ())-math.floor(source:getZ()))>SpiffBoy.HEAR_LEVELS then
return false
end
local a=math.abs(listener:getX()-source:getX())
local e=math.abs(listener:getY()-source:getY())
return math.max(a,e)<=reach
end

function SpiffBoy.newSeed()
return(getTimestampMs()%(SpiffBoyRandom.MODULUS-1))+1
end
