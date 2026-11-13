-- SpiffBoy (c) 2026 Ohhoop. All rights reserved. See LICENSE.txt.
require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/GameErrors"

SpiffBoy.Textures=SpiffBoy.Textures or{}
local a=SpiffBoy.Textures

a.generation=0

local i=3

local d={}
local e={}
local f={}
local g={}

local function h(modId)
local b=getModInfoByID(modId)
if not b then
SpiffBoy.GameErrors.raise("SB-ART-MOD","the mod "..tostring(modId).." is not in the mod list of the game")
end
return b
end

function a.commonFolder(modId)
local b=f[modId]
if not b then
b=h(modId):getCommonDir()
f[modId]=b
end
return b
end

function a.versionFolder(modId)
local b=g[modId]
if not b then
b=h(modId):getVersionDir()
g[modId]=b
end
return b
end

function a.cartridgeFolder(definition)
if definition.api>=SpiffBoy.COMMON_ART_API then
return a.commonFolder(definition.mod)
end
return a.versionFolder(definition.mod)
end

local function j(root,path)
return root.."/"..path
end

local function k(path)
local c,b=pcall(Texture.new,path)
if c and b and b:getWidth()>0 then
return b
end
return nil
end

local function l(path)
local b=Texture.getSharedTexture(path,i)
if b and SpiffBoy.isDevBuild()then
b:reloadFromFile(path)
end
return b
end

local function m(path)
if SpiffBoy.isDevBuild()then
return k(path)
end
return getTexture(path)
end

function a.get(root,path,nearest)
local b=j(root,path)
local c=d[b]
if c then
return c
end
if e[b]then
return nil
end
if nearest then
c=l(b)
else
c=m(b)
end
if c then
d[b]=c
else
e[b]=true
SpiffBoy.GameErrors.warn("SB-ART-MISSING","missing texture "..b)
end
return c
end

function a.refresh()
if not SpiffBoy.isDevBuild()then
return
end
d={}
e={}
a.generation=a.generation+1
end

function a.folder(root,base,nearest)
return function(name)
return a.get(root,base..name..".png",nearest)
end
end
