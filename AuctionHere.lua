
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
	* ?
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
						{true, 14, {}, {}, 1, "14 day median"}
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
