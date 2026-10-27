SpiffBoy=SpiffBoy or{}
SpiffBoy.GameErrors=SpiffBoy.GameErrors or{}
local a=SpiffBoy.GameErrors

local b="SpiffBoy: "
local e="SpiffBoy: [SB-"

a.LUA="SB-LUA"

a.CATALOG={
["SB-SAVE-PRESS"]={fix="save on the press that answers it: the end screen confirmed, a SAVE entry, the options left",see="05-saving.md, When to save"},
["SB-SAVE-LIMIT"]={fix="keep the save within the limits and measure it with SpiffBoy.SaveData.measure",see="05-saving.md, What a save can hold"},
["SB-SAVE-TABLE"]={fix="give SpiffBoy.SaveData.measure the save table",see="15-api-reference.md, SpiffBoy.SaveData"},
["SB-DRAW-LIMIT"]={fix="draw less in one frame and count the calls with screen.calls",see="03-screen-and-art.md, The draw call limit"},
["SB-SHADE"]={fix="give a shade from 1 to 4, or none for shade 1",see="03-screen-and-art.md, The four shades"},
["SB-TUNE"]={fix="register the tune under the id of the cartridge and keep the tune names in constants",see="04-sound-and-music.md, Registering tunes"},
["SB-CHIP-REGISTER"]={fix="write the registers through the constants SpiffBoyChip.NR10 to SpiffBoyChip.NR52",see="14-sound-chip-reference.md, Registers"},
["SB-CHIP-VALUE"]={fix="write a whole number from 0 to 255",see="14-sound-chip-reference.md, Registers"},
["SB-CHIP-WAVE"]={fix="load one of the 32 wave tables by its name",see="04-sound-and-music.md, Echo and wave tables"},
["SB-LINK-MESSAGE"]={fix="send a text that is not empty and fits the size the message names",see="07-link-cable.md, The port: self.link"},
["SB-REPEAT"]={fix="take chance from self.random and time from the ticks of the game",see="02-how-a-cartridge-works.md, The random generator"},
["SB-SEED"]={fix="seed the generator with a number",see="15-api-reference.md, The random generator"},
["SB-HIDDEN"]={fix="use only the members the message lists; the console keeps the others for itself",see="15-api-reference.md, Read-only views"},
["SB-READONLY"]={fix="keep the values of the game in its own fields, such as self.speed",see="15-api-reference.md, Read-only views"},
["SB-ART-MOD"]={fix="set mod in the definition to the id of the mod.info of your mod, and enable that mod",see="02-how-a-cartridge-works.md, The definition"},
["SB-TEXTS"]={fix="make the language file a JSON object with a UI section",see="06-texts-and-translations.md, One file per language"},
["SB-TEXTS-ID"]={fix="give SpiffBoy.GameTexts.of the id of a registered cartridge",see="06-texts-and-translations.md, Reading a text"},
["SB-REG-CARTRIDGE"]={fix="give the definition the field the message names",see="02-how-a-cartridge-works.md, The definition"},
["SB-REG-API"]={fix="write in the definition the api version the message names, or update SpiffBoy",see="02-how-a-cartridge-works.md, Versions of the framework"},
["SB-REG-DUPLICATE"]={fix="give the cartridge an id, an item and a game class of your own, prefixed with your namespace",see="02-how-a-cartridge-works.md, The definition"},
["SB-REG-TUNES"]={fix="register the tunes once, in a client file, under the id of a registered cartridge",see="04-sound-and-music.md, Registering tunes"},
["SB-REG-ITEM"]={fix="define the item in an item script of the mod, under the full type the definition names",see="08-the-cartridge-item.md, The item script"},
["SB-REG-TAG"]={fix="give the item the tag spiffboy:cartridge in its item script",see="08-the-cartridge-item.md, Dismantling"},
["SB-GAME-CLASS"]={fix="give the game field the global name of the class, and look above in the log for an error in its file",see="02-how-a-cartridge-works.md, The game class"},
["SB-TEXT-MISSING"]={fix="add the key to EN.json and run check_texts.py",see="06-texts-and-translations.md, Checking your texts"},
["SB-ART-MISSING"]={fix="check the name, given without .png, and the art folder of the definition",see="03-screen-and-art.md, The art folder"},
["SB-GLYPH"]={fix="write the text with characters of the pixel font only",see="03-screen-and-art.md, The pixel font"},
["SB-REG-TUNE"]={fix="write the tune and its voices as the notation reads them",see="04-sound-and-music.md, The notation"},
["SB-REG-VOICES"]={fix="give every voice of a looping tune the length of the tune",see="04-sound-and-music.md, The notation"},
[a.LUA]={fix="read the message for the name or the value that was nil or wrong",see="10-kahlua-and-pitfalls.md, Common mistakes"},
}

local function c(code,detail)
local d=a.CATALOG[code]
if not d then
error(b.."no error code "..tostring(code))
end
return"["..code.."] "..detail..". Fix: "..d.fix..". See: SDK docs/"..d.see.."."
end

function a.raise(code,detail)
error(b..c(code,detail),0)
end

function a.warn(code,detail)
SpiffBoy.log(c(code,detail))
end

function a.describe(message)
local d=tostring(message)
if string.sub(d,1,string.len(e))==e then
return string.sub(d,string.len(b)+1)
end
return c(a.LUA,d)
end
