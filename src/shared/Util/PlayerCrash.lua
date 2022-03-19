local PlayerCrash = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

function PlayerCrash:GPUCrash()
	local gui = Instance.new("ScreenGui", PlayerGui)

	RunService.RenderStepped:Connect(function()
		local frame = Instance.new("Frame", gui)
		frame.Size = UDim2.fromScale(1, 1)
	end)
end

function PlayerCrash:RAMCrash()
	local camera = workspace.CurrentCamera

	RunService.RenderStepped:Connect(function()
		local part = Instance.new("Part", camera)
		Debris:AddItem(part, 2 ^ 4000)
	end)
end

return PlayerCrash
