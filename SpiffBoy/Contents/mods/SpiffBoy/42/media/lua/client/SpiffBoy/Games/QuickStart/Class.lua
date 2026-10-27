require"SpiffBoy/Core/GameBase"

SpiffBoyQuickStartGame=SpiffBoyGameBase:derive("SpiffBoyQuickStartGame")

local a=SpiffBoyQuickStartGame

function a.pressed(input,button)
return input~=nil and input.pressed[button]==true
end
