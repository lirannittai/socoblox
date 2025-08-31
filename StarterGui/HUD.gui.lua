-- Creates minimal HUD (ScreenGui + labels + admin reset button)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "HUDGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(0, 200, 0, 40)
timerLabel.Position = UDim2.new(0, 12, 0, 12)
timerLabel.BackgroundTransparency = 0.35
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.GothamBold
timerLabel.Text = "⏱ 180s"
timerLabel.Parent = gui

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0, 400, 0, 120)
statusLabel.Position = UDim2.new(0, 12, 0, 58)
statusLabel.BackgroundTransparency = 0.35
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 16
statusLabel.Text = "Welcome to Sokoban Showdown!"
statusLabel.Parent = gui

if RunService:IsStudio() then
	local resetBtn = Instance.new("TextButton")
	resetBtn.Name = "ResetBtn"
	resetBtn.Text = "Reset Level"
	resetBtn.Size = UDim2.new(0, 140, 0, 40)
	resetBtn.Position = UDim2.new(0, 12, 0, 184)
	resetBtn.Parent = gui
	resetBtn.MouseButton1Click:Connect(function()
		local ok, msg = Remotes.AdminReset:InvokeServer()
		statusLabel.Text = ok and ("[Admin] " .. (msg or "reset ok")) or ("[Admin] " .. (msg or "reset failed"))
	end)

	local nextBtn = Instance.new("TextButton")
	nextBtn.Name = "NextBtn"
	nextBtn.Text = "Next Level"
	nextBtn.Size = UDim2.new(0, 140, 0, 40)
	nextBtn.Position = UDim2.new(0, 160, 0, 184)
	nextBtn.Parent = gui
	nextBtn.MouseButton1Click:Connect(function()
		local ok, msg = Remotes.AdminReset:InvokeServer()
		statusLabel.Text = ok and ("[Admin] " .. (msg or "reset ok")) or ("[Admin] " .. (msg or "reset failed"))
	end)
end
