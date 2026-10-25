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

local function b(context)
return SpiffBoy.GameView.new("context",{art=context.art},{})
end

local function c(id,acting,write)
return function(game)
if not acting()then
SpiffBoy.GameErrors.raise("SB-SAVE-PRESS","the game "..id.." tried to save without a button press, and nothing was written")
end
local a=SpiffBoy.SaveData.check(game.save)
if a then
SpiffBoy.GameErrors.raise("SB-SAVE-LIMIT","the game "..id.." cannot save, "..a..", and nothing was written")
end
write(game.save)
end
end

function SpiffBoyGameBase:new(runtime,context)
local a=setmetatable({},self)
a.screen=runtime.view
a.context=b(context)
a.random=SpiffBoyRandom.new(context.seed)
a.save=SpiffBoy.SaveData.clean(context.save)
a.persist=c(tostring(context.definition and context.definition.id),context.acting,context.persist)
a.chip=context.chip:view()
a.sequencer=context.sequencer:view()
a.link=context.link
a:init()
return a
end

function SpiffBoyGameBase:init()
end

function SpiffBoyGameBase:tick(inputs,tick)
end

function SpiffBoyGameBase:draw(screen)
end
