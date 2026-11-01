local _,wt=...
local frame,scroll,buttons
local ROWS=13
local filters={{"all","All"},{"available","Available"},{"next","Next level"},{"future","Upcoming"},{"requirements","Requirements"},{"known","Learned"}}
local colors={available="|cff60dd86",next="|cff79caff",future="|cffffcb68",requirements="|cffff8080",known="|cffaaaaaa"}
local function create()
 if frame then return end
 frame=CreateFrame("Frame","WhatsTrainingCoAFrame",UIParent)
 frame:SetWidth(590);frame:SetHeight(425);frame:SetPoint("CENTER",UIParent,"CENTER",0,0)
 frame:SetFrameStrata("DIALOG");frame:SetMovable(true);frame:EnableMouse(true)
 frame:RegisterForDrag("LeftButton");frame:SetScript("OnDragStart",function(self) self:StartMoving() end)
 frame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
 frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile=true,tileSize=32,edgeSize=32,insets={left=9,right=9,top=9,bottom=9}})
 local title=frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge");title:SetPoint("TOPLEFT",20,-17);title:SetText("What's Training? CoA")
 local close=CreateFrame("Button",nil,frame,"UIPanelCloseButton");close:SetPoint("TOPRIGHT",-5,-5)
 local subtitle=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");subtitle:SetPoint("TOPLEFT",20,-45);subtitle:SetWidth(540);subtitle:SetJustifyH("LEFT")
 frame.subtitle=subtitle
 for i,entry in ipairs(filters) do
  local b=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
  b:SetWidth(85);b:SetHeight(23);b:SetPoint("TOPLEFT",15+(i-1)*93,-71);b:SetText(entry[2])
  b:SetScript("OnClick",function() wt.db.settings.filter=entry[1];wt:RefreshUI() end)
 end
 local scan=CreateFrame("Button",nil,frame,"UIPanelButtonTemplate")
 scan:SetWidth(116);scan:SetHeight(22);scan:SetPoint("BOTTOMLEFT",17,15);scan:SetText("Scan trainer")
 scan:SetScript("OnClick",function() local n=wt:CaptureTrainer();if n==0 then print("What's Training? CoA: Open a class trainer to scan services") end end)
 local info=frame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");info:SetPoint("BOTTOMLEFT",144,20)
 info:SetText("Trainer-observed entries only")
 scroll=CreateFrame("ScrollFrame","WhatsTrainingCoAScroll",frame,"FauxScrollFrameTemplate")
 scroll:SetPoint("TOPLEFT",18,-105);scroll:SetPoint("BOTTOMRIGHT",-40,45)
 scroll:SetScript("OnVerticalScroll",function(self,offset) FauxScrollFrame_OnVerticalScroll(self,offset,21,function() wt:RefreshUI() end) end)
 buttons={}
 for i=1,ROWS do
  local b=CreateFrame("Button",nil,frame);b:SetWidth(540);b:SetHeight(21);b:SetPoint("TOPLEFT",22,-107-(i-1)*21)
  local icon=b:CreateTexture(nil,"ARTWORK");icon:SetWidth(18);icon:SetHeight(18);icon:SetPoint("LEFT",2,0);b.icon=icon
  local text=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");text:SetPoint("LEFT",icon,"RIGHT",6,0);text:SetWidth(365);text:SetJustifyH("LEFT");b.text=text
  local cost=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall");cost:SetPoint("RIGHT",-2,0);cost:SetWidth(138);cost:SetJustifyH("RIGHT");b.cost=cost
  b:SetScript("OnEnter",function(self)
   if not self.entry then return end
   GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
   if self.entry.spellID and GameTooltip.SetSpellByID then GameTooltip:SetSpellByID(self.entry.spellID) else GameTooltip:AddLine(self.entry.name or "Unknown") end
   if self.entry.requiredLevel then GameTooltip:AddLine("Required level: "..self.entry.requiredLevel) end
   GameTooltip:Show()
  end)
  b:SetScript("OnLeave",function()GameTooltip:Hide()end);buttons[i]=b
 end
 frame:Hide()
end
function wt:RefreshUI()
 if not frame or not frame:IsShown() then return end
 local _,className=self:GetCoAClass()
 local rows=self:GetRows(self.db.settings.filter or "all")
 frame.subtitle:SetText((className or "Unknown").." • "..#rows.." records")
 FauxScrollFrame_Update(scroll,#rows,ROWS,21)
 local offset=FauxScrollFrame_GetOffset(scroll)
 for i,b in ipairs(buttons) do
  local row=rows[i+offset]
  if row then
   local r=row.record;b.entry=r
   b.icon:SetTexture((r.spellID and select(3,GetSpellInfo(r.spellID))) or "Interface\\Icons\\INV_Misc_QuestionMark")
   local lv=r.requiredLevel and ("Lv "..r.requiredLevel.." ") or ""
   b.text:SetText((colors[row.status] or "")..lv..(r.name or "Unknown")..(r.rank and r.rank~="" and (" ("..r.rank..")") or "").."|r")
   b.cost:SetText(r.costCopper and GetCoinTextureString(r.costCopper) or "Cost unknown")
   b:Show()
  else b.entry=nil;b:Hide() end
 end
end
function wt:ToggleUI() create();if frame:IsShown() then frame:Hide() else frame:Show();self:RefreshUI() end end
local launcher=CreateFrame("Button","WhatsTrainingCoALauncher",UIParent)
launcher:SetWidth(38);launcher:SetHeight(38);launcher:SetFrameStrata("MEDIUM")
launcher:SetClampedToScreen(true);launcher:SetMovable(true);launcher:EnableMouse(true)
launcher:RegisterForClicks("LeftButtonUp","RightButtonUp");launcher:RegisterForDrag("LeftButton")
local icon=launcher:CreateTexture(nil,"BACKGROUND");icon:SetAllPoints(launcher);icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
local border=launcher:CreateTexture(nil,"OVERLAY");border:SetPoint("TOPLEFT",-5,5);border:SetPoint("BOTTOMRIGHT",5,-5)
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
launcher:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
local dragging=false
local function restorePosition()
 local d=wt.db and wt.db.settings and wt.db.settings.launcher
 launcher:ClearAllPoints()
 if d and type(d.x)=="number" and type(d.y)=="number" then launcher:SetPoint("CENTER",UIParent,"CENTER",d.x,d.y)
 else launcher:SetPoint("CENTER",UIParent,"CENTER",270,15) end
end
launcher:SetScript("OnDragStart",function(self) dragging=true;self:StartMoving() end)
launcher:SetScript("OnDragStop",function(self)
 self:StopMovingOrSizing()
 if wt.db then
  wt.db.settings.launcher=wt.db.settings.launcher or {}
  local x,y=self:GetCenter();local ux,uy=UIParent:GetCenter()
  if x and y and ux and uy then wt.db.settings.launcher.x=x-ux;wt.db.settings.launcher.y=y-uy end
 end
end)
launcher:SetScript("OnClick",function(self,button)
 if dragging then dragging=false;return end
 if button=="RightButton" then
  if wt.db then wt.db.settings.hideLauncher=true end
  self:Hide();print("What's Training? CoA: /wtcoa button restores the floating icon.")
 else wt:ToggleUI() end
end)
launcher:SetScript("OnEnter",function(self)
 GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:AddLine("What's Training? CoA")
 GameTooltip:AddLine("Click to open • Drag to move • Right-click to hide",1,1,1);GameTooltip:Show()
end)
launcher:SetScript("OnLeave",function()GameTooltip:Hide()end)
function wt:UpdateLauncher()
 if not self.db then return end
 restorePosition()
 if self.db.settings.hideLauncher then launcher:Hide() else launcher:Show() end
end
function wt:ShowLauncher()
 if not self.db then self:Initialize() end
 self.db.settings.hideLauncher=false;self:UpdateLauncher()
end
launcher:SetPoint("CENTER",UIParent,"CENTER",270,15)
