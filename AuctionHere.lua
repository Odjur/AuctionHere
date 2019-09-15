
local addonName, addonTable = ...
local eventFrame = CreateFrame("FRAME")

eventFrame:SetScript("OnEvent", function(_, _, addon)
	if addon == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
		
		if not AuctionHere_data then
			AuctionHere_data = {
				state = {
					getAll = nil
				},
				
				prices = {
					["14 day median"] = nil
				},
				
				settings = {
					iterations = 1000,
					attempts = 1000,
					prices = {
						-- update, range, excluded, included, stat, name
						{true, 14, {}, {}, 1, "14 day median"}
					}
				},
				
				scans = {},
				snapshot = {}
			}
		end
		
		local collectgarbage = collectgarbage
		
		local Setup = addonTable.Setup
		
		collectgarbage()
		
		eventFrame:SetScript("OnEvent", function()
			if Setup then
				Setup()
				
				Setup = nil
			end
			
			BrowseNextPageButton:Show()
			BrowsePrevPageButton:Show()
		end)
		
		eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
	end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
