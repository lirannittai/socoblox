-- GUI + SocialService share (with fallback)
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "SocialShareGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Name = "ShareButton"
btn.Text = "Share Win"
btn.Visible = false
btn.Size = UDim2.new(0, 160, 0, 44)
btn.Position = UDim2.new(1, -172, 1, -56)
btn.BackgroundTransparency = 0.2
btn.Font = Enum.Font.GothamBold
btn.TextScaled = true
btn.Parent = gui

local fallbackFrame = Instance.new("Frame")
fallbackFrame.Visible = false
fallbackFrame.Size = UDim2.new(0, 420, 0, 100)
fallbackFrame.Position = UDim2.new(0.5, -210, 0.5, -50)
fallbackFrame.Parent = gui

local msg = Instance.new("TextBox")
msg.Size = UDim2.new(1, -20, 1, -20)
msg.Position = UDim2.new(0, 10, 0, 10)
msg.ClearTextOnFocus = false
msg.TextWrapped = true
msg.Text = "I won in Sokoban Showdown!"
msg.Parent = fallbackFrame

local function doShare()
	local canInvite = false
	pcall(function()
		canInvite = SocialService:CanSendGameInviteAsync(player)
	end)
	if canInvite then
		pcall(function()
			SocialService:PromptGameInvite(player)
		end)
	else
		fallbackFrame.Visible = true
		msg.Text = gui:GetAttribute("ShareText") or "I won in Sokoban Showdown! Beat my time!"
	end
end

btn.MouseButton1Click:Connect(function()
	doShare()
	btn.Visible = false
end)
