local _,wt=...
local function safe(f,...)
 if type(f)~="function" then return nil end
 local ok,a,b,c,d=pcall(f,...)
 if ok then return a,b,c,d end
end
local function initialize()
 WhatsTrainingCoADB=WhatsTrainingCoADB or {characters={},settings={}}
 WhatsTrainingCoADB.characters=WhatsTrainingCoADB.characters or {}
 WhatsTrainingCoADB.settings=WhatsTrainingCoADB.settings or {}
 local class=select(2,UnitClass("player")) or "UNKNOWN"
 local key=(GetRealmName() or "Realm")..":"..(UnitName("player") or "Player")..":"..class
 local saved=WhatsTrainingCoADB.characters[key] or {spells={},trainers={}}
 saved.spells=saved.spells or {};saved.trainers=saved.trainers or {}
 WhatsTrainingCoADB.characters[key]=saved
 wt.character=saved;wt.db=WhatsTrainingCoADB
end
function wt:Initialize() initialize() end
function wt:CaptureTrainer()
 if not self.character then initialize()end
 local count=safe(GetNumTrainerServices) or 0
 if count<1 then return 0 end
 local guid=safe(UnitGUID,"npc") or safe(UnitGUID,"target") or "unknown"
 local name=safe(UnitName,"npc") or safe(UnitName,"target") or "Unknown trainer"
 self.character.trainers[guid]=name
 local seen=0
 for i=1,count do
  local spellName,rank,kind,available=safe(GetTrainerServiceInfo,i)
  if type(spellName)=="string" and spellName~="" and kind~="header" then
   local spellID=safe(GetTrainerServiceSpellID,i)
   local link=safe(GetTrainerServiceItemLink,i)
   if not spellID and type(link)=="string" then spellID=tonumber(link:match("|Hspell:(%d+)")) end
   if type(spellID)~="number" then spellID=nil end
   local key=spellID and ("id:"..spellID) or ("name:"..spellName..":"..tostring(rank or ""))
   local row=self.character.spells[key] or {}
   row.name=spellName;row.rank=rank;row.kind=kind;row.available=available;row.spellID=spellID
   row.costCopper=safe(GetTrainerServiceCost,i);row.requiredLevel=safe(GetTrainerServiceLevelReq,i)
   row.source="observed_trainer_window";row.trainers=row.trainers or {};row.trainers[guid]=true
   self.character.spells[key]=row;seen=seen+1
  end
 end
 if self.RefreshUI then self:RefreshUI()end
 return seen
end
function wt:GetRows(filter)
 if not self.character then initialize()end
 local results={};local level=UnitLevel("player") or 1
 for _,row in pairs(self.character.spells) do
  local known=row.spellID and type(IsSpellKnown)=="function" and IsSpellKnown(row.spellID)
  local status=known and "known" or (row.requiredLevel and row.requiredLevel>level and (row.requiredLevel==level+1 and "next" or "future")) or ((row.kind=="unavailable" or row.available==false) and "requirements") or "available"
  if filter=="all" or filter==status then results[#results+1]={record=row,status=status} end
 end
 table.sort(results,function(a,b)
  local x,y=a.record.requiredLevel or 999,b.record.requiredLevel or 999
  if x~=y then return x<y end
  return (a.record.name or "")<(b.record.name or "")
 end)
 return results
end
local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN");events:RegisterEvent("TRAINER_SHOW");events:RegisterEvent("TRAINER_UPDATE");events:RegisterEvent("LEARNED_SPELL_IN_TAB");events:RegisterEvent("PLAYER_LEVEL_UP")
events:SetScript("OnEvent",function(self,event)
 if event=="PLAYER_LOGIN" then initialize()
 elseif event=="TRAINER_SHOW" or event=="TRAINER_UPDATE" then wt:CaptureTrainer()
 elseif wt.RefreshUI then wt:RefreshUI()end
end)
SLASH_WHATSTRAININGCOA1="/wtcoa"
SlashCmdList.WHATSTRAININGCOA=function(msg)
 msg=(msg or ""):lower():match("^%s*(.-)%s*$")
 if msg=="scan" then print("What's Training? CoA: "..wt:CaptureTrainer().." trainer services found")
 elseif msg=="status" then
  if not wt.character then initialize()end
  local count=0;for _ in pairs(wt.character.spells) do count=count+1 end
  print("What's Training? CoA: "..count.." observed spell entries")
 elseif wt.ToggleUI then wt:ToggleUI()end
end
