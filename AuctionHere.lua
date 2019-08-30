
 --[[
	TODO
	
	--------------------------------------------------
	
	Quality of life:
	
	* Expand clickable rarity filter area
	* Expand scrollable page area
	* Optimize reset button
	* Fix background texture
	* Fix bid price positioning / clearing
	* Make tabs dynamically sized
	
	--------------------------------------------------
	
	Functionality:
	
	* Bag slots replacing level
	* Search resets page
	* Make level range searchable
	* Add stack size filter
 --]]

 --[[
	itemString format
	
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

local select = select
local tostring = tostring

local template = print

local function print_(...)
	template("|cFFF5DEB3" .. tostring(... or ""), select(2, ...))
end

addonTable.print = print_

local print = print_

local Setup
local pointLast, relativePointLast, xLast, yLast

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

eventFrame:SetScript("OnEvent", function(_, event, addon)
	if event == "ADDON_LOADED" and addon == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
		
		Setup = addonTable.Setup
		
		if not AuctionHere_settings then
			AuctionHere_settings = {}
		end
		
		if not AuctionHere_scans then
			AuctionHere_scans = {}
		end
		
		local sanitized
		
		local string_lower = string.lower
		local wipe = wipe
		local AuctionHere_scans = AuctionHere_scans
		local GetAll = addonTable.GetAll
		local Scan = addonTable.Scan
		
		SlashCmdList[addonName] = function(message)
			sanitized = string_lower(message)
			
			if sanitized == "getall" then
				GetAll()
			elseif sanitized == "save" then
				Scan()
			elseif sanitized == "clear" then
				wipe(AuctionHere_scans)
				
				print("AuctionHere | Auction data cleared")
			else
				print("AuctionHere | Commands:")
				print("/ah getall - display the entire auction house on one page")
				print("/ah save  - save the current auction house page's data to disk")
				print("/ah clear  - clear all saved auction house data")
			end
		end
		
		SLASH_AuctionHere1 = "/" .. addonName
		SLASH_AuctionHere2 = "/ah"
	elseif event == "AUCTION_HOUSE_SHOW" then
		if Setup then
			Setup()
			
			local point, _, relativePoint, x, y = AuctionFrame:GetPoint()
			pointLast = point
			relativePointLast = relativePoint
			xLast = x + 2
			yLast = y + 10
			
			Setup = nil
		end
		
		AuctionFrame:ClearAllPoints()
		AuctionFrame:SetPoint(pointLast, UIParent, relativePointLast, xLast, yLast)
		
		BrowseNextPageButton:Show()
		BrowsePrevPageButton:Show()
	elseif event == "AUCTION_HOUSE_CLOSED" then
		local point, _, relativePoint, x, y = AuctionFrame:GetPoint()
		pointLast = point
		relativePointLast = relativePoint
		xLast = x
		yLast = y
	end
end)
