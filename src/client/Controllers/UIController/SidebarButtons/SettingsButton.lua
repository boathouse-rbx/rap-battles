local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local GetStrokeSize = require(Shared.Util.GetStrokeSize)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local State = Fusion.State
local Tween = Fusion.Tween
local Computed = Fusion.Computed

local SETTINGS_TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 1)

local SETTINGS_ICON_START_ANGLE = 0
local SETTINGS_ICON_TARGET_ANGLE = 360 / 6 -- cog has 6 teeth

local function SettingsButton(props)
	local settingsToggle = State(false)
	local settingsIconRotation = State(SETTINGS_ICON_START_ANGLE)

	local UIController = Knit.GetController("UIController")

	return {
		New "Frame" {
			Position = UDim2.fromScale(0.97, 0.6),
			Size = UDim2.fromScale(0.038, 0.062),
			BackgroundColor3 = Color3.fromRGB(49, 49, 49),
			AnchorPoint = Vector2.new(0.5, 0.5),

			[Children] = {
				New "UIStroke" {
					Color = Color3.fromRGB(33, 33, 33),
					Thickness = GetStrokeSize(4)
				},

				New "UICorner" {
					CornerRadius = UDim.new(0.15, 0)
				},

				New "UIAspectRatioConstraint" {},
				New "UIScale" {},

				New "ImageButton" {
					Size = UDim2.fromScale(0.85, 0.85),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = Global.UI.SETTINGS_ICON,

					Rotation = Tween(settingsIconRotation, SETTINGS_TWEEN_INFO),

					[OnEvent "Activated"] = function()
						settingsToggle:set(not settingsToggle:get())

						if settingsToggle:get() then
							settingsIconRotation:set(SETTINGS_ICON_TARGET_ANGLE)
						else
							settingsIconRotation:set(SETTINGS_ICON_START_ANGLE)
						end

						local toggle = settingsToggle:get()
						UIController.SettingsToggled:Fire(toggle)

						props.OnActivation()
					end
				}
			}
		}
	}
end

return SettingsButton
