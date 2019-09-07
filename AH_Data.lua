
local _, addonTable = ...

local C_Timer_After = C_Timer.After
local math_floor = math.floor
local math_ceil = math.ceil
local math_min = math.min
local string_match = string.match
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

do
	local scans
	local prices
	local snapshot
	
	-- Delete scanned data saved to disk
	local function Clear()
		local AuctionHere_data = AuctionHere_data
		scans = AuctionHere_data.scans
		prices = AuctionHere_data.prices
		snapshot = AuctionHere_data.snapshot
		
		wipe(scans)
		wipe(prices)
		wipe(snapshot)
		collectgarbage()
	end
	
	addonTable.Clear = Clear
end

do
	local UpdatePrices
	
	do
		local stamp
		local prices
		local settings_prices
		local scans
		local values
		local range
		local excluded
		local included
		local link
		local index
		local position
		
		-- Calculate prices for each enabled price source
		UpdatePrices = function()
			stamp = GetServerTime()
			local AuctionHere_data = AuctionHere_data
			prices = AuctionHere_data.prices
			
			wipe(prices)
			collectgarbage()
			
			settings_prices = AuctionHere_data.settings.prices
			scans = AuctionHere_data.scans
			
			for a = 1, #settings_prices do
				values = settings_prices[a]
				
				if values[1] then
					local buyouts = {}
					range = stamp - values[2] * 86400
					excluded = values[3]
					included = values[4]
					
					for b, c in pairs(scans) do
						if (b > range and not excluded[b]) or included[b] then
							-- itemLinks only for now
							for d in string_gmatch(c, "%@[^%!%@]+") do
								link = string_match(d, "%l+:[%-%d:]+")
								
								if not buyouts[link] then
									buyouts[link] = {1}
								end
								
								link = buyouts[link]
								index = link[1]
								position = index
								
								for e in string_gmatch(string_match(d, "%#[^%$]+"), "%d+") do
									index = index + 1
									link[index] = e
								end
								
								index = position
								
								for e in string_gmatch(string_match(d, "%%[^%^]+"), "%d+") do
									index = index + 1
									link[index] = e / link[index]
								end
								
								link[1] = index
							end
						end
					end
					
					range = values[5]
					
					if range == 1 then
						-- mean
						for b, c in pairs(buyouts) do
							excluded = 0
							included = 0
							
							for d = 2, c[1] do
								link = c[d]
								
								if link > 0 then
									excluded = excluded + link
									included = included + 1
								end
							end
							
							if included > 0 then
								buyouts[b] = math_ceil(excluded / included)
							else
								buyouts[b] = 0
							end
						end
					elseif range == 2 then
						-- median
						for b, c in pairs(buyouts) do
							excluded = c[1]
							c[1] = 0
							
							table_sort(c)
							
							included = 0
							
							for d = 2, excluded do
								if c[d] > 0 then
									included = d
									
									break
								end
							end
							
							if included > 0 then
								link = (excluded + included) / 2
								
								if (excluded - included) % 2 > 0 then
									link = math_floor(link)
									buyouts[b] = math_ceil((c[link] + c[link + 1]) / 2)
								else
									buyouts[b] = math_ceil(c[link])
								end
							else
								buyouts[b] = 0
							end
						end
					end
					
					--[[
					-- work in progress
					
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
					--]]
					
					prices[values[6]] = buyouts
				end
			end
			
			collectgarbage()
			
			print("Finished the getall search, scanning, saving and updating prices")
		end
	end
	
	local data
	local total
	local stamp
	
	local Save
	
	do
		local values
		local auction
		local ID
		local link
		local index
		local scans
		
		-- Save the scanned data to disk
		Save = function()
			values = {}
			
			for a = 1, total do
				auction = data[a]
				ID = auction[6]
				
				if not values[ID] then
					values[ID] = {}
				end
				
				ID = values[ID]
				link = auction[7]
				
				if not ID[link] then
					ID[link] = {{"#"}, {"$"}, {"%"}, {"^"}, {"&"}, 1}
				end
				
				link = ID[link]
				index = link[6] + 1
				
				for b = 1, 5 do
					link[b][index] = auction[b]
				end
				
				link[6] = index
			end
			
			total = 0
			auction = {}
			
			for a, b in pairs(values) do
				total = total + 1
				auction[total] = "!"
				total = total + 1
				auction[total] = a
				
				for c, d in pairs(b) do
					total = total + 1
					auction[total] = "@"
					total = total + 1
					auction[total] = c
					ID = d[6]
					link = ID - 1
					
					for e = 1, 5 do
						index = d[e]
						total = total + 1
						auction[total] = index[1]
						
						for f = 2, link do
							total = total + 1
							auction[total] = index[f]
							total = total + 1
							auction[total] = ","
						end
						
						total = total + 1
						auction[total] = index[ID]
					end
				end
			end
			
			values = nil
			collectgarbage()
			
			auction = table_concat(auction)
			local AuctionHere_data = AuctionHere_data
			scans = AuctionHere_data.scans
			scans[stamp] = auction
			AuctionHere_data.snapshot = data
			
			collectgarbage()
			
			UpdatePrices()
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
				-- _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name
				ID = GetAuctionItemLink("list", index)
				
				if ID then
					data[index][7] = string_match(ID, "%l+:[%-%d:]+")
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
					index = data[index]
					index[1] = stack
					
					if bid == buyout then
						index[2] = 0
					else
						index[2] = bid
					end
					
					index[3] = buyout
					index[4] = offer
					index[5] = seller
					index[6] = ID
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
				
				for a = total + 1, batch do
					data[a] = {}
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
			stamp = GetServerTime()
			indices = {}
			data = {}
			N_incomplete = 0
			incomplete = {}
			attempts = 1
			total = 0
			
			ScanControl()
		end
		
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
end
