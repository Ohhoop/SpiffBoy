require"SpiffBoy/Core/Core"

SpiffBoy.CompatVersion=SpiffBoy.CompatVersion or{}
local c=SpiffBoy.CompatVersion

local function g(text)
local a={}
for b in string.gmatch(text..".","([^.]*)%.")do
if not string.match(b,"^%d+$")then
return nil
end
table.insert(a,tonumber(b))
end
return a
end

local function h(text)
if text==""then
return nil
end
local a=string.match(text,"^%-?(%w+)$")
if a==nil then
return false
end
local b,d=string.match(a,"^(%a*)(%d*)$")
if b==nil then
return false
end
local e=0
if d~=""then
e=tonumber(d)
end
return{label=string.lower(b),number=e}
end

function c.parse(text)
if type(text)~="string"then
return nil
end
local a,e=string.match(text,"^%s*([%d%.]+)(.-)%s*$")
if a==nil then
return nil
end
local b=g(a)
local d=h(e)
if b==nil or d==false then
return nil
end
return{numbers=b,pre=d}
end

local function i(a,b)
for d=1,math.max(#a,#b)do
local e,f=a[d]or 0,b[d]or 0
if e~=f then
return e<f and-1 or 1
end
end
return 0
end

local function j(a,b)
if a==nil or b==nil then
if a==b then
return 0
end
return a==nil and 1 or-1
end
if a.label~=b.label then
return a.label<b.label and-1 or 1
end
if a.number~=b.number then
return a.number<b.number and-1 or 1
end
return 0
end

function c.compare(a,b)
local d=i(a.numbers,b.numbers)
if d~=0 then
return d
end
return j(a.pre,b.pre)
end

function c.installed(modId)
local a=getModInfoByID(modId)
if a==nil then
return nil
end
return a:getModVersion()
end

function c.activeMod(modIds)
local a=getActivatedMods()
for e,b in ipairs(modIds)do
for d=0,a:size()-1 do
if a:get(d)==b then
return b
end
end
end
return nil
end

function c.branch(compatName,modId,version,branches)
local e=c.parse(version)
local a,b=nil,nil
for l,f in ipairs(branches)do
local d=c.parse(f.from)
local k=e==nil or c.compare(d,e)<=0
if k and(b==nil or c.compare(d,b)>0)then
a,b=f,d
end
end
if a==nil then
SpiffBoy.log(compatName.." compatibility off: "..modId.." "..tostring(version).." is older than every version it knows")
return nil
end
if a.from~=version then
SpiffBoy.trace(compatName.." compatibility: "..modId.." "..tostring(version).." follows the "..a.from.." branch")
end
return a
end
