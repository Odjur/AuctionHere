
local _, addonTable = ...

 -- Modify the auction house UI
local function Setup()
	local C_Timer_NewTicker = C_Timer.NewTicker
	local math_floor = math.floor
	local math_ceil = math.ceil
	local math_min = math.min
	local math_max = math.max
	local table_sort = table.sort
	local pairs = pairs
	local select = select
	local _G = _G
	
	NUM_BROWSE_TO_DISPLAY = 10
	AUCTIONS_BUTTON_HEIGHT = 30
	
	local MouseIsOver = MouseIsOver
	local GetServerTime = GetServerTime
	local CanSendAuctionQuery = CanSendAuctionQuery
	local PanelTemplates_SetNumTabs = PanelTemplates_SetNumTabs
	local PanelTemplates_DeselectTab = PanelTemplates_DeselectTab
	local PanelTemplates_TabResize = PanelTemplates_TabResize
	local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue
	local AuctionFrame_SetSort = AuctionFrame_SetSort
	local NUM_BROWSE_TO_DISPLAY = NUM_BROWSE_TO_DISPLAY
	local AUCTIONS_BUTTON_HEIGHT = AUCTIONS_BUTTON_HEIGHT
	
	AuctionFrameTab_OnClick = addonTable.AuctionFrameTab_OnClick
	AuctionFrameBrowse_UpdateArrows = addonTable.AuctionFrameBrowse_UpdateArrows
	AuctionFrame_OnClickSortColumn = addonTable.AuctionFrame_OnClickSortColumn
	AuctionFrameBrowse_Search = addonTable.AuctionFrameBrowse_Search
	AuctionFrameBrowse_Update = addonTable.AuctionFrameBrowse_Update
	
	local AuctionFrameTab_OnClick = AuctionFrameTab_OnClick
	local AuctionFrame_OnClickSortColumn = AuctionFrame_OnClickSortColumn
	local AuctionFrameBrowse_Search = AuctionFrameBrowse_Search
	
	local AuctionFrameBrowse_Reset = addonTable.AuctionFrameBrowse_Reset
	local BrowseResetButton_OnUpdate = addonTable.BrowseResetButton_OnUpdate
	local BrowseSearchButton_OnUpdate = addonTable.BrowseSearchButton_OnUpdate
	
	local GetAll = addonTable.GetAll
	local Clear = addonTable.Clear
	
	-- AuctionFrame
	local point, relativeTo, relativePoint, x, y = AuctionFrame:GetPoint()
	AuctionFrame:SetPoint(point, relativeTo, relativePoint, x, y + 12)
	AuctionFrame:SetHeight(438)
	AuctionFrame:SetMovable(true)
	local template = AuctionFrame.SetPoint
	AuctionFrame.SetPoint = function() end
	AuctionFrame:SetScript("OnMouseDown", function(self)
		AuctionFrame.SetPoint = template
		
		self:StartMoving()
		
		BrowseName:ClearFocus()
		BrowseMinLevel:ClearFocus()
		BrowseMaxLevel:ClearFocus()
		BrowseBidPriceGold:ClearFocus()
		BrowseBidPriceSilver:ClearFocus()
		BrowseBidPriceCopper:ClearFocus()
		AuctionHere_BuyFilters:ClearFocus()
	end)
	
	AuctionFrame:SetScript("OnMouseUp", function(self)
		self:StopMovingOrSizing()
		AuctionFrame.SetPoint = function() end
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
	
	-- BrowseDropDownName
	point, relativeTo, relativePoint, x, y = BrowseDropDownName:GetPoint()
	BrowseDropDownName:SetPoint(point, relativeTo, relativePoint, x, y + 1)
	
	-- BrowseDropDown
	point, relativeTo, relativePoint, x, y = BrowseDropDown:GetPoint()
	BrowseDropDown:SetPoint(point, relativeTo, relativePoint, x - 1, y - 1)
	UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
	
	-- BrowseDropDownButton
	point, relativeTo, relativePoint, x, y = BrowseDropDownButton:GetPoint()
	BrowseDropDownButton:SetPoint(point, relativeTo, relativePoint, x - 1, y)
	
	-- DropDownList1Backdrop
	point, relativeTo, relativePoint, x, y = DropDownList1Backdrop:GetPoint()
	DropDownList1Backdrop:SetPoint(point, relativeTo, relativePoint, x + 7, y - 1)
	
	-- IsUsableCheckButton
	point, relativeTo, relativePoint, x, y = IsUsableCheckButton:GetPoint()
	IsUsableCheckButton:SetPoint(point, relativeTo, relativePoint, x - 95, y)
	
	-- BrowseIsUsableText
	point, relativeTo, relativePoint, x, y = BrowseIsUsableText:GetPoint()
	BrowseIsUsableText:SetPoint(point, relativeTo, relativePoint, x - 10, y + 12)
	
	-- ShowOnPlayerCheckButton
	point, relativeTo, relativePoint, x, y = ShowOnPlayerCheckButton:GetPoint()
	ShowOnPlayerCheckButton:SetPoint(point, relativeTo, relativePoint, x - 129, y)
	
	-- BrowseShowOnCharacterText
	point, relativeTo, relativePoint, x, y = BrowseShowOnCharacterText:GetPoint()
	BrowseShowOnCharacterText:SetPoint(point, relativeTo, relativePoint, x - 210, y - 8)
	BrowseShowOnCharacterText:SetText("Preview Equipment")
	
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
	BrowsePrevPageButton:SetPoint(point, relativeTo, relativePoint, x + 451, y + 262)
	
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
	
	-- AuctionCategories
	local template = AuctionCategories
	template[3].subCategories[5] = AuctionCategories[7].subCategories[1]
	template[3].subCategories[6] = template[7].subCategories[2]
	local categories = {1, 2, 6, 3, 4, 5, 9, 8, 10}
	
	for a, b in pairs(categories) do
		categories[a] = template[b]
	end
	
	template = categories
	template[3].name = "Projectiles"
	template[4].name = "Containers"
	template[5].name = "Consumables"
	template[7].name = "Reagents"
	template[8].name = "Recipes"
	
	-- Weapons
	local subCategories = {8, 9, 1, 2, 5, 6, 13, 11, 7, 10, 3, 15, 4, 16, 14, 17, 12}
	
	for a, b in pairs(subCategories) do
		subCategories[a] = template[1].subCategories[b]
	end
	
	template[1].filters = {{["classID"] = 2}}
	template[1].subCategories = subCategories
	template[1].subCategories[15].name = "Thrown Weapons"
	template[1].subCategories[16].name = "Fishing Poles"
	
	-- Armor
	template[2].filters = {{["classID"] = 4}}
	template[2].subCategories[10] = template[2].subCategories[9]
	template[2].subCategories[9] = template[2].subCategories[7]
	template[2].subCategories[7] = template[2].subCategories[1].subCategories[14]
	
	-- Miscellaneous
	template[2].subCategories[1].filters[3] = template[2].subCategories[2].filters[14]
	template[2].subCategories[1].subCategories[3] = template[2].subCategories[2].subCategories[13]
	
	local filters = {}
	local subCategories = {1, 2, 3, 4, 8, 11, 12}
	
	for a, b in pairs(subCategories) do
		filters[a] = template[2].subCategories[1].filters[b]
		subCategories[a] = template[2].subCategories[1].subCategories[b]
	end
	
	template[2].subCategories[1].filters = filters
	template[2].subCategories[1].subCategories = subCategories
	template[2].subCategories[1].subCategories[4].name = "Shirts"
	
	-- Cloth
	local filters = {}
	local subCategories = {1, 3, 5, 9, 10, 6, 7, 8}
	
	for a, b in pairs(subCategories) do
		filters[a] = template[2].subCategories[2].filters[b + 1]
		subCategories[a] = template[2].subCategories[2].subCategories[b]
	end
	
	filters[9] = template[2].subCategories[2].filters[16]
	template[2].subCategories[2].filters = filters
	template[2].subCategories[2].subCategories = subCategories
	template[2].subCategories[2].subCategories[2].name = "Shoulders"
	template[2].subCategories[2].subCategories[4].name = "Wrists"
	
	-- Leather
	local filters = {}
	local subCategories = {1, 3, 5, 9, 10, 6, 7, 8}
	
	for a, b in pairs(subCategories) do
		filters[a] = template[2].subCategories[3].filters[b + 1]
		subCategories[a] = template[2].subCategories[3].subCategories[b]
	end
	
	filters[9] = template[2].subCategories[3].filters[16]
	template[2].subCategories[3].filters = filters
	template[2].subCategories[3].subCategories = subCategories
	template[2].subCategories[3].subCategories[2].name = "Shoulders"
	template[2].subCategories[3].subCategories[4].name = "Wrists"
	
	-- Mail
	local filters = {}
	local subCategories = {1, 3, 5, 9, 10, 6, 7, 8}
	
	for a, b in pairs(subCategories) do
		filters[a] = template[2].subCategories[4].filters[b + 1]
		subCategories[a] = template[2].subCategories[4].subCategories[b]
	end
	
	filters[9] = template[2].subCategories[4].filters[16]
	template[2].subCategories[4].filters = filters
	template[2].subCategories[4].subCategories = subCategories
	template[2].subCategories[4].subCategories[2].name = "Shoulders"
	template[2].subCategories[4].subCategories[4].name = "Wrists"
	
	-- Plate
	local filters = {}
	local subCategories = {1, 3, 5, 9, 10, 6, 7, 8}
	
	for a, b in pairs(subCategories) do
		filters[a] = template[2].subCategories[5].filters[b + 1]
		subCategories[a] = template[2].subCategories[5].subCategories[b]
	end
	
	filters[9] = template[2].subCategories[5].filters[16]
	template[2].subCategories[5].filters = filters
	template[2].subCategories[5].subCategories = subCategories
	template[2].subCategories[5].subCategories[2].name = "Shoulders"
	template[2].subCategories[5].subCategories[4].name = "Wrists"
	
	-- Projectiles
	template[3].filters = {{["classID"] = 6}}
	template[3].subCategories[1].name = "Arrows"
	template[3].subCategories[2].name = "Bullets"
	
	-- Containers
	local subCategories = {1, 3, 4, 2, 5, 6}
	
	for a, b in pairs(subCategories) do
		subCategories[a] = template[4].subCategories[b]
	end
	
	template[4].filters = {
		{["classID"] = 1},
		{["classID"] = 11}
	}
	
	template[4].subCategories = subCategories
	template[4].subCategories[1].name = "Bags"
	template[4].subCategories[2].name = "Herb Bags"
	template[4].subCategories[3].name = "Enchanting Bags"
	template[4].subCategories[4].name = "Soul Bags"
	template[4].subCategories[5].name = "Quivers"
	template[4].subCategories[6].name = "Ammo Pouches"
	
	-- Recipes
	local subCategories = {1, 3, 2, 5, 4, 9, 7, 10, 8, 6}
	
	for a, b in pairs(subCategories) do
		subCategories[a] = template[8].subCategories[b]
	end
	
	template[8].filters = {{["classID"] = 9}}
	template[8].subCategories = subCategories
	template[8].subCategories[1].name = "Books"
	
	-- Miscellaneous
	template[9].filters = {
		{["classID"] = 15},
		{["classID"] = 3},
		{["classID"] = 8},
		{["classID"] = 10},
		{["classID"] = 12},
		{["classID"] = 13},
		{["classID"] = 14}
	}
	
	AuctionCategories = template
	AuctionFrameFilters_Update()
	
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
	
	-- AuctionHere_Count
	local count = CreateFrame("Button", "AuctionHere_Count", AuctionFrameBrowse, "AuctionSortButtonTemplate")
	count:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 184, -82)
	count:SetSize(37, 19)
	count:SetText("#")
	count:SetScript("OnClick", function()
		AuctionFrame_OnClickSortColumn("list", "quantity")
	end)
	
	AuctionSort.list_quantity = {
		{
			column = "quantity",
			["reverse"] = false
		}
	}
	
	-- BrowseQualitySort
	point, relativeTo, relativePoint, x, y = BrowseQualitySort:GetPoint()
	BrowseQualitySort:SetPoint(point, relativeTo, relativePoint, x + 33, y)
	BrowseQualitySort:SetWidth(187)
	AuctionFrame_SetSort("list", "quality", false)
	
	-- BrowseLevelSort
	BrowseLevelSort:SetWidth(43)
	
	-- BrowseDurationSort
	BrowseDurationSort:SetWidth(74)
	BrowseDurationSort:SetText("Duration")
	
	-- BrowseHighBidderSort
	BrowseHighBidderSort:SetWidth(100)
	
	-- BrowseCurrentBidSort
	BrowseCurrentBidSort:SetWidth(209)
	BrowseCurrentBidSort:SetText("Buyout unit price")
	BrowseCurrentBidSort:SetScript("OnClick", function()
		AuctionFrame_OnClickSortColumn("list", "unitprice")
	end)
	
	AuctionSort.list_bid = nil
	AuctionSort.list_unitprice = {
		{
			column = "unitprice",
			["reverse"] = false
		}
	}
	
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
			browseButtonN:SetPoint(point, relativeTo, relativePoint, x - 10, y + 4)
		end
		
		browseButtonN:SetHeight(AUCTIONS_BUTTON_HEIGHT)
		local template = browseButtonN:GetScript("OnClick")
		browseButtonN:SetScript("OnClick", function(self, button, down)
			UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
			template(self, button, down)
			UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
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
			UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
			template(self, button, down)
			UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		end)
		
		-- BrowseButtonNItemNormalTexture
		_G[name .. "ItemNormalTexture"]:SetSize(51, 51)
		
		-- BrowseButtonNName
		local browseButtonNName = _G[name .. "Name"]
		point, relativeTo, relativePoint, x, y = browseButtonNName:GetPoint()
		browseButtonNName:SetPoint(point, relativeTo, relativePoint, x - 3, y + 2)
		browseButtonNName:SetWidth(177)
		
		-- BrowseButtonNLevel
		local browseButtonNLevel = _G[name .. "Level"]
		point, relativeTo, relativePoint, x, y = browseButtonNLevel:GetPoint()
		browseButtonNLevel:SetPoint(point, relativeTo, relativePoint, x + 10, y + 2)
		
		-- BrowseButtonNClosingTime
		local browseButtonNClosingTime = _G[name .. "ClosingTime"]
		point, relativeTo, relativePoint, x, y = browseButtonNClosingTime:GetPoint()
		browseButtonNClosingTime:SetPoint(point, relativeTo, relativePoint, x - 2, y + 2)
		browseButtonNClosingTime:SetHeight(30)
		browseButtonNClosingTime:SetScript("OnMouseUp", function(_, button)
			if button == "LeftButton" and MouseIsOver(browseButtonN) then
				browseButtonN:Click()
			end
		end)
		
		-- BrowseButtonNHighBidder
		local browseButtonNHighBidder = _G[name .. "HighBidder"]
		point, relativeTo, relativePoint, x, y = browseButtonNHighBidder:GetPoint()
		browseButtonNHighBidder:SetPoint(point, relativeTo, relativePoint, x + - 10, y + 1)
		browseButtonNHighBidder:SetWidth(95)
		browseButtonNHighBidder:EnableMouse(false)
		
		-- BrowseButtonNHighBidderName
		local browseButtonNHighBidderName = _G[name .. "HighBidderName"]
		point, relativeTo, relativePoint, x, y = browseButtonNHighBidderName:GetPoint()
		browseButtonNHighBidderName:SetPoint(point, relativeTo, relativePoint, x, y + 2)
		
		-- BrowseButtonNBuyoutFrameText
		_G[name .. "BuyoutFrameText"]:Hide()
	end
	
	-- BrowseScrollFrameScrollBar
	point, relativeTo, relativePoint, x, y = BrowseScrollFrameScrollBar:GetPoint()
	BrowseScrollFrameScrollBar:SetPoint(point, relativeTo, relativePoint, x - 1, y)
	BrowseScrollFrameScrollBar:SetWidth(18)
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
	
	local function GetAllTicker()
		getAll:Disable()
		local state_getAll
		local delta
		local remainder
		local AuctionHere_data = AuctionHere_data
		
		local ticker = 	C_Timer_NewTicker(0.1, function()
			local state_getAll = AuctionHere_data.state.getAll
			
			if state_getAll then
				delta = GetServerTime() - state_getAll
				
				if delta < 901 then
					delta = 900 - delta
					remainder = delta % 60
					
					if remainder < 10 then
						getAll:SetText(math_floor(delta / 60) .. ":0" .. remainder)
					else
						getAll:SetText(math_floor(delta / 60) .. ":" .. remainder)
					end
				else
					getAll:SetText("GetAll")
					
					if select(2, CanSendAuctionQuery()) then
						AuctionHere_data.state.getAll = nil
						getAll:Enable()
						ticker:Cancel()
					end
				end
			end
		end)
	end
	
	local ticker
	getAll:SetScript("OnClick", function(self)
		GetAllTicker()
		
		AuctionFrameTab1:Disable()
		AuctionFrameTab2:Disable()
		AuctionFrameTab3:Disable()
		
		ticker = C_Timer_NewTicker(0.1, function()
			local AuctionHere_data = AuctionHere_data
			
			if AuctionHere_data.state.getAll then
				AuctionFrameTab1:Enable()
				AuctionFrameTab2:Enable()
				AuctionFrameTab3:Enable()
			
				ticker:Cancel()
			end
		end)
		
		GetAll()
	end)
	
	local AuctionHere_data = AuctionHere_data
	
	if select(2, CanSendAuctionQuery()) then
		AuctionHere_data.state.getAll = nil
	else
		if AuctionHere_data.state.getAll then
			GetAllTicker()
		else
			getAll:Disable()
			
			local ticker = C_Timer_NewTicker(0.1, function()
				if select(2, CanSendAuctionQuery()) then
					getAll:Enable()
					ticker:Cancel()
				end
			end)
		end
	end
	
	-- AuctionHere_Clear
	local clear = CreateFrame("Button", "AuctionHere_Clear", container, "UIPanelButtonTemplate")
	clear:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 180, -41)
	clear:SetSize(80, 22)
	clear:SetText("Clear")
	clear:SetScript("OnClick", Clear)
	
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
	
	-- AuctionHere_BuyFiltersText
	local buyFiltersText = buy:CreateFontString("AuctionHere_BuyFiltersText")
	buyFiltersText:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 69, -85)
	buyFiltersText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	buyFiltersText:SetShadowOffset(1, -1)
	buyFiltersText:SetText("Filters")
	
	-- AuctionHere_BuyFiltersBackground
	local buyFiltersBackground = CreateFrame("ScrollFrame", "AuctionHere_BuyFiltersBackground", buy)
	buyFiltersBackground:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 25, -106)
	buyFiltersBackground:SetSize(150, 266)
	buyFiltersBackground:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		tile = false,
		tileSize = 0,
		edgeSize = 2,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		}
	})
	buyFiltersBackground:SetBackdropColor(0, 0.168, 0.211)
	buyFiltersBackground:SetBackdropBorderColor(0.025, 0.025, 0.025)
	buyFiltersBackground:SetScript("OnMouseDown", function()
		AuctionHere_BuyFilters:SetFocus()
	end)
	
	buyFiltersBackground:SetScript("OnMouseWheel", function(_, delta)
		AuctionHere_BuyFiltersScroll:SetVerticalScroll(math_min(math_max(AuctionHere_BuyFiltersScroll:GetVerticalScroll() - delta * 10, 0), AuctionHere_BuyFiltersScroll:GetVerticalScrollRange()))
	end)
	
	-- AuctionHere_BuyFiltersScroll
	local buyFiltersScroll = CreateFrame("ScrollFrame", "AuctionHere_BuyFiltersScroll", buy)
	buyFiltersScroll:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 25, -106)
	buyFiltersScroll:SetSize(150, 261)
	
	-- AuctionHere_BuyFilters
	local buyFilters = CreateFrame("EditBox", "AuctionHere_BuyFilters", buy)
	buyFilters:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 25, -106)
	buyFilters:SetSize(150, 261)
	buyFilters:SetFont("Interface\\Addons\\AuctionHere\\Fonts\\Inconsolata-Regular.ttf", 10)
	buyFilters:SetShadowOffset(1, -1)
	buyFilters:SetTextColor(0.975, 0.975, 0.975)
	buyFilters:SetTextInsets(5, 5, 4, 0)
	buyFilters:SetMultiLine(true)
	buyFilters:SetAutoFocus(false)
	buyFiltersScroll:SetScrollChild(buyFilters)
	
	-- AuctionHere_BuySearch
	local buySearch = CreateFrame("Button", "AuctionHere_BuySearch", buy, "UIPanelButtonTemplate")
	buySearch:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 58, -377)
	buySearch:SetSize(80, 22)
	buySearch:SetText("Search")
	buySearch:SetScript("OnClick", function()
		buyFilters:ClearFocus()
		
		local results = {}
		local AuctionHere_data = AuctionHere_data
		local snapshot = AuctionHere_data.snapshot or {}
		
		for a, b in pairs(snapshot) do
			results[a] = a
		end
		
		local indexA
		local indexB
		local prices = AuctionHere_data.prices["14 day median"]
		
		table_sort(results, function(a, b)
			indexA = snapshot[a]
			indexB = snapshot[b]
			
			return ((indexA[3] / indexA[1]) / (prices[indexA[6]][indexA[7]] or 1)) < ((indexB[3] / indexB[1]) / (prices[indexB[6]][indexB[7]] or 1))
		end)
		
		addonTable.snapshot = results
		AuctionHere_BuySlider:SetMinMaxValues(0, math_max(0, #results - 18))
		AuctionHere_BuySlider:SetValue(1)
		AuctionHere_BuySlider:SetValue(0)
	end)
	
	-- AuctionHere_BuyNameSort
	local buyNameSort = CreateFrame("Button", "AuctionHere_BuyNameSort", buy, "AuctionSortButtonTemplate")
	buyNameSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 184, -82)
	buyNameSort:SetSize(334, 19)
	buyNameSort:SetText("Name")
	
	-- AuctionHere_BuyCountSort
	local buyCountSort = CreateFrame("Button", "AuctionHere_BuyCountSort", buy, "AuctionSortButtonTemplate")
	buyCountSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 516, -82)
	buyCountSort:SetSize(31, 19)
	buyCountSort:SetText("#")
	
	-- AuctionHere_BuyDurationSort
	local buyDurationSort = CreateFrame("Button", "AuctionHere_BuyDurationSort", buy, "AuctionSortButtonTemplate")
	buyDurationSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 545, -82)
	buyDurationSort:SetSize(62, 19)
	buyDurationSort:SetText("Duration")
	
	-- AuctionHere_BuyBidSort
	local buyBidSort = CreateFrame("Button", "AuctionHere_BuyBidSort", buy, "AuctionSortButtonTemplate")
	buyBidSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 605, -82)
	buyBidSort:SetSize(87, 19)
	buyBidSort:SetText("Bid")
	
	-- AuctionHere_BuyBuyoutSort
	local buyBuyoutSort = CreateFrame("Button", "AuctionHere_BuyBuyoutSort", buy, "AuctionSortButtonTemplate")
	buyBuyoutSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 690, -82)
	buyBuyoutSort:SetSize(87, 19)
	buyBuyoutSort:SetText("Buyout")
	
	-- AuctionHere_BuyPercentSort
	local buyPercentSort = CreateFrame("Button", "AuctionHere_BuyPercentSort", buy, "AuctionSortButtonTemplate")
	buyPercentSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 775, -82)
	buyPercentSort:SetSize(31, 19)
	buyPercentSort:SetText("%")
	
	for a = 1, 18 do
		-- AuctionHere_BuyN
		local buyN = CreateFrame("Button", "AuctionHere_Buy" .. a, buy)
		buyN:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 188, -85 - 17 * a)
		buyN:SetSize(634, 19)
		buyN:SetScript("OnMouseWheel", function(_, delta)
			AuctionHere_BuySlider:SetValue(AuctionHere_BuySlider:GetValue() - delta * 9)
		end)
		
		-- AuctionHere_BuyNTexture
		local buyNTexture = buyN:CreateTexture("AuctionHere_Buy" .. a .. "Texture", "BACKGROUND")
		buyNTexture:SetPoint("TOPLEFT", buyN, "TOPLEFT", 0, 0)
		buyNTexture:SetSize(634, 19)
		buyNTexture:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
		buyNTexture:SetTexCoord(0.078125, 0.75, 0, 1)
		
		-- AuctionHere_BuyNIcon
		
		-- AuctionHere_BuyNName
		local buyNName = buyN:CreateFontString("AuctionHere_Buy" .. a .. "Name")
		buyNName:SetPoint("LEFT", buyN, "LEFT", 4, 0)
		buyNName:SetFont("Interface\\Addons\\AuctionHere\\Fonts\\Inconsolata-Regular.ttf", 12)
		buyNName:SetShadowOffset(1, -1)
		
		-- AuctionHere_BuyNCount
		local buyNNCount = buyN:CreateFontString("AuctionHere_Buy" .. a .. "Count")
		buyNNCount:SetPoint("RIGHT", buyN, "RIGHT", -276, 0)
		buyNNCount:SetFont("Interface\\Addons\\AuctionHere\\Fonts\\Inconsolata-Regular.ttf", 12)
		buyNNCount:SetShadowOffset(1, -1)
		
		-- AuctionHere_BuyNDuration
		local buyNDuration = buyN:CreateFontString("AuctionHere_Buy" .. a .. "Duration")
		buyNDuration:SetPoint("RIGHT", buyN, "RIGHT", -218, 0)
		buyNDuration:SetFont("Interface\\Addons\\AuctionHere\\Fonts\\Inconsolata-Regular.ttf", 12)
		buyNDuration:SetShadowOffset(1, -1)
		
		-- AuctionHere_BuyNBid
		local buytNBid = buyN:CreateFontString("AuctionHere_Buy" .. a .. "Bid")
		buytNBid:SetPoint("RIGHT", buyN, "RIGHT", -133, 0)
		buytNBid:SetFont("Interface\\Addons\\AuctionHere\\Fonts\\Inconsolata-Regular.ttf", 12)
		buytNBid:SetShadowOffset(1, -1)
		
		-- AuctionHere_BuyNBuyout
		local buyNBuyout = buyN:CreateFontString("AuctionHere_Buy" .. a .. "Buyout")
		buyNBuyout:SetPoint("RIGHT", buyN, "RIGHT", -48, 0)
		buyNBuyout:SetFont("Interface\\Addons\\AuctionHere\\Fonts\\Inconsolata-Regular.ttf", 12)
		buyNBuyout:SetShadowOffset(1, -1)
		
		-- AuctionHere_BuyNPercent
		local buyNPercent = buyN:CreateFontString("AuctionHere_Buy" .. a .. "Percent")
		buyNPercent:SetPoint("RIGHT", buyN, "RIGHT", -19, 0)
		buyNPercent:SetFont("Interface\\Addons\\AuctionHere\\Fonts\\Inconsolata-Regular.ttf", 12)
		buyNPercent:SetShadowOffset(1, -1)
	end
	
	-- AuctionHere_BuySlider
	local buySlider = CreateFrame("Slider", "AuctionHere_BuySlider", buy, "UIPanelScrollBarTemplate")
	buySlider:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 804, -120)
	buySlider:SetSize(18, 273)
	buySlider:SetValueStep(1)
	buySlider:SetObeyStepOnDrag(true)
	buySlider:SetFrameStrata("HIGH")
	buySlider:SetMinMaxValues(0, 0)
	addonTable.snapshot = {}
	local results
	buySlider:SetScript("OnValueChanged", function(_, value)
		results = addonTable.snapshot
		local position = math_min(#results, 18)
		local AuctionHere_data = AuctionHere_data
		local prices = AuctionHere_data.prices["14 day median"]
		local snapshot = AuctionHere_data.snapshot
		
		for a = 1, position do
			local index = a + value
			local auction = snapshot[results[index]]
			local ID = auction[6]
			local _, link = GetItemInfo(ID)
			local count = auction[1]
			local bid = math_max(auction[2], math_ceil(auction[4] * 1.05))
			local bidCopper = bid % 100
			local bidSilver = math_floor(bid / 100) % 100
			local bidGold = math_floor(bid / 10000)
			local buyout = auction[3]
			local buyoutCopper = buyout % 100
			local buyoutSilver = math_floor(buyout / 100) % 100
			local buyoutGold = math_floor(buyout / 10000)
			local percent = math_ceil(((buyout / count) / (prices[ID][auction[7]] or 1)) * 100)
			
			if bidGold == 0 then
				bidGold = ""
				
				if bidSilver == 0 then
					bidSilver = ""
				else
					if bidCopper < 10 then
						bidCopper = "0" .. bidCopper
					end
				end
			else
				if bidSilver < 10 then
					bidSilver = "0" .. bidSilver
				end
				
				if bidCopper < 10 then
					bidCopper = "0" .. bidCopper
				end
			end
			
			if buyoutGold == 0 then
				buyoutGold = ""
				
				if buyoutSilver == 0 then
					buyoutSilver = ""
				else
					if buyoutCopper < 10 then
						buyoutCopper = "0" .. buyoutCopper
					end
				end
			else
				if buyoutSilver < 10 then
					buyoutSilver = "0" .. buyoutSilver
				end
				
				if buyoutCopper < 10 then
					buyoutCopper = "0" .. buyoutCopper
				end
			end
			
			if percent > 999 then
				percent = 999
			end
			
			if percent < 25 then
				percent = "|cffff8000" .. percent .. "|r"
			elseif percent < 50 then
				percent = "|cffa335ee" .. percent .. "|r"
			elseif percent < 75 then
				percent = "|cff1eff00" .. percent .. "|r"
			elseif percent < 100 then
				percent = "|cffffffff" .. percent .. "|r"
			elseif percent < 125 then
				percent = "|cff9d9d9d" .. percent .. "|r"
			elseif percent < 150 then
				percent = "|cff996600" .. percent .. "|r"
			elseif percent < 175 then
				percent = "|cffffff00" .. percent .. "|r"
			elseif percent < 200 then
				percent = "|cffff5050" .. percent .. "|r"
			else
				percent = "|cffff0000" .. percent .. "|r"
			end
			
			local name = "AuctionHere_Buy" .. a
			
			_G[name .. "Name"]:SetText(link or "")
			_G[name .. "Count"]:SetText(count)
			_G[name .. "Duration"]:SetText("N/A")
			_G[name .. "Bid"]:SetText("|cffffd100" .. bidGold .. " |cffe6e6e6" .. bidSilver .. " |cffc8602c" .. bidCopper .. "|r")
			_G[name .. "Buyout"]:SetText("|cffffd100" .. buyoutGold .. " |cffe6e6e6" .. buyoutSilver .. " |cffc8602c" .. buyoutCopper .. "|r")
			_G[name .. "Percent"]:SetText(percent)
			_G[name]:Show()
		end
		
		for a = position + 1, 18 do
			_G["AuctionHere_Buy" .. a]:Hide()
		end
	end)
	
	buySlider:SetValue(0)
	
	-- AuctionHere_BuySliderScrollUpButton
	AuctionHere_BuySliderScrollUpButton:SetScript("OnClick", function()
		buySlider:SetValue(buySlider:GetValue() - 1)
	end)
	
	-- AuctionHere_BuySliderScrollDownButton
	AuctionHere_BuySliderScrollDownButton:SetScript("OnClick", function()
		buySlider:SetValue(buySlider:GetValue() + 1)
	end)
	
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
end

addonTable.Setup = Setup
