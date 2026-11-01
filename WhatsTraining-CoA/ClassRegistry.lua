local _,wt=...
local tokens={
 BARBARIAN="Barbarian",WITCHDOCTOR="Witch Doctor",FELSWORN="Felsworn",
 WITCHHUNTER="Witch Hunter",STORMBRINGER="Stormbringer",KNIGHTOFXOROTH="Knight of Xoroth",
 GUARDIAN="Guardian",TEMPLAR="Templar",BLOODMAGE="Bloodmage",RANGER="Ranger",
 CHRONOMANCER="Chronomancer",NECROMANCER="Necromancer",PYROMANCER="Pyromancer",
 CULTIST="Cultist",STARCALLER="Starcaller",SUNCLERIC="Sun Cleric",
 TINKER="Tinker",VENOMANCER="Venomancer",REAPER="Reaper",
 PRIMALIST="Primalist",RUNEMASTER="Runemaster",
}
function wt:GetCoAClass()
 local name,token=UnitClass("player")
 return token or "UNKNOWN",tokens[token] or name or token or "Unknown"
end
