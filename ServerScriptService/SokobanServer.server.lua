-- Core server-authoritative game logic: grid state, validation, rounds, timer, broadcasting
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local LevelStore = require(ReplicatedStorage:WaitForChild("LevelStore"))
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

-- ===== State =====
local currentLevelId = LevelStore.GetCurrentLevelId()
local RoundActive = false
local RoundStartTime = 0

-- Grid state
local width, height
local wallsSet = {} -- key "x,y" -> true
local goalsSet = {} -- key "x,y" -> true
local boxesById = {} -- id -> Vector2
local boxAtCell = {} -- key "x,y" -> id
local playerCell = {} -- userId -> Vector2
local lastPushAt = {} -- userId -> os.clock() guard (anti-spam)

local function key(x, y)
	return ("%d,%d"):format(x, y)
end
local function inBounds(v)
	return v.X >= 0 and v.X < width and v.Y >= 0 and v.Y < height
end

local function isWall(v)
	return wallsSet[key(v.X, v.Y)] == true
end
local function hasBox(v)
	return boxAtCell[key(v.X, v.Y)] ~= nil
end

local function loadLevelState(levelId)
	local lvl = LevelStore.GetLevel(levelId)
	currentLevelId = lvl.id
	width, height = lvl.width, lvl.height
	wallsSet, goalsSet, boxesById, boxAtCell = {}, {}, {}, {}

	for _, w in ipairs(lvl.walls) do
		wallsSet[key(w.X, w.Y)] = true
	end
	for _, g in ipairs(lvl.goals) do
		goalsSet[key(g.X, g.Y)] = true
	end
	for i, b in ipairs(lvl.boxes) do
		boxesById[i] = Vector2.new(b.X, b.Y)
		boxAtCell[key(b.X, b.Y)] = i
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		playerCell[plr.UserId] = Vector2.new(lvl.playerSpawn.X, lvl.playerSpawn.Y)
	end
end

local function broadcastInit()
	Remotes.RoundState:FireAllClients("Init", {
		levelId = currentLevelId,
		duration = Constants.ROUND_DURATION,
		startEpoch = os.time(),
	})
end

local function startRound()
	RoundActive = true
	RoundStartTime = os.clock()
	broadcastInit()
end

local function endRound(reason, winnerPlr, elapsedMs)
	RoundActive = false
	if winnerPlr and elapsedMs then
		Remotes.RoundState:FireAllClients("RoundEnd", {
			reason = reason,
			winner = winnerPlr.Name,
			ms = elapsedMs,
			levelId = currentLevelId,
		})
		Remotes.SubmitBestTime:Fire(winnerPlr, elapsedMs, currentLevelId)
	else
		Remotes.RoundState:FireAllClients(
			"RoundEnd",
			{ reason = reason, winner = nil, ms = nil, levelId = currentLevelId }
		)
	end

	task.delay(Constants.NEXT_ROUND_DELAY, function()
		local nextId = LevelStore.NextLevelId()
		LevelStore.LoadLevel(nextId)
		loadLevelState(nextId)
		Remotes.BuildLevel:Fire(nextId)
		startRound()
	end)
end

local function solved()
	for k, _ in pairs(goalsSet) do
		local x, y = string.match(k, "(-?%d+),(-?%d+)")
		local id = boxAtCell[key(tonumber(x), tonumber(y))]
		if not id then
			return false
		end
	end
	return true
end

task.defer(function()
	loadLevelState(currentLevelId)
	Remotes.BuildLevel:Fire(currentLevelId)
	startRound()
end)

task.spawn(function()
	while true do
		task.wait(0.25)
		if RoundActive then
			local left = Constants.ROUND_DURATION - (os.clock() - RoundStartTime)
			if left <= 0 then
				endRound("timeout", nil, nil)
			else
				Remotes.RoundState:FireAllClients("Timer", { tLeft = math.floor(left) })
			end
		end
	end
end)

Remotes.AdminReset.OnServerInvoke = function(plr, optLevelIdOrIndex)
	if RunService:IsStudio() or require(ReplicatedStorage.Constants).ADMIN_USERIDS[plr.UserId] then
		local id = optLevelIdOrIndex or LevelStore.GetCurrentLevelId()
		LevelStore.LoadLevel(id)
		loadLevelState(id)
		Remotes.BuildLevel:Fire(id)
		startRound()
		return true, ("Level reset to %s"):format(id)
	end
	return false, "Not authorized"
end

Players.PlayerAdded:Connect(function(plr)
	local lvl = LevelStore.GetLevel(currentLevelId)
	playerCell[plr.UserId] = Vector2.new(lvl.playerSpawn.X, lvl.playerSpawn.Y)
end)

Players.PlayerRemoving:Connect(function(plr)
	playerCell[plr.UserId] = nil
	lastPushAt[plr.UserId] = nil
end)

local allowedDirs = {
	["1,0"] = Vector2.new(1, 0),
	["-1,0"] = Vector2.new(-1, 0),
	["0,1"] = Vector2.new(0, 1),
	["0,-1"] = Vector2.new(0, -1),
}

local function tryMove(plr, dir)
	if not RoundActive then
		return false, "round-not-active"
	end

	local now = os.clock()
	local last = lastPushAt[plr.UserId] or 0
	if now - last < 0.1 then
		return false, "too-fast"
	end
	lastPushAt[plr.UserId] = now

	local dirKey = key(dir.X, dir.Y)
	if not allowedDirs[dirKey] then
		return false, "bad-dir"
	end

	local pCell = playerCell[plr.UserId]
	if not pCell then
		return false, "no-player-cell"
	end

	local target = pCell + dir
	if not inBounds(target) or isWall(target) then
		return false, "blocked"
	end

	if hasBox(target) then
		local nextCell = target + dir
		if not inBounds(nextCell) or isWall(nextCell) or hasBox(nextCell) then
			return false, "box-blocked"
		end
		local boxId = boxAtCell[key(target.X, target.Y)]
		boxAtCell[key(target.X, target.Y)] = nil
		boxAtCell[key(nextCell.X, nextCell.Y)] = boxId
		boxesById[boxId] = Vector2.new(nextCell.X, nextCell.Y)
		playerCell[plr.UserId] = Vector2.new(target.X, target.Y)

		local boxPart = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild(("Box_%d"):format(boxId))
		if boxPart then
			local cs = Constants.CELL_SIZE
			boxPart.CFrame = CFrame.new(Vector3.new(nextCell.X * cs, 1, nextCell.Y * cs))
		end

		Remotes.BoxMoved:FireAllClients({
			boxId = boxId,
			toCell = nextCell,
			playerUserId = plr.UserId,
			playerToCell = playerCell[plr.UserId],
			tween = Constants.TWEEN_TIME,
		})

		if solved() then
			local elapsedMs = math.floor((os.clock() - RoundStartTime) * 1000)
			endRound("solved", plr, elapsedMs)
		end

		return true, "pushed"
	else
		playerCell[plr.UserId] = Vector2.new(target.X, target.Y)
		return true, "stepped"
	end
end

Remotes.PushBoxRequest.OnServerEvent:Connect(function(plr, dir)
	local ok, msg = pcall(function()
		return tryMove(plr, dir)
	end)
	if not ok then
		warn("[Sokoban] error in tryMove:", msg)
	end
end)

Remotes.SubmitTime.OnServerInvoke = function(_, msClient, levelId)
	if not msClient or typeof(msClient) ~= "number" then
		return false, "bad-ms"
	end
	if not levelId or levelId ~= currentLevelId then
		return false, "bad-level"
	end
	return true, "queued"
end
