-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/GameBase"
require"SpiffBoy/Framework/GameTexts"

SpiffBoyBrickBashGame=SpiffBoyGameBase:derive("SpiffBoyBrickBashGame")

local a=SpiffBoyBrickBashGame

a.gameText=SpiffBoy.GameTexts.of("BrickBash")
a.MODES={{key="c",text="ModeA",endless=false},{key="e",text="ModeB",endless=true}}
