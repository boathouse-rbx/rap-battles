local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local State = Fusion.State
local Tween = Fusion.Tween

local DEFAULT_ROTATION = 1

local function Vinyl(props)
	local rotation = State(DEFAULT_ROTATION)

	RunService:BindToRenderStep("UPDATE_VINYL_ROTATION", 0, function()
		rotation:set(rotation:get() + 1)
		task.wait()
	end)

	return {
		New "ImageLabel" {
			AnchorPoint = props.AnchorPoint,
			Position = props.Position,
			BackgroundTransparency = 1,
			Image = Global.UI.VINYL_ICON,
			Size = UDim2.fromScale(0.317, 0.576),
			Rotation = Tween(rotation, props.RotationTweenInfo),

			[Children] = {
				New "UIAspectRatioConstraint" {}
			}
		}
	}
end

return Vinyl
