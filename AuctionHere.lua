
 --[[
	TODO
	
	--------------------------------------------------
	
	Quality of life:
	
	* Expand clickable rarity filter area
	* Expand scrollable page area
	* Optimize reset button
	* Fix background texture
	
	--------------------------------------------------
	
	Functionality:
	
	* Bag slots replacing level
	* Search resets page
 --]]

local addonName, addonTable = ...
local eventFrame = CreateFrame("FRAME")
local pointLast, relativePointLast, xLast, yLast

local C_Timer_After = C_Timer.After
local math_min = math.min
local tostring = tostring
local select = select

local debugprofilestop = debugprofilestop
local GetServerTime = GetServerTime
local CanSendAuctionQuery = CanSendAuctionQuery
local GetNumAuctionItems = GetNumAuctionItems
local GetAuctionItemInfo = GetAuctionItemInfo
local GetAuctionItemLink = GetAuctionItemLink

local template = print
local print = function(...)
	template("|cFFF5DEB3" .. tostring(... or ""), select(2, ...))
end

 -- Search the entire auction house at once
local function GetAll()
	if select(2, CanSendAuctionQuery()) then
		print("AuctionHere | Performing a getall search")
		
		AuctionFrameBrowse:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
		
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
		
		print("AuctionHere | Finished searching " .. GetNumAuctionItems("list") .. " auctions")
	else
		print("AuctionHere | Cannot perform a getall search")
	end
end

local before
local iterations

local batch
local position
local limit
local index
local data
local _, stack, bid, buyout, offer, seller, ID
local indices
local incomplete

local info
local link

 -- Recursively call GetAuctionItemLink on each auction
local function SaveLink()
	limit = math_min(batch, position + iterations)
	
	for a = position, limit do
		index = indices[a]
		data = GetAuctionItemLink("list", index)
		
		if data then
			link[index] = data
		else
			incomplete[#incomplete + 1] = index
		end
	end
	
	batch = #indices
	
	if limit == batch then
		batch = #incomplete
		
		if batch == 0 then
			print("SaveLink: " .. debugprofilestop() - before)
			
			-- Save the data
			local AuctionHere_data = AuctionHere_data
			batch = GetServerTime()
			AuctionHere_data[batch] = {}
			batch = AuctionHere_data[batch]
			
			for a = 1, #info do
				position = info[a]
				limit = position[6]
				
				if not batch[limit] then
					batch[limit] = {}
				end
				
				limit = batch[limit]
				index = link[a]
				
				if not limit[index] then
					limit[index] = { {}, {}, {}, {}, {} }
				end
				
				index = limit[index]
				data = #index[1] + 1
				
				for b = 1, 5 do
					index[b][data] = position[b]
				end
			end
			
			return
		end
		
		iterations = 10000
		position = 1
		indices = incomplete
		incomplete = {}
	else
		position = limit + 1
	end
	
	C_Timer_After(0, SaveLink)
end

 -- Recursively call GetAuctionItemInfo on each auction
local function SaveInfo()
	limit = math_min(batch, position + iterations)
	
	for a = position, limit do
		index = indices[a]
		data = info[index]
		_, _, stack, _, _, _, _, bid, _, buyout, offer, _, _, seller, _, _, ID = GetAuctionItemInfo("list", index)
		
		if stack then
			data[1] = stack
		end
		
		if bid then
			data[2] = bid
		end
		
		if buyout then
			data[3] = buyout
		end
		
		if offer then
			data[4] = offer
		end
		
		if seller then
			data[5] = seller
		end
		
		if ID then
			data[6] = ID
		end
		
		if not (data[5] and data[1] and data[2] and data[3] and data[4] and data[6]) then
			incomplete[#incomplete + 1] = index
		end
	end
	
	if limit == batch then
		batch = #incomplete
		position = 1
		
		if batch == 0 then
			print("SaveInfo: " .. debugprofilestop() - before)
			
			batch = #info
			indices = {}
			
			for a = 1, batch do
				indices[a] = a
			end
			
			link = {}
			
			-- GetAuctionItemTimeLeft is bugged; skip it
			SaveLink()
			
			return
		end
		
		indices = incomplete
		incomplete = {}
	else
		position = limit + 1
	end
	
	C_Timer_After(0, SaveInfo)
end

 -- Save the current auction house page's data to disk
local function Save()
	batch = GetNumAuctionItems("list")
	
	if batch > 0 then
		print("AuctionHere | Saving " .. batch .. " auctions")
		
		before = debugprofilestop()
		iterations = 1000
		position = 1
		indices = {}
		info = {}
		
		for a = 1, batch do
			indices[a] = a
			info[a] = {}
		end
		
		incomplete = {}
		
		SaveInfo()
	else
		print("AuctionHere | No auctions to save")
	end
end

 -- Modify the auction house UI
local function Setup()
	NUM_BROWSE_TO_DISPLAY = 10
	AUCTIONS_BUTTON_HEIGHT = 30
	
	local math_max = math.max
	local _G = _G
	
	local NUM_BROWSE_TO_DISPLAY = NUM_BROWSE_TO_DISPLAY
	local AUCTIONS_BUTTON_HEIGHT = AUCTIONS_BUTTON_HEIGHT
	local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue
	local MouseIsOver = MouseIsOver
	
	AuctionFrameBrowse_Update = addonTable.AuctionFrameBrowse_Update
	
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
	local point, relativeTo, relativePoint, x, y = BrowseLevelText:GetPoint()
	BrowseLevelText:SetPoint(point, relativeTo, relativePoint, x + 5, y)
	
	-- BrowseMinLevel
	local point, relativeTo, relativePoint, x, y = BrowseMinLevel:GetPoint()
	BrowseMinLevel:SetPoint(point, relativeTo, relativePoint, x - 0, y)
	
	-- BrowseMaxLevel
	local point, relativeTo, relativePoint, x, y = BrowseMaxLevel:GetPoint()
	BrowseMaxLevel:SetPoint(point, relativeTo, relativePoint, x + 3, y)
	
	-- BrowseLevelHyphen
	local point, relativeTo, relativePoint, x, y = BrowseLevelHyphen:GetPoint()
	BrowseLevelHyphen:SetPoint(point, relativeTo, relativePoint, x + 3, y)
	
	-- BrowseDropDown
	local point, relativeTo, relativePoint, x, y = BrowseDropDown:GetPoint()
	BrowseDropDown:SetPoint(point, relativeTo, relativePoint, x - 1, y)
	UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
	
	-- IsUsableCheckButton
	local point, relativeTo, relativePoint, x, y = IsUsableCheckButton:GetPoint()
	IsUsableCheckButton:SetPoint(point, relativeTo, relativePoint, x - 94, y)
	
--[[
	-- BrowseIsUsableText
	local point, relativeTo, relativePoint, x, y = BrowseIsUsableText:GetPoint()
	BrowseIsUsableText:SetPoint(point, relativeTo, relativePoint, x - 11, y + 12)
--]]
	
	-- ShowOnPlayerCheckButton
	local point, relativeTo, relativePoint, x, y = ShowOnPlayerCheckButton:GetPoint()
	ShowOnPlayerCheckButton:SetPoint(point, relativeTo, relativePoint, x - 136, y)
	
--[[
	-- BrowseShowOnCharacterText
	local point, relativeTo, relativePoint, x, y = BrowseShowOnCharacterText:GetPoint()
	BrowseShowOnCharacterText:SetPoint(point, relativeTo, relativePoint, x - 211, y - 8)
--]]
	
	-- AuctionHere_UnitPrice
	local unitPrice = CreateFrame("CheckButton", "AuctionHere_UnitPrice", BrowseMinLevel, "UICheckButtonTemplate")
	unitPrice:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 614, -37)
	unitPrice:SetSize(24, 24)
	
--[[
	-- AuctionHere_UnitPriceText
	local unitPriceText = unitPrice:CreateFontString("AuctionHere_UnitPriceText")
	unitPriceText:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 563, -44)
	unitPriceText:SetFont(BrowseIsUsableText:GetFont())
	unitPriceText:SetShadowOffset(BrowseIsUsableText:GetShadowOffset())
	unitPriceText:SetText("Unit Price")
--]]
	
	-- BrowseSearchButton
	local point, relativeTo, relativePoint, x, y = BrowseSearchButton:GetPoint()
	y = y + 2
	BrowseSearchButton:SetPoint(point, relativeTo, relativePoint, x + 159, y)
	
	-- AuctionHere_Reset
	local reset = CreateFrame("Button", "AuctionHere_Reset", BrowseSearchButton:GetParent(), "UIPanelButtonTemplate")
	reset:SetPoint(point, relativeTo, relativePoint, x + 262, y)
	reset:SetSize(80, 22)
	reset:SetText("Reset")
	reset:SetScript("OnClick", function(self, button)
		addonTable.AuctionFrameBrowse_Reset(self)
	end)
	
	reset:SetScript("OnUpdate", function(self, elapsed)
		addonTable.BrowseResetButton_OnUpdate(self, elapsed)
	end)
	
	-- BrowsePrevPageButton
	local point, relativeTo, relativePoint, x, y = BrowsePrevPageButton:GetPoint()
	BrowsePrevPageButton:SetPoint(point, relativeTo, relativePoint, x + 441, y + 318)
	
	-- BrowseNextPageButton
	BrowseNextPageButton:ClearAllPoints()
	BrowseNextPageButton:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 797, -54)
	
--[[
	-- AuctionHere_PageText
	local pageText = BrowseSearchButton:CreateFontString("AuctionHere_PageText")
	pageText:SetPoint("TOP", relativeTo, "TOP", x + 261, y - 30)
	pageText:SetFont(BrowseIsUsableText:GetFont())
	pageText:SetShadowOffset(BrowseIsUsableText:GetShadowOffset())
--]]
	
--[[
	-- AuctionHere_ExactMatch
	local exactMatch = CreateFrame("CheckButton", "AuctionHere_ExactMatch", BrowseTabText:GetParent(), "UICheckButtonTemplate")
	local point, relativeTo, relativePoint, x, y = BrowseTabText:GetPoint()
	exactMatch:SetPoint(point, relativeTo, relativePoint, x + 61, y + 7)
	exactMatch:SetSize(24, 24)
--]]
	
--[[
	-- BrowseTabText
	BrowseTabText:SetText("Exact Match")
--]]
	
	for a = 9, NUM_BROWSE_TO_DISPLAY do
		-- BrowseButtonN
		local browseButtonN = CreateFrame("Button", "BrowseButton" .. a, AuctionFrameBrowse, "BrowseButtonTemplate")
		browseButtonN:SetPoint("TOPLEFT", _G["BrowseButton" .. (a - 1)], "BOTTOMLEFT", 0, 0)
		browseButtonN:SetID(a)
		browseButtonN:Hide()
	end
	
	for a = 1, NUM_BROWSE_TO_DISPLAY do
		local name = "BrowseButton" .. a
		
		-- BrowseButtonN
		local browseButtonN = _G[name]
		local point, relativeTo, relativePoint, x, y = browseButtonN:GetPoint()
		
		if a > 1 then
			browseButtonN:SetPoint(point, relativeTo, relativePoint, 0, 0)
		else
			browseButtonN:SetPoint(point, relativeTo, relativePoint, x, y + 4)
		end
		
		browseButtonN:SetHeight(AUCTIONS_BUTTON_HEIGHT)
		
		-- BrowseButtonNLeft
		local browseButtonNLeft = _G[name .. "Left"]
		local point, relativeTo, relativePoint, x, y = browseButtonNLeft:GetPoint()
		browseButtonNLeft:SetPoint(point, relativeTo, relativePoint, x, y - 2)
		
		-- BrowseButtonNRight
		local browseButtonNRight = _G[name .. "Right"]
		local point, relativeTo, relativePoint, x, y = browseButtonNRight:GetPoint()
		browseButtonNRight:SetPoint(point, relativeTo, relativePoint, x, y - 2)
		
		-- BrowseButtonNHighlight
		_G[name .. "Highlight"]:SetHeight(31)
		
		-- BrowseButtonNItem
		local browseButtonNItem = _G[name .. "Item"]
		local point, relativeTo, relativePoint, x, y = browseButtonNItem:GetPoint()
		browseButtonNItem:SetPoint(point, relativeTo, relativePoint, x + 5, y)
		browseButtonNItem:SetSize(AUCTIONS_BUTTON_HEIGHT, AUCTIONS_BUTTON_HEIGHT)
		
		-- BrowseButtonNItem.IconBorder
		browseButtonNItem.IconBorder:SetSize(AUCTIONS_BUTTON_HEIGHT, AUCTIONS_BUTTON_HEIGHT)
		
		-- BrowseButtonNNormalTexture
		_G[name .. "ItemNormalTexture"]:SetSize(52, 52)
		
		-- BrowseButtonNName
		local browseButtonNName = _G[name .. "Name"]
		local point, relativeTo, relativePoint, x, y = browseButtonNName:GetPoint()
		browseButtonNName:SetPoint(point, relativeTo, relativePoint, x, y + 2)
		
		-- BrowseButtonNLevel
		local browseButtonNLevel = _G[name .. "Level"]
		local point, relativeTo, relativePoint, x, y = browseButtonNLevel:GetPoint()
		browseButtonNLevel:SetPoint(point, relativeTo, relativePoint, x, y + 2)
		
		-- BrowseButtonNClosingTime
		local browseButtonNClosingTime = _G[name .. "ClosingTime"]
		browseButtonNClosingTime:SetHeight(30)
		browseButtonNClosingTime:SetScript("OnMouseUp", function(_, button)
			if button == "LeftButton" and MouseIsOver(browseButtonN) then
				browseButtonN:Click()
			end
		end)
		
		-- BrowseButtonNClosingTimeText
		local browseButtonNClosingTimeText = _G[name .. "ClosingTimeText"]
		local point, relativeTo, relativePoint, x, y = browseButtonNClosingTimeText:GetPoint()
		browseButtonNClosingTimeText:SetPoint(point, relativeTo, relativePoint, x, y + 2)
		
		-- BrowseButtonNHighBidder
		_G[name .. "HighBidder"]:EnableMouse(false)
		
		-- BrowseButtonNHighBidderName
		local browseButtonNHighBidderName = _G[name .. "HighBidderName"]
		local point, relativeTo, relativePoint, x, y = browseButtonNHighBidderName:GetPoint()
		browseButtonNHighBidderName:SetPoint(point, relativeTo, relativePoint, x, y + 2)
		
		-- BrowseButtonNBuyoutFrameText
		_G[name .. "BuyoutFrameText"]:Hide()
	end
	
	-- BrowseScrollFrameScrollBar
	BrowseScrollFrameScrollBar:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * 149.25, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseScrollFrameScrollBarScrollUpButton
	BrowseScrollFrameScrollBarScrollUpButton:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * 149.25, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseScrollFrameScrollBarScrollDownButton
	BrowseScrollFrameScrollBarScrollDownButton:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * 149.25, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseSearchCountText
	local point, relativeTo, relativePoint, x, y = BrowseSearchCountText:GetPoint()
	BrowseSearchCountText:SetPoint(point, relativeTo, relativePoint, x - 177, y - 33)
	
	-- BrowseBidText
	local point, relativeTo, relativePoint, x, y = BrowseBidText:GetPoint()
	BrowseBidText:SetPoint(point, relativeTo, relativePoint, x, y - 2)
	
	-- BrowseBidPrice
	local point, relativeTo, relativePoint, x, y = BrowseBidPrice:GetPoint()
	BrowseBidPrice:SetPoint(point, relativeTo, relativePoint, x + 92, y)
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

eventFrame:SetScript("OnEvent", function(_, event, addon)
	if event == "ADDON_LOADED" and addon == addonName then
		eventFrame:UnregisterEvent("ADDON_LOADED")
		
		if not AuctionHere_data then
			AuctionHere_data = {}
		end
		
		local AuctionHere_data = AuctionHere_data
		local string_lower = string.lower
		local wipe = wipe
		local sanitized
		
		SlashCmdList[addonName] = function(message)
			sanitized = string_lower(message)
			
			if sanitized == "getall" then
				GetAll()
			elseif sanitized == "save" then
				Save()
			elseif sanitized == "clear" then
				wipe(AuctionHere_data)
				
				print("AuctionHere | Auction data cleared")
			else
				print("AuctionHere | Commands:")
				print("/ah getall - displays the entire auction house on one page")
				print("/ah save  - saves the current auction house page's data to disk")
				print("/ah clear  - clears all saved auction house data")
			end
		end
		
		SLASH_AuctionHere1 = "/" .. addonName
		SLASH_AuctionHere2 = "/ah"
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
