--[[
If the unit is "player", the logic is simple: hook the slot button update method
on the paper doll frame.
  
If the unit is "target", the logic is more complicated:

 1. Wait for the Blizzard_InspectUI addon to load.
 2. Hook the slot button update method on the inspect paper doll frame.
 3. Display colors for items we already know about.
4a. Wait for any GET_ITEM_INFO_RECEIVED events to fire.
4b. If a GET_ITEM_INFO_RECEIVED event is fired, return to step 3 by directly
    calling the inspect paper doll frame's OnShow event handler.
--]]

local f = CreateFrame("Frame", nil, UIParent)

local function CreateButtonBorder(button)
  if button.border then return end

  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetWidth(67)
  border:SetHeight(67)
  border:SetPoint("CENTER", button)
  border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
  border:SetBlendMode("ADD")
  border:Hide()
  
  button.border = border
end

local function CreateButtonText(button)
  if button.text then return end
    
  local text = button:CreateFontString(nil, "ARTWORK", "NumberFontNormalSmall")
  text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 1)
  text:Hide()
  
  button.text = text
end

local function GetItemQualityAndLevel(unit, slotID)
  if not f:IsEventRegistered("GET_ITEM_INFO_RECEIVED") then
    f:RegisterEvent("GET_ITEM_INFO_RECEIVED") 	
  end
  
  local itemID = GetInventoryItemID(unit, slotID)

  if itemID ~= nil then
    local _, _, quality, level = GetItemInfo(itemID)
  
    return quality, level
  end
end

local function UpdateItemSlotButton(button, unit)
  local slotID = button:GetID()
  
  if (slotID >= INVSLOT_FIRST_EQUIPPED and slotID <= INVSLOT_LAST_EQUIPPED) then
    local itemQuality, itemLevel = GetItemQualityAndLevel(unit, slotID)
    
    CreateButtonBorder(button)
    CreateButtonText(button)
    
    if itemQuality and itemQuality >= ITEM_QUALITY_UNCOMMON then
      local r, g, b = GetItemQualityColor(itemQuality)
      
      button.border:SetVertexColor(r, g, b, 0.85)
      button.border:Show()
      
      button.text:SetText(itemLevel)
      button.text:Show()
    else
      button.border:Hide()
      button.text:Hide()
    end
  end
end

hooksecurefunc("PaperDollItemSlotButton_Update", function (button)
  UpdateItemSlotButton(button, "player")
end)

f:SetScript("OnEvent", function (frame, event, ...)
  if event == "ADDON_LOADED" then
    local addon = ...
    
    if addon == "Blizzard_InspectUI" then
      hooksecurefunc("InspectPaperDollItemSlotButton_Update", function (button)
        UpdateItemSlotButton(button, "target")
      end)
    end
  elseif event == "GET_ITEM_INFO_RECEIVED" then
    if InspectFrame and InspectFrame:IsShown() then
      InspectPaperDollFrame_OnShow()
    end
  end
end)
f:RegisterEvent("ADDON_LOADED")
