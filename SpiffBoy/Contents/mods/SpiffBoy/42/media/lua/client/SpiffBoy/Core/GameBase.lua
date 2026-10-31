require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/GameErrors"
require"SpiffBoy/Core/GameView"
require"SpiffBoy/Core/Random"
require"SpiffBoy/Core/SaveData"

SpiffBoyGameBase={}
SpiffBoyGameBase.__index=SpiffBoyGameBase

function SpiffBoyGameBase:derive(name)
local a={}
a.__index=a
a.Type=name
setmetatable(a,self)
return a
end

local function g(context)
return SpiffBoy.GameView.new("context",{art=context.art},{})
end

local h=3
local i=3600

local function j(id,acting,write,clock)
local b={}
local c=false
return function(game)
if not acting()then
SpiffBoy.GameErrors.raise("SB-SAVE-PRESS","the game "..id.." tried to save without a button press, and nothing was written")
end
local d=SpiffBoy.SaveData.check(game.save)
if d then
SpiffBoy.GameErrors.raise("SB-SAVE-LIMIT","the game "..id.." cannot save, "..d..", and nothing was written")
end
write(game.save)
local e=clock()
local a={}
for k,f in ipairs(b)do
if e-f<i then
a[#a+1]=f
end
end
a[#a+1]=e
b=a
if#b>h and not c then
c=true
SpiffBoy.GameErrors.warn("SB-SAVE-OFTEN","the game "..id.." saved "..#b.." times within a minute of play")
end
end
end

function SpiffBoyGameBase:new(runtime,context)
local a=setmetatable({},self)
local b=SpiffBoyGameBase.coreParts(runtime,context)
a.screen=b.screen
a.context=b.context
a.random=SpiffBoyRandom.new(context.seed)
a.save=SpiffBoy.SaveData.clean(context.save)
a.persist=b.persist
a.chip=b.chip
a.sequencer=b.sequencer
a.link=b.link
a:init()
return a
end

function SpiffBoyGameBase.coreParts(runtime,context)
return{
screen=runtime.view,
context=g(context),
persist=j(tostring(context.definition and context.definition.id),context.acting,context.persist,function()return runtime.tick end),
chip=context.chip:view(),
sequencer=context.sequencer:view(),
link=context.link,
}
end

function SpiffBoyGameBase:init()
end

function SpiffBoyGameBase:tick(inputs,tick)
end

function SpiffBoyGameBase:draw(screen)
end
