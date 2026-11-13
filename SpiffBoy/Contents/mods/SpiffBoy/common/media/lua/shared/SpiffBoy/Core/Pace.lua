-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Sandbox"

local b={[5]=2,[20]=4,[40]=6}
local a=1

function SpiffBoy.consoleRate()
if SpiffBoy.Sandbox.fastForwardWhilePlaying()then
return a
end
return b[getGameTime():getTrueMultiplier()]or a
end
