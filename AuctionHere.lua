
local addonName, addonTable = ...
local eventFrame = CreateFrame("FRAME")

eventFrame:SetScript("OnEvent", function(_, _, addon)
	if addon == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
		
		if not AuctionHere_data then
			AuctionHere_data = {
				state = {},
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
		
		local select = select
		local collectgarbage = collectgarbage
		
		local CanSendAuctionQuery = CanSendAuctionQuery
		
		local Setup = addonTable.Setup
		
		collectgarbage()
		
		eventFrame:SetScript("OnEvent", function(_, event)
			if event == "PLAYER_ALIVE" then
				if select(2, CanSendAuctionQuery()) then
					local AuctionHere_data = AuctionHere_data
					AuctionHere_data.state.getAll = 0
				end
			else
				if Setup then
					Setup()
					
					Setup = nil
				end
				
				AuctionFrame:ClearAllPoints()
				AuctionFrame:SetPoint(addonTable.point, UIParent, addonTable.relativePoint, addonTable.x, addonTable.y)
				
				BrowseNextPageButton:Show()
				BrowsePrevPageButton:Show()
			end
		end)
		
		eventFrame:RegisterEvent("PLAYER_ALIVE")
		eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
	end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
