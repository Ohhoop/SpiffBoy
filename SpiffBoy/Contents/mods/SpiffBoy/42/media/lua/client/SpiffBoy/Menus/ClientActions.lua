require"SpiffBoy/Core/Core"
require"SpiffBoy/Core/Commands"
require"SpiffBoy/Core/SaveData"
require"SpiffBoy/Handheld/Handheld"
require"SpiffBoy/Handheld/ConsoleLocator"

SpiffBoyClientActions={}

function SpiffBoyClientActions.saveHandheld(playerObj,console,save,battery,volume,place)
if isClient()then
local b=save and SpiffBoy.SaveData.clean(save)or nil
local a={itemId=console:getID(),battery=battery,volume=volume,save=b}
SpiffBoy.ConsoleLocator.writePlace(a,place)
sendClientCommand(playerObj,SpiffBoy.COMMAND_MODULE,SpiffBoy.COMMAND_SAVE_HANDHELD,a)
return
end
SpiffBoy.Handheld.applySaved(console,save,battery,volume)
end
