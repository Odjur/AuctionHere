
local _, addonTable = ...

local math_floor = math.floor
local math_ceil = math.ceil
local math_min = math.min
local math_max = math.max
local string_match = string.match
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local table_sort = table.sort
local table_concat = table.concat
local pairs = pairs
local tonumber = tonumber
local collectgarbage = collectgarbage
local coroutine_yield = coroutine.yield

local wipe = wipe
local debugprofilestop = debugprofilestop
local GetServerTime = GetServerTime
local GetItemInfo = GetItemInfo
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
		
		addonTable.status = "Data cleared"
	end
	
	addonTable.Clear = Clear
end

do
	local results
	local snapshot
	local prices
	local indexA
	local indexB
	local priceA
	local priceB
	
	local function Sort(criteria, invert, price)
		results = addonTable.snapshot
		local AuctionHere_data = AuctionHere_data
		snapshot = AuctionHere_data.snapshot
		
		if criteria == 1 then
			-- Name
			if invert then
				table_sort(results, function(a, b)
					return (GetItemInfo(snapshot[a][6]) or "") > (GetItemInfo(snapshot[b][6]) or "")
				end)
			else
				table_sort(results, function(a, b)
					return (GetItemInfo(snapshot[a][6]) or "") < (GetItemInfo(snapshot[b][6]) or "")
				end)
			end
		elseif criteria == 2 then
			-- Count
			if invert then
				table_sort(results, function(a, b)
					return snapshot[a][1] > snapshot[b][1]
				end)
			else
				table_sort(results, function(a, b)
					return snapshot[a][1] < snapshot[b][1]
				end)
			end
		elseif criteria == 3 then
			-- Duration
			if invert then
				table_sort(results, function(a, b)
					return (snapshot[a][8] or 5) > (snapshot[b][8] or 5)
				end)
			else
				table_sort(results, function(a, b)
					return (snapshot[a][8] or 5) < (snapshot[b][8] or 5)
				end)
			end
		elseif criteria == 4 then
			-- Bid
			if invert then
				table_sort(results, function(a, b)
					indexA = snapshot[a]
					indexB = snapshot[b]
					
					priceA = indexA[2]
					priceB = indexB[2]
					
					if priceA == 0 then
						priceA = indexA[3]
					else
						priceA = math_max(priceA, math_ceil(indexA[4] * 1.05))
					end
					
					if priceB == 0 then
						priceB = indexB[3]
					else
						priceB = math_max(priceB, math_ceil(indexB[4] * 1.05))
					end
					
					return priceA > priceB
				end)
			else
				table_sort(results, function(a, b)
					indexA = snapshot[a]
					indexB = snapshot[b]
					
					priceA = indexA[2]
					priceB = indexB[2]
					
					if priceA == 0 then
						priceA = indexA[3]
					else
						priceA = math_max(priceA, math_ceil(indexA[4] * 1.05))
					end
					
					if priceB == 0 then
						priceB = indexB[3]
					else
						priceB = math_max(priceB, math_ceil(indexB[4] * 1.05))
					end
					
					return priceA < priceB
				end)
			end
		elseif criteria == 5 then
			-- Buyout
			if invert then
				table_sort(results, function(a, b)
					return snapshot[a][3] > snapshot[b][3]
				end)
			else
				table_sort(results, function(a, b)
					priceA = snapshot[a][3]
					priceB = snapshot[b][3]
					
					if priceA == 0 then
						priceA = 12345678901
					end
					
					if priceB == 0 then
						priceB = 12345678901
					end
					
					return priceA < priceB
				end)
			end
		elseif criteria == 6 then
			-- Bid Percent
			prices = AuctionHere_data.prices[price]
			
			if invert then
				table_sort(results, function(a, b)
					indexA = snapshot[a]
					indexB = snapshot[b]
					
					priceA = indexA[2]
					priceB = indexB[2]
					
					if priceA == 0 then
						priceA = indexA[3]
					end
					
					if priceB == 0 then
						priceB = indexB[3]
					end
					
					return ((priceA / indexA[1]) / (prices[indexA[6]][indexA[7]] or 1)) > ((priceB / indexB[1]) / (prices[indexB[6]][indexB[7]] or 1))
				end)
			else
				table_sort(results, function(a, b)
					indexA = snapshot[a]
					indexB = snapshot[b]
					
					priceA = indexA[2]
					priceB = indexB[2]
					
					if priceA == 0 then
						priceA = indexA[3]
					end
					
					if priceB == 0 then
						priceB = indexB[3]
					end
					
					return ((priceA / indexA[1]) / (prices[indexA[6]][indexA[7]] or 1)) < ((priceB / indexB[1]) / (prices[indexB[6]][indexB[7]] or 1))
				end)
			end
		elseif criteria == 7 then
			-- Buyout Percent
			prices = AuctionHere_data.prices[price]
			
			if invert then
				table_sort(results, function(a, b)
					indexA = snapshot[a]
					indexB = snapshot[b]
					
					return ((indexA[3] / indexA[1]) / (prices[indexA[6]][indexA[7]] or 1)) > ((indexB[3] / indexB[1]) / (prices[indexB[6]][indexB[7]] or 1))
				end)
			else
				table_sort(results, function(a, b)
					indexA = snapshot[a]
					indexB = snapshot[b]
					
					priceA = indexA[3]
					priceB = indexB[3]
					
					if priceA == 0 then
						priceA = 12345678901
					end
					
					if priceB == 0 then
						priceB = 12345678901
					end
					
					return ((priceA / indexA[1]) / (prices[indexA[6]][indexA[7]] or 1)) < ((priceB / indexB[1]) / (prices[indexB[6]][indexB[7]] or 1))
				end)
			end
		end
	end
	
	addonTable.Sort = Sort
end

do
	local throttle
	local settings_iterations
	
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
			addonTable.status = "Updating prices"
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
					throttle = 0
					
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
									
									throttle = throttle + 1
									
									if throttle % settings_iterations == 0 then
										coroutine_yield()
									end
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
								
								throttle = throttle + 1
								
								if throttle % settings_iterations == 0 then
									coroutine_yield()
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
								
								throttle = throttle + 1
								
								if throttle % settings_iterations == 0 then
									coroutine_yield()
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
								
								throttle = throttle + 1
								
								if throttle % settings_iterations == 0 then
									coroutine_yield()
								end
							end
						end
					end
					
					prices[values[6]] = buyouts
				end
			end
			
			collectgarbage()
			
			addonTable.status = "Scan complete"
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
			addonTable.status = "Saving data"
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
				
				if a % settings_iterations == 0 then
					coroutine_yield()
				end
			end
			
			total = 0
			auction = {}
			throttle = 0
			
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
					
					throttle = throttle + 1
					
					if throttle % settings_iterations == 0 then
						coroutine_yield()
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
			
			addonTable.task = UpdatePrices
		end
	end
	
	do
		local batch
		local index
		local indices
		local _, count, bid, buyout, offer, seller, ID
		local N_incomplete
		local incomplete
		local iterations
		local segment
		local complete
		local attempts
		local settings
		local settings_attempts
		
		-- Scan the current auction house page
		local function Scan()
			-- Initialize scanning resources
			stamp = GetServerTime()
			addonTable.status = "Scanning"
			indices = {}
			data = {}
			N_incomplete = 0
			incomplete = {}
			total = 0
			
			local AuctionHere_data = AuctionHere_data
			settings = AuctionHere_data.settings
			settings_iterations = settings.iterations
			settings_attempts = settings.attempts
			
			while true do
				batch = GetNumAuctionItems("list")
				
				if batch > total then
					segment = batch - total
					
					for a = 1, segment do
						indices[a] = total + a
					end
					
					total = batch
					batch = segment
					iterations = settings_iterations
					complete = indices
					attempts = 1
					
					-- Call GetAuctionItemInfo on each auction
					while true do
						for a = 1, batch do
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
							
							if a % iterations == 0 then
								coroutine_yield()
							end
						end
						
						coroutine_yield()
						
						if N_incomplete > 0 then
							if batch == N_incomplete then
								if attempts * N_incomplete > iterations * settings_attempts then
									addonTable.status = "Scan failed with " .. N_incomplete .. " remaining"
									
									return
								end
								
								attempts = attempts + 1
							else
								attempts = 1
							end
							
							batch = N_incomplete
							indices = incomplete
							N_incomplete = 0
							incomplete = {}
						else
							break
						end
					end
					
					batch = segment
					indices = complete
					attempts = 1
					
					-- GetAuctionItemTimeLeft is bugged; skip it
					
					-- Call GetAuctionItemLink on each auction
					while true do
						for a = 1, batch do
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
							
							if a % iterations == 0 then
								coroutine_yield()
							end
						end
						
						if N_incomplete > 0 then
							if batch == N_incomplete then
								if attempts * N_incomplete > iterations * settings_attempts then
									addonTable.status = "Scan failed with " .. N_incomplete .. " remaining"
									
									return
								end
								
								attempts = attempts + 1
							else
								attempts = 1
							end
							
							batch = N_incomplete
							indices = incomplete
							N_incomplete = 0
							incomplete = {}
							iterations = settings_iterations * 10
							
							coroutine_yield()
						else
							break
						end
					end
				end
				
				if CanSendAuctionQuery() and GetNumAuctionItems("list") == total then
					break
				else
					coroutine_yield()
				end
			end
			
			AuctionHere_data.state.getAll = GetServerTime()
			
			addonTable.task = Save
		end
		
		addonTable.Scan = Scan
	end
end
