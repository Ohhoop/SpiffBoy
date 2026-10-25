require"SpiffBoy/Core/Core"
require"SpiffBoy/Framework/Cartridges"

SpiffBoy.Cartridges.register({
api=1,
id="BuggedGame",
item="SpiffBoy.Cartridge_BuggedGame",
title="Bugged Game",
mod=SpiffBoy.MOD_ID,
game="SpiffBoyBuggedGameGame",
art="media/ui/SpiffBoy/Games/BuggedGame/",
texts="media/lua/shared/SpiffBoy/Games/BuggedGame/Translate/",
loot={weight=0.5},
})
