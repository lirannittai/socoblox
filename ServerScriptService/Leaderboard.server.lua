-- Persists per-player best times and maintains a global Top-10 using OrderedDataStore
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Remotes   = require(ReplicatedStorage:WaitForChild("Remotes"))

local BestDs = DataStoreService:GetDataStore(Constants.DATASTORE_NAME)
local function OrderedFor(levelId) return DataStoreService:GetOrderedDataStore(Constants.ORDERED_NAME_PREFIX .. tostring(levelId)) end

local lastSaveAt = {}

local function saveBestTime(plr, ms, levelId)
	local now = os.time()
	if lastSaveAt[plr.UserId] and now - lastSaveAt[plr.UserId] < 10 then return end
	lastSaveAt[plr.UserId] = now

	local key = ("p_%d"):format(plr.UserId)
	local best
	local ok1, err1 = pcall(function()
		best = BestDs:GetAsync(key)
	end)
	if not ok1 then warn("[Leaderboard] GetAsync failed:", err1) end
	if not best or ms < (best and best.ms or math.huge) then
		local ok2, err2 = pcall(function()
			BestDs:SetAsync(key, { ms = ms, levelId = levelId, when = now, name = plr.Name })
		end)
		if not ok2 then warn("[Leaderboard] SetAsync failed:", err2) end
	end

	local ods = OrderedFor(levelId)
	local ok3, err3 = pcall(function()
		ods:SetAsync(("u_%d"):format(plr.UserId), -ms)
	end)
	if not ok3 then warn("[Leaderboard] Ordered SetAsync failed:", err3) end

	task.spawn(function()
		local top = {}
		local ok4, pages = pcall(function()
			return ods:GetSortedAsync(true, 10)
		end)
		if ok4 and pages then
			local items = pages:GetCurrentPage()
			for i,entry in ipairs(items) do
				local uid = tonumber(string.match(entry.key, "u_(%d+)")) or 0
				local name = ("User %d"):format(uid)
				for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
					if p.UserId == uid then name = p.Name break end
				end
				top[i] = { rank = i, name = name, ms = -entry.value }
			end
		end
		Remotes.RoundState:FireAllClients("Leaderboard", top)
	end)
end

Remotes.SubmitBestTime.Event:Connect(function(plr, ms, levelId)
	if typeof(ms)~="number" or typeof(levelId)~="string" then return end
	saveBestTime(plr, ms, levelId)
end)
