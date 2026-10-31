require"TimedActions/ISTimedActionQueue"
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/GameErrors"
require"SpiffBoy/Core/Sandbox"
require"SpiffBoy/Framework/Cartridges"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Core/Runtime"
require"SpiffBoy/Core/Input"
require"SpiffBoy/Core/Audio"
require"SpiffBoy/Core/Chip"
require"SpiffBoy/Core/Speaker"
require"SpiffBoy/Core/Sequencer"
require"SpiffBoy/Core/Tunes"
require"SpiffBoy/Core/Textures"
require"SpiffBoy/Core/Mood"
require"SpiffBoy/Core/PlayerGuard"
require"SpiffBoy/Menus/ClientActions"
require"SpiffBoy/Network/ChipLink"
require"SpiffBoy/Link/LinkState"
require"SpiffBoy/Link/LinkChannel"
require"SpiffBoy/Handheld/ConsoleStatus"
require"SpiffBoy/Handheld/BootScreen"
require"SpiffBoy/Handheld/ConsoleLocator"
require"SpiffBoy/Network/RemoteSpeakers"
require"SpiffBoy/Core/LocalPlayers"
require"SpiffBoy/Core/SaveState"
require"SpiffBoy/Network/ConsoleHandover"

SpiffBoyConsoleInstance={}
SpiffBoyConsoleInstance.__index=SpiffBoyConsoleInstance
SpiffBoyConsoleInstance.instances={}

local o="media/ui/SpiffBoy/handheld/"
local j=1000
local z=5000
local A=4
local g={period=120,drain=1.25,loudness=100,soundingMs=2000}
local e=SpiffBoy.REACH
local B=60
local C="SpiffBoy_PowerSwitch"
local c=10
local D=7
local p="SpiffBoy_VolumeWheel"
local q=7
local E=24
local F=120
local r=40
local G=6
local k=#SpiffBoy.Cartridges.SHADES
local s="spiffboy"
local t="SpiffBoyRemoveCartridgeAction"
local H=2
local u=5000
local I=3
local v=0.5
local b=SpiffBoy.ConsoleLocator
local f=SpiffBoy.MUFFLE
local h=SpiffBoy.SaveState
local w={"powered","switchOn","battery","volumeStep","glitch","linkLost","gameMissing","noiseCounter","flickerFrames"}

SpiffBoyConsoleInstance.ART=o
SpiffBoyConsoleInstance.VOLUME_STEPS=c
SpiffBoyConsoleInstance.REMOVE_ACTION=t

local function x(playerObj,console,anchor,enclosures)
local a=setmetatable({},SpiffBoyConsoleInstance)
a.playerObj=playerObj
a.playerNum=playerObj:getPlayerNum()
a.window=nil
a.nextSecondMs=getTimestampMs()+j
a.closing=false
a.console=console
a.consoleId=console:getID()
a.gameMissing=false
a.battery=SpiffBoy.Handheld.getBattery(console)
a.seated=SpiffBoy.Handheld.getCartridge(console)
a.headphonesType=SpiffBoy.Handheld.getHeadphones(console)
a.cableIn=SpiffBoy.Handheld.hasCable(console)
a.guestCable=false
a.batteryDirty=false
a.screen=SpiffBoyScreen.new(nil,SpiffBoy.Cartridges.SCREEN_WIDTH,SpiffBoy.Cartridges.SCREEN_HEIGHT)
a.screen:setPalette(SpiffBoy.Cartridges.SHADES)
a.screen:setWholePixels(true)
a.runtime=SpiffBoyRuntime.new(a.screen)
a.runtime.onCrash=function()
a:onGameCrash()
end
a.screenArt=SpiffBoy.Textures.folder(SpiffBoy.MOD_ID,o,true)
a.boot=nil
a.input=SpiffBoyInputState.new()
a.inputs={a.input}
a.powered=false
a.switchOn=false
a.flickerFrames=0
local d=SpiffBoy.Handheld.getVolume(console)
a.volumeStep=D
if d then
a.volumeStep=math.floor(d*c+0.5)
end
a.volumeDirty=false
a.chip=SpiffBoyChip.new()
a.speaker=SpiffBoySpeaker.new(false)
a.speaker:setVolume(a:volume())
a.link=SpiffBoyChipLink.new(playerObj,a.consoleId)
a.chip.listener=a.link
a.channel=SpiffBoyLinkChannel.new(a)
a.sequencer=nil
a.glitch=nil
a.linkLost=false
a.noiseCounter=0
a.lastSoundingMs=nil
a.anchor,a.enclosures=anchor,enclosures
a.shut=false
a.link:setPlace(b.placeOf(a.anchor),a.enclosures)
a.link:setReach(a:wallReach())
a.link:setOpen(a:openReach(),a.enclosures)
a.far=false
a.lastSquare=nil
a.lastShownMs=0
a.lastTouchedMs=getTimestampMs()
a.paused=false
a.nextLocateMs=0
a.nextAnchorWriteMs=0
a.handedOver=false
a.transferring=false
a.sending=false
a.awaitingGame=false
a.pendingVolumeStep=nil
a.transferStartMs=0
a.transferStage=0
a:loadCartridge()
return a
end

function SpiffBoyConsoleInstance.new(playerObj,console)
local a=x(playerObj,console,b.anchorOf(console))
SpiffBoyConsoleInstance.instances[a.consoleId]=a
return a
end

function SpiffBoyConsoleInstance.shadowOf(instance)
return x(instance.playerObj,instance.console,instance.anchor,instance.enclosures)
end

function SpiffBoyConsoleInstance:discard()
self.speaker:destroy()
end

function SpiffBoyConsoleInstance:transferProgress()
return self.transferStage/I
end

function SpiffBoyConsoleInstance.runningOn(console)
return SpiffBoyConsoleInstance.instances[console:getID()]
end

function SpiffBoyConsoleInstance.hostedBy(playerNum)
local a={}
for i,d in pairs(SpiffBoyConsoleInstance.instances)do
if d.playerNum==playerNum and not d.sending then
a[#a+1]=d
end
end
return a
end

function SpiffBoyConsoleInstance.linkedFor(playerNum)
local a=SpiffBoy.LinkState.of(playerNum)
if not a then
return nil
end
return SpiffBoyConsoleInstance.instances[a.consoleId]
end

local function y(instances,accept)
local a=nil
for i,d in ipairs(instances)do
if accept(d)and(not a or d.lastTouchedMs<a.lastTouchedMs)then
a=d
end
end
return a
end

function SpiffBoyConsoleInstance.makeRoom(playerNum,keep)
local d=SpiffBoyConsoleInstance.hostedBy(playerNum)
local i=0
for l,a in ipairs(d)do
if not a.paused and a~=keep and a.powered then
i=i+1
end
end
if i>=SpiffBoy.MAX_HOSTED then
local a=y(d,function(instance)
return instance~=keep and not instance.paused and not instance.window and instance.powered
end)
if a then
a:pause()
end
end
local a={}
for m,l in ipairs(d)do
if l.paused then
a[#a+1]=l
end
end
while#a>SpiffBoy.MAX_PAUSED do
local l=y(a,function(instance)return instance~=keep end)
l:turnOff()
for m=#a,1,-1 do
if a[m]==l then
table.remove(a,m)
end
end
end
end

function SpiffBoyConsoleInstance:pause()
if self.paused then
return
end
self.paused=true
self.speaker:silence()
self.link:setPrivate(true)
self.link:flush(self.sequencer)
if SpiffBoy.isDevBuild()then
SpiffBoy.log("console "..tostring(self.consoleId)..": paused")
end
end

function SpiffBoyConsoleInstance:wake()
self.lastTouchedMs=getTimestampMs()
if not self.paused then
return
end
SpiffBoyConsoleInstance.makeRoom(self.playerNum,self)
self.paused=false
if SpiffBoy.isDevBuild()then
SpiffBoy.log("console "..tostring(self.consoleId)..": woken")
end
end

function SpiffBoyConsoleInstance:stepPaused()
if self.transferring then
return
end
self:followNewCharacter()
local d=self:hostReason()
if self:stopsOn(d)then
self:close()
return
end
local a=self:locateConsole()
if a=="lost"then
if isClient()then
SpiffBoy.ConsoleHandover.send(self)
return
end
self:close()
return
end
if a=="far"and isClient()then
SpiffBoy.ConsoleHandover.check(self)
end
if not self:secondElapsed()then
return
end
if self.battery~=nil and SpiffBoy.Handheld.getBattery(self.console)==nil then
self:close()
return
end
if not isGamePaused()and SpiffBoy.Sandbox.batteriesDrain()then
self:drainBattery()
end
self:writeAwayCharge()
if self.battery<=0 then
self.battery=0
self:close()
end
end

function SpiffBoyConsoleInstance.playability(console,playerNum)
if SpiffBoyHandheldWindow.forPlayer(playerNum)then
return"AlreadyPlaying"
end
if SpiffBoyHandheldWindow.hiddenOn(console)then
return nil
end
local a=SpiffBoy.Handheld.getCartridge(console)
if a and not SpiffBoy.Cartridges.get(a.type)then
return"UnknownCartridge"
end
return nil
end

function SpiffBoyConsoleInstance:consoleAction()
local d=ISTimedActionQueue.getTimedActionQueue(self.playerObj).queue
local a=d and d[1]
if not(a and a.action and a.console and a.console:getID()==self.consoleId)then
return nil,0
end
return a,SpiffBoy.clamp(a:getJobDelta(),0,1)
end

function SpiffBoyConsoleInstance:readHardware()
self.seated=SpiffBoy.Handheld.getCartridge(self.console)
self.headphonesType=SpiffBoy.Handheld.getHeadphones(self.console)
local a=SpiffBoy.LinkState.of(self.playerNum)
self.guestCable=a~=nil and a.seat==H
self.cableIn=SpiffBoy.Handheld.hasCable(self.console)or self.guestCable
end

function SpiffBoyConsoleInstance:freezeOnRemoval(current)
if current and current.Type==t and self.powered and self.record and not self:isFrozen()then
self:freeze()
end
end

function SpiffBoyConsoleInstance:hasHeadphones()
return self.headphonesType~=nil
end

function SpiffBoyConsoleInstance:turnOff()
if self.switchOn then
self:togglePower()
end
self:close()
end

function SpiffBoyConsoleInstance:hostReason()
local a=SpiffBoy.PlayerGuard.hitReason(self.playerObj)
if a=="dead"and self.anchor.kind~=b.PLAYER then
return nil
end
return a
end

function SpiffBoyConsoleInstance:followNewCharacter()
if not self.playerObj:isDead()then
return
end
local a=getSpecificPlayer(self.playerNum)
if not a or a==self.playerObj then
return
end
if SpiffBoy.isDevBuild()then
SpiffBoy.log("console "..tostring(self.consoleId)..": host player "..tostring(self.playerNum).." plays a new character")
end
self.playerObj=a
self.link:setPlayer(a)
end

function SpiffBoyConsoleInstance:stopsOn(reason)
return reason~=nil and reason~="hit"
end

function SpiffBoyConsoleInstance:secondElapsed()
local a=getTimestampMs()
if a<self.nextSecondMs then
return false
end
self.nextSecondMs=a+j
return true
end

function SpiffBoyConsoleInstance:drainBattery()
self.battery=self.battery-SpiffBoy.Handheld.BATTERY_PER_MINUTE/B*getGameTime():getTrueMultiplier()
self.batteryDirty=true
end

function SpiffBoyConsoleInstance:batteryDied()
self:powerOff()
SpiffBoy.ConsoleStatus.refreshName(self.console)
end

function SpiffBoyConsoleInstance:checkGuards()
self:followNewCharacter()
local a=self:hostReason()
if self:stopsOn(a)then
return a
end
if a=="hit"and self.window then
self.window:putAway()
return nil
end
local d=self:locateConsole()
if d=="lost"then
if isClient()and self.powered then
SpiffBoy.ConsoleHandover.send(self)
return nil
end
return"lost"
end
if d=="far"and isClient()then
SpiffBoy.ConsoleHandover.check(self)
end
if not self:secondElapsed()then
return nil
end
if self.battery~=nil and SpiffBoy.Handheld.getBattery(self.console)==nil then
return"unplugged"
end
local i=self:everySecond()
self:writeAwayCharge()
return i
end

function SpiffBoyConsoleInstance:writeAwayCharge()
if self.anchor.kind==b.PLAYER then
return
end
local a=getTimestampMs()
if a<self.nextAnchorWriteMs then
return
end
self.nextAnchorWriteMs=a+u
self:persistHardware()
end

function SpiffBoyConsoleInstance:traceAnchor(anchor,enclosures)
if not SpiffBoy.isDevBuild()then
return
end
local a=anchor.kind
if anchor.kind==b.SQUARE then
a=a.." "..anchor.x..","..anchor.y..","..anchor.z
elseif anchor.kind==b.VEHICLE then
a=a.." "..tostring(anchor.id)
end
SpiffBoy.log("console "..tostring(self.consoleId)..": "..self.anchor.kind.." -> "..a..", enclosures "..tostring(enclosures))
end

function SpiffBoyConsoleInstance:anchorMoved(anchor,enclosures)
local a=self.anchor
if a.kind~=anchor.kind or self.enclosures~=enclosures then
return true
end
if anchor.kind==b.SQUARE then
return a.x~=anchor.x or a.y~=anchor.y or a.z~=anchor.z
end
if anchor.kind==b.VEHICLE then
return a.id~=anchor.id
end
return a.character~=anchor.character
end

local function J(anchor)
if anchor.kind==b.SQUARE then
return getCell():getGridSquare(anchor.x,anchor.y,anchor.z)
end
if anchor.kind==b.VEHICLE then
return anchor.vehicle:getSquare()
end
return anchor.character:getCurrentSquare()
end

function SpiffBoyConsoleInstance:settle(item)
local a,d=b.anchorOf(item)
if not a then
return false
end
self.console=item
self.far=false
if self:anchorMoved(a,d)then
self:traceAnchor(a,d)
self.anchor=a
self.enclosures=d
self.link:setPlace(b.placeOf(a),d)
self:persistHardware()
self.nextAnchorWriteMs=getTimestampMs()+u
else
self.anchor=a
end
local i=J(a)
if i then
self.lastSquare={x=i:getX(),y=i:getY(),z=i:getZ()}
end
return true
end

function SpiffBoyConsoleInstance:changeHost(playerObj)
if self.window then
self.window:hide()
end
if SpiffBoy.isDevBuild()then
SpiffBoy.log("console "..tostring(self.consoleId)..": host player "..tostring(self.playerNum).." -> "..tostring(playerObj:getPlayerNum()))
end
self.playerObj=playerObj
self.playerNum=playerObj:getPlayerNum()
self.link:setPlayer(playerObj)
self.lastTouchedMs=getTimestampMs()
SpiffBoyConsoleInstance.makeRoom(self.playerNum,self)
if not self.transferring then
SpiffBoy.ConsoleHandover.started(self)
end
end

function SpiffBoyConsoleInstance:findPlaced()
local i=self.consoleId
if self.anchor.kind==b.VEHICLE then
if not self.anchor.vehicle:getSquare()then
return"far"
end
local a=b.findInVehicle(self.anchor.vehicle,i)
if a then
return a
end
end
local a=self.lastSquare
if a then
if self.anchor.kind~=b.PLAYER and not getCell():getGridSquare(a.x,a.y,a.z)then
return"far"
end
local d=b.findAround(a.x,a.y,a.z,i)
if d then
return d
end
end
local d=self.playerObj:getCurrentSquare()
if d then
return b.findAround(d:getX(),d:getY(),d:getZ(),i)
end
return nil
end

function SpiffBoyConsoleInstance:locateConsole()
local d=self.consoleId
local i=self.playerObj:getInventory():getItemWithIDRecursiv(d)
if i and self:settle(i)then
return"held"
end
if self.anchor.kind~=b.PLAYER then
local a=getTimestampMs()
if a<self.nextLocateMs then
if self.far then
return"far"
end
return"placed"
end
self.nextLocateMs=a+j
end
local l,m=SpiffBoy.LocalPlayers.carrierOf(d,self.playerObj)
if l then
self:changeHost(l)
if self:settle(m)then
return"held"
end
return"lost"
end
local a=self:findPlaced()
if a=="far"then
self.far=true
return"far"
end
if a and self:settle(a)then
return"placed"
end
return"lost"
end

function SpiffBoyConsoleInstance:isPlaying()
local a=self.runtime
return self.powered and self.window~=nil and not isGamePaused()and a.game~=nil and self.boot==nil and a.crash==nil and not self:isFrozen()and self.input:activeWithin(z)
end

function SpiffBoyConsoleInstance:everySecond()
if not self.powered then
return nil
end
if not isGamePaused()and SpiffBoy.Sandbox.batteriesDrain()then
self:drainBattery()
end
if self:isPlaying()then
SpiffBoy.Mood.applySecond(self.playerObj)
end
if self.battery>0 then
return nil
end
self.battery=0
if not self.window then
return"battery"
end
self:batteryDied()
return nil
end

function SpiffBoyConsoleInstance:clearInput()
SpiffBoy.Input.refreshProfile()
self.input:clearHeld()
end

function SpiffBoyConsoleInstance:step()
if self.transferring then
self:locateConsole()
if self.window then
self.window:drawConsole()
end
return
end
local d=self:checkGuards()
if d then
self:close()
return
end
if self.closing then
return
end
SpiffBoy.Audio.beginFrame()
if self.window then
self.window:refreshHardware()
else
self:readHardware()
end
local a,i=self:consoleAction()
if self.window then
self.window:followConsole(a,i)
end
self:freezeOnRemoval(a)
if self.window then
self.window:readInput()
else
self:clearInput()
end
self:advance()
if self.closing then
return
end
self.channel:flush()
if self.window then
self.window:drawConsole()
end
self:sound()
end

function SpiffBoyConsoleInstance:anchorPoint()
local a=self.anchor
if a.kind~=b.PLAYER and self.far then
return nil
end
if a.kind==b.SQUARE then
return a.x+v,a.y+v
end
if a.kind==b.VEHICLE then
return a.vehicle:getX(),a.vehicle:getY()
end
return a.character:getX(),a.character:getY()
end

function SpiffBoyConsoleInstance:listenGain()
if self.anchor.kind==b.PLAYER then
if self:hasHeadphones()then
return 1
end
return f.gain^self.enclosures
end
if self:hasHeadphones()then
return 0
end
local a,d=self:anchorPoint()
if not a then
return 0
end
local i,l=self:hearingFor(self.playerObj)
return SpiffBoy.RemoteSpeakers.gainAt(a,d,i)*f.gain^l
end

function SpiffBoyConsoleInstance:sound()
if self.chip:isSounding()then
self.lastSoundingMs=getTimestampMs()
end
self:checkShut()
if self.sending and SpiffBoy.RemoteSpeakers.isHeard(self.consoleId)then
self.speaker:silence()
else
self.speaker:setDistanceGain(self:listenGain())
self.speaker:play(self.chip)
end
if self.link.networked then
self.link:setEnclosures(self:outerEnclosures())
self.link:setReach(self:wallReach())
self.link:setOpen(self:openReach(),self.enclosures)
end
self.link:setPrivate(self:hasHeadphones())
self.link:flush(self.sequencer)
if not self.sending then
self:makeNoise()
end
end

function SpiffBoyConsoleInstance:noiseRange(inRoom)
local a=self:volume()
if inRoom then
return e.roomFloor+math.floor(e.base*e.roomShare*a)
end
return e.outsideFloor+math.floor(e.base*a)
end

function SpiffBoyConsoleInstance:soundSquare()
local a=self.anchor
if a.kind==b.SQUARE then
return a.x,a.y,a.z,a.inRoom
end
local d=nil
if a.kind==b.VEHICLE then
d=a.vehicle:getSquare()
else
d=self.playerObj:getCurrentSquare()
end
if not d then
return nil
end
return d:getX(),d:getY(),d:getZ(),d:getRoom()~=nil
end

function SpiffBoyConsoleInstance:checkShut()
local a=nil
if self.anchor.kind==b.VEHICLE then
a=self.anchor.vehicle
elseif self.anchor.kind==b.PLAYER then
a=self.playerObj:getVehicle()
end
self.shut=a~=nil and b.isShut(a)
end

function SpiffBoyConsoleInstance:outerEnclosures()
if self.shut then
return math.min(self.enclosures+1,SpiffBoy.MAX_ENCLOSURES)
end
return self.enclosures
end

function SpiffBoyConsoleInstance:reachFrom(inRoom)
return math.floor(self:noiseRange(inRoom)*f.range^self:outerEnclosures())
end

function SpiffBoyConsoleInstance:hearingReach()
local a,i,l,d=self:soundSquare()
if not a then
return 0
end
return self:reachFrom(d)
end

function SpiffBoyConsoleInstance:openReach()
if not self:soundSquare()then
return 0
end
return math.floor(self:noiseRange(false)*f.range^self.enclosures)
end

function SpiffBoyConsoleInstance:wallReach()
if not self:soundSquare()then
return 0
end
return self:reachFrom(not self.shut)
end

function SpiffBoyConsoleInstance:soundSpace()
local a=self.anchor
if a.kind==b.VEHICLE then
return b.spaceOf(a.vehicle)
end
if a.kind==b.SQUARE then
return b.spaceOf(getCell():getGridSquare(a.x,a.y,a.z))
end
return b.spaceOf(self.playerObj)
end

function SpiffBoyConsoleInstance:hearingFor(listener)
if b.spaceOf(listener)==self:soundSpace()then
return self:openReach(),self.enclosures
end
return self:wallReach(),self:outerEnclosures()
end

function SpiffBoyConsoleInstance:makeNoise()
if isGamePaused()then
return
end
self.noiseCounter=self.noiseCounter-g.drain*getGameTime():getMultiplier()
if self.noiseCounter>0 then
return
end
self.noiseCounter=g.period
local a,i,l,m,n=self:noiseSource()
if not a then
return
end
local d=nil
if self.anchor.kind==b.PLAYER then
d=self.playerObj
end
addSound(d,a,i,l,m,n)
end

function SpiffBoyConsoleInstance:soundedLately()
return self.lastSoundingMs~=nil and getTimestampMs()-self.lastSoundingMs<=g.soundingMs
end

function SpiffBoyConsoleInstance:noiseSource()
local a=self:volume()
if not self.powered or self.paused or not self:soundedLately()or a<=0 or self:hasHeadphones()or not SpiffBoy.Sandbox.noiseAttractsZombies()then
return nil
end
local d,i,l,m=self:soundSquare()
if not d then
return nil
end
return d,i,l,self:reachFrom(m),math.floor(g.loudness*a*f.gain^self:outerEnclosures())
end

function SpiffBoyConsoleInstance:volume()
return self.volumeStep/c
end

function SpiffBoyConsoleInstance:turnVolume(notches)
self:setVolumeStep(self:wheelStep()+notches)
end

function SpiffBoyConsoleInstance:wheelStep()
return self.pendingVolumeStep or self.volumeStep
end

function SpiffBoyConsoleInstance:takeVolume(volume)
self.volumeStep=SpiffBoy.clamp(math.floor(volume*c+0.5),0,c)
self.volumeDirty=true
self.speaker:setVolume(self:volume())
end

function SpiffBoyConsoleInstance:setVolumeStep(step)
step=SpiffBoy.clamp(step,0,c)
if self.transferring and not self.awaitingGame then
if step==self:wheelStep()then
return
end
self.pendingVolumeStep=step
self.speaker:setVolume(step/c)
SpiffBoy.Audio.playSound(p)
return
end
if step==self.volumeStep then
return
end
self.volumeStep=step
self.volumeDirty=true
self.speaker:setVolume(self:volume())
self.link:setVolume(self:volume())
SpiffBoy.Audio.playSound(p)
end

function SpiffBoyConsoleInstance:togglePower()
if self.transferring then
return
end
SpiffBoy.Audio.playSound(C)
if not self.switchOn then
self.lastTouchedMs=getTimestampMs()
SpiffBoyConsoleInstance.makeRoom(self.playerNum,self)
end
if self.switchOn then
self.switchOn=false
self.flickerFrames=0
if self.powered then
self:powerOff()
end
else
self.switchOn=true
if self.battery~=nil and self.battery>0 then
self:powerOn()
elseif self.battery~=nil then
self.flickerFrames=A
end
end
SpiffBoy.ConsoleStatus.refreshName(self.console)
end

function SpiffBoyConsoleInstance:powerOn()
self.powered=true
self.chip:boot()
self:loadCartridge()
if self.definition then
self.link:powerOn(self.definition.item,self:volume())
end
self.channel:announce()
self.boot=SpiffBoyBootScreen.new(self.screenArt(s),self.chip,not self.definition)
self.runtime:setDevices({self.chip,self.link,self.channel})
self.runtime:setGame(self.boot)
end

function SpiffBoyConsoleInstance:loadCartridge()
local a=SpiffBoy.Handheld.getCartridge(self.console)
self.record=a
self.definition=a and SpiffBoy.Cartridges.get(a.type)
self.gameArt=self.definition and SpiffBoy.Textures.folder(self.definition.mod,self.definition.art,true)
end

function SpiffBoyConsoleInstance:freeze()
local d=self.screen.width
local i=self.screen.height
local a={}
for m=1,q do
local l=ZombRand(E,F+1)
a[#a+1]={x=ZombRand(d),y=ZombRand(i),w=l,h=1,shade=ZombRand(k)+1}
end
for l=1,r do
a[#a+1]={x=ZombRand(d),y=ZombRand(i),w=ZombRand(1,G+1),h=1,shade=ZombRand(k)+1}
end
self.glitch=a
self.link:freeze()
end

function SpiffBoyConsoleInstance:isFrozen()
return self.glitch~=nil or self.linkLost
end

function SpiffBoyConsoleInstance:onLinkLost()
if not self.powered or self:isFrozen()then
return
end
self.linkLost=true
self.link:freeze()
end

function SpiffBoyConsoleInstance:powerOff()
self.powered=false
self.gameMissing=false
self.boot=nil
self.glitch=nil
self.linkLost=false
self.runtime:setGame(nil)
self.runtime:setDevices({})
self.sequencer=nil
self.chip:halt()
self.link:powerOff()
self.channel:announce()
self:persistHardware()
end

function SpiffBoyConsoleInstance:writeHardware(save)
SpiffBoyClientActions.saveHandheld(self.playerObj,self.console,save,self.battery,self:volume(),b.placeOf(self.anchor))
self.batteryDirty=false
self.volumeDirty=false
end

function SpiffBoyConsoleInstance:persistHardware()
if not self.batteryDirty and not self.volumeDirty then
return
end
self:writeHardware(nil)
end

function SpiffBoyConsoleInstance:persistSave(save)
self:writeHardware(save)
end

function SpiffBoyConsoleInstance:advance()
local a=self.runtime
if a.game and not self:isFrozen()then
a:advance(self.inputs,isGamePaused(),SpiffBoy.consoleRate())
else
self.input:latch()
end
if self.boot and not self:isFrozen()and self.boot:isDone()then
self.boot=nil
self:startGame()
end
if self.input.pressed.exit and self.window then
self.window:putAway()
end
end

function SpiffBoyConsoleInstance:onGameCrash()
self:freeze()
end

function SpiffBoyConsoleInstance:startGame()
local a=SpiffBoy.Cartridges.resolveGame(self.definition)
if not a then
self.runtime:setGame(nil)
SpiffBoy.GameErrors.warn("SB-GAME-CLASS","no game class named "..tostring(self.definition.game))
self.gameMissing=true
return
end
self.sequencer=SpiffBoySequencer.new(self.chip,SpiffBoy.Tunes.set(self.definition.id))
self.sequencer.listener=self.link
self.runtime:setDevices({self.sequencer,self.chip,self.link,self.channel})
self.gameContext=self:buildContext()
self.runtime:start(a,self.gameContext)
end

function SpiffBoyConsoleInstance:buildContext()
local a=self
self.artNames={}
return{
seed=SpiffBoy.newSeed(),
definition=self.definition,
art=h.namedArt(self.gameArt,self.artNames),
chip=self.chip,
sequencer=self.sequencer,
link=self.channel:view(),
save=SpiffBoy.Handheld.recordSave(self.record),
persist=function(save)
a:persistSave(save)
end,
}
end

function SpiffBoyConsoleInstance:stateParts()
local a=self.runtime.game
if a==self.boot then
a=nil
end
return{
runtime=self.runtime,
chip=self.chip,
sequencer=self.sequencer,
context=self.gameContext or{definition=self.definition},
artNames=self.artNames,
game=a,
boot=self.boot,
bootLogo=self.screenArt(s),
}
end

function SpiffBoyConsoleInstance:captureState(pace)
local a=self:stateParts()
local d={}
for l,i in ipairs(w)do
d[i]=self[i]
end
a.console=d
return h.capture(a,pace)
end

function SpiffBoyConsoleInstance:runAhead(ticks)
local a={}
local d=self.chip.listener
local i=self.sequencer and self.sequencer.listener
self.chip.listener=h.chipTrace(a)
if self.sequencer then
self.sequencer.listener=nil
end
if not self:isFrozen()then
self.runtime:stepTicks({SpiffBoyInputState.new()},ticks)
end
self.chip.listener=d
if self.sequencer then
self.sequencer.listener=i
end
return a
end

local function K(glitch,width,height)
if type(glitch)~="table"or#glitch>q+r then
return false
end
for L,a in ipairs(glitch)do
if type(a)~="table"then
return false
end
local d,i,l,m,n=a.x,a.y,a.w,a.h,a.shade
if not(SpiffBoy.isInteger(d)and SpiffBoy.isInteger(i)and SpiffBoy.isInteger(l)and SpiffBoy.isInteger(m)and SpiffBoy.isInteger(n))then
return false
end
if d<0 or d>=width or i<0 or i>=height or l<1 or l>width or m<1 or m>height or n<1 or n>k then
return false
end
end
return true
end

local function l(fields,width,height)
if type(fields)~="table"then
return false
end
for d,a in ipairs({"powered","switchOn","linkLost","gameMissing"})do
if type(fields[a])~="boolean"then
return false
end
end
local a=fields.battery
if a~=nil and not(SpiffBoy.isFinite(a)and a>=0 and a<=1)then
return false
end
if not SpiffBoy.isInteger(fields.volumeStep)or fields.volumeStep<0 or fields.volumeStep>c then
return false
end
if not SpiffBoy.isInteger(fields.flickerFrames)or fields.flickerFrames<0 then
return false
end
if not SpiffBoy.isFinite(fields.noiseCounter)then
return false
end
return fields.glitch==nil or K(fields.glitch,width,height)
end

function SpiffBoyConsoleInstance:restoreState(data,pace)
if self.definition then
self.sequencer=SpiffBoySequencer.new(self.chip,SpiffBoy.Tunes.set(self.definition.id))
self.sequencer.listener=self.link
self.gameContext=self:buildContext()
end
local d=self:stateParts()
d.game=nil
d.boot=nil
local a=h.restore(data,d,pace)
if not l(a.console,self.screen.width,self.screen.height)then
error("the console fields of the save state are out of their range")
end
for m,i in ipairs(w)do
self[i]=a.console[i]
end
self.speaker:setVolume(self:volume())
self.volumeDirty=true
self.boot=a.boot
if a.game then
self.runtime:setDevices({self.sequencer,self.chip,self.link,self.channel})
else
self.runtime:setDevices({self.chip,self.link,self.channel})
end
end

function SpiffBoyConsoleInstance:announce()
if self.powered and self.definition then
self.link:powerOn(self.definition.item,self:volume())
if self:isFrozen()then
self.link:freeze()
end
end
self.channel:announce()
end

function SpiffBoyConsoleInstance:close()
if self.closing then
return
end
self.closing=true
self.paused=false
if self.awaitingGame then
SpiffBoy.ConsoleHandover.forgetClaim(self.consoleId)
end
if self.window then
self.window:hide()
end
self.runtime:setGame(nil)
self:persistHardware()
self.link:close()
self.speaker:destroy()
if not self.handedOver then
SpiffBoy.ConsoleHandover.stopped(self)
end
if SpiffBoyConsoleInstance.instances[self.consoleId]==self then
SpiffBoyConsoleInstance.instances[self.consoleId]=nil
end
SpiffBoy.ConsoleStatus.refreshName(self.console)
end

local function d()
for i,a in pairs(SpiffBoyConsoleInstance.instances)do
if a.paused then
a:stepPaused()
elseif not a.window then
a:step()
end
end
end

Events.OnPreUIDraw.Add(d)
