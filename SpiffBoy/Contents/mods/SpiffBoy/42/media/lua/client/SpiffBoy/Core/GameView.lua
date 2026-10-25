require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/GameErrors"

SpiffBoy.GameView=SpiffBoy.GameView or{}
local b=SpiffBoy.GameView

local function c(members,readers)
local a={}
for d,e in pairs(members)do
a[#a+1]=d
end
for d,e in pairs(readers)do
a[#a+1]=d
end
table.sort(a)
return table.concat(a,", ")
end

local function d(name,key,list)
SpiffBoy.GameErrors.raise("SB-HIDDEN","the "..name.." of the console has no "..tostring(key).."; a game reaches only "..list)
end

local function e(name)
return function(_,key)
SpiffBoy.GameErrors.raise("SB-READONLY","a game cannot write "..tostring(key).." on the "..name.." of the console")
end
end

function b.new(name,members,readers)
local f=c(members,readers)
local a=setmetatable({},{
__index=function(_,key)
local a=readers[key]
if a then
return a()
end
d(name,key,f)
end,
})
for g,h in pairs(members)do
a[g]=h
end
return setmetatable({},{
__index=a,
__newindex=e(name),
__metatable=false,
})
end

function b.live(name,source,keys)
local a={}
for g,f in ipairs(keys)do
a[f]=true
end
local f=c(a,{})
return setmetatable({},{
__index=function(_,key)
if a[key]then
return source[key]
end
d(name,key,f)
end,
__newindex=e(name),
__metatable=false,
})
end
