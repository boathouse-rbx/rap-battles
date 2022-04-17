local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)

local Global = Knit.Global

local ProximityController = Knit.CreateController {
	Name = "ProximityController",

	DJProximityOpened = Signal.new(),
	DJControlsOpen = false
}

function ProximityController:KnitInit()
	self.GamepassService = Knit.GetService("GamepassService")
end

function ProximityController:CreatePrompt(parent, title, description, distance, duration, key)
	local proximity = Instance.new("ProximityPrompt")
	proximity.HoldDuration = duration
	proximity.MaxActivationDistance = distance
	proximity.ObjectText = description
	proximity.ActionText = title
	proximity.KeyboardKeyCode = key or Enum.KeyCode.E
	proximity.Parent = parent

	return proximity
end

function ProximityController:SetupDJ()
	local info = Global.PROXIMITY_PROMPTS.DJ

	local Map = workspace:WaitForChild("Map")
	local DJStand = Map:WaitForChild("DJStand")
	local BaseStand = DJStand:WaitForChild("BaseStand")

	local djProximity = self:CreatePrompt(
		BaseStand,
		info.TITLE,
		info.DESCRIPTION,
		info.DISTANCE,
		info.DURATION,
		info.KEY
	)

	djProximity.Triggered:Connect(function()
		self.DJControlsOpen = not self.DJControlsOpen
		self.DJProximityOpened:Fire(self.DJControlsOpen)
	end)
end

function ProximityController:KnitStart()
	local success, OwnsGamepass = self.GamepassService:OwnsGamepass(
		Global.PRODUCTS.GAMEPASSES.DJ,
		false
	):await()

	if success and OwnsGamepass then
		self:SetupDJ()
	end

	self.GamepassService.GamepassBought:Connect(function(id)
		if id == Global.PRODUCTS.GAMEPASSES.DJ then
			self:SetupDJ()
		end
	end)

	self.DJProximityOpened:Connect(function(toggle)
		self.DJControlsOpen = toggle
	end)
end

return ProximityController
