-- Handles input, sends push requests, visual tween via ghost clones, HUD hooks
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local player = Players.LocalPlayer

local function cellToWorld(cell)
	local cs = Constants.CELL_SIZE
	return Vector3.new(cell.X * cs, 1, cell.Y * cs)
end

local function getBoxPart(id)
	local map = workspace:FindFirstChild("Map")
	if not map then
		return nil
	end
	return map:FindFirstChild(("Box_%d"):format(id))
end

local function tweenBoxTo(id, toCell, duration)
	local real = getBoxPart(id)
	if not real then
		return
	end

	local ghost = real:Clone()
	ghost.Name = ("Box_%d_Ghost"):format(id)
	ghost.Parent = workspace
	ghost.Anchored = true
	ghost.CanCollide = false

	real.LocalTransparencyModifier = 1

	ghost.CFrame = real.CFrame
	local targetCF = CFrame.new(cellToWorld(toCell))
	local tw = TweenService:Create(
		ghost,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = targetCF }
	)
	tw:Play()
	tw.Completed:Connect(function()
		if ghost then
			ghost:Destroy()
		end
		if real then
			real.LocalTransparencyModifier = 0
		end
	end)
end

local function toDir(inputState, inputObj)
	if inputState ~= Enum.UserInputState.Begin then
		return
	end
	local key = inputObj.KeyCode
	local dir
	if key == Enum.KeyCode.W or key == Enum.KeyCode.Up then
		dir = Vector2.new(0, -1)
	elseif key == Enum.KeyCode.S or key == Enum.KeyCode.Down then
		dir = Vector2.new(0, 1)
	elseif key == Enum.KeyCode.A or key == Enum.KeyCode.Left then
		dir = Vector2.new(-1, 0)
	elseif key == Enum.KeyCode.D or key == Enum.KeyCode.Right then
		dir = Vector2.new(1, 0)
	end
	if dir then
		Remotes.PushBoxRequest:FireServer(dir)
	end
end

ContextActionService:BindAction(
	"SokobanMove",
	toDir,
	false,
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Up,
	Enum.KeyCode.Down,
	Enum.KeyCode.Left,
	Enum.KeyCode.Right
)

Remotes.RoundState.OnClientEvent:Connect(function(kind, payload)
	if kind == "Timer" then
		local gui = player:FindFirstChildOfClass("PlayerGui")
		if gui then
			local hud = gui:FindFirstChild("HUDGui")
			if hud and hud:FindFirstChild("TimerLabel") then
				hud.TimerLabel.Text = ("⏱ %ds"):format(payload.tLeft or 0)
			end
		end
	elseif kind == "RoundEnd" then
		local gui = player:FindFirstChildOfClass("PlayerGui")
		if gui then
			local share = gui:FindFirstChild("SocialShareGui")
			if share and share:FindFirstChild("ShareButton") then
				share.ShareButton.Visible = true
				share:SetAttribute(
					"ShareText",
					("I won %s on %s in %.2fs! Come beat my time!"):format(
						payload.levelId or "",
						Constants.GAME_NAME,
						(payload.ms or 0) / 1000
					)
				)
			end
		end
	elseif kind == "Leaderboard" then
		local gui = player:FindFirstChildOfClass("PlayerGui")
		if gui then
			local hud = gui:FindFirstChild("HUDGui")
			if hud and hud:FindFirstChild("StatusLabel") then
				local lines = {}
				for _, row in ipairs(payload or {}) do
					table.insert(lines, ("%d) %s — %.2fs"):format(row.rank, row.name, (row.ms or 0) / 1000))
				end
				hud.StatusLabel.Text = (#lines > 0 and table.concat(lines, "\n")) or "No records yet"
			end
		end
	end
end)

Remotes.BoxMoved.OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" then
		return
	end
	tweenBoxTo(data.boxId, data.toCell, data.tween or Constants.TWEEN_TIME)
end)
