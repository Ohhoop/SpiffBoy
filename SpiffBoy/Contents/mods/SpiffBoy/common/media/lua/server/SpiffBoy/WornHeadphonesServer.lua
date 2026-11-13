-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Handheld/WornHeadphones"

local c=SpiffBoy.WornHeadphones

local g=40

local e={}

local function h(player,args)
local a,b=args.session,args.sequence
if type(a)~="string"or#a==0 or#a>g then
return false
end
if not(SpiffBoy.isFinite(b)and SpiffBoy.isInteger(b)and b>=1)then
return false
end
local f=player:getOnlineID()
local d=e[f]
if d and d.session==a and b<=d.sequence then
return false
end
e[f]={session=a,sequence=b}
return true
end

local function b(player,args)
if type(args)~="table"or not h(player,args)then
return
end
local a=args.type
if a~=nil and not(c.isWornType(a)and c.isCarried(player,a))then
return
end
if c.apply(player,a)then
sendHumanVisual(player)
end
end

SpiffBoy.Commands.fromClient(c.COMMAND,b)
