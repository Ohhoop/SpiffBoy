-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Framework/Cartridges"

SpiffBoy.Cartridges.register({
api=2,
id="PipeBomber",
item="SpiffBoy.Cartridge_PipeBomber",
title="Pipe Bomber",
mod=SpiffBoy.MOD_ID,
game="SpiffBoyPipeBomberGame",
art="media/ui/SpiffBoy/Games/PipeBomber/",
texts="media/lua/shared/SpiffBoy/Games/PipeBomber/Translate/",
loot={weight=2},
})
