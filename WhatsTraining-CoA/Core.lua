local _,wt=...
local function safe(f,...)
 if type(f)~="function" then return nil end
 local ok,a,b,c,d=pcall(f,...)
 if ok then return a,b,c,d end
end
local function initialize()
 WhatsTrainingCoADB=WhatsTrainingCoADB or {}
 local db=WhatsTrainingCoADB
 db.characters=db.characters or {};db.settings=db.settings or {};db.catalog=db.catalog or {}
 local class=select(2,UnitClass("player")) or "UNKNOWN"
 local realm=GetRealmName() or "Realm"
 local player=UnitName("player") or "Player"
 local key=realm..":"..player..":"..class
 local saved=db.characters[key] or {spells={},trainers={}}
 saved.spells=saved.spells or {};saved.trainers=saved.trainers or {}
 db.characters[key]=saved
 wt.character=saved;wt.db=db;wt.classToken=class;wt.realm=realm
end
function wt:Initialize() initialize() end
local function merge(dst,src)
 dst.name=src.name or dst.name
 dst.rank=src.rank or dst.rank
 dst.spellID=src.spellID or dst.spellID
 if type(src.requiredLevel)=="number" then dst.requiredLevel=src.requiredLevel end
 if type(src.costCopper)=="number" then dst.costCopper=src.costCopper end
 dst.source="observed_trainer_window";dst.verification="VERIFIED"
 dst.trainers=dst.trainers or {}
 for id in pairs(src.trainers or {}) do dst.trainers[id]=true end
 -- Availability is a snapshot, not a property of the spell catalog.
 return dst
end
function wt:CaptureTrainer()
 if not self.character then initialize()end
 local count=safe(GetNumTrainerServices) or 0
 if count<1 then return 0 end
 local guid=safe(UnitGUID,"npc") or safe(UnitGUID,"target") or "unknown"
 local name=safe(UnitName,"npc") or safe(UnitName,"target") or "Unknown trainer"
 self.character.trainers[guid]=name
 local class=self.classToken or "UNKNOWN"
 local catalog=self.db.catalog[class] or {};self.db.catalog[class]=catalog
 local seen=0
 for i=1,count do
  local spellName,rank,kind,available=safe(GetTrainerServiceInfo,i)
  if type(spellName)=="string" and spellName~="" and kind~="header" then
   local spellID=safe(GetTrainerServiceSpellID,i)
   local link=safe(GetTrainerServiceItemLink,i)
   if not spellID and type(link)=="string" then spellID=tonumber(link:match("|Hspell:(%d+)")) end
   if type(spellID)~="number" then spellID=nil end
   local key=spellID and ("id:"..spellID) or ("name:"..spellName..":"..tostring(rank or ""))
   local observation={name=spellName,rank=rank,kind=kind,available=available,spellID=spellID,
      costCopper=safe(GetTrainerServiceCost,i),requiredLevel=safe(GetTrainerServiceLevelReq,i),
      trainers={[guid]=true}}
   local row=self.character.spells[key] or {}
   merge(row,observation);row.kind=kind;row.available=available
   self.character.spells[key]=row
   catalog[key]=merge(catalog[key] or {},observation)
   seen=seen+1
  end
 end
 if self.RefreshUI then self:RefreshUI()end
 return seen
end
function wt:GetRows(filter,search)
 if not self.character then initialize()end
 local results={};local level=UnitLevel("player") or 1
 local source=self.db.catalog[self.classToken] or {}
 local combined={}
 for key,row in pairs(source) do combined[key]=row end
 for key,row in pairs(self.character.spells) do combined[key]=row end
 search=(search or ""):lower()
 for _,row in pairs(combined) do
  local known=row.spellID and type(IsSpellKnown)=="function" and IsSpellKnown(row.spellID)
  local status=known and "known" or (row.requiredLevel and row.requiredLevel>level and (row.requiredLevel==level+1 and "next" or "future")) or ((row.kind=="unavailable" or row.available==false) and "requirements") or "available"
  local matches=search=="" or (row.name or ""):lower():find(search,1,true)
  if matches and (filter=="all" or filter==status) then
   results[#results+1]={record=row,status=status,verification=row.verification or (row.source=="observed_trainer_window" and "VERIFIED" or "UNKNOWN")}
  end
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
