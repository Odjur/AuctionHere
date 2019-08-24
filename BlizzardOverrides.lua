
local _, addonTable = ...

local math_ceil =  math.ceil

--[[
 -- Unkown source
 -- QueryAuctionItems(name, minLevel, maxLevel, page, isUsable, qualityIndex, getAll, exactMatch, filterData)
function QueryAuctionItems(name, minLevel, maxLevel, page, isUsable, qualityIndex, getAll, _, filterData)
	QueryAuctionItems(name, minLevel, maxLevel, page, isUsable, qualityIndex, getAll, AuctionHere_ExactMatch:GetChecked(), filterData)
end
--]]

 -- MoneyFrame.lua
function MoneyFrame_SetMaxDisplayWidth(moneyFrame, width)
	moneyFrame.maxDisplayWidth = nil
end

 -- Blizzard_AuctionUI.lua
addonTable.AuctionFrameBrowse_Reset = function(self)
	BrowseName:SetText("")
	BrowseMinLevel:SetText("")
	BrowseMaxLevel:SetText("")
	
	UIDropDownMenu_SetSelectedValue(BrowseDropDown, -1)
	
	IsUsableCheckButton:SetChecked(false)
	
	if ShowOnPlayerCheckButton:GetChecked() then
		ShowOnPlayerCheckButton:Click()
	end
	
	AuctionHere_UnitPrice:SetChecked(false)
	AuctionHere_ExactMatch:SetChecked(false)
	
	-- reset the filters
	OPEN_FILTER_LIST = {}
	
	AuctionFrameBrowse.selectedCategoryIndex = nil
	AuctionFrameBrowse.selectedSubCategoryIndex = nil
	AuctionFrameBrowse.selectedSubSubCategoryIndex = nil
	
	-- BrowseLevelSort:SetText(AuctionFrame_GetDetailColumnString(AuctionFrameBrowse.selectedCategoryIndex, AuctionFrameBrowse.selectedSubCategoryIndex))
	
	AuctionFrameFilters_Update()
	
	self:Disable()
end

 -- Blizzard_AuctionUI.lua
addonTable.BrowseResetButton_OnUpdate = function(self, elapsed)
	if 		(BrowseName:GetText() == "")
		and (BrowseMinLevel:GetText() == "")
		and (BrowseMaxLevel:GetText() == "")
		
		and (UIDropDownMenu_GetSelectedValue(BrowseDropDown) == -1)
		
		and (not IsUsableCheckButton:GetChecked())
		and (not ShowOnPlayerCheckButton:GetChecked())
		and (not AuctionHere_UnitPrice:GetChecked())
--		and (not AuctionHere_ExactMatch:GetChecked())
		
		and (not AuctionFrameBrowse.selectedCategoryIndex)
		and (not AuctionFrameBrowse.selectedSubCategoryIndex)
		and (not AuctionFrameBrowse.selectedSubSubCategoryIndex)
	then
		self:Disable()
	else
		self:Enable()
	end
end

 -- Blizzard_AuctionUI.lua
addonTable.AuctionFrameBrowse_Update = function()
	if not AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", AuctionFrameBrowse.selectedCategoryIndex) then
		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list")
		local button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount, moneyFrame, yourBidText, buyoutFrame, buyoutMoney
		local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
		local index
		local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo
		local displayedPrice, requiredBid
		BrowseBidButton:Show()
		BrowseBuyoutButton:Show()
		BrowseBidButton:Disable()
		BrowseBuyoutButton:Disable()
		
		-- Update sort arrows
		AuctionFrameBrowse_UpdateArrows()
		
		-- Show the no results text if no items found
		if numBatchAuctions == 0 then
			BrowseNoResultsText:Show()
			
			BrowseSearchCountText:Hide()
			
		--	AuctionHere_PageText:Hide()
		else
			BrowseNoResultsText:Hide()
			
		--	AuctionHere_PageText:SetText(AuctionFrameBrowse.page .. " / " .. math_ceil(totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE))
			
			local itemsMin = AuctionFrameBrowse.page * NUM_AUCTION_ITEMS_PER_PAGE + 1
			local itemsMax = itemsMin + numBatchAuctions - 1
			BrowseSearchCountText:SetText("Items " .. itemsMin .. " - " .. itemsMax .. " (" .. totalAuctions .. " total)")
			BrowseSearchCountText:Show()
		end
		
		for i = 1, NUM_BROWSE_TO_DISPLAY do
			index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
			button = _G["BrowseButton" .. i]
			local shouldHide = index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page))
			if not shouldHide then
				name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =  GetAuctionItemInfo("list", offset + i)
				
				-- Bug  145328
				if not hasAllInfo then
					shouldHide = true
				end
			end
			
			-- Show or hide auction buttons
			if shouldHide then
				button:Hide()
			else
				button:Show()
				buttonName = "BrowseButton" .. i
				duration = GetAuctionItemTimeLeft("list", offset + i)
				
				-- Resize button if there isn't a scrollbar
				buttonHighlight = _G["BrowseButton" .. i .. "Highlight"]
				
				if numBatchAuctions < NUM_BROWSE_TO_DISPLAY then
					button:SetWidth(625)
					buttonHighlight:SetWidth(591)
					BrowseCurrentBidSort:SetWidth(207)
				elseif (numBatchAuctions == NUM_BROWSE_TO_DISPLAY) and (totalAuctions <= NUM_BROWSE_TO_DISPLAY) then
					button:SetWidth(625)
					buttonHighlight:SetWidth(591)
					BrowseCurrentBidSort:SetWidth(207)
				else
					button:SetWidth(600)
					buttonHighlight:SetWidth(567)
					BrowseCurrentBidSort:SetWidth(184)
				end
				
				-- Set name and quality color
				color = ITEM_QUALITY_COLORS[quality]
				
				itemName = _G[buttonName .. "Name"]
				itemName:SetText(name)
				itemName:SetVertexColor(color.r, color.g, color.b)
				local itemButton = _G[buttonName .. "Item"]
				SetItemButtonQuality(itemButton, quality, itemId)
				
				-- Set level
				if (levelColHeader == "REQ_LEVEL_ABBR") and (level > UnitLevel("player")) then
					_G[buttonName .. "Level"]:SetText(RED_FONT_COLOR_CODE .. level .. FONT_COLOR_CODE_CLOSE)
				else
					_G[buttonName .. "Level"]:SetText(level)
				end
				
				-- Set closing time
				_G[buttonName .. "ClosingTimeText"]:SetText(AuctionFrame_GetTimeLeftText(duration))
				_G[buttonName .. "ClosingTime"].tooltip = AuctionFrame_GetTimeLeftTooltipText(duration)
				
				-- Set item texture, count, and usability
				iconTexture = _G[buttonName .. "ItemIconTexture"]
				iconTexture:SetTexture(texture)
				
				if not canUse then
					iconTexture:SetVertexColor(1.0, 0.1, 0.1)
				else
					iconTexture:SetVertexColor(1.0, 1.0, 1.0)
				end
				
				itemCount = _G[buttonName .. "ItemCount"]
				
				if count > 1 then
					itemCount:SetText(count)
					itemCount:Show()
				else
					itemCount:Hide()
				end
				
				-- Set high bid
				moneyFrame = _G[buttonName .. "MoneyFrame"]
				
				-- If not bidAmount set the bid amount to the min bid
				if bidAmount == 0 then
					displayedPrice = minBid
					requiredBid = minBid
				else
					displayedPrice = bidAmount
					requiredBid = bidAmount + minIncrement
				end
				
				MoneyFrame_Update(moneyFrame:GetName(), displayedPrice)
				yourBidText = _G[buttonName .. "YourBidText"]
				
				if highBidder then
					yourBidText:Show()
				else
					yourBidText:Hide()
				end
				
				if requiredBid >= MAXIMUM_BID_PRICE then
					-- Lie about our buyout price
					buyoutPrice = requiredBid
				end
				
				buyoutFrame = _G[buttonName .. "BuyoutFrame"]
				
				if buyoutPrice > 0 then
					moneyFrame:SetPoint("RIGHT", button, "RIGHT", 10, 8)
					buyoutMoney = _G[buyoutFrame:GetName() .. "Money"]
					MoneyFrame_Update(buyoutMoney, buyoutPrice)
					buyoutFrame:Show()
				else
					moneyFrame:SetPoint("RIGHT", button, "RIGHT", 10, 0)
					buyoutFrame:Hide()
				end
				
				-- Set high bidder
				-- if not highBidder then
				--     highBidder = RED_FONT_COLOR_CODE .. NO_BIDS .. FONT_COLOR_CODE_CLOSE
				-- end
				local highBidderFrame = _G[buttonName .. "HighBidder"]
				highBidderFrame.fullName = ownerFullName
				highBidderFrame.Name:SetText(owner)
				
				-- this is for comparing to the player name to see if they are the owner of this auction
				local ownerName
				
				if not ownerFullName then
					ownerName = owner
				else
					ownerName = ownerFullName
				end
				
				button.bidAmount = displayedPrice
				button.buyoutPrice = buyoutPrice
				button.itemCount = count
				button.itemIndex = index
				
				-- Set highlight
				if GetSelectedAuctionItem("list") and ((offset + i) == GetSelectedAuctionItem("list")) then
					button:LockHighlight()
					
					if (buyoutPrice > 0) and (buyoutPrice >= minBid) then
						local canBuyout = 1
						
						if GetMoney() < buyoutPrice then
							if not highBidder or GetMoney() + bidAmount < buyoutPrice then
								canBuyout = nil
							end
						end
						
						if canBuyout and (ownerName ~= UnitName("player")) then
							BrowseBuyoutButton:Enable()
							AuctionFrame.buyoutPrice = buyoutPrice
						end
					else
						AuctionFrame.buyoutPrice = nil
					end
					
					-- Set bid
					MoneyInputFrame_SetCopper(BrowseBidPrice, requiredBid)
					
					if not highBidder and ownerName ~= UnitName("player") and GetMoney() >= MoneyInputFrame_GetCopper(BrowseBidPrice) and MoneyInputFrame_GetCopper(BrowseBidPrice) <= MAXIMUM_BID_PRICE then
						BrowseBidButton:Enable()
					end
				else
					button:UnlockHighlight()
				end
			end
		end
		
		-- Update scrollFrame
		-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
		if totalAuctions > NUM_AUCTION_ITEMS_PER_PAGE then
			BrowsePrevPageButton.isEnabled = (AuctionFrameBrowse.page ~= 0)
			BrowseNextPageButton.isEnabled = (AuctionFrameBrowse.page ~= (math_ceil(totalAuctions / NUM_AUCTION_ITEMS_PER_PAGE) - 1))
		else
			BrowsePrevPageButton.isEnabled = false
			BrowseNextPageButton.isEnabled = false
		end
		
		FauxScrollFrame_Update(BrowseScrollFrame, numBatchAuctions, NUM_BROWSE_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT)
	end
end
