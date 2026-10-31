require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Link/Links"
require"SpiffBoy/Link/LinkState"

SpiffBoy.LocalLink=SpiffBoy.LocalLink or{}
local d=SpiffBoy.LocalLink
local b=SpiffBoy.Handheld
local g=SpiffBoy.LinkState

local p=1000
local j=1
local k=2

local a={}
local l=0

local function f(consoleId)
return SpiffBoyConsoleInstance.instances[consoleId]
end

local function c(player,reason,name)
HaloTextHelper.addText(player,getText("UI_SpiffBoy_"..reason,name),"",HaloTextHelper.getColorRed())
end

local function m(playerNum)
local e=a[playerNum]
if not e then
return
end
local i=a[e.peer]
local n={[playerNum]=e.console,[e.peer]=i and i.console}
a[playerNum]=nil
a[e.peer]=nil
for q,h in ipairs({playerNum,e.peer})do
g.clear(h)
local o=n[h]and f(n[h])
if o then
o.channel:onDisconnected()
end
end
end

function d.offer(owner,peer)
local e,h=owner:getPlayerNum(),peer:getPlayerNum()
if a[e]then
c(owner,"CableTaken")
return
end
if not b.consoleWithCable(owner)then
c(owner,"NoCable")
return
end
if not b.withinCableReach(owner,peer)then
c(owner,"CableTooFar")
return
end
if a[h]or not b.consoleWithFreePort(peer)then
c(owner,"NoLinkableConsole")
return
end
SpiffBoy.LinkMenu.ask(peer,owner)
end

function d.decline(peer,ownerNum)
local e=getSpecificPlayer(ownerNum)
if e then
c(e,"CableDeclined",b.characterName(peer))
end
end

function d.connect(guest,console,ownerId,ownerNum)
local h=getSpecificPlayer(ownerNum)
if not h then
return
end
local e=guest:getPlayerNum()
if a[e]or b.hasCable(console)then
c(guest,"PortBusy")
return
end
if a[ownerNum]then
c(guest,"CableTaken")
return
end
local i=b.consoleWithCable(h)
if not i then
c(guest,"NoCable")
return
end
if not b.withinCableReach(guest,h)then
c(guest,"CableTooFar")
return
end
a[ownerNum]={peer=e,console=i:getID(),seat=j}
a[e]={peer=ownerNum,console=console:getID(),seat=k}
g.set(ownerNum,b.characterName(guest),j,nil,e,i:getID())
g.set(e,b.characterName(h),k,nil,ownerNum,console:getID())
for q,o in ipairs({i:getID(),console:getID()})do
local n=f(o)
if n then
n.channel:onConnected()
end
end
if not f(console:getID())then
SpiffBoyHandheldWindow.open(guest,console)
end
end

function d.disconnect(character,console)
local e=character:getPlayerNum()
local h=a[e]
if h and h.console==console:getID()then
m(e)
end
end

function d.sendData(playerObj,sequence,messages)
local e=a[playerObj:getPlayerNum()]
local h=e and a[e.peer]
local i=h and f(h.console)
if i then
i.channel:onData(sequence,messages)
end
end

function d.sendState(playerObj,cartridge,on)
local e=a[playerObj:getPlayerNum()]
local h=e and a[e.peer]
local i=h and f(h.console)
if i then
i.channel:onState(cartridge,on)
end
end

local function n(playerNum,link)
local e=getSpecificPlayer(playerNum)
local h=getSpecificPlayer(link.peer)
if not e or not h or e:isDead()or h:isDead()or not b.withinCableReach(e,h)then
return false
end
local i=e:getInventory():getItemWithIDRecursiv(link.console)
if not i then
return false
end
return link.seat~=j or b.hasCable(i)
end

local function o()
local h=getTimestampMs()
if h<l then
return
end
l=h+p
local e=nil
for i,q in pairs(a)do
if not n(i,q)then
e=e or{}
e[#e+1]=i
end
end
if e then
for i=1,#e do
m(e[i])
end
end
end

local function e()
for h in pairs(a)do
g.clear(h)
end
a={}
end

if not isClient()then
SpiffBoy.Links.install(d)
end

Events.OnTick.Add(o)
Events.OnGameStart.Add(e)
