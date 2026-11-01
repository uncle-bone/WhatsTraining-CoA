local _,wt=...
local host,panel,tab,scroll,rows,searchBox
local selection="all"
local watched=setmetatable({},{__mode="k"})
local function activeHost()
 local names={"DragonUI_SpellbookFrame","AscensionSpellbookFrame","SpellBookFrame"}
 for _,name in ipairs(names) do local f=_G[name];if f and f.IsShown and f:IsShown() then return f end end
 return nil
end
local function refresh()
 if not panel or not panel:IsShown() then return end
 local data=wt:GetRows(selection,searchBox and searchBox:GetText() or "")
 local _,className=wt:GetCoAClass()
 panel.subtitle:SetText((className or "Unknown").." • "..#data.." entries • Trainer-observed data only")
 FauxScrollFrame_Update(scroll,#data,#rows,22)
 local offset=FauxScrollFrame_GetOffset(scroll)
 for i,b in ipairs(rows) do
  local row=data[i+offset]
  if not row then b.entry=nil;b:Hide() else
   local r=row.record;b.entry=r;b.verification=row.verification
   b.icon:SetTexture((r.spellID and select(3,GetSpellInfo(r.spellID))) or "Interface\\Icons\\INV_Misc_QuestionMark")
   b.name:SetText((r.requiredLevel and ("Lv "..r.requiredLevel.." ") or "")..(r.name or "Unknown")..(r.rank and r.rank~="" and " ("..r.rank..")" or ""))
   b.cost:SetText(type(r.costCopper)=="number" and GetCoinTextureString(r.costCopper) or "—")
   b:Show()
  end
 end
end
function wt:RefreshUI()refresh()end
local function show(value)
 if not panel then return end
 if value then panel:Show();refresh()else panel:Hide()end
end
local function create()
 if panel then return end
 host=activeHost()
 if not host then return end
 panel=CreateFrame("Frame","WhatsTrainingCoAPage",host)
 panel:SetAllPoints(host);panel:SetFrameLevel(host:GetFrameLevel()+3)
 panel:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=24,insets={left=8,right=8,top=8,bottom=8}})
 panel:Hide()
 local title=panel:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
 title:SetPoint("TOPLEFT",22,-27);title:SetText("What's Training? CoA")
 local subtitle=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
 subtitle:SetPoint("TOPLEFT",22,-53);subtitle:SetWidth(360);subtitle:SetJustifyH("LEFT");panel.subtitle=subtitle
 local close=CreateFrame("Button",nil,panel,"UIPanelCloseButton");close:SetPoint("TOPRIGHT",-10,-10)
 close:SetScript("OnClick",function()show(false)end)
 local filters={{"all","All"},{"available","Available"},{"next","Next level"},{"future","Upcoming"},{"requirements","Requires"},{"known","Known"}}
 for i,f in ipairs(filters) do
  local b=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
  b:SetSize(110,22);b:SetPoint("TOPLEFT",20+((i-1)%3)*116,-78-math.floor((i-1)/3)*26)
  b:SetText(f[2]);b:SetScript("OnClick",function()selection=f[1];refresh()end)
 end
 searchBox=CreateFrame("EditBox","WhatsTrainingCoASearch",panel,"InputBoxTemplate")
 searchBox:SetSize(280,20);searchBox:SetPoint("TOPLEFT",28,-138);searchBox:SetAutoFocus(false)
 searchBox:SetScript("OnTextChanged",function()if scroll then FauxScrollFrame_SetOffset(scroll,0)end;refresh()end)
 searchBox:SetScript("OnEscapePressed",function(self)self:ClearFocus()end)
 local searchLabel=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
 searchLabel:SetPoint("LEFT",searchBox,"RIGHT",8,0);searchLabel:SetText("Search")
 scroll=CreateFrame("ScrollFrame","WhatsTrainingCoAScroll",panel,"FauxScrollFrameTemplate")
 scroll:SetPoint("TOPLEFT",20,-174);scroll:SetPoint("BOTTOMRIGHT",-42,22)
 scroll:SetScript("OnVerticalScroll",function(self,offset)FauxScrollFrame_OnVerticalScroll(self,offset,22,refresh)end)
 rows={}
 for i=1,10 do
  local b=CreateFrame("Button",nil,panel);b:SetSize(345,22);b:SetPoint("TOPLEFT",24,-178-(i-1)*22)
  local icon=b:CreateTexture(nil,"ARTWORK");icon:SetSize(18,18);icon:SetPoint("LEFT");b.icon=icon
  local name=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");name:SetPoint("LEFT",icon,"RIGHT",4,0);name:SetWidth(235);name:SetJustifyH("LEFT");b.name=name
  local cost=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");cost:SetPoint("RIGHT",0,0);cost:SetWidth(100);cost:SetJustifyH("RIGHT");b.cost=cost
  b:SetScript("OnEnter",function(self)
   if not self.entry then return end
   GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
   if self.entry.spellID and GameTooltip.SetSpellByID then GameTooltip:SetSpellByID(self.entry.spellID) else GameTooltip:AddLine(self.entry.name or "Unknown spell")end
   if self.entry.requiredLevel then GameTooltip:AddLine("Required level: "..self.entry.requiredLevel)end
   GameTooltip:AddLine("Source: "..(self.verification or "UNKNOWN"),0.8,0.8,0.8)
   GameTooltip:Show()
  end)
  b:SetScript("OnLeave",function()GameTooltip:Hide()end)
  rows[i]=b
 end
 tab=CreateFrame("CheckButton","WhatsTrainingCoASpellbookTab",host)
 tab:SetFrameStrata("DIALOG")
 tab:SetFrameLevel(host:GetFrameLevel()+8)
 tab:SetSize(32,32)
 tab:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
 tab:SetScript("OnClick",function()show(not panel:IsShown())end)
 tab:SetScript("OnEnter",function(self)GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:AddLine("What's Training? CoA");GameTooltip:Show()end)
 tab:SetScript("OnLeave",function()GameTooltip:Hide()end)
 local function position()
  if not tab or not host then return end
  local anchor
  for i=1,10 do
   local candidate=host==SpellBookFrame and _G["SpellBookSkillLineTab"..i] or nil
   if candidate and candidate~=tab and candidate:IsShown() then anchor=candidate end
  end
  tab:ClearAllPoints()
  if anchor then tab:SetPoint("TOP",anchor,"BOTTOM",0,-4)
  else tab:SetPoint("TOPLEFT",host,"TOPRIGHT",-8,-110)end
 end
 -- Active spellbook hooks are installed by watchFrames.
 -- Attachment is refreshed by syncHost, not by a tab OnShow reanchor.
 position()
 panel:SetScript("OnShow",function()tab:SetChecked(true)end)
 panel:SetScript("OnHide",function()tab:SetChecked(false)end)
 host:HookScript("OnHide",function()show(false)end)
end
local function syncHost()
 local current=activeHost()
 if not current then
  if panel then panel:Hide() end
  if tab then tab:Hide() end
  return
 end
 if not panel then create() end
 if not panel then return end
 if host~=current then
  panel:Hide()
  host=current
  panel:SetParent(host);panel:ClearAllPoints();panel:SetAllPoints(host)
  tab:SetParent(host)
 end
 tab:SetFrameLevel(host:GetFrameLevel()+8)
 tab:ClearAllPoints()
 if host==SpellBookFrame then
  local anchor
  for i=1,10 do
   local candidate=_G["SpellBookSkillLineTab"..i]
   if candidate and candidate:IsShown() then anchor=candidate end
  end
  if anchor then tab:SetPoint("TOP",anchor,"BOTTOM",0,-4)
  else tab:SetPoint("TOPLEFT",host,"TOPRIGHT",-8,-110) end
 else
  tab:SetPoint("TOPLEFT",host,"TOPRIGHT",-8,-92)
 end
 tab:Show()
end
local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("SPELLS_CHANGED")
events:SetScript("OnEvent",function()syncHost()end)
local function watchFrames()
 for _,name in ipairs({"SpellBookFrame","AscensionSpellbookFrame","DragonUI_SpellbookFrame"}) do
  local f=_G[name]
  if f and not watched[f] then
   watched[f]=true
   f:HookScript("OnShow",syncHost)
   f:HookScript("OnHide",syncHost)
  end
 end
end
local previousSync=syncHost
syncHost=function()
 watchFrames()
 previousSync()
end
function wt:ToggleUI()
 syncHost()
 if not host or not host:IsShown() then
  if type(ToggleSpellBook)=="function" then ToggleSpellBook(BOOKTYPE_SPELL) end
  syncHost()
 end
 if not host or not host:IsShown() then print("What's Training? CoA: Open your spellbook first");return end
 show(not panel:IsShown())
end
