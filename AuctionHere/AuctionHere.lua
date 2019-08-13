
local addonName, addonTable = ...
local eventFrame = CreateFrame("FRAME")
local pointLast, relativePointLast, xLast, yLast

local math_min = math.min
local math_max = math.max

 -- Search the entire auction house
local function GetAll()
	local _, canQueryAll = CanSendAuctionQuery()
	
	if canQueryAll then
		canQueryAll = false
		
		print("AuctionHere | Performing a getall search")
		
		local filter
		
		if category and subCategory and subSubCategory then
			filter = AuctionCategories[category].subCategories[subCategory].subCategories[subSubCategory].filters
		elseif category and subCategory then
			filter = AuctionCategories[category].subCategories[subCategory].filters
		elseif category then
			filter = AuctionCategories[category].filters
		end
		
		-- QueryAuctionItems(name, minLevel, maxLevel, page, isUsable, qualityIndex, getAll, exactMatch, filterData)
		QueryAuctionItems("", nil, nil, 0, false, 0, true, false, filter)
		
		local batch = GetNumAuctionItems("list")
		print("AuctionHere | Finished searching " .. batch .. " items")
	else
		print("AuctionHere | Cannot perform a getall search")
	end
end

 -- Save auction listing information to disk
local function Record()
	local batch = GetNumAuctionItems("list")
	print("AuctionHere | Recording " .. batch .. " listings")
	
	if not AuctionHere_data then
		AuctionHere_data = {}
	end
	
	local missed = {}
	
	for a = 1, batch do
		local debounce = true
		
		-- name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo = GetAuctionItemInfo("type", index)
		local _, _, stack, _, _, _, _, bid, _, buyout, offer, bidder, _, seller, _, _, ID, hasAllInfo = GetAuctionItemInfo("list", a)
		
		if seller and hasAllInfo then
			-- _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(
			-- itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
			local link = GetAuctionItemLink("list", a)
			
			if link then
				local duration = GetAuctionItemTimeLeft("list", a)
				
				if duration then
					if not AuctionHere_data[ID] then
						AuctionHere_data[ID] = {}
					end
					
					if not AuctionHere_data[ID][link] then
						AuctionHere_data[ID][link] = {
							stacks = {},
							bids = {},
							buyouts = {},
							offers = {},
							bidders = {},
							sellers = {},
							durations = {}
						}
					end
					
					table.insert(AuctionHere_data[ID][link].stacks, stack)
					table.insert(AuctionHere_data[ID][link].bids, bid)
					table.insert(AuctionHere_data[ID][link].buyouts, buyout)
					table.insert(AuctionHere_data[ID][link].offers, offer)
					table.insert(AuctionHere_data[ID][link].bidders, bidder)
					table.insert(AuctionHere_data[ID][link].sellers, seller)
					table.insert(AuctionHere_data[ID][link].durations, duration)
					
					debounce = false
				end
			end
		end
		
		if debounce then
			table.insert(missed, a)
		end
	end
	
	print("AuctionHere | Missed " .. #missed .. " listings")
end

 -- Modify the auction house UI
local function Setup()
	AuctionFrameBrowse_Update = addonTable.AuctionFrameBrowse_Update_Override
	
	-- AuctionFrame
	local point, _, relativePoint, x, y = AuctionFrame:GetPoint()
	pointLast = point
	relativePointLast = relativePoint
	xLast = x + 2
	yLast = y + 10
	
	AuctionFrame:SetMovable(true)
	AuctionFrame:SetScript("OnMouseDown", function(self)
		self:StartMoving()
		
		BrowseName:ClearFocus()
		BrowseMinLevel:ClearFocus()
		BrowseMaxLevel:ClearFocus()
	end)
	
	AuctionFrame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
	end)
	
	-- BrowseTitle
	local _, _, _, _, y = BrowseTitle:GetPoint()
	BrowseTitle:SetPoint("TOP", AuctionFrame, "TOP", 0, y)
	
	-- BrowseLevelText
	local point, relativeRegion, relativePoint, x, y = BrowseLevelText:GetPoint()
	BrowseLevelText:SetPoint(point, relativeRegion, relativePoint, x + 5, y)
	
	-- BrowseMinLevel
	local point, relativeRegion, relativePoint, x, y = BrowseMinLevel:GetPoint()
	BrowseMinLevel:SetPoint(point, relativeRegion, relativePoint, x - 0, y)
	
	-- BrowseLevelHyphen
	local point, relativeRegion, relativePoint, x, y = BrowseLevelHyphen:GetPoint()
	BrowseLevelHyphen:SetPoint(point, relativeRegion, relativePoint, x + 3, y)
	
	-- BrowseMaxLevel
	local point, relativeRegion, relativePoint, x, y = BrowseMaxLevel:GetPoint()
	BrowseMaxLevel:SetPoint(point, relativeRegion, relativePoint, x + 3, y)
	
	-- BrowseDropDown
	local point, relativeRegion, relativePoint, x, y = BrowseDropDown:GetPoint()
	BrowseDropDown:SetPoint(point, relativeRegion, relativePoint, x - 1, y)
	
	-- BrowseDropDownButton
	BrowseDropDownButton:Click()
	DropDownList1Button1:Click()
	
	-- IsUsableCheckButton
	local point, relativeRegion, relativePoint, x, y = IsUsableCheckButton:GetPoint()
	IsUsableCheckButton:SetPoint(point, relativeRegion, relativePoint, x - 94, y)
	
	-- BrowseIsUsableText
	local point, relativeRegion, relativePoint, x, y = BrowseIsUsableText:GetPoint()
	BrowseIsUsableText:SetPoint(point, relativeRegion, relativePoint, x - 11, y + 12)
	
	-- ShowOnPlayerCheckButton
	local point, relativeRegion, relativePoint, x, y = ShowOnPlayerCheckButton:GetPoint()
	ShowOnPlayerCheckButton:SetPoint(point, relativeRegion, relativePoint, x - 136, y)
	
	-- BrowseShowOnCharacterText
	local point, relativeRegion, relativePoint, x, y = BrowseShowOnCharacterText:GetPoint()
	BrowseShowOnCharacterText:SetPoint(point, relativeRegion, relativePoint, x - 211, y - 8)
	
	-- AuctionHere_UnitPrice
	local unitPrice = CreateFrame("CheckButton", "AuctionHere_UnitPrice", BrowseMinLevel, "UICheckButtonTemplate")
	unitPrice:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 614, -37)
	local width, height = IsUsableCheckButton:GetSize()
	unitPrice:SetSize(width, height)
	
	-- AuctionHere_UnitPriceText
	local unitPriceText = unitPrice:CreateFontString("AuctionHere_UnitPriceText")
	unitPriceText:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 563, -44)
	unitPriceText:SetFont(BrowseIsUsableText:GetFont())
	unitPriceText:SetText("Unit Price")
	unitPriceText:SetShadowOffset(BrowseIsUsableText:GetShadowOffset())
	
	-- BrowseSearchButton
	local point, relativeRegion, relativePoint, x, y = BrowseSearchButton:GetPoint()
	y = y + 2
	BrowseSearchButton:SetPoint(point, relativeRegion, relativePoint, x + 159, y)
	
	-- AuctionHere_Reset
	local reset = CreateFrame("Button", "AuctionHere_Reset", BrowseSearchButton:GetParent(), "UIPanelButtonTemplate")
	local width, height = BrowseSearchButton:GetSize()
	reset:SetSize(width, height)
	reset:SetPoint(point, relativeRegion, relativePoint, x + 262, y)
	reset:SetText("Reset")
	local template = reset:GetScript("OnMouseUp")
	reset:SetScript("OnMouseUp", function(self, button)
		template(self, button)
		
		if button == "LeftButton" and MouseIsOver(reset) then
			BrowseName:SetText("")
			BrowseMinLevel:SetText("")
			BrowseMaxLevel:SetText("")
			
			BrowseDropDownButton:Click()
			DropDownList1Button1:Click()
			
			IsUsableCheckButton:SetChecked(false)
			
			if ShowOnPlayerCheckButton:GetChecked() then
				ShowOnPlayerCheckButton:Click()
			end
			
			AuctionHere_UnitPrice:SetChecked(false)
			AuctionHere_ExactMatch:SetChecked(false)
			
			if BrowseFilterScrollFrameScrollBar:IsVisible() then
				local sliderMin = BrowseFilterScrollFrameScrollBar:GetMinMaxValues()
				BrowseFilterScrollFrameScrollBar:SetValue(sliderMin)
			end
			
			AuctionFilterButton1:Click()
			
			if AuctionFilterButton11:IsVisible() then
				AuctionFilterButton1:Click()
			end
		end
	end)
	
	-- BrowsePrevPageButton
	local point, relativeRegion, relativePoint, x, y = BrowsePrevPageButton:GetPoint()
	BrowsePrevPageButton:SetPoint(point, relativeRegion, relativePoint, x + 441, y + 318)
	
	-- AuctionHere_PageText
	local pageText = BrowseSearchButton:CreateFontString("AuctionHere_PageText")
	pageText:SetPoint("TOP", relativeRegion, "TOP", x + 261, y - 30)
	pageText:SetFont(BrowseIsUsableText:GetFont())
	pageText:SetShadowOffset(BrowseIsUsableText:GetShadowOffset())
	
	-- BrowseNextPageButton
	BrowseNextPageButton:ClearAllPoints()
	BrowseNextPageButton:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 797, -54)
	
	-- BrowseTabText
	BrowseTabText:SetText("Exact Match")
	
	-- AuctionHere_ExactMatch
	local exactMatch = CreateFrame("CheckButton", "AuctionHere_ExactMatch", BrowseTabText:GetParent(), "UICheckButtonTemplate")
	local point, relativeRegion, relativePoint, x, y = BrowseTabText:GetPoint()
	exactMatch:SetPoint(point, relativeRegion, relativePoint, x + 61, y + 7)
	local width, height = IsUsableCheckButton:GetSize()
	exactMatch:SetSize(width, height)
	
	local template = QueryAuctionItems
	
	QueryAuctionItems = function(a, b, c, d, e, f, g, h, i)
		template(a, b, c, d, e, f, g, exactMatch:GetChecked(), i)
	end
	
	for a = 1, 8 do
		local offset = "BrowseButton" .. a
		
		-- BrowseButtonNClosingTime
		_G[offset .. "ClosingTime"]:SetScript("OnMouseUp", function(_, button)
			local browseButtonN = _G[offset]
			
			if button == "LeftButton" and MouseIsOver(browseButtonN) then
				browseButtonN:Click()
			end
		end)
		
		-- BrowseButtonNHighBidder
		_G[offset .. "HighBidder"]:EnableMouse(false)
		
		-- BrowseButtonNBuyoutFrameText
		_G[offset .. "BuyoutFrameText"]:Hide()
	end
	
	local offset = 1544 / 11
	
	-- BrowseScrollFrameScrollBarScrollUpButton
	BrowseScrollFrameScrollBarScrollUpButton:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * offset, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseScrollFrameScrollBar
	BrowseScrollFrameScrollBar:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * offset, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseScrollFrameScrollBarScrollDownButton
	BrowseScrollFrameScrollBarScrollDownButton:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * offset, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseSearchCountText
	local point, relativeRegion, relativePoint, x, y = BrowseSearchCountText:GetPoint()
	BrowseSearchCountText:SetPoint(point, relativeRegion, relativePoint, x - 177, y - 33)
	
	-- BrowseBidText
	local point, relativeRegion, relativePoint, x, y = BrowseBidText:GetPoint()
	BrowseBidText:SetPoint(point, relativeRegion, relativePoint, x, y - 2)
	
	-- BrowseBidPrice
	local point, relativeRegion, relativePoint, x, y = BrowseBidPrice:GetPoint()
	BrowseBidPrice:SetPoint(point, relativeRegion, relativePoint, x + 92, y)
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
eventFrame:SetScript("OnEvent", function(_, event, addon)
	if event == "ADDON_LOADED" and addon == addonName then
		SlashCmdList[addonName] = function(message)
			local sanitized = string.lower(message)
			
			if sanitized == "getall" then
				GetAll()
			elseif sanitized == "record" then
				Record()
			elseif sanitized == "clear" then
				AuctionHere_data = nil
			else
				print("AuctionHere commands:")
				print("/ah getall  - performs a search of the entire auction house")
				print("/ah record - records information about auction listings")
				print("/ah clear   - clears all recorded auction listing information")
			end
		end
		
		SLASH_AuctionHere1 = "/" .. addonName
		SLASH_AuctionHere2 = "/ah"
		
		eventFrame:UnregisterEvent("ADDON_LOADED")
	elseif event == "AUCTION_HOUSE_SHOW" then
		if Setup then
			Setup()
			
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
