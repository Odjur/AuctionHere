
local _, addonTable = ...

 -- Modify the auction house UI
local function Setup()
	NUM_BROWSE_TO_DISPLAY = 10
	AUCTIONS_BUTTON_HEIGHT = 30
	
	local C_Timer_NewTicker = C_Timer.NewTicker
	local math_floor = math.floor
	local math_min = math.min
	local math_max = math.max
	local select = select
	local _G = _G
	
	local NUM_BROWSE_TO_DISPLAY = NUM_BROWSE_TO_DISPLAY
	local AUCTIONS_BUTTON_HEIGHT = AUCTIONS_BUTTON_HEIGHT
	local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue
	local MouseIsOver = MouseIsOver
	local GetServerTime = GetServerTime
	local CanSendAuctionQuery = CanSendAuctionQuery
	
	local AuctionFrameBrowse_Reset = addonTable.AuctionFrameBrowse_Reset
	local BrowseResetButton_OnUpdate = addonTable.BrowseResetButton_OnUpdate
	local BrowseSearchButton_OnUpdate = addonTable.BrowseSearchButton_OnUpdate
	local GetAll = addonTable.GetAll
	local Clear = addonTable.Clear
	
	local _, point, relativeTo, relativePoint, x, y
	
	AuctionFrameTab_OnClick = addonTable.AuctionFrameTab_OnClick
	
	-- AuctionFrame
	addonTable.point, _, addonTable.relativePoint, addonTable.x, addonTable.y = AuctionFrame:GetPoint()
	addonTable.y = addonTable.y + 12
	AuctionFrame:SetHeight(438)
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
	
	-- AuctionFrameTab1
	point, relativeTo, relativePoint, x, y = AuctionFrameTab1:GetPoint()
	AuctionFrameTab1:SetPoint(point, relativeTo, relativePoint, x, y - 8)
	AuctionFrameTab1:SetFrameStrata("LOW")
	
	-- AuctionFrameTab2
	AuctionFrameTab2:SetFrameStrata("LOW")
	
	-- AuctionFrameTab3
	AuctionFrameTab3:SetFrameStrata("LOW")
	
	-- AuctionFrameTab4
	local tab = CreateFrame("Button", "AuctionFrameTab4", AuctionFrame, "AuctionTabTemplate")
	tab:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 235, -434)
	tab:SetID(4)
	tab:SetText("AuctionHere")
	tab:SetFrameStrata("LOW")
	PanelTemplates_SetNumTabs(AuctionFrame, 4)
	PanelTemplates_DeselectTab(tab)
	PanelTemplates_TabResize(tab, 0)
	
	-------------------------------------------------------------------------------
	-- Browse
	-------------------------------------------------------------------------------
	
	AuctionFrameBrowse_Search = addonTable.AuctionFrameBrowse_Search
	AuctionFrameBrowse_Update = addonTable.AuctionFrameBrowse_Update
	
	-- BrowseTitle
	_, _, _, _, y = BrowseTitle:GetPoint()
	BrowseTitle:SetPoint("TOP", AuctionFrame, "TOP", 0, y)
	
	-- BrowseLevelText
	point, relativeTo, relativePoint, x, y = BrowseLevelText:GetPoint()
	BrowseLevelText:SetPoint(point, relativeTo, relativePoint, x + 5, y)
	
	-- BrowseMinLevel
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
	AuctionFrameMoneyFrame:SetPoint(point, relativeTo, relativePoint, x, y - 8)
	
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
	
	-------------------------------------------------------------------------------
	-- Bids
	-------------------------------------------------------------------------------
	
	-- BidTitle
	_, _, _, _, y = BidTitle:GetPoint()
	BidTitle:SetPoint("TOP", AuctionFrame, "TOP", 0, y)
	
	-- BidQualitySort
	point, relativeTo, relativePoint, x, y = BidQualitySort:GetPoint()
	BidQualitySort:SetPoint(point, relativeTo, relativePoint, x + 2, y)
	BidQualitySort:SetWidth(193)
	
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
	
	-------------------------------------------------------------------------------
	-- AuctionHere
	-------------------------------------------------------------------------------
	
	-- AuctionHere_Container
	local container = CreateFrame("Frame", "AuctionHere_Container", AuctionFrame)
	container:Hide()
	
	-- AuctionHere_Title
	local title = container:CreateFontString("AuctionHere_Title")
	title:SetPoint("TOP", AuctionFrame, "TOP", 0, -18)
	title:SetFont("Fonts\\FRIZQT__.TTF", 12)
	title:SetShadowOffset(1, -1)
	title:SetTextColor(1, 0.82, 0, 1)
	title:SetText("AuctionHere")
	
	-- AuctionHere_GetAll
	local getAll = CreateFrame("Button", "AuctionHere_GetAll", container, "UIPanelButtonTemplate")
	getAll:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 80, -41)
	getAll:SetSize(80, 22)
	getAll:SetText("GetAll")
	getAll:SetScript("OnClick", GetAll)
	
	-- AuctionHere_Clear
	local clear = CreateFrame("Button", "AuctionHere_Clear", container, "UIPanelButtonTemplate")
	clear:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 180, -41)
	clear:SetSize(80, 22)
	clear:SetText("Clear")
	clear:SetScript("OnClick", Clear)
	
	for a = 1, 18 do
		-- AuctionHere_ItemN
		local itemN = CreateFrame("Button", "AuctionHere_Item" .. a, container)
		itemN:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 188, -85 - 17 * a)
		itemN:SetSize(634, 19)
		itemN:SetScript("OnMouseWheel", function(_, delta)
			AuctionHere_Slider:SetValue(AuctionHere_Slider:GetValue() - delta * 9)
		end)
		
		-- AuctionHere_ItemNTexture
		local itemNTexture = itemN:CreateTexture("AuctionHere_Item" .. a .. "Texture", "BACKGROUND")
		itemNTexture:SetPoint("TOPLEFT", itemN, "TOPLEFT", 0, 0)
		itemNTexture:SetSize(634, 19)
		itemNTexture:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
		itemNTexture:SetTexCoord(0.078125, 0.75, 0, 1)
		
		-- AuctionHere_ItemNIcon
		
		-- AuctionHere_ItemNName
		local itemNName = itemN:CreateFontString("AuctionHere_Item" .. a .. "Name")
		itemNName:SetPoint("LEFT", itemN, "LEFT", 4, 0)
		itemNName:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNName:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNCount
		local itemNNCount = itemN:CreateFontString("AuctionHere_Item" .. a .. "Count")
		itemNNCount:SetPoint("LEFT", itemN, "LEFT", 320, 0)
		itemNNCount:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNNCount:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNDuration
		local itemNDuration = itemN:CreateFontString("AuctionHere_Item" .. a .. "Duration")
		itemNDuration:SetPoint("LEFT", itemN, "LEFT", 365, 0)
		itemNDuration:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNDuration:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNBid
		local itemNBid = itemN:CreateFontString("AuctionHere_Item" .. a .. "Bid")
		itemNBid:SetPoint("LEFT", itemN, "LEFT", 430, 0)
		itemNBid:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNBid:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNBuyout
		local itemNBuyout = itemN:CreateFontString("AuctionHere_Item" .. a .. "Buyout")
		itemNBuyout:SetPoint("LEFT", itemN, "LEFT", 513, 0)
		itemNBuyout:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNBuyout:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNPercent
		local itemNPercent = itemN:CreateFontString("AuctionHere_Item" .. a .. "Percent")
		itemNPercent:SetPoint("LEFT", itemN, "LEFT", 592, 0)
		itemNPercent:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNPercent:SetShadowOffset(1, -1)
	end
	
	-- AuctionHere_Slider
	local slider = CreateFrame("Slider", "AuctionHere_Slider", container, "UIPanelScrollBarTemplate")
	slider:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 804, -120)
	slider:SetSize(18, 273)
	slider:SetValueStep(1)
	slider:SetObeyStepOnDrag(true)
	slider:SetFrameStrata("HIGH")
	
	-- AuctionHere_SliderScrollUpButton
	AuctionHere_SliderScrollUpButton:SetScript("OnClick", function()
		slider:SetValue(slider:GetValue() - 9)
	end)
	
	-- AuctionHere_SliderScrollDownButton
	AuctionHere_SliderScrollDownButton:SetScript("OnClick", function()
		slider:SetValue(slider:GetValue() + 9)
	end)
	
	-- AuctionHere_BuyTab
	local buyTab = CreateFrame("Button", "AuctionHere_BuyTab", container, "AuctionClassButtonTemplate")
	buyTab:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 180, -413)
	buyTab:SetSize(42, 20)
	buyTab:SetText("Buy")
	buyTab:LockHighlight()
	buyTab:SetScript("OnClick", function(self)
		AuctionHere_SellTab:UnlockHighlight()
		AuctionHere_ListsTab:UnlockHighlight()
		AuctionHere_PricesTab:UnlockHighlight()
		AuctionHere_Sell:Hide()
		AuctionHere_Lists:Hide()
		AuctionHere_Prices:Hide()
		self:LockHighlight()
		AuctionHere_Buy:Show()
	end)
	
	-- AuctionHere_SellTab
	local sellTab = CreateFrame("Button", "AuctionHere_SellTab", container, "AuctionClassButtonTemplate")
	sellTab:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 222, -413)
	sellTab:SetSize(42, 20)
	sellTab:SetText("Sell")
	sellTab:SetScript("OnClick", function(self)
		AuctionHere_BuyTab:UnlockHighlight()
		AuctionHere_ListsTab:UnlockHighlight()
		AuctionHere_PricesTab:UnlockHighlight()
		AuctionHere_Buy:Hide()
		AuctionHere_Lists:Hide()
		AuctionHere_Prices:Hide()
		self:LockHighlight()
		AuctionHere_Sell:Show()
	end)
	
	-- AuctionHere_ListsTab
	local listsTab = CreateFrame("Button", "AuctionHere_ListsTab", container, "AuctionClassButtonTemplate")
	listsTab:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 264, -413)
	listsTab:SetSize(42, 20)
	listsTab:SetText("Lists")
	listsTab:SetScript("OnClick", function(self)
		AuctionHere_BuyTab:UnlockHighlight()
		AuctionHere_SellTab:UnlockHighlight()
		AuctionHere_PricesTab:UnlockHighlight()
		AuctionHere_Buy:Hide()
		AuctionHere_Sell:Hide()
		AuctionHere_Prices:Hide()
		self:LockHighlight()
		AuctionHere_Lists:Show()
	end)
	
	-- AuctionHere_PricesTab
	local pricesTab = CreateFrame("Button", "AuctionHere_PricesTab", container, "AuctionClassButtonTemplate")
	pricesTab:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 306, -413)
	pricesTab:SetSize(42, 20)
	pricesTab:SetText("Prices")
	pricesTab:SetScript("OnClick", function(self)
		AuctionHere_BuyTab:UnlockHighlight()
		AuctionHere_SellTab:UnlockHighlight()
		AuctionHere_ListsTab:UnlockHighlight()
		AuctionHere_Buy:Hide()
		AuctionHere_Sell:Hide()
		AuctionHere_Lists:Hide()
		self:LockHighlight()
		AuctionHere_Prices:Show()
	end)
	
	-------------------------------------------------------------------------------
	-- AuctionHere Buy
	-------------------------------------------------------------------------------
	
	-- AuctionHere_Buy
	local buy = CreateFrame("Frame", "AuctionHere_Buy", container)
	
	local nameSort = CreateFrame("Button", "AuctionHere_NameSort", buy, "AuctionSortButtonTemplate")
	nameSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 184, -82)
	nameSort:SetSize(320, 19)
	nameSort:SetText("Name")
	
	local countSort = CreateFrame("Button", "AuctionHere_CountSort", buy, "AuctionSortButtonTemplate")
	countSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 502, -82)
	countSort:SetSize(45, 19)
	countSort:SetText("Count")
	
	local durationSort = CreateFrame("Button", "AuctionHere_DurationSort", buy, "AuctionSortButtonTemplate")
	durationSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 545, -82)
	durationSort:SetSize(68, 19)
	durationSort:SetText("Duration")
	
	local bidSort = CreateFrame("Button", "AuctionHere_BidSort", buy, "AuctionSortButtonTemplate")
	bidSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 611, -82)
	bidSort:SetSize(85, 19)
	bidSort:SetText("Bid")
	
	local buyoutSort = CreateFrame("Button", "AuctionHere_BuyoutSort", buy, "AuctionSortButtonTemplate")
	buyoutSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 694, -82)
	buyoutSort:SetSize(85, 19)
	buyoutSort:SetText("Buyout")
	
	local percentSort = CreateFrame("Button", "AuctionHere_PercentSort", buy, "AuctionSortButtonTemplate")
	percentSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 777, -82)
	percentSort:SetSize(29, 19)
	percentSort:SetText("%")
	
	-------------------------------------------------------------------------------
	-- AuctionHere Sell
	-------------------------------------------------------------------------------
	
	-- AuctionHere_Sell
	local sell = CreateFrame("Frame", "AuctionHere_Sell", container)
	sell:Hide()
	
	-------------------------------------------------------------------------------
	-- AuctionHere Lists
	-------------------------------------------------------------------------------
	
	-- AuctionHere_Lists
	local lists = CreateFrame("Frame", "AuctionHere_Lists", container)
	lists:Hide()
	
	-------------------------------------------------------------------------------
	-- AuctionHere Prices
	-------------------------------------------------------------------------------
	
	-- AuctionHere_Prices
	local prices = CreateFrame("Frame", "AuctionHere_Prices", container)
	prices:Hide()
	
	-------------------------------------------------------------------------------
	-- Continuous Updates
	-------------------------------------------------------------------------------
	
	local data
	local state_getAll
	local delta
	local remainder
	
	-- Continous updates
	C_Timer_NewTicker(0.1, function()
		data = AuctionHere_data
		state_getAll = AuctionHere_data.state.getAll
		
		if state_getAll then
			delta = GetServerTime() - state_getAll
			
			if delta < 901 then
				getAll:Disable()
				delta = 900 - delta
				remainder = delta % 60
				
				if remainder < 10 then
					remainder = "0" .. remainder
				end
				
				getAll:SetText(math_floor(delta / 60) .. ":" .. remainder)
			else
				getAll:SetText("GetAll")
				
				if select(2, CanSendAuctionQuery()) then
					data.state.getAll = nil
					getAll:Enable()
				end
			end
		end
	end)
	
	-------------------------------------------------------------------------------
	-- Testing
	-------------------------------------------------------------------------------
	
	local notice = container:CreateFontString("AuctionHere_Notice")
	notice:SetPoint("TOP", AuctionFrame, "TOP", 0, -42)
	notice:SetFont("Fonts\\FRIZQT__.TTF", 10)
	notice:SetShadowOffset(1, -1)
	
	local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
	local GetFramerate = GetFramerate
	local GetAddOnMemoryUsage = GetAddOnMemoryUsage
	
	C_Timer_NewTicker(0.1, function()
		UpdateAddOnMemoryUsage()
		notice:SetText("This tab is in development, so use it with caution.\n" .. math_floor(GetFramerate()) .. " fps\nAuctionHere memory: " .. math_floor(GetAddOnMemoryUsage("AuctionHere")) .. " KB")
	end)
	
	local math_ceil = math.ceil
	local table_sort = table.sort
	local snapshot = AuctionHere_data.snapshot
	local prices = AuctionHere_data.prices["14 day median"]
	
	table_sort(snapshot, function(a, b)
		return ((a[3] / a[1]) / (prices[a[6]][a[7]] or 1)) < ((b[3] / b[1]) / (prices[b[6]][b[7]] or 1))
	end)
	
	slider:SetScript("OnValueChanged", function(_, value)
		local position = math_min(#snapshot, 18)
		
		for a = 1, position do
			local index = a + value
			local auction = snapshot[index]
			local count = auction[1]
			local buyout = auction[3]
			local ID = auction[6]
			local _, link = GetItemInfo(ID)
			local percent = math_ceil(((buyout / count) / (prices[ID][auction[7]] or 1)) * 100)
			
			if percent > 999 then
				percent = 999
			end
			
			_G["AuctionHere_Item" .. a .. "Name"]:SetText(link or "")
			_G["AuctionHere_Item" .. a .. "Count"]:SetText(count)
			_G["AuctionHere_Item" .. a .. "Duration"]:SetText("N/A")
			_G["AuctionHere_Item" .. a .. "Bid"]:SetText(math_ceil(math_max(auction[2], auction[4]) * 1.05))
			_G["AuctionHere_Item" .. a .. "Buyout"]:SetText(buyout)
			_G["AuctionHere_Item" .. a .. "Percent"]:SetText(percent)
		end
		
		for a = position + 1, 18 do
			_G["AuctionHere_Item" .. a]:Hide()
		end
	end)
	
	slider:SetMinMaxValues(0, math_max(0, #snapshot - 18))
	slider:SetValue(0)
end

addonTable.Setup = Setup
