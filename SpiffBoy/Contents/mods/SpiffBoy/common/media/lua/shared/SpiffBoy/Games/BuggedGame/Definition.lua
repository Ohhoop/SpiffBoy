-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/Core"
require"SpiffBoy/Framework/Cartridges"

SpiffBoy.Cartridges.register({
api=2,
id="BuggedGame",
item="SpiffBoy.Cartridge_BuggedGame",
title="Bugged Game",
mod=SpiffBoy.MOD_ID,
game="SpiffBoyBuggedGameGame",
art="media/ui/SpiffBoy/Games/BuggedGame/",
texts="media/lua/shared/SpiffBoy/Games/BuggedGame/Translate/",
loot={weight=0.5},
})
