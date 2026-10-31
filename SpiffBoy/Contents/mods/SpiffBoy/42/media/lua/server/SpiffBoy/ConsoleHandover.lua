require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Handheld/ConsoleLocator"
require"SpiffBoy/Handheld/StateTransfer"
require"SpiffBoy/ConsoleHosts"

local b=SpiffBoy.COMMAND_MODULE
local l=5000
local q=1000
local r=20000
local s=1000

local i=SpiffBoy.StateTransfer.newCollector()
local j={}
local d={}
local e={}
local m=0

local function a(message)
SpiffBoy.trace("console handover: "..message)
end

local function t(header,consoleId)
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
local f=SpiffBoy.ConsoleLocator.anchorOf(c)
return c,f and SpiffBoy.ConsoleLocator.placeOf(f)
end

local function u(key,consoleId,transferId,sender)
e[key]=nil
d[key]={id=transferId,ms=getTimestampMs()}
if sender then
local c,f=SpiffBoy.ConsoleHosts.otherCarrier(sender,consoleId)
if c then
SpiffBoy.ConsoleHosts.release(consoleId,f)
sendServerCommand(c,b,SpiffBoy.COMMAND_CONSOLE_OFF,{i=consoleId})
else
SpiffBoy.ConsoleHosts.release(consoleId,nil)
end
sendServerCommand(sender,b,SpiffBoy.COMMAND_CONSOLE_GONE,{i=consoleId})
end
a("console "..tostring(consoleId)..": transfer incomplete, dropped")
end

local function v(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoy.isInteger(args.t)then
return
end
local f=player:getOnlineID()
if SpiffBoy.ConsoleHosts.of(args.i)~=f then
a("state of console "..tostring(args.i).." refused: player "..tostring(f).." is not its host")
return
end
local c=tostring(f)..":"..tostring(args.i)
local k=getTimestampMs()
if d[c]and d[c].id==args.t then
return
end
local h=j[c]
if not h or h.id~=args.t then
if h and k-h.startedMs<l then
a("state of console "..tostring(args.i).." refused by the rate")
return
end
j[c]={id=args.t,startedMs=k}
end
e[c]=player
local w,x,n=SpiffBoy.StateTransfer.add(i,c,args)
if not w then
return
end
d[c]={id=args.t,ms=k}
e[c]=nil
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_RECEIVED,{i=args.i,t=args.t})
local g,y=SpiffBoy.ConsoleHosts.otherCarrier(player,args.i)
if g then
SpiffBoy.ConsoleHosts.host(y,g)
SpiffBoy.ConsoleHosts.recordHandedFrom(args.i,player)
for p=1,#n do
local o=n[p]
o.me=g:getOnlineID()
sendServerCommand(g,b,SpiffBoy.COMMAND_CONSOLE_RESUME,o)
end
a("console "..tostring(args.i).." handed from player "..tostring(f).." to player "..tostring(g:getOnlineID()))
return
end
local z,o=t(x,args.i)
if z and o then
local p={i=args.i}
SpiffBoy.ConsoleLocator.writePlace(p,o)
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_MOVED,p)
a("console "..tostring(args.i).." moved nearby, player "..tostring(f).." keeps it")
return
end
SpiffBoy.ConsoleHosts.release(args.i,nil)
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_GONE,{i=args.i})
a("console "..tostring(args.i).." gone")
end

local function o(player,args)
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

local function p(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local h=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if not h then
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_STARTED,{i=args.i})
a("console "..tostring(args.i).." started by player "..tostring(player:getOnlineID())..", not yet seen on that player")
return
end
local f=player:getOnlineID()
local k=SpiffBoy.ConsoleHosts.handedFrom(args.i)
local c=SpiffBoy.ConsoleHosts.of(args.i)
if not k and c and c~=f and not SpiffBoy.ConsoleHosts.sameMachine(c,f)then
sendServerCommand(getPlayerByOnlineID(c),b,SpiffBoy.COMMAND_CONSOLE_LOST,{i=args.i,h=c})
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_BUSY,{i=args.i})
a("console "..tostring(args.i).." switched on by player "..tostring(f).." while player "..tostring(c).." runs it, its game asked for")
return
end
local g=k or c
SpiffBoy.ConsoleHosts.forgetHandedFrom(args.i)
local n=g and g~=f and getPlayerByOnlineID(g)
SpiffBoy.ConsoleHosts.host(h,player)
if n then
sendServerCommand(n,b,SpiffBoy.COMMAND_CONSOLE_TAKEN,{i=args.i,h=f})
end
a("console "..tostring(args.i).." runs on player "..tostring(player:getOnlineID()))
end

local function k(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local c=player:getOnlineID()
if SpiffBoy.ConsoleHosts.of(args.i)~=c then
return
end
local g=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if g then
SpiffBoy.ConsoleHosts.release(args.i,g)
a("console "..tostring(args.i).." switched off by player "..tostring(c))
return
end
local f,h=SpiffBoy.ConsoleHosts.otherCarrier(player,args.i)
if f then
SpiffBoy.ConsoleHosts.release(args.i,h)
sendServerCommand(f,b,SpiffBoy.COMMAND_CONSOLE_OFF,{i=args.i})
a("console "..tostring(args.i).." off, carried by player "..tostring(f:getOnlineID()))
return
end
SpiffBoy.ConsoleHosts.release(args.i,SpiffBoy.ConsoleLocator.findAtPlace(args,args.i))
a("console "..tostring(args.i).." switched off away from player "..tostring(c))
end

local function n(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local f=player:getOnlineID()
local g=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if not g then
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_CLAIM,{i=args.i})
a("console "..tostring(args.i).." asked by player "..tostring(f)..", not yet seen on that player")
return
end
local c=SpiffBoy.ConsoleHosts.of(args.i)
if c==f then
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_CLAIM,{i=args.i})
a("console "..tostring(args.i).." asked by player "..tostring(f)..", who already hosts it")
return
end
local h=c and getPlayerByOnlineID(c)
if h then
sendServerCommand(h,b,SpiffBoy.COMMAND_CONSOLE_LOST,{i=args.i,h=c})
a("console "..tostring(args.i).." asked of player "..tostring(c).." for player "..tostring(f))
return
end
SpiffBoy.ConsoleHosts.release(args.i,g)
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_OFF,{i=args.i})
a("console "..tostring(args.i).." off for player "..tostring(f)..", host "..tostring(c).." not running it")
end

local function w(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
if SpiffBoy.ConsoleHosts.of(args.i)~=nil then
return
end
local c=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if not c then
local g,f=SpiffBoy.ConsoleHosts.otherCarrier(player,args.i)
c=f
end
if not c then
local f=SpiffBoy.ConsoleLocator.findAtPlace(args,args.i)
if f and SpiffBoy.Handheld.isConsole(f)then
c=f
end
end
if c and SpiffBoy.Handheld.getHost(c)~=nil then
SpiffBoy.ConsoleHosts.release(args.i,c)
a("console "..tostring(args.i).." marked on with no host, wiped for player "..tostring(player:getOnlineID()))
end
end

local function x(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)then
return
end
local c=player:getOnlineID()
local g=SpiffBoy.ConsoleHosts.carriedBy(player,args.i)
if not g then
a("console "..tostring(args.i).." not yet seen on player "..tostring(c).." who just joined")
return
end
local f=SpiffBoy.ConsoleHosts.of(args.i)
if f and f~=c and getPlayerByOnlineID(f)then
a("console "..tostring(args.i).." carried by player "..tostring(c).." still runs on player "..tostring(f))
else
SpiffBoy.ConsoleHosts.release(args.i,g)
a("console "..tostring(args.i).." off, carried by player "..tostring(c).." who just joined")
end
sendServerCommand(player,b,SpiffBoy.COMMAND_CONSOLE_IDLE,{i=args.i})
end

local function y(player,args)
if type(args)~="table"or not SpiffBoy.isInteger(args.i)or not SpiffBoy.isFinite(args.v)or args.v<0 or args.v>1 then
return
end
if SpiffBoy.ConsoleHosts.of(args.i)~=player:getOnlineID()then
return
end
local c=SpiffBoy.ConsoleHosts.otherCarrier(player,args.i)
if c then
sendServerCommand(c,b,SpiffBoy.COMMAND_CONSOLE_VOLUME,{i=args.i,v=args.v})
end
end

local function g(map,field,ageMs,now)
local c={}
for f,h in pairs(map)do
if now-h[field]>ageMs then
c[#c+1]=f
end
end
for h,f in ipairs(c)do
map[f]=nil
end
end

local function z(now)
if now<m then
return
end
m=now+s
g(d,"ms",r,now)
g(j,"startedMs",l,now)
end

local function A()
local f=getTimestampMs()
z(f)
for B,c in ipairs(SpiffBoy.StateTransfer.overdue(i,q,f))do
local h=e[c.key]
if h then
sendServerCommand(h,b,SpiffBoy.COMMAND_CONSOLE_RESEND,{i=c.consoleId,t=c.id,m=c.missing})
a("console "..tostring(c.consoleId)..": "..tostring(c.missing.n).." chunks asked again")
end
end
for h,c in ipairs(SpiffBoy.StateTransfer.expire(i,f))do
u(c.key,c.consoleId,c.id,e[c.key])
end
end

SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_STATE,v)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_CHECK,o)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_STARTED,p)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_STOPPED,k)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_CLAIM,n)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_IDLE,x)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_VERIFY,w)
SpiffBoy.Commands.fromClient(SpiffBoy.COMMAND_CONSOLE_VOLUME,y)
Events.OnTick.Add(A)
