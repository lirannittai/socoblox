-- Lightweight monitors; core validation lives in SokobanServer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local lastAt = {}
local spikeCount = {}

Remotes.PushBoxRequest.OnServerEvent:Connect(function(plr, dir)
	local now = os.clock()
	local last = lastAt[plr.UserId] or 0
	local dt = now - last
	lastAt[plr.UserId] = now
	if dt < 0.07 then
		spikeCount[plr.UserId] = (spikeCount[plr.UserId] or 0) + 1
		if spikeCount[plr.UserId] % 10 == 0 then
			warn(("[AntiCheat] %s push spam (%d in a row, dt=%.3f)"):format(plr.Name, spikeCount[plr.UserId], dt))
		end
	else
		spikeCount[plr.UserId] = 0
	end
	if typeof(dir) ~= "Vector2" or (math.abs(dir.X) + math.abs(dir.Y) ~= 1) then
		warn(("[AntiCheat] %s sent invalid dir: %s"):format(plr.Name, tostring(dir)))
	end
end)
