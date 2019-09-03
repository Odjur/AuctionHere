
local _, addonTable = ...

local C_Timer_After = C_Timer.After
local math_ceil = math.ceil
local math_min = math.min
local string_find = string.find
local string_match = string.match
local string_sub = string.sub
local string_gmatch = string.gmatch
local table_sort = table.sort
local table_concat = table.concat
local pairs = pairs
local select = select
local collectgarbage = collectgarbage

local wipe = wipe
local debugprofilestop = debugprofilestop
local GetServerTime = GetServerTime
local CanSendAuctionQuery = CanSendAuctionQuery
local GetNumAuctionItems = GetNumAuctionItems
local GetAuctionItemInfo = GetAuctionItemInfo
local GetAuctionItemLink = GetAuctionItemLink

local function Clear()
	local AuctionHere_scans = AuctionHere_scans
	
	wipe(AuctionHere_scans)
end

addonTable.Clear = Clear

do
	local before
	local N_stacks
	local stacks
	local N_buyouts
	local buyouts
	local _, position
	local limit
	local price
	local index
	
	-- Return the requested price for an item in a limited time range
	local function GetPrice(item, stat, range)
		before = debugprofilestop()
		
		-- itemLinks only for now
		local item = item
		local stat = stat
		local range = range
		local AuctionHere_scans = AuctionHere_scans
		N_stacks = 0
		stacks = {}
		N_buyouts = 0
		buyouts = {}
		
		for a, b in pairs(AuctionHere_scans) do
			if a > range then
				_, position = string_find(b, item)
				
				if position then
					position = position + 1
					limit = string_find(b, "%$", position)
					
					for c in string_gmatch(string_sub(b, position, limit), "%d+") do
						N_stacks = N_stacks + 1
						stacks[N_stacks] = c
					end
					
					position = string_find(b, "%%", limit)
					limit = string_find(b, "%^", position)
					
					for c in string_gmatch(string_sub(b, position, limit), "%d+") do
						N_buyouts = N_buyouts + 1
						buyouts[N_buyouts] = c
					end
				end
			end
		end
		
		if N_buyouts > 0 then
			if stat == 1 then
				-- mean
				price = 0
				
				for a = 1, N_buyouts do
					price = price + (buyouts[a] / stacks[a])
				end
				
				price = math_ceil(price / N_buyouts)
			elseif stat == 2 then
				-- median
				for a = 1, N_buyouts do
					buyouts[a] = buyouts[a] / stacks[a]
				end
				
				table_sort(buyouts)
				
				position = N_buyouts / 2
				
				if N_buyouts % 2 > 0 then
					price = math_ceil(buyouts[math_ceil(position)])
				else
					price = math_ceil((buyouts[position] + buyouts[position + 1]) / 2)
				end
			elseif stat == 3 then
				-- mode (smallest)
				for a = 1, N_buyouts do
					buyouts[a] = buyouts[a] / stacks[a]
				end
				
				table_sort(buyouts)
				
				N_stacks = N_buyouts + 1
				
				for a = 1, N_buyouts do
					if buyouts[a] > 0 then
						N_stacks = a
						
						break
					end
				end
				
				price = 0
				stacks = 0
				position = 0
				limit = 0
				
				for a = N_stacks, N_buyouts do
					index = buyouts[a]
					
					if index > position then
						if limit > stacks then
							price = position
							stacks = limit
						end
						
						position = index
						limit = 1
					else
						limit = limit + 1
					end
				end
			end
		end
		
		print("GetPrice benchmark (ms): " .. debugprofilestop() - before)
		
		return price
	end
	
	addonTable.GetPrice = GetPrice
end

local data
local total
local before

local Save

do
	local values
	local offset
	local ID
	local link
	local index
	
	-- Save the scanned data to disk
	Save = function()
		values = {}
		
		for a = 1, total do
			offset = (a - 1) * 7
			ID = data[offset + 6]
			
			if not values[ID] then
				values[ID] = {}
			end
			
			ID = values[ID]
			link = data[offset + 7]
			
			if not ID[link] then
				ID[link] = {{"#"}, {"$"}, {"%"}, {"^"}, {"&"}, 1}
			end
			
			link = ID[link]
			index = link[6] + 1
			
			for b = 1, 5 do
				link[b][index] = data[offset + b]
			end
			
			link[6] = index
		end
		
		data = nil
		collectgarbage()
		
		offset = 0
		local data = {}
		
		for a, b in pairs(values) do
			offset = offset + 1
			data[offset] = "!"
			offset = offset + 1
			data[offset] = a
			
			for c, d in pairs(b) do
				offset = offset + 1
				data[offset] = "@"
				offset = offset + 1
				data[offset] = c
				ID = d[6]
				
				for e = 1, 5 do
					index = d[e]
					offset = offset + 1
					data[offset] = index[1]
					
					for f = 2, ID - 1 do
						offset = offset + 1
						data[offset] = index[f]
						offset = offset + 1
						data[offset] = ","
					end
					
					offset = offset + 1
					data[offset] = index[ID]
				end
			end
		end
		
		values = nil
		collectgarbage()
		
		data = table_concat(data)
		local AuctionHere_scans = AuctionHere_scans
		offset = GetServerTime()
		
		if AuctionHere_scans[offset] then
			print("Save failed due to preexisting timestamp")
			
			return
		end
		
		AuctionHere_scans[offset] = data
		
		print("Scan benchmark (ms): " .. debugprofilestop() - before)
	end
end

do
	local limit
	local batch
	local position
	local iterations
	local index
	local indices
	local _, stack, bid, buyout, offer, seller, ID
	local N_incomplete
	local incomplete
	local segment
	local complete
	local attempts
	
	local ScanControl
	
	-- Recursively call GetAuctionItemLink on each auction
	local function ScanLink()
		limit = math_min(batch, position + iterations)
		
		for a = position, limit do
			index = indices[a]
			ID = GetAuctionItemLink("list", index)
			
			if ID then
				data[index * 7] = string_match(ID, "%l+:[%-?%d+:]+")
			else
				N_incomplete = N_incomplete + 1
				incomplete[N_incomplete] = index
			end
		end
		
		if limit == batch then
			if N_incomplete == 0 then
				ScanControl()
				
				return
			end
			
			if batch == N_incomplete then
				if attempts * N_incomplete > 100000 then
					print("ScanLink failed with " .. N_incomplete .. " auctions remaining")
					
					return
				end
				
				attempts = attempts + 1
			else
				attempts = 1
			end
			
			batch = N_incomplete
			iterations = 10000
			position = 1
			indices = incomplete
			N_incomplete = 0
			incomplete = {}
		else
			position = limit + 1
		end
		
		C_Timer_After(0, ScanLink)
	end
	
	-- Recursively call GetAuctionItemInfo on each auction
	local function ScanInfo()
		limit = math_min(batch, position + iterations)
		
		for a = position, limit do
			index = indices[a]
			-- name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, highBidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo
			_, _, stack, _, _, _, _, bid, _, buyout, offer, _, _, seller, _, _, ID = GetAuctionItemInfo("list", index)
			
			if seller and stack and bid and buyout and offer and ID then
				index = index * 7 - 6
				data[index] = stack
				
				if bid == buyout then
					data[index + 1] = 0
				else
					data[index + 1] = bid
				end
				
				data[index + 2] = buyout
				data[index + 3] = offer
				data[index + 4] = seller
				data[index + 5] = ID
			else
				N_incomplete = N_incomplete + 1
				incomplete[N_incomplete] = index
			end
		end
		
		if limit == batch then
			if N_incomplete == 0 then
				batch = segment
				position = 1
				indices = complete
				
				-- GetAuctionItemTimeLeft is bugged; skip it
				ScanLink()
				
				return
			end
			
			if batch == N_incomplete then
				if attempts * N_incomplete > 100000 then
					print("ScanInfo failed with " .. N_incomplete .. " auctions remaining")
					
					return
				end
				
				attempts = attempts + 1
			else
				attempts = 1
			end
			
			batch = N_incomplete
			position = 1
			indices = incomplete
			N_incomplete = 0
			incomplete = {}
		else
			position = limit + 1
		end
		
		C_Timer_After(0, ScanInfo)
	end
	
	-- Scan the current auction house page
	ScanControl = function()
		batch = GetNumAuctionItems("list")
		
		if batch > total then
			segment = batch - total
			
			for a = 1, segment do
				indices[a] = total + a
			end
			
			total = batch
			batch = segment
			position = 1
			iterations = 1000
			complete = indices
			
			ScanInfo()
		else
			if CanSendAuctionQuery() and GetNumAuctionItems("list") == total then
				Save()
			else
				C_Timer_After(0, ScanControl)
			end
		end
	end
	
	-- Initialize the scanning resources
	local function Scan()
		before = debugprofilestop()
		indices = {}
		data = {}
		N_incomplete = 0
		incomplete = {}
		attempts = 1
		total = 0
		
		ScanControl()
	end
	
	addonTable.Scan = Scan
	
	-- Search the entire auction house at once
	local function GetAll()
		if select(2, CanSendAuctionQuery()) then
			AuctionFrameBrowse:UnregisterEvent("AUCTION_ITEM_LIST_UPDATE")
			
			-- QueryAuctionItems(name, minLevel, maxLevel, page, isUsable, qualityIndex, getAll, exactMatch, filterData)
			QueryAuctionItems("", nil, nil, 0, false, 0, true, false, nil)
			
			Scan()
		end
	end

	addonTable.GetAll = GetAll
end
