-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/GameBase"

SpiffBoyQuickStartGame=SpiffBoyGameBase:derive("SpiffBoyQuickStartGame")

local a=SpiffBoyQuickStartGame

function a.pressed(input,button)
return input~=nil and input.pressed[button]==true
end
