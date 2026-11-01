local _,wt=...
local host,panel,tab,scroll,rows
local selection="all"
local function refresh()
 if not panel or not panel:IsShown() then return end
 local data=wt:GetRows(selection)
 panel.subtitle:SetText(#data.." trainer-observed entries • Visit trainers to build the catalog")
 FauxScrollFrame_Update(scroll,#data,#rows,22)
 local offset=FauxScrollFrame_GetOffset(scroll)
 for i,b in ipairs(rows) do
  local row=data[i+offset]
  if not row then b.entry=nil;b:Hide() else
   local r=row.record;b.entry=r
   b.icon:SetTexture((r.spellID and select(3,GetSpellInfo(r.spellID))) or "Interface\\Icons\\INV_Misc_QuestionMark")
   b.name:SetText((r.requiredLevel and ("Lv "..r.requiredLevel.." ") or "")..(r.name or "Unknown")..(r.rank and r.rank~="" and " ("..r.rank..")" or ""))
   b.cost:SetText(type(r.costCopper)=="number" and GetCoinTextureString(r.costCopper) or "")
   b:Show()
  end
 end
end
function wt:RefreshUI()refresh()end
local function show(value) if panel then if value then panel:Show();refresh()else panel:Hide()end end end
local function create()
 if panel or not SpellBookFrame then return end
 host=SpellBookFrame
 panel=CreateFrame("Frame","WhatsTrainingCoAPage",host)
 panel:SetAllPoints(host);panel:SetFrameLevel(host:GetFrameLevel()+3)
 panel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,insets={left=8,right=8,top=8,bottom=8}})
 panel:Hide()
 local title=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
 title:SetPoint("TOPLEFT",22,-27);title:SetText("What's Training? CoA")
 local subtitle=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
 subtitle:SetPoint("TOPLEFT",22,-53);subtitle:SetWidth(340);subtitle:SetJustifyH("LEFT");panel.subtitle=subtitle
 local close=CreateFrame("Button",nil,panel,"UIPanelCloseButton");close:SetPoint("TOPRIGHT",-10,-10)
 close:SetScript("OnClick",function()show(false)end)
 local filters={{"all","All"},{"available","Available"},{"next","Next level"},{"future","Upcoming"},{"requirements","Requires"},{"known","Known"}}
 for i,f in ipairs(filters) do
  local b=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
  b:SetSize(110,22);b:SetPoint("TOPLEFT",20+((i-1)%3)*116,-78-math.floor((i-1)/3)*26)
  b:SetText(f[2]);b:SetScript("OnClick",function()selection=f[1];refresh()end)
 end
 scroll=CreateFrame("ScrollFrame","WhatsTrainingCoAScroll",panel,"FauxScrollFrameTemplate")
 scroll:SetPoint("TOPLEFT",20,-145);scroll:SetPoint("BOTTOMRIGHT",-42,22)
 scroll:SetScript("OnVerticalScroll",function(self,offset)FauxScrollFrame_OnVerticalScroll(self,offset,22,refresh)end)
 rows={}
 for i=1,10 do
  local b=CreateFrame("Button",nil,panel);b:SetSize(345,22);b:SetPoint("TOPLEFT",24,-150-(i-1)*22)
  local icon=b:CreateTexture(nil,"ARTWORK");icon:SetSize(18,18);icon:SetPoint("LEFT");b.icon=icon
  local name=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");name:SetPoint("LEFT",icon,"RIGHT",4,0);name:SetWidth(235);name:SetJustifyH("LEFT");b.name=name
  local cost=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");cost:SetPoint("RIGHT",0,0);cost:SetWidth(100);cost:SetJustifyH("RIGHT");b.cost=cost
  b:SetScript("OnEnter",function(self)
   if not self.entry then return end
   GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
   if self.entry.spellID and GameTooltip.SetSpellByID then GameTooltip:SetSpellByID(self.entry.spellID) else GameTooltip:AddLine(self.entry.name or "Unknown spell")end
   if self.entry.requiredLevel then GameTooltip:AddLine("Required level: "..self.entry.requiredLevel)end
   GameTooltip:Show()
  end)
  b:SetScript("OnLeave",function()GameTooltip:Hide()end)
  rows[i]=b
 end
 tab=CreateFrame("CheckButton","WhatsTrainingCoASpellbookTab",host,"SpellBookSkillLineTabTemplate")
 tab:SetSize(34,34);tab:SetPoint("TOPLEFT",host,"TOPRIGHT",-8,-100)
 tab:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
 tab:SetScript("OnClick",function()show(not panel:IsShown())end)
 tab:SetScript("OnEnter",function(self)
  GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:AddLine("What's Training? CoA");GameTooltip:Show()
 end)
 tab:SetScript("OnLeave",function()GameTooltip:Hide()end)
 panel:SetScript("OnShow",function()tab:SetChecked(true)end)
 panel:SetScript("OnHide",function()tab:SetChecked(false)end)
 host:HookScript("OnHide",function()show(false)end)
end
local events=CreateFrame("Frame");events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent",function()create()end)
function wt:ToggleUI()
 create()
 if not host then print("What's Training? CoA: Spellbook unavailable");return end
 if not host:IsShown() then if type(ToggleSpellBook)=="function" then ToggleSpellBook(BOOKTYPE_SPELL) else host:Show()end end
 show(not panel:IsShown())
end
