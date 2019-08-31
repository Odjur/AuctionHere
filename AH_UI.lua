
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
	local BrowseSearchButton_OnUpdate = addonTable.BrowseSearchButton_OnUpdate
	
	local _, point, relativeTo, relativePoint, x, y
	
	AuctionFrameBrowse_Search = addonTable.AuctionFrameBrowse_Search
	AuctionFrameBrowse_Update = addonTable.AuctionFrameBrowse_Update
	
	-- AuctionFrame
	addonTable.point, _, addonTable.relativePoint, addonTable.x, addonTable.y = AuctionFrame:GetPoint()
	addonTable.y = addonTable.y + 12
	AuctionFrame:SetHeight(439)
	AuctionFrame:SetMovable(true)
	AuctionFrame:SetScript("OnMouseDown", function(self)
		self:StartMoving()
		
		BrowseName:ClearFocus()
		BrowseMinLevel:ClearFocus()
		BrowseMaxLevel:ClearFocus()
		BrowseBidPriceGold:ClearFocus()
		BrowseBidPriceSilver:ClearFocus()
		BrowseBidPriceCopper:ClearFocus()
	end)
	
	AuctionFrame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
		
		addonTable.point, _, addonTable.relativePoint, addonTable.x, addonTable.y = AuctionFrame:GetPoint()
	end)
	
	-------------------------------------------------------------------------------
	-- Browse
	-------------------------------------------------------------------------------
	
	-- BrowseTitle
	_, _, _, _, y = BrowseTitle:GetPoint()
	BrowseTitle:SetPoint("TOP", AuctionFrame, "TOP", 0, y)
	
	-- BrowseLevelText
	point, relativeTo, relativePoint, x, y = BrowseLevelText:GetPoint()
	BrowseLevelText:SetPoint(point, relativeTo, relativePoint, x + 5, y)
	
	-- BrowseMinLevel
	point, relativeTo, relativePoint, x, y = BrowseMinLevel:GetPoint()
	BrowseMinLevel:SetPoint(point, relativeTo, relativePoint, x, y)
	BrowseMinLevel:SetScript("OnEnterPressed", function(self)
		AuctionFrameBrowse_Search()
		self:ClearFocus()
	end)
	
	-- BrowseMaxLevel
	point, relativeTo, relativePoint, x, y = BrowseMaxLevel:GetPoint()
	BrowseMaxLevel:SetPoint(point, relativeTo, relativePoint, x + 3, y)
	BrowseMaxLevel:SetScript("OnEnterPressed", function(self)
		AuctionFrameBrowse_Search()
		self:ClearFocus()
	end)
	
	-- BrowseLevelHyphen
	point, relativeTo, relativePoint, x, y = BrowseLevelHyphen:GetPoint()
	BrowseLevelHyphen:SetPoint(point, relativeTo, relativePoint, x + 3, y)
	
	-- BrowseDropDown
	point, relativeTo, relativePoint, x, y = BrowseDropDown:GetPoint()
	BrowseDropDown:SetPoint(point, relativeTo, relativePoint, x - 1, y)
	UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
	
	-- BrowseDropDownButton
	point, relativeTo, relativePoint, x, y = BrowseDropDownButton:GetPoint()
	BrowseDropDownButton:SetPoint(point, relativeTo, relativePoint, x - 1, y)
	
	-- IsUsableCheckButton
	point, relativeTo, relativePoint, x, y = IsUsableCheckButton:GetPoint()
	IsUsableCheckButton:SetPoint(point, relativeTo, relativePoint, x - 95, y)
	
	-- BrowseIsUsableText
	point, relativeTo, relativePoint, x, y = BrowseIsUsableText:GetPoint()
	BrowseIsUsableText:SetPoint(point, relativeTo, relativePoint, x - 10, y + 12)
	
	-- ShowOnPlayerCheckButton
	point, relativeTo, relativePoint, x, y = ShowOnPlayerCheckButton:GetPoint()
	ShowOnPlayerCheckButton:SetPoint(point, relativeTo, relativePoint, x - 137, y)
	
	-- BrowseShowOnCharacterText
	point, relativeTo, relativePoint, x, y = BrowseShowOnCharacterText:GetPoint()
	BrowseShowOnCharacterText:SetPoint(point, relativeTo, relativePoint, x - 210, y - 8)
	
	-- BrowseSearchButton
	point, relativeTo, relativePoint, x, y = BrowseSearchButton:GetPoint()
	BrowseSearchButton:SetPoint(point, relativeTo, relativePoint, x + 158, y + 3)
	BrowseSearchButton:SetScript("OnUpdate", BrowseSearchButton_OnUpdate)
	
	-- AuctionHere_Reset
	local reset = CreateFrame("Button", "AuctionHere_Reset", AuctionFrameBrowse, "UIPanelButtonTemplate")
	reset:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 747, -35)
	reset:SetSize(80, 22)
	reset:SetText("Reset")
	reset:SetScript("OnClick", AuctionFrameBrowse_Reset)
	reset:SetScript("OnUpdate", BrowseResetButton_OnUpdate)
	
	-- BrowsePrevPageButton
	point, relativeTo, relativePoint, x, y = BrowsePrevPageButton:GetPoint()
	BrowsePrevPageButton:SetPoint(point, relativeTo, relativePoint, x + 441, y + 262)
	
	-- BrowseNextPageButton
	BrowseNextPageButton:ClearAllPoints()
	BrowseNextPageButton:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 797, -53)
	
	-- AuctionHere_PageText
	local pageText = AuctionFrameBrowse:CreateFontString("AuctionHere_PageText")
	pageText:SetPoint("TOP", AuctionFrame, "TOP", 318, -65)
	pageText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	pageText:SetShadowOffset(1, -1)
	
	-- AuctionHere_ExactMatch
	local exactMatch = CreateFrame("CheckButton", "AuctionHere_ExactMatch", AuctionFrameBrowse, "UICheckButtonTemplate")
	exactMatch:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 134, -78)
	exactMatch:SetSize(24, 24)
	
	-- BrowseTabText
	BrowseTabText:SetText("Exact Match")
	
	-- BrowseFilterScrollFrameScrollBar
	BrowseFilterScrollFrameScrollBar:SetScript("OnMouseWheel", function(_, delta)
		BrowseFilterScrollFrame:SetVerticalScroll(math_min(math_max(BrowseFilterScrollFrame:GetVerticalScroll() - delta * 20, 0), BrowseFilterScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseFilterScrollFrameScrollBarScrollUpButton
	BrowseFilterScrollFrameScrollBarScrollUpButton:SetScript("OnMouseWheel", function(_, delta)
		BrowseFilterScrollFrame:SetVerticalScroll(math_min(math_max(BrowseFilterScrollFrame:GetVerticalScroll() - delta * 20, 0), BrowseFilterScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseFilterScrollFrameScrollBarScrollDownButton
	BrowseFilterScrollFrameScrollBarScrollDownButton:SetScript("OnMouseWheel", function(_, delta)
		BrowseFilterScrollFrame:SetVerticalScroll(math_min(math_max(BrowseFilterScrollFrame:GetVerticalScroll() - delta * 20, 0), BrowseFilterScrollFrame:GetVerticalScrollRange()))
	end)
	
	for a = 9, NUM_BROWSE_TO_DISPLAY do
		-- BrowseButtonN
		browseButtonN = CreateFrame("Button", "BrowseButton" .. a, AuctionFrameBrowse, "BrowseButtonTemplate")
		browseButtonN:SetPoint("TOPLEFT", _G["BrowseButton" .. (a - 1)], "BOTTOMLEFT", 0, 0)
		browseButtonN:SetID(a)
		browseButtonN:Hide()
	end
	
	for a = 1, NUM_BROWSE_TO_DISPLAY do
		local name = "BrowseButton" .. a
		
		-- BrowseButtonN
		local browseButtonN = _G[name]
		point, relativeTo, relativePoint, x, y = browseButtonN:GetPoint()
		
		if a > 1 then
			browseButtonN:SetPoint(point, relativeTo, relativePoint, 0, 0)
		else
			browseButtonN:SetPoint(point, relativeTo, relativePoint, x, y + 4)
		end
		
		browseButtonN:SetHeight(AUCTIONS_BUTTON_HEIGHT)
		local template = browseButtonN:GetScript("OnClick")
		browseButtonN:SetScript("OnClick", function(self, button, down)
			template(self, button, down)
			
			AuctionFrame:ClearAllPoints()
			AuctionFrame:SetPoint(addonTable.point, UIParent, addonTable.relativePoint, addonTable.x, addonTable.y)
		end)
		
		-- BrowseButtonNLeft
		local browseButtonNLeft = _G[name .. "Left"]
		point, relativeTo, relativePoint, x, y = browseButtonNLeft:GetPoint()
		browseButtonNLeft:SetPoint(point, relativeTo, relativePoint, x, y - 2)
		
		-- BrowseButtonNRight
		local browseButtonNRight = _G[name .. "Right"]
		point, relativeTo, relativePoint, x, y = browseButtonNRight:GetPoint()
		browseButtonNRight:SetPoint(point, relativeTo, relativePoint, x, y - 2)
		
		-- BrowseButtonNHighlight
		local browseButtonNHightlight = _G[name .. "Highlight"]
		point, relativeTo, relativePoint, x, y = browseButtonNHightlight:GetPoint()
		browseButtonNHightlight:SetPoint(point, relativeTo, relativePoint, x, y + 1)
		browseButtonNHightlight:SetHeight(32)
		
		-- BrowseButtonNItem
		local browseButtonNItem = _G[name .. "Item"]
		point, relativeTo, relativePoint, x, y = browseButtonNItem:GetPoint()
		browseButtonNItem:SetPoint(point, relativeTo, relativePoint, x + 5, y + 1)
		browseButtonNItem:SetSize(32, 32)
		local template = browseButtonNItem:GetScript("OnClick")
		browseButtonNItem:SetScript("OnClick", function(self, button, down)
			template(self, button, down)
			
			AuctionFrame:ClearAllPoints()
			AuctionFrame:SetPoint(addonTable.point, UIParent, addonTable.relativePoint, addonTable.x, addonTable.y)
		end)
		
		-- BrowseButtonNItemNormalTexture
		_G[name .. "ItemNormalTexture"]:SetSize(51, 51)
		
		-- BrowseButtonNName
		local browseButtonNName = _G[name .. "Name"]
		point, relativeTo, relativePoint, x, y = browseButtonNName:GetPoint()
		browseButtonNName:SetPoint(point, relativeTo, relativePoint, x, y + 2)
		
		-- BrowseButtonNLevel
		local browseButtonNLevel = _G[name .. "Level"]
		point, relativeTo, relativePoint, x, y = browseButtonNLevel:GetPoint()
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
		point, relativeTo, relativePoint, x, y = browseButtonNClosingTimeText:GetPoint()
		browseButtonNClosingTimeText:SetPoint(point, relativeTo, relativePoint, x + 4, y + 2)
		
		-- BrowseButtonNHighBidder
		local browseButtonNHighBidder = _G[name .. "HighBidder"]
		point, relativeTo, relativePoint, x, y = browseButtonNHighBidder:GetPoint()
		browseButtonNHighBidder:SetPoint(point, relativeTo, relativePoint, x + 1, y + 1)
		browseButtonNHighBidder:EnableMouse(false)
		
		-- BrowseButtonNHighBidderName
		local browseButtonNHighBidderName = _G[name .. "HighBidderName"]
		point, relativeTo, relativePoint, x, y = browseButtonNHighBidderName:GetPoint()
		browseButtonNHighBidderName:SetPoint(point, relativeTo, relativePoint, x, y + 2)
		
		-- BrowseButtonNBuyoutFrameText
		_G[name .. "BuyoutFrameText"]:Hide()
	end
	
	-- BrowseScrollFrameScrollBar
	BrowseScrollFrameScrollBar:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * 150, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseScrollFrameScrollBarScrollUpButton
	BrowseScrollFrameScrollBarScrollUpButton:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * 150, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- BrowseScrollFrameScrollBarScrollDownButton
	BrowseScrollFrameScrollBarScrollDownButton:SetScript("OnMouseWheel", function(_, delta)
		BrowseScrollFrame:SetVerticalScroll(math_min(math_max(BrowseScrollFrame:GetVerticalScroll() - delta * 150, 0), BrowseScrollFrame:GetVerticalScrollRange()))
	end)
	
	-- AuctionFrameMoneyFrame
	point, relativeTo, relativePoint, x, y = AuctionFrameMoneyFrame:GetPoint()
	AuctionFrameMoneyFrame:SetPoint(point, relativeTo, relativePoint, x, y - 7)
	
	-- BrowseSearchCountText
	point, relativeTo, relativePoint, x, y = BrowseSearchCountText:GetPoint()
	BrowseSearchCountText:SetPoint(point, relativeTo, relativePoint, x - 177, y - 33)
	
	-- BrowseBidText
	point, relativeTo, relativePoint, x, y = BrowseBidText:GetPoint()
	BrowseBidText:SetPoint(point, relativeTo, relativePoint, x, y - 1)
	
	-- BrowseBidPrice
	point, relativeTo, relativePoint, x, y = BrowseBidPrice:GetPoint()
	BrowseBidPrice:SetPoint(point, relativeTo, relativePoint, x + 92, y - 1)
	
	-- SideDressUpModelCloseButton
	local template = SideDressUpModelCloseButton:GetScript("OnClick")
	SideDressUpModelCloseButton:SetScript("OnClick", function(self, button, down)
		template(self, button, down)
		
		AuctionFrame:ClearAllPoints()
		AuctionFrame:SetPoint(addonTable.point, UIParent, addonTable.relativePoint, addonTable.x, addonTable.y)
	end)
	
	-- SideDressUpModelResetButton
	point, relativeTo, relativePoint, x, y = SideDressUpModelResetButton:GetPoint()
	SideDressUpModelResetButton:SetPoint(point, relativeTo, relativePoint, x, y - 37)
	
	-- AuctionFrameTab1
	point, relativeTo, relativePoint, x, y = AuctionFrameTab1:GetPoint()
	AuctionFrameTab1:SetPoint(point, relativeTo, relativePoint, x, y - 7)
	
	-------------------------------------------------------------------------------
	-- Bids
	-------------------------------------------------------------------------------
	
	-- BidTitle
	_, _, _, _, y = BidTitle:GetPoint()
	BidTitle:SetPoint("TOP", AuctionFrame, "TOP", 0, y)
	
	-- BidBidText
	point, relativeTo, relativePoint, x, y = BidBidText:GetPoint()
	BidBidText:SetPoint(point, relativeTo, relativePoint, x, y - 1)
	
	-- BidBidPrice
	point, relativeTo, relativePoint, x, y = BidBidPrice:GetPoint()
	BidBidPrice:SetPoint(point, relativeTo, relativePoint, x + 92, y - 1)
	
	-------------------------------------------------------------------------------
	-- Auctions
	-------------------------------------------------------------------------------
	
	-- AuctionsTitle
	_, _, _, _, y = AuctionsTitle:GetPoint()
	AuctionsTitle:SetPoint("TOP", AuctionFrame, "TOP", 0, y)
end

addonTable.Setup = Setup
