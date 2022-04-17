local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Player = Knit.Player

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local TeleportController = Knit.CreateController { Name = "TeleportController" }

local DEFAULT_OFFSET = CFrame.new(0, 3, 0)

local canCollideRecord = {}
local isTeleporting = false

local IS_ON_STAGE = false

function TeleportController:KnitInit()
	self.RoundService = Knit.GetService("RoundService")
end

function TeleportController:Teleport(cframe: CFrame, shouldBeStill: boolean)
	isTeleporting = not isTeleporting

	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and not descendant:IsDescendantOf(Character) then
			descendant.CanCollide = false
		end
	end

	local tween = TweenService:Create(Humanoid.RootPart, TweenInfo.new(0.5), {
		CFrame = cframe * DEFAULT_OFFSET
	})

	tween:Play()
	tween.Completed:Connect(function()
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant:IsA("BasePart") and not descendant:IsDescendantOf(Character) then
				descendant.CanCollide = canCollideRecord[descendant.Name]
			end
		end
	end)
end

function TeleportController:KnitStart()
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") then
			canCollideRecord[descendant.Name] = descendant.CanCollide
		end
	end

	self.RoundService.Teleport:Connect(function(cframe, shouldBeStill)
		self:Teleport(cframe, shouldBeStill)
	end)

	Humanoid.Died:Connect(function()
		Character = Player.Character or Player.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")
	end)
end

return TeleportController
