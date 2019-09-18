
local addonName, addonTable = ...
local eventFrame = CreateFrame("FRAME")

eventFrame:SetScript("OnEvent", function(_, _, addon)
	if addon == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
		
		if not AuctionHere_data then
			AuctionHere_data = {
				state = {
					scan = nil,
					snapshot = nil
				},
				
				prices = {
					["14 day median"] = nil
				},
				
				settings = {
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
		
		collectgarbage()
		
		eventFrame:SetScript("OnEvent", function()
			addonTable.Setup()
			
			eventFrame:UnregisterEvent("AUCTION_HOUSE_SHOW")
		end)
		
		eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
	end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
