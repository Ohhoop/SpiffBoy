require"SpiffBoy/UI/HandheldWindow"
require"SpiffBoy/Compat/CompatVersion"

local d="pz3d"
local c="pz3d"
local e={
{from="0.9.2"},
}

local a=false

local function f()
local b=MainScreen and MainScreen.instance
return b~=nil and b.inGame==true and b:isVisible()
end

local function g()
if SpiffBoyHandheldWindow.anyShown()~=nil then
if not PZ3D.menuUi()then
PZ3D.menuUi(true)
end
a=true
elseif a then
a=false
PZ3D.menuUi(f())
end
end

local function h()
if PZ3D==nil then
return
end
local b=SpiffBoy.CompatVersion
if b.branch(d,c,b.installed(c),e)then
Events.OnTick.Add(g)
end
end

Events.OnGameStart.Add(h)
