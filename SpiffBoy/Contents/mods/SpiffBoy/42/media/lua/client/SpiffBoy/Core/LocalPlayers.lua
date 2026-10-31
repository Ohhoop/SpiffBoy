require"SpiffBoy/Core/Core"

SpiffBoy.LocalPlayers=SpiffBoy.LocalPlayers or{}
local b=SpiffBoy.LocalPlayers

function b.byOnlineId(onlineId)
for c=0,getNumActivePlayers()-1 do
local a=getSpecificPlayer(c)
if a and a:getOnlineID()==onlineId then
return a,c
end
end
return nil
end

function b.carrierOf(itemId,except)
for d=0,getNumActivePlayers()-1 do
local a=getSpecificPlayer(d)
if a and a~=except then
local c=a:getInventory():getItemWithIDRecursiv(itemId)
if c then
return a,c
end
end
end
return nil
end
