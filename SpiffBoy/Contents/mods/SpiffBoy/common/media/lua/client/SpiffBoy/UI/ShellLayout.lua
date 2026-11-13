-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/Core"
require"SpiffBoy/Framework/Cartridges"
require"SpiffBoy/Handheld/ConsoleInstance"

SpiffBoy.ShellLayout=SpiffBoy.ShellLayout or{}
local a=SpiffBoy.ShellLayout

a.ART=SpiffBoyConsoleInstance.ART
a.SHELL_WIDTH=384
a.SHELL_HEIGHT=252
a.SCREEN_X=102
a.SCREEN_Y=60
a.SCREEN_WIDTH=SpiffBoy.Cartridges.SCREEN_WIDTH
a.SCREEN_HEIGHT=SpiffBoy.Cartridges.SCREEN_HEIGHT
a.GLASS_BORDER=0.5
a.BOOT_LOGO=SpiffBoyConsoleInstance.BOOT_LOGO
a.SCREEN_OFF={r=132/255,g=146/255,b=138/255}
a.DPAD={x=47.5,y=125.5,size=72}
a.DPAD_COLUMNS=3
a.DPAD_REST=4
a.BUTTON_A={x=336,y=157}
a.BUTTON_B={x=336,y=95}
a.BUTTON_W=40
a.BUTTON_H=40
a.START={x=192,y=228,w=24,h=8}
a.LED={x=30,y=30,size=8}
a.LED_LIT=0
a.LED_DIM=1
a.LED_OFF=2
a.BLINK_MS=500
a.POWER={x=-4,w=4,h=20,onY=41,offY=47,hitMargin=4}
a.CRISP_BORDER=1/4
a.SIDE_TUCK=1
a.VOLUME={x=a.SHELL_WIDTH,w=4,h=22,y=43,hitMargin=4}
a.VOLUME_STEPS=SpiffBoyConsoleInstance.VOLUME_STEPS
a.SHELL_ART="shell"
a.POWER_SWITCH_ART="power_switch"
a.LED_ART="led"
a.BUTTON_START_ART="button_start"
a.SLOT={x=130,y=-3,w=125,h=9,empty="slot_empty",full="slot_cartridge"}
a.JACK={
x=322,
y=a.SHELL_HEIGHT,
zone={x=318,y=232,w=24},
empty={name="jack_empty",w=16,h=3,reach=3},
plugs={
headphones={name="jack_plugged",w=24,h=58,reach=38},
earbuds={name="jack_plugged_earbuds",w=24,h=52,reach=32},
},
slides={
headphones={name="plug_headphones",w=24,h=79,pin=25,dx=0},
earbuds={name="plug_earbuds",w=24,h=73,pin=25,dx=0},
},
}
a.LINK={
x=56,
y=a.SHELL_HEIGHT,
zone={x=55,y=232,w=24},
empty={name="link_empty",w=22,h=3,reach=3},
plugged={name="link_plugged",w=22,h=56,reach=36},
slide={name="plug_link",w=24,h=60,pin=8,dx=-1},
}
a.DPAD_FRAMES={}
a.BUTTON_FRAMES={a={[0]="button_a_0",[1]="button_a_1"},b={[0]="button_b_0",[1]="button_b_1"}}
a.VOLUME_FRAMES={}

for b=0,a.DPAD_COLUMNS*a.DPAD_COLUMNS-1 do
a.DPAD_FRAMES[b]="dpad_"..b
end
for b=0,a.VOLUME_STEPS do
a.VOLUME_FRAMES[b]="volume_wheel_"..b
end

function a.partRect(part)
if part=="power"then
local b=a.POWER
return b.x,b.onY,b.w,b.h
elseif part=="led"then
local b=a.LED
return b.x-b.size/2,b.y-b.size/2,b.size,b.size
elseif part=="volume"then
local b=a.VOLUME
return b.x,b.y,b.w,b.h
elseif part=="dpad"then
local b=a.DPAD
return b.x-b.size/2,b.y-b.size/2,b.size,b.size
elseif part=="a"or part=="b"then
local b=a.BUTTON_A
if part=="b"then
b=a.BUTTON_B
end
return b.x-a.BUTTON_W/2,b.y-a.BUTTON_H/2,a.BUTTON_W,a.BUTTON_H
elseif part=="start"then
local b=a.START
return b.x-b.w/2,b.y-b.h/2,b.w,b.h
elseif part=="slot"then
local b=a.SLOT
return b.x,b.y,b.w,b.h
elseif part=="link"or part=="jack"then
local b=a.LINK
if part=="jack"then
b=a.JACK
end
local c=b.zone
return c.x,c.y,c.w,b.y+b.empty.reach-c.y
elseif part=="shell"then
return 0,0,a.SHELL_WIDTH,a.SHELL_HEIGHT
end
error("SpiffBoy: the shell has no part "..tostring(part))
end
