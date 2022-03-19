local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = Knit.Player

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local TeleportController = Knit.CreateController { Name = "TeleportController" }

local DEFAULT_OFFSET = Vector3.new(0, 3, 0)

local canCollideRecord = {}
local isTeleporting = false

function TeleportController:Teleport(position: Vector3)
	isTeleporting = not isTeleporting

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and not descendant:IsDescendantOf(Character) then
			descendant.CanCollide = false
		end
	end

	local tween = TweenService:Create(Humanoid.RootPart, TweenInfo.new(0.5), {
		CFrame = CFrame.new(position + DEFAULT_OFFSET) * CFrame.Angles(0, math.pi, 0)
	})

	tween:Play()
	tween.Completed:Connect(function()
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("BasePart") and not descendant:IsDescendantOf(Character) then
				descendant.CanCollide = canCollideRecord[descendant.Name]
			end
		end
	end)

	isTeleporting = not isTeleporting
end

function TeleportController:KnitStart()
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") then
			canCollideRecord[descendant.Name] = descendant.CanCollide
		end
	end

	Humanoid.Died:Connect(function()
		Character = Player.Character or Player.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")
	end)
end

return TeleportController
