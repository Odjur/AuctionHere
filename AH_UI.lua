
local _, addonTable = ...

 -- Modify the auction house UI
local function Setup()
	NUM_BROWSE_TO_DISPLAY = 10
	AUCTIONS_BUTTON_HEIGHT = 30
	
	local math_min = math.min
	local math_max = math.max
	local _G = _G
	
	local NUM_BROWSE_TO_DISPLAY = NUM_BROWSE_TO_DISPLAY
	local AUCTIONS_BUTTON_HEIGHT = AUCTIONS_BUTTON_HEIGHT
	local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue
	local MouseIsOver = MouseIsOver
	
	local AuctionFrameBrowse_Reset = addonTable.AuctionFrameBrowse_Reset
	local BrowseResetButton_OnUpdate = addonTable.BrowseResetButton_OnUpdate
	
	AuctionFrameBrowse_Update = addonTable.AuctionFrameBrowse_Update
	
	-- AuctionFrame
	AuctionFrame:SetHeight(439)
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
		AuctionFrameBrowse_Reset(self)
	end)
	
	reset:SetScript("OnUpdate", function(self, elapsed)
		BrowseResetButton_OnUpdate(self, elapsed)
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
	
	-- AuctionFrameMoneyFrame
	local point, relativeTo, relativePoint, x, y = AuctionFrameMoneyFrame:GetPoint()
	AuctionFrameMoneyFrame:SetPoint(point, relativeTo, relativePoint, x - 3, y - 9)
	
	-- BrowseSearchCountText
	local point, relativeTo, relativePoint, x, y = BrowseSearchCountText:GetPoint()
	BrowseSearchCountText:SetPoint(point, relativeTo, relativePoint, x - 177, y - 33)
	
	-- BrowseBidText
	local point, relativeTo, relativePoint, x, y = BrowseBidText:GetPoint()
	BrowseBidText:SetPoint(point, relativeTo, relativePoint, x, y - 2)
	
	-- BrowseBidPrice
	local point, relativeTo, relativePoint, x, y = BrowseBidPrice:GetPoint()
	BrowseBidPrice:SetPoint(point, relativeTo, relativePoint, x + 92, y)
	
	-- AuctionFrameTab1
	local point, relativeTo, relativePoint, x, y = AuctionFrameTab1:GetPoint()
	AuctionFrameTab1:SetPoint(point, relativeTo, relativePoint, x, y - 8)
end

addonTable.Setup = Setup
