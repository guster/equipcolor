--[[
If the unit is "player", the logic is simple: hook the slot button update method
on the paper doll frame.
  
If the unit is "target", the logic is more complicated:

 1. Wait for the Blizzard_InspectUI addon to load.
 2. Hook the slot button update method on the inspect paper doll frame.
 3. Register for the GET_ITEM_INFO_RECEIVED event if not already registered.
 4. Display colors for items we already know about.
5a. Wait for any GET_ITEM_INFO_RECEIVED events to fire.
5b. If a GET_ITEM_INFO_RECEIVED event is fired, return to step 4 by directly
    calling the inspect paper doll frame's OnShow event handler.
--]]

local f = CreateFrame("Frame", nil, UIParent)

local function GetItemQuality(unit, slotID)
  if unit == "player" then
    return GetInventoryItemQuality(unit, slotID)
  elseif unit == "target" then
    if not f:IsEventRegistered("GET_ITEM_INFO_RECEIVED") then
      f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    end
    
    local itemID = GetInventoryItemID(unit, slotID)
    
    if itemID ~= nil then
      local _, _, quality = GetItemInfo(itemID)
    
      return quality
    end
  end
end

local function UpdateItemSlotButton(button, unit)
  local slotID = button:GetID()
  
  if (slotID >= INVSLOT_FIRST_EQUIPPED and slotID <= INVSLOT_LAST_EQUIPPED) then
    local quality = GetItemQuality(unit, slotID)
    local texture = button:GetNormalTexture()
    
    if quality and quality >= ITEM_QUALITY_UNCOMMON then
      local r, g, b = GetItemQualityColor(quality)
      
      texture:SetSize(button:GetWidth(), button:GetHeight())
      texture:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
      texture:SetVertexColor(r, g, b)
    
      texture:Show()
    else
      texture:Hide()
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
    if InspectFrame:IsShown() then
      InspectPaperDollFrame_OnShow()
    end
  end
end)
f:RegisterEvent("ADDON_LOADED")
