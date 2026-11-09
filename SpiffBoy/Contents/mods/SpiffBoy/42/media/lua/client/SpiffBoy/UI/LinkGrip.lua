-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/UI/JackGrip"

SpiffBoyLinkGrip=SpiffBoyJackGrip:derive("SpiffBoyLinkGrip")

function SpiffBoyLinkGrip:onRightMouseUp(x,y)
if not isGamePaused()then
self.window:openLinkMenu()
end
return true
end
