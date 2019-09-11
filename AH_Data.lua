
local _, addonTable = ...

local C_Timer_After = C_Timer.After
local math_floor = math.floor
local math_ceil = math.ceil
local math_min = math.min
local string_match = string.match
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local table_sort = table.sort
local table_concat = table.concat
local pairs = pairs
local tonumber = tonumber
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
		
		AuctionHere_data.state.snapshot = nil
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
		local ID
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
					-- itemLinks only for now
					local buyouts = {}
					range = stamp - values[2] * 86400
					excluded = values[3]
					included = values[4]
					
					for b, c in pairs(scans) do
						if (b > range and not excluded[b]) or included[b] then
							for d in string_gmatch(c, "%![^%!]+") do
								ID = tonumber(string_match(d, "%d+"))
								
								if not buyouts[ID] then
									buyouts[ID] = {}
								end
								
								ID = buyouts[ID]
								
								for e in string_gmatch(d, "%@[^%@]+") do
									link = string_match(e, "%d*:%d*")
									
									if not ID[link] then
										ID[link] = {1}
									end
									
									link = ID[link]
									index = link[1]
									position = index
									
									for f in string_gmatch(string_match(e, "%#[^%$]+"), "%d+") do
										index = index + 1
										link[index] = f
									end
									
									index = position
									
									for f in string_gmatch(string_match(e, "%%[^%^]+"), "%d+") do
										index = index + 1
										link[index] = f / link[index]
									end
									
									link[1] = index
								end
							end
						end
					end
					
					range = values[5]
					
					if range == 1 then
						-- median
						for b, c in pairs(buyouts) do
							for d, e in pairs(c) do
								excluded = e[1]
								e[1] = e[excluded]
								e[excluded] = nil
								excluded = excluded - 1
								
								table_sort(e)
								
								included = 0
								
								for f = 1, excluded do
									if e[f] > 0 then
										included = f
										
										break
									end
								end
								
								if included > 0 then
									range = (excluded + included) / 2
									
									if (excluded - included) % 2 > 0 then
										range = math_floor(range)
										c[d] = math_ceil((e[range] + e[range + 1]) / 2)
									else
										c[d] = math_ceil(e[range])
									end
								else
									c[d] = nil
								end
							end
						end
					elseif range == 2 then
						-- mean
						for b, c in pairs(buyouts) do
							for d, e in pairs(c) do
								excluded = 0
								included = 0
								
								for f = 2, e[1] do
									range = e[f]
									
									if range > 0 then
										excluded = excluded + range
										included = included + 1
									end
								end
								
								if included > 0 then
									c[d] = math_ceil(excluded / included)
								else
									c[d] = nil
								end
							end
						end
					elseif stat == 3 then
						-- mode (lowest)
						for b, c in pairs(buyouts) do
							for d, e in pairs(c) do
								excluded = e[1]
								e[1] = e[excluded]
								e[excluded] = nil
								excluded = excluded - 1
								
								table_sort(e)
								
								range = nil
								
								for f = 1, excluded do
									link = e[f]
									
									if link > 0 then
										ID = 0
										index = 1
										
										for g = f + 1, excluded do
											position = e[g]
											
											if position > link then
												if index > ID then
													range = link
													ID = index
												end
												
												link = position
												index = 1
											else
												index = index + 1
											end
										end
										
										if index > ID then
											range = link
										end
										
										range = math_ceil(range)
										
										break
									end
								end
								
								c[d] = range
							end
						end
					end
					
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
			AuctionHere_data.state.snapshot = stamp
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
		local _, count, bid, buyout, offer, seller, ID
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
					-- item:itemId:enchantId:gemId1:gemId2:gemId3:gemId4:suffixId:uniqueId:linkLevel:specializationID:upgradeId:instanceDifficultyId:numBonusIds:bonusId1:bonusId2:upgradeValue
					data[index][7] = string_gsub(ID, ".+m:%d-:(%d-):%d-:%d-:%d-:%d-(:%d*).+", "%1%2")
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
				_, _, count, _, _, _, _, bid, _, buyout, offer, _, _, seller, _, _, ID = GetAuctionItemInfo("list", index)
				
				if seller and count and bid and buyout and offer and ID then
					if bid == buyout then
						bid = 0
					end
					
					data[index] = {count, bid, buyout, offer, seller, ID}
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
					local AuctionHere_data = AuctionHere_data
					AuctionHere_data.state.getAll = GetServerTime()
					
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
			-- QueryAuctionItems(name, minLevel, maxLevel, page, isUsable, qualityIndex, getAll, exactMatch, filterData)
			QueryAuctionItems("", nil, nil, 0, false, 0, true, false, nil)
			
			Scan()
		end
		
		addonTable.GetAll = GetAll
	end
end
