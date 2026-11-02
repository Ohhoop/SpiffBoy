require"SpiffBoy/Core/Core"

SpiffBoy.GuideMemory=SpiffBoy.GuideMemory or{}
local b=SpiffBoy.GuideMemory

local g="SpiffBoy/Guide.ini"
local h="show="
local c="world="
local j="false"

local a=nil

local function i()
local d=getCore():getGameMode().."/"..getWorld():getWorld()
return(string.gsub(d,"[\r\n]",""))
end

local function d()
if a then
return a
end
a={opensWithConsole=true,worlds={}}
local f=getFileReader(g,false)
if not f then
return a
end
while true do
local e=f:readLine()
if e==nil then
break
end
if e==h..j then
a.opensWithConsole=false
elseif string.sub(e,1,#c)==c then
a.worlds[string.sub(e,#c+1)]=true
end
end
f:close()
return a
end

local function f()
local e=getFileWriter(g,true,false)
e:writeln(h..tostring(a.opensWithConsole))
for k in pairs(a.worlds)do
e:writeln(c..k)
end
e:close()
end

function b.opensWithConsole()
return d().opensWithConsole
end

function b.setOpensWithConsole(opens)
d().opensWithConsole=opens
f()
end

function b.openedInWorld()
return d().worlds[i()]==true
end

function b.markOpenedInWorld()
d().worlds[i()]=true
f()
end
