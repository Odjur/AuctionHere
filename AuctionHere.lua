
 --[[
	TODO
	
	Browse tab
	
	* BrowseScrollFrame improvements
	
	-------------------------------------------------------------------------------
	
	Bids tab
	* ?
	
	-------------------------------------------------------------------------------
	
	Auctions tab
	* ?
	
	-------------------------------------------------------------------------------
	
	AuctionHere tab
	* itemString formatting
	
 x	itemID					Item ID that can be used for GetItemInfo calls.
	enchantId				Permament enchants applied to an item. See list of EnchantIds.
	gemId1					Embedded gems re-use EnchantId indices, though gem icons show only for specific values
	gemId2					(number)
	gemId3					(number)
	gemId4					(number)
	suffixId				Random enchantment ID; may be negative. See list of SuffixIds.
	uniqueId				Data pertaining to a specific instance of the item.
 x	linkLevel				Level of the character supplying the link. This is used to render scaling heirloom item tooltips at the proper level.
 x	specializationID		Specialization ID
 x	upgradeId				Reforging info. 0 or empty for items that have not been reforged
	instanceDifficultyId	(number)
	numBonusIds				(number)
	bonusId1				(number)
	bonusId2				(number)
	upgradeValue			(number)
 --]]

local addonName, addonTable = ...
local eventFrame = CreateFrame("FRAME")

eventFrame:SetScript("OnEvent", function(_, _, addon)
	if addon == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
		
		if not AuctionHere_data then
			AuctionHere_data = {
				settings = {
					prices = {
						-- update, range, excluded, included, stat, name
						{true, 14, {}, {}, 2, "14 day median"}
					}
				},
				
				scans = {},
				prices = {},
				snapshot = {}
			}
		end
		
		local Setup = addonTable.Setup
		
		collectgarbage()
		
		eventFrame:SetScript("OnEvent", function()
			if Setup then
				Setup()
				
				Setup = nil
			end
			
			AuctionFrame:ClearAllPoints()
			AuctionFrame:SetPoint(addonTable.point, UIParent, addonTable.relativePoint, addonTable.x, addonTable.y)
			
			BrowseNextPageButton:Show()
			BrowsePrevPageButton:Show()
		end)
		
		eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
	end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
