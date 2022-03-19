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

local RANDOM = Random.new()
local SHOP_ICON_TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 1)

local DEFAULT_ICON_ROTATION = 0
local MAX_ICON_ROTATION = 5
local MIN_ICON_ROTATION = -5

local JINGLES = 3

local function ShopButton(props)
	local shopToggle = State(false)
	local shopIconRotation = State(0)

	local UIController = Knit.GetController("UIController")

	return {
		New "Frame" {
			Position = UDim2.fromScale(0.97, 0.5),
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

				New "UIScale" {},
				New "UIAspectRatioConstraint" {},

				New "ImageButton" {
					Size = UDim2.fromScale(0.75, 0.75),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = Global.UI.SHOP_ICON,

					Rotation = Tween(shopIconRotation, SHOP_ICON_TWEEN_INFO),

					[OnEvent "Activated"] = function(...)
						shopToggle:set(not shopToggle:get())

						for _ = 1, JINGLES do
							shopIconRotation:set(MIN_ICON_ROTATION)
							task.wait(SHOP_ICON_TWEEN_INFO.Time)
							shopIconRotation:set(MAX_ICON_ROTATION)
							task.wait(SHOP_ICON_TWEEN_INFO.Time)
						end

						local toggle = shopToggle:get()
						shopIconRotation:set(DEFAULT_ICON_ROTATION)
						UIController.ShopToggled:Fire(toggle)
						props.OnActivation(...)
					end
				}
			}
		}
	}
end

return ShopButton
