
local _, addonTable = ...

local C_Timer_After = C_Timer.After
local math_ceil = math.ceil
local math_min = math.min
local string_find = string.find
local string_match = string.match
local string_sub = string.sub
local string_gmatch = string.gmatch
local table_concat = table.concat
local pairs = pairs
local select = select
local collectgarbage = collectgarbage

local debugprofilestop = debugprofilestop
local GetServerTime = GetServerTime
local CanSendAuctionQuery = CanSendAuctionQuery
local GetNumAuctionItems = GetNumAuctionItems
local GetAuctionItemInfo = GetAuctionItemInfo
local GetAuctionItemLink = GetAuctionItemLink

local print = addonTable.print

 -- Return the requested price for an itemLink in a limited time range
local function GetPrice(item, stat, range)
	local before = debugprofilestop()
	local stacks = {}
	local buyouts = {}
	
	local item = item
	local stat = stat
	local range = range
	local AuctionHere_scans = AuctionHere_scans
	
	for a, b in pairs(AuctionHere_scans) do
		-- itemLinks only for now
		if a > range then
			-- stacks
			local _, position = string_find(b, item)
			
			if position then
				position = position + 1
				local limit = string_find(b, "%$", position)
				local values = string_sub(b, position, limit)
				
				for c in string_gmatch(values, "%d+") do
					stacks[#stacks + 1] = c
				end
				
				-- buyouts
				position = string_find(b, "%%", limit)
				limit = string_find(b, "%^", position)
				values = string_sub(b, position, limit)
				
				for c in string_gmatch(values, "%d+") do
					buyouts[#buyouts + 1] = c
				end
			end
		end
	end
	
	local price = 0
	
	if #stacks > 0 then
		if stat == 1 then
			-- mean
			for a = 1, #stacks do
				price = price + (buyouts[a] / stacks[a])
			end
			
			price = math_ceil(price / #stacks)
		elseif stat == 2 then
			-- median
			
		elseif stat == 3 then
			-- mode
			
		end
	end
	
	print("GetPrice: " .. debugprofilestop() - before)
	
	return price
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
		
		-- print("AuctionHere | Finished searching " .. GetNumAuctionItems("list") .. " auctions")
	else
		print("AuctionHere | Cannot perform a getall search")
	end
end

addonTable.GetAll = GetAll

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
local attempts
local info
local link

 -- Save the scanned data to disk
local function Save()
	batch = {}
	
	for a = 1, #info do
		position = info[a]
		limit = position[6]
		
		if not batch[limit] then
			batch[limit] = {}
		end
		
		limit = batch[limit]
		index = link[a]
		
		if not limit[index] then
			limit[index] = { {"#"}, {"$"}, {"%"}, {"^"}, {"&"} }
		end
		
		index = limit[index]
		data = #index[1] + 1
		
		for b = 1, 5 do
			index[b][data] = position[b]
		end
	end
	
	info = nil
	link = nil
	collectgarbage()
	
	position = {}
	
	for a, b in pairs(batch) do
		position[#position + 1] = "!"
		position[#position + 1] = a
		
		for c, d in pairs(b) do
			position[#position + 1] = "@"
			position[#position + 1] = c
			
			for e = 1, 5 do
				limit = d[e]
				position[#position + 1] = limit[1]
				
				for f = 2, #limit - 1 do
					position[#position + 1] = limit[f]
					position[#position + 1] = ","
				end
				
				position[#position + 1] = limit[#limit]
			end
		end
	end
	
	position = table_concat(position)
	batch = GetServerTime()
	local AuctionHere_scans = AuctionHere_scans
	
	if AuctionHere_scans[batch] then
		print("Save failed")
		
		return
	end
	
	AuctionHere_scans[batch] = position
	
	print("Save: " .. debugprofilestop() - before)
	
	before = nil
	iterations = nil
	batch = nil
	limit = nil
	index = nil
	data = nil
	_, stack, bid, buyout, offer, seller, ID = nil, nil, nil, nil, nil, nil, nil
	indices = nil
	incomplete = nil
	attempts = nil
	collectgarbage()
end

 -- Recursively call GetAuctionItemLink on each auction
local function ScanLink()
	limit = math_min(batch, position + iterations)
	
	for a = position, limit do
		index = indices[a]
		data = GetAuctionItemLink("list", index)
		
		if data then
			link[index] = string_match(data, "%l+:[%-?%d+:]+")
		else
			incomplete[#incomplete + 1] = index
		end
	end
	
	if limit == batch then
		batch = #incomplete
		
		if batch == 0 then
			print("ScanLink: " .. debugprofilestop() - before)
			
			Save()
			
			return
		end
		
		if limit == batch then
			if attempts > 10 then
				print("ScanLink failed")
				
				return
			end
			
			attempts = attempts + 1
		else
			attempts = 1
		end
		
		iterations = 10000
		position = 1
		indices = incomplete
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
		data = info[index]
		_, _, stack, _, _, _, _, bid, _, buyout, offer, _, _, seller, _, _, ID = GetAuctionItemInfo("list", index)
		
		if stack then
			data[1] = stack
		end
		
		if bid and buyout then
			if bid == buyout then
				data[2] = 0
			else
				data[2] = bid
			end
			
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
		
		if batch == 0 then
			print("ScanInfo: " .. debugprofilestop() - before)
			
			batch = #info
			position = 1
			indices = {}
			
			for a = 1, batch do
				indices[a] = a
			end
			
			link = {}
			
			-- GetAuctionItemTimeLeft is bugged; skip it
			ScanLink()
			
			return
		end
		
		if limit == batch then
			if attempts > 10 then
				print("ScanInfo failed")
				
				return
			end
			
			attempts = attempts + 1
		else
			attempts = 1
		end
		
		position = 1
		indices = incomplete
		incomplete = {}
	else
		position = limit + 1
	end
	
	C_Timer_After(0, ScanInfo)
end

 -- Scan the current auction house page
local function Scan()
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
		attempts = 1
		
		ScanInfo()
	else
		print("AuctionHere | No auctions to save")
	end
end

addonTable.Scan = Scan
