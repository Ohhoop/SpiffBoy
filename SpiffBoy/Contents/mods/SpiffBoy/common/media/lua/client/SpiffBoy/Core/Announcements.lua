-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"PZAPI/ModOptions"
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/ConsolePosition"

SpiffBoy.Announcements=SpiffBoy.Announcements or{}
local a=SpiffBoy.Announcements

a.ART="media/ui/SpiffBoy/Announcements/"
a.LABEL="label"
a.GAMES={
{id="BeforeTheBell",mod="BeforeTheBell",workshop="3838972108",shots={"shot_1","shot_2"}},
}

local f="SpiffBoy/Announcements.ini"
local c="seen="
local i="AnnounceGames"
local j="UI_SpiffBoy_Announce_"

local b=nil
local g=PZAPI.ModOptions:getOptions(SpiffBoy.MOD_ID):addTickBox(i,"UI_SpiffBoy_AnnounceGames",true)

local function h()
if b then
return b
end
b={}
local d=getFileReader(f,false)
if not d then
return b
end
while true do
local e=d:readLine()
if e==nil then
break
end
if string.sub(e,1,#c)==c then
b[string.sub(e,#c+1)]=true
end
end
d:close()
return b
end

local function e()
local d=getFileWriter(f,true,false)
for k in pairs(b)do
d:writeln(c..k)
end
d:close()
end

function a.latest()
return a.GAMES[#a.GAMES]
end

function a.isOn()
return g:getValue()==true
end

function a.setOn(on)
g:setValue(on)
PZAPI.ModOptions:save()
end

function a.isInstalled(game)
return getModInfoByID(game.mod)~=nil
end

function a.wasSeen(game)
return h()[game.id]==true
end

function a.markSeen(game)
h()[game.id]=true
e()
end

function a.pending()
local d=a.latest()
if not a.isOn()or a.wasSeen(d)or a.isInstalled(d)then
return nil
end
return d
end

function a.textKey(game,name)
return j..game.id.."_"..name
end

function a.artPath(game,name)
return a.ART..game.id.."/"..name..".png"
end
