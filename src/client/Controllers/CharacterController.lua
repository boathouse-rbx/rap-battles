local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Logger = Knit.Logger
local Player = Knit.Player

local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Head = Character:WaitForChild("Head")
local Neck = Head:WaitForChild("Neck")

local INITIAL_NECK_C0_Y = Neck.C0.Y
local NECK_LERP_ALPHA = 0.1

local Camera = workspace.CurrentCamera

local CharacterController = Knit.CreateController { Name = "CharacterController" }

function CharacterController:KnitInit()
	self.PlayerService = Knit.GetService("PlayerService")
end

function CharacterController:UpdateNeck()
	local direction = HumanoidRootPart.CFrame:ToObjectSpace(Camera.CFrame)
	local C0 = CFrame.new(0, INITIAL_NECK_C0_Y, 0)
			* CFrame.Angles(0, -math.asin(direction.LookVector.X), 0)
			* CFrame.Angles(math.asin(direction.LookVector.Y), 0, 0)

	local newC0 = Neck.C0:Lerp(C0, NECK_LERP_ALPHA)
	Neck.C0 = newC0
end

function CharacterController:KnitStart()
	Humanoid.Died:Connect(function()
		Character = Player.Character or Player.CharacterAdded:Wait()
		HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
		Humanoid = Character:WaitForChild("Humanoid")
		Head = Character:WaitForChild("Head")
		Neck = Head:WaitForChild("Neck")
		Camera = workspace.CurrentCamera
	end)

	RunService:BindToRenderStep("UPDATE_CHARACTER", Enum.RenderPriority.Character.Value + 1, function()
		self:UpdateNeck()
	end)
end

return CharacterController
