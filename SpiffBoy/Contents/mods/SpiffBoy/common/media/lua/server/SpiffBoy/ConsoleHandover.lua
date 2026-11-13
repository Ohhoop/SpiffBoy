-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Handheld/ConsoleLocator"
require"SpiffBoy/Handheld/StateTransfer"
require"SpiffBoy/ConsoleHosts"

local b=SpiffBoy.COMMAND_MODULE
local m=5000
local v=1000
local w=20000
local x=1000
local n=SpiffBoy.StateTransfer.TIMEOUT_MS
local y=1000

local i=SpiffBoy.StateTransfer.newCollector()
local k={}
local f={}
local g={}
local e={}
local o=0
local p=0

local function a(message)
SpiffBoy.trace("console handover: "..message)
end

local function q(onlineId,consoleId)
return tostring(onlineId)..":"..tostring(consoleId)
end

local function r(consoleId,player)
e[consoleId]={id=player:getOnlineID(),name=player:getUsername(),untilMs=getTimestampMs()+n}
end

local function z(consoleId)
local c=e[consoleId]
if c then
c.untilMs=getTimestampMs()+n
end
end

local function A(claim)
local c=getPlayerByOnlineID(claim.id)
if c and c:getUsername()==claim.name then
return c
end
return nil
end

local function B(header,consoleId)
if SpiffBoy.isInteger(header.v)then
local c=SpiffBoy.ConsoleLocator.findAtPlace({v=header.v},consoleId)
if c then
return c,{v=header.v}
end
return nil
end
if not(SpiffBoy.isInteger(header.x)and SpiffBoy.isInteger(header.y)and SpiffBoy.isInteger(header.z))then
return nil
end
local c=SpiffBoy.ConsoleLocator.findAround(header.x,header.y,header.z,consoleId)
if not c or not SpiffBoy.Handheld.isConsole(c)then
return nil
end
local d=SpiffBoy.ConsoleLocator.anchorOf(c)
return c,d and SpiffBoy.ConsoleLocator.placeOf(d)
end

local function C(key,consoleId,transferId,sender)
g[key]=nil
e[consoleId]=nil
f[key]={id=transferId,ms=getTimestampMs()}
if sender then
local c,d=SpiffBoy.ConsoleHosts.otherCarrier(sender,consoleId)
if c then
SpiffBoy.ConsoleHosts.release(consoleId,d)
sendServerCommand(c,b,SpiffBoy.COMMAND_CONSOLE_OFF,{i=consoleId})
else
SpiffBoy.ConsoleHosts.release(consoleId,nil)
end
sendServerCommand(sender,b,SpiffBoy.COMMAND_CONSOLE_GONE,{i=consoleId})
end
a("console "..tostring(consoleId)..": transfer incomplete, dropped")
end

local function D(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoy.isInteger(args.t)then
return
end
local d=player:getOnlineID()
if SpiffBoy.ConsoleHosts.of(args.i)~=d then
a("state of console "..tostring(args.i).." refused: player "..tostring(d).." is not its host")
return
end
local c=q(d,args.i)
local l=getTimestampMs()
if f[c]and f[c].id==args.t then
return
end
local j=k[c]
if not j or j.id~=args.t then
if j and l-j.startedMs<m then
a("state of console "..tostring(args.i).." refused by the rate")
return
end
k[c]={id=args.t,startedMs=l}
end
g[c]=player
local E,F,s=SpiffBoy.StateTransfer.add(i,c,args)
if not E then
return
end
f[c]={id=args.t,ms=l}
g[c]=nil
e[args.i]=nil
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_RECEIVED,{i=args.i,t=args.t})
local h,G=SpiffBoy.ConsoleHosts.otherCarrier(player,args.i)
if h then
SpiffBoy.ConsoleHosts.host(G,h)
SpiffBoy.ConsoleHosts.recordHandedFrom(args.i,player)
for u=1,#s do
local t=s[u]
t.me=h:getOnlineID()
sendServerCommand(h,b,SpiffBoy.COMMAND_CONSOLE_RESUME,t)
end
a("console "..tostring(args.i).." handed from player "..tostring(d).." to player "..tostring(h:getOnlineID()))
return
end
local H,t=B(F,args.i)
if H and t then
local u={i=args.i}
SpiffBoy.ConsoleLocator.writePlace(u,t)
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_MOVED,u)
a("console "..tostring(args.i).." moved nearby, player "..tostring(d).." keeps it")
return
end
SpiffBoy.ConsoleHosts.release(args.i,nil)
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_GONE,{i=args.i})
a("console "..tostring(args.i).." gone")
end

local function t(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
if SpiffBoy.ConsoleHosts.of(args.i)~=player:getOnlineID()then
return
end
if SpiffBoy.ConsoleLocator.findAtPlace(args,args.i)then
return
end
local c=false
if SpiffBoy.isInteger(args.v)then
c=getVehicleById(args.v)~=nil
elseif SpiffBoy.isInteger(args.x)and SpiffBoy.isInteger(args.y)and SpiffBoy.isInteger(args.z)then
c=getCell():getGridSquare(args.x,args.y,args.z)~=nil
end
if c then
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_LOST,{i=args.i,h=player:getOnlineID()})
end
end

local function u(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local j=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if not j then
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_STARTED,{i=args.i})
a("console "..tostring(args.i).." started by player "..tostring(player:getOnlineID())..", not yet seen on that player")
return
end
local d=player:getOnlineID()
local l=SpiffBoy.ConsoleHosts.handedFrom(args.i)
local c=SpiffBoy.ConsoleHosts.of(args.i)
if not l and c and c~=d and not SpiffBoy.ConsoleHosts.sameMachine(c,d)then
sendServerCommand(getPlayerByOnlineID(c),b,SpiffBoy.COMMAND_CONSOLE_LOST,{i=args.i,h=c})
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_BUSY,{i=args.i})
r(args.i,player)
a("console "..tostring(args.i).." switched on by player "..tostring(d).." while player "..tostring(c).." runs it, its game asked for")
return
end
local h=l or c
SpiffBoy.ConsoleHosts.forgetHandedFrom(args.i)
local s=h and h~=d and getPlayerByOnlineID(h)
SpiffBoy.ConsoleHosts.host(j,player)
e[args.i]=nil
if s then
sendServerCommand(s,b,SpiffBoy.COMMAND_CONSOLE_TAKEN,{i=args.i,h=d})
end
a("console "..tostring(args.i).." runs on player "..tostring(player:getOnlineID()))
end

local function s(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local c=player:getOnlineID()
if SpiffBoy.ConsoleHosts.of(args.i)~=c then
return
end
local h=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if h then
SpiffBoy.ConsoleHosts.release(args.i,h)
a("console "..tostring(args.i).." switched off by player "..tostring(c))
return
end
local d,j=SpiffBoy.ConsoleHosts.otherCarrier(player,args.i)
if d then
SpiffBoy.ConsoleHosts.release(args.i,j)
e[args.i]=nil
sendServerCommand(d,b,SpiffBoy.COMMAND_CONSOLE_OFF,{i=args.i})
a("console "..tostring(args.i).." off, carried by player "..tostring(d:getOnlineID()))
return
end
SpiffBoy.ConsoleHosts.release(args.i,SpiffBoy.ConsoleLocator.findAtPlace(args,args.i))
a("console "..tostring(args.i).." switched off away from player "..tostring(c))
end

local function E(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local d=player:getOnlineID()
local h=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if not h then
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_CLAIM,{i=args.i})
a("console "..tostring(args.i).." asked by player "..tostring(d)..", not yet seen on that player")
return
end
local c=SpiffBoy.ConsoleHosts.of(args.i)
if c==d then
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_CLAIM,{i=args.i})
a("console "..tostring(args.i).." asked by player "..tostring(d)..", who already hosts it")
return
end
local j=c and getPlayerByOnlineID(c)
if j then
sendServerCommand(j,b,SpiffBoy.COMMAND_CONSOLE_LOST,{i=args.i,h=c})
r(args.i,player)
a("console "..tostring(args.i).." asked of player "..tostring(c).." for player "..tostring(d))
return
end
SpiffBoy.ConsoleHosts.release(args.i,h)
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_OFF,{i=args.i})
a("console "..tostring(args.i).." off for player "..tostring(d)..", host "..tostring(c).." not running it")
end

local function F(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
if SpiffBoy.ConsoleHosts.of(args.i)~=nil then
return
end
local c=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if not c then
local h,d=SpiffBoy.ConsoleHosts.otherCarrier(player,args.i)
c=d
end
if not c then
local d=SpiffBoy.ConsoleLocator.findAtPlace(args,args.i)
if d and SpiffBoy.Handheld.isConsole(d)then
c=d
end
end
if c and SpiffBoy.Handheld.getHost(c)~=nil then
SpiffBoy.ConsoleHosts.release(args.i,c)
a("console "..tostring(args.i).." marked on with no host, wiped for player "..tostring(player:getOnlineID()))
end
end

local function G(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local c=player:getOnlineID()
local h=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if not h then
a("console "..tostring(args.i).." not yet seen on player "..tostring(c).." who just joined")
return
end
local d=SpiffBoy.ConsoleHosts.of(args.i)
if d and d~=c and getPlayerByOnlineID(d)then
a("console "..tostring(args.i).." carried by player "..tostring(c).." still runs on player "..tostring(d))
else
SpiffBoy.ConsoleHosts.release(args.i,h)
a("console "..tostring(args.i).." off, carried by player "..tostring(c).." who just joined")
end
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_IDLE,{i=args.i})
end

local function H(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoy.isFinite(args.v)or args.v<0 or args.v>1 then
return
end
if SpiffBoy.ConsoleHosts.of(args.i)~=player:getOnlineID()then
return
end
z(args.i)
local c=SpiffBoy.ConsoleHosts.otherCarrier(player,args.i)
if c then
sendServerCommand(c,b,SpiffBoy.COMMAND_CONSOLE_VOLUME,{i=args.i,v=args.v})
end
end

local function I(consoleId,claim,now)
local c=SpiffBoy.ConsoleHosts.of(consoleId)
if c==nil then
return true
end
return now>=claim.untilMs and not SpiffBoy.StateTransfer.receiving(i,q(c,consoleId))
end

local function J()
local h=getTimestampMs()
if h<p then
return
end
p=h+y
local c=nil
for d,j in pairs(e)do
local l=A(j)
if not l then
c=c or{}
c[#c+1]={consoleId=d}
elseif I(d,j,h)then
c=c or{}
c[#c+1]={consoleId=d,claimer=l}
end
end
if not c then
return
end
for j,d in ipairs(c)do
e[d.consoleId]=nil
if d.claimer then
SpiffBoy.ConsoleHosts.release(d.consoleId,SpiffBoy.ConsoleHosts.carriedBy(d.claimer,d.consoleId))
sendServerCommand(d.claimer,b,SpiffBoy.COMMAND_CONSOLE_OFF,{i=d.consoleId})
a("console "..tostring(d.consoleId).." off for player "..tostring(d.claimer:getOnlineID())..", its host sent no game")
end
end
end

local function h(map,field,ageMs,now)
local c={}
for d,j in pairs(map)do
if now-j[field]>ageMs then
c[#c+1]=d
end
end
for j,d in ipairs(c)do
map[d]=nil
end
end

local function l(now)
if now<o then
return
end
o=now+x
h(f,"ms",w,now)
h(k,"startedMs",m,now)
end

local function K()
local d=getTimestampMs()
l(d)
for L,c in ipairs(SpiffBoy.StateTransfer.overdue(i,v,d))do
local j=g[c.key]
if j then
sendServerCommand(j,b,SpiffBoy.COMMAND_CONSOLE_RESEND,{i=c.consoleId,t=c.id,m=c.missing})
a("console "..tostring(c.consoleId)..": "..tostring(c.missing.n).." chunks asked again")
end
end
for j,c in ipairs(SpiffBoy.StateTransfer.expire(i,d))do
C(c.key,c.consoleId,c.id,g[c.key])
end
end

SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_STATE,D)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_CHECK,t)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_STARTED,u)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_STOPPED,s)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_CLAIM,E)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_IDLE,G)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_VERIFY,F)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_VOLUME,H)
Events.OnTick.Add(K)
Events.OnTick.Add(J)
