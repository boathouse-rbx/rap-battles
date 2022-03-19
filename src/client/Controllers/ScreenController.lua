local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared

local ViewportHandler = require(Shared.ViewportHandler)

local ScreenController = Knit.CreateController { Name = "ScreenController" }

local Camera = workspace.CurrentCamera

local Atmosphere = Lighting:WaitForChild("Atmosphere")
local Map = workspace:WaitForChild("Map")

local FOV = 70

function ScreenController:CreateScreen(part, face, camera)
	local SurfaceGui = Instance.new("SurfaceGui")
	SurfaceGui.Parent = Knit.Player:WaitForChild("PlayerGui", math.huge)
	SurfaceGui.Name = "ConcertScreen"
	SurfaceGui.Adornee = part
	SurfaceGui.Face = face
	SurfaceGui.LightInfluence = 0.999
	SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	SurfaceGui.CanvasSize = Camera.ViewportSize

	local ViewportFrame = Instance.new("ViewportFrame")
	ViewportFrame.Parent = SurfaceGui
	ViewportFrame.Size = UDim2.fromScale(1, 1)
	ViewportFrame.CurrentCamera = camera

	ViewportFrame.Ambient = Atmosphere.Color
	ViewportFrame.LightColor = Atmosphere.Decay
	ViewportFrame.LightDirection = Lighting:GetSunDirection()

	local handler = ViewportHandler.new(ViewportFrame)

	local function onPlayerAdded(player)
		local character = player.Character or player.CharacterAdded:Wait()

		if character:WaitForChild("Humanoid") then
			handler:RenderHumanoid(character)
		end
	end

	for _, object in ipairs(Map:GetDescendants()) do
		if object:IsA("BasePart") then
			handler:RenderObject(object)
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
end

function ScreenController:KnitStart()
	local ViewportCamera = Instance.new("Camera")
	ViewportCamera.Parent = workspace
	ViewportCamera.Name = "Screen"
	ViewportCamera.FieldOfView = FOV
	ViewportCamera.CFrame = workspace.Part.CFrame

	local Stage = Map:WaitForChild("Stage")
	local Screen = Stage:WaitForChild("InnerScreen")
	self:CreateScreen(Screen, Enum.NormalId.Left, ViewportCamera)
end

return ScreenController
