
local _, addonTable = ...

 -- Modify the auction house UI
local function Setup()
	local C_Timer_NewTicker = C_Timer.NewTicker
	local math_floor = math.floor
	local math_min = math.min
	local math_max = math.max
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
	AuctionCategories[3].subCategories[5] = AuctionCategories[7].subCategories[1]
	AuctionCategories[3].subCategories[6] = AuctionCategories[7].subCategories[2]
	local categories = {1, 2, 6, 3, 4, 5, 9, 8, 10}
	
	for a, b in pairs(categories) do
		categories[a] = AuctionCategories[b]
	end
	
	AuctionCategories = categories
	AuctionCategories[3].name = "Projectiles"
	AuctionCategories[4].name = "Containers"
	AuctionCategories[5].name = "Consumables"
	AuctionCategories[7].name = "Reagents"
	AuctionCategories[8].name = "Recipes"
	
	-- Weapons
	local subCategories = {8, 9, 1, 2, 5, 6, 13, 11, 7, 10, 3, 15, 4, 16, 14, 17, 12}
	
	for a, b in pairs(subCategories) do
		subCategories[a] = AuctionCategories[1].subCategories[b]
	end
	
	AuctionCategories[1].filters = {{["classID"] = 2}}
	AuctionCategories[1].subCategories = subCategories
	AuctionCategories[1].subCategories[15].name = "Thrown Weapons"
	AuctionCategories[1].subCategories[16].name = "Fishing Poles"
	
	-- Armor
	AuctionCategories[2].filters = {{["classID"] = 4}}
	AuctionCategories[2].subCategories[10] = AuctionCategories[2].subCategories[9]
	AuctionCategories[2].subCategories[9] = AuctionCategories[2].subCategories[7]
	AuctionCategories[2].subCategories[7] = AuctionCategories[2].subCategories[1].subCategories[14]
	
	-- Miscellaneous
	AuctionCategories[2].subCategories[1].filters[3] = AuctionCategories[2].subCategories[2].filters[14]
	AuctionCategories[2].subCategories[1].subCategories[3] = AuctionCategories[2].subCategories[2].subCategories[13]
	
	local filters = {}
	local subCategories = {1, 2, 3, 4, 8, 11, 12}
	
	for a, b in pairs(subCategories) do
		filters[a] = AuctionCategories[2].subCategories[1].filters[b]
		subCategories[a] = AuctionCategories[2].subCategories[1].subCategories[b]
	end
	
	AuctionCategories[2].subCategories[1].filters = filters
	AuctionCategories[2].subCategories[1].subCategories = subCategories
	AuctionCategories[2].subCategories[1].subCategories[4].name = "Shirts"
	
	-- Cloth
	local filters = {}
	local subCategories = {1, 3, 5, 9, 10, 6, 7, 8}
	
	for a, b in pairs(subCategories) do
		filters[a] = AuctionCategories[2].subCategories[2].filters[b + 1]
		subCategories[a] = AuctionCategories[2].subCategories[2].subCategories[b]
	end
	
	filters[9] = AuctionCategories[2].subCategories[2].filters[16]
	AuctionCategories[2].subCategories[2].filters = filters
	AuctionCategories[2].subCategories[2].subCategories = subCategories
	AuctionCategories[2].subCategories[2].subCategories[2].name = "Shoulders"
	AuctionCategories[2].subCategories[2].subCategories[4].name = "Wrists"
	
	-- Leather
	local filters = {}
	local subCategories = {1, 3, 5, 9, 10, 6, 7, 8}
	
	for a, b in pairs(subCategories) do
		filters[a] = AuctionCategories[2].subCategories[3].filters[b + 1]
		subCategories[a] = AuctionCategories[2].subCategories[3].subCategories[b]
	end
	
	filters[9] = AuctionCategories[2].subCategories[3].filters[16]
	AuctionCategories[2].subCategories[3].filters = filters
	AuctionCategories[2].subCategories[3].subCategories = subCategories
	AuctionCategories[2].subCategories[3].subCategories[2].name = "Shoulders"
	AuctionCategories[2].subCategories[3].subCategories[4].name = "Wrists"
	
	-- Mail
	local filters = {}
	local subCategories = {1, 3, 5, 9, 10, 6, 7, 8}
	
	for a, b in pairs(subCategories) do
		filters[a] = AuctionCategories[2].subCategories[4].filters[b + 1]
		subCategories[a] = AuctionCategories[2].subCategories[4].subCategories[b]
	end
	
	filters[9] = AuctionCategories[2].subCategories[4].filters[16]
	AuctionCategories[2].subCategories[4].filters = filters
	AuctionCategories[2].subCategories[4].subCategories = subCategories
	AuctionCategories[2].subCategories[4].subCategories[2].name = "Shoulders"
	AuctionCategories[2].subCategories[4].subCategories[4].name = "Wrists"
	
	-- Plate
	local filters = {}
	local subCategories = {1, 3, 5, 9, 10, 6, 7, 8}
	
	for a, b in pairs(subCategories) do
		filters[a] = AuctionCategories[2].subCategories[5].filters[b + 1]
		subCategories[a] = AuctionCategories[2].subCategories[5].subCategories[b]
	end
	
	filters[9] = AuctionCategories[2].subCategories[5].filters[16]
	AuctionCategories[2].subCategories[5].filters = filters
	AuctionCategories[2].subCategories[5].subCategories = subCategories
	AuctionCategories[2].subCategories[5].subCategories[2].name = "Shoulders"
	AuctionCategories[2].subCategories[5].subCategories[4].name = "Wrists"
	
	-- Projectiles
	AuctionCategories[3].filters = {{["classID"] = 6}}
	AuctionCategories[3].subCategories[1].name = "Arrows"
	AuctionCategories[3].subCategories[2].name = "Bullets"
	
	-- Containers
	local subCategories = {1, 3, 4, 2, 5, 6}
	
	for a, b in pairs(subCategories) do
		subCategories[a] = AuctionCategories[4].subCategories[b]
	end
	
	AuctionCategories[4].filters = {
		{["classID"] = 1},
		{["classID"] = 11}
	}
	
	AuctionCategories[4].subCategories = subCategories
	AuctionCategories[4].subCategories[1].name = "Bags"
	AuctionCategories[4].subCategories[2].name = "Herb Bags"
	AuctionCategories[4].subCategories[3].name = "Enchanting Bags"
	AuctionCategories[4].subCategories[4].name = "Soul Bags"
	AuctionCategories[4].subCategories[5].name = "Quivers"
	AuctionCategories[4].subCategories[6].name = "Ammo Pouches"
	
	-- Recipes
	local subCategories = {1, 3, 2, 5, 4, 9, 7, 10, 8, 6}
	
	for a, b in pairs(subCategories) do
		subCategories[a] = AuctionCategories[8].subCategories[b]
	end
	
	AuctionCategories[8].filters = {{["classID"] = 9}}
	AuctionCategories[8].subCategories = subCategories
	AuctionCategories[8].subCategories[1].name = "Books"
	
	-- Miscellaneous
	AuctionCategories[9].filters = {
		{["classID"] = 15},
		{["classID"] = 3},
		{["classID"] = 8},
		{["classID"] = 10},
		{["classID"] = 12},
		{["classID"] = 13},
		{["classID"] = 14}
	}
	
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
	local ticker
	getAll:SetScript("OnClick", function(self)
		self:Disable()
		
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
	
	if select(2, CanSendAuctionQuery()) then
		local AuctionHere_data = AuctionHere_data
		AuctionHere_data.state.getAll = 0
	end
	
	local state_getAll
	local delta
	local remainder
	
	C_Timer_NewTicker(0.1, function()
		local AuctionHere_data = AuctionHere_data
		state_getAll = AuctionHere_data.state.getAll
		
		if state_getAll then
			delta = GetServerTime() - state_getAll
			
			if delta < 901 then
				getAll:Disable()
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
				end
			end
		end
	end)
	
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
		itemNNCount:SetPoint("RIGHT", itemN, "RIGHT", -276, 0)
		itemNNCount:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNNCount:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNDuration
		local itemNDuration = itemN:CreateFontString("AuctionHere_Item" .. a .. "Duration")
		itemNDuration:SetPoint("RIGHT", itemN, "RIGHT", -218, 0)
		itemNDuration:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNDuration:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNBid
		local itemNBid = itemN:CreateFontString("AuctionHere_Item" .. a .. "Bid")
		itemNBid:SetPoint("RIGHT", itemN, "RIGHT", -133, 0)
		itemNBid:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNBid:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNBuyout
		local itemNBuyout = itemN:CreateFontString("AuctionHere_Item" .. a .. "Buyout")
		itemNBuyout:SetPoint("RIGHT", itemN, "RIGHT", -48, 0)
		itemNBuyout:SetFont("Fonts\\FRIZQT__.TTF", 10)
		itemNBuyout:SetShadowOffset(1, -1)
		
		-- AuctionHere_ItemNPercent
		local itemNPercent = itemN:CreateFontString("AuctionHere_Item" .. a .. "Percent")
		itemNPercent:SetPoint("RIGHT", itemN, "RIGHT", -19, 0)
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
	
	-- AuctionHere_NameSort
	local nameSort = CreateFrame("Button", "AuctionHere_NameSort", buy, "AuctionSortButtonTemplate")
	nameSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 184, -82)
	nameSort:SetSize(336, 19)
	nameSort:SetText("Name")
	
	-- AuctionHere_CountSort
	local countSort = CreateFrame("Button", "AuctionHere_CountSort", buy, "AuctionSortButtonTemplate")
	countSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 518, -82)
	countSort:SetSize(31, 19)
	countSort:SetText("#")
	
	-- AuctionHere_DurationSort
	local durationSort = CreateFrame("Button", "AuctionHere_DurationSort", buy, "AuctionSortButtonTemplate")
	durationSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 547, -82)
	durationSort:SetSize(60, 19)
	durationSort:SetText("Duration")
	
	-- AuctionHere_BidSort
	local bidSort = CreateFrame("Button", "AuctionHere_BidSort", buy, "AuctionSortButtonTemplate")
	bidSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 605, -82)
	bidSort:SetSize(87, 19)
	bidSort:SetText("Bid")
	
	-- AuctionHere_BuyoutSort
	local buyoutSort = CreateFrame("Button", "AuctionHere_BuyoutSort", buy, "AuctionSortButtonTemplate")
	buyoutSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 690, -82)
	buyoutSort:SetSize(87, 19)
	buyoutSort:SetText("Buyout")
	
	-- AuctionHere_PercentSort
	local percentSort = CreateFrame("Button", "AuctionHere_PercentSort", buy, "AuctionSortButtonTemplate")
	percentSort:SetPoint("TOPLEFT", AuctionFrame, "TOPLEFT", 775, -82)
	percentSort:SetSize(31, 19)
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
			local ID = auction[6]
			local _, link = GetItemInfo(ID)
			local count = auction[1]
			local bid = math_ceil(math_max(auction[2], auction[4]) * 1.05)
			local bidCopper = bid % 100
			local bidSilver = math_floor(bid / 100) % 100
			local buyout = auction[3]
			local buyoutCopper = buyout % 100
			local buyoutSilver = math_floor(buyout / 100) % 100
			local percent = math_ceil(((buyout / count) / (prices[ID][auction[7]] or 1)) * 100)
			
			if bidCopper < 10 then
				bidCopper = "0" .. bidCopper
			end
			
			if bidSilver < 10 then
				bidSilver = "0" .. bidSilver
			end
			
			if buyoutCopper < 10 then
				buyoutCopper = "0" .. buyoutCopper
			end
			
			if buyoutSilver < 10 then
				buyoutSilver = "0" .. buyoutSilver
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
			
			_G["AuctionHere_Item" .. a .. "Name"]:SetText(link or "")
			_G["AuctionHere_Item" .. a .. "Count"]:SetText(count)
			_G["AuctionHere_Item" .. a .. "Duration"]:SetText("N/A")
			_G["AuctionHere_Item" .. a .. "Bid"]:SetText("|cffffd100" .. math_floor(bid / 10000) .. " |cffe6e6e6" .. bidSilver .. " |cffc8602c" .. bidCopper .. "|r")
			_G["AuctionHere_Item" .. a .. "Buyout"]:SetText("|cffffd100" .. math_floor(buyout / 10000) .. " |cffe6e6e6" .. buyoutSilver .. " |cffc8602c" .. buyoutCopper .. "|r")
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
