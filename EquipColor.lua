local function PaperDollItemSlotButton_Update(self)
  local slotID = self:GetID()
  
  if (slotID >= INVSLOT_FIRST_EQUIPPED and slotID <= INVSLOT_LAST_EQUIPPED) then
    local quality = GetInventoryItemQuality("player", slotID)
    local texture = _G[self:GetName().."NormalTexture"]
    
    if quality and quality >= ITEM_QUALITY_UNCOMMON then
      local r, g, b = GetItemQualityColor(quality)
      
      texture:SetSize(self:GetWidth(), self:GetHeight())
      texture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
      texture:SetVertexColor(r, g, b)
    
      texture:Show()
    else
      texture:Hide()
    end
  end
end

hooksecurefunc("PaperDollItemSlotButton_Update", PaperDollItemSlotButton_Update)