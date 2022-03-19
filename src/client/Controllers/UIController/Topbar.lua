local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local Camera = workspace.CurrentCamera

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local New = Fusion.New
local State = Fusion.State
local Children = Fusion.Children
local Tween = Fusion.Tween

local TOPBAR_X_SIZE = 0.35
local TOPBAR_X_POSITION = 0.5

local Y_OFFSET = 5

local function Topbar(props)
	local RoundController = Knit.GetController("RoundController")

	local initialInset = GuiService:GetGuiInset()

	local size = State(
		UDim2.new(TOPBAR_X_SIZE, 0, 0, initialInset.Y + Y_OFFSET)
	)

	local position = State(
		UDim2.new(TOPBAR_X_POSITION, 0, 0, initialInset.Y)
	)

	local maxVisibleGraphemes = State(0)
	local text = State(Global.ROUND_MESSAGES.IDLE)

	RoundController.NotificationSent:Connect(function(message)
		maxVisibleGraphemes:set(0)
		text:set(message)
		maxVisibleGraphemes:set(
			utf8.len(message)
		)
	end)

	RoundController.NotificationDeleted:Connect(function()
		maxVisibleGraphemes:set(0)
	end)

	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local inset = GuiService:GetGuiInset()

		size:set(
			UDim2.new(TOPBAR_X_SIZE, 0, 0, inset.Y + Y_OFFSET)
		)

		position:set(
			UDim2.new(TOPBAR_X_POSITION, 0, 0, inset.Y)
		)
	end)

	return {
		New "Frame" {
			ZIndex = -math.huge,
			BackgroundColor3 = Color3.fromRGB(),
			BackgroundTransparency = 0.5,
			AnchorPoint = Vector2.new(0.5, 1),

			Size = size,
			Position = position,

			[Children] = {
				New "UICorner" {
					CornerRadius = UDim.new(0.2, 0)
				},

				New "TextLabel" {
					Text = text,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.GothamSemibold,
					TextSize = 16,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.95, 1),

					MaxVisibleGraphemes = Tween(maxVisibleGraphemes, props.TypewriterTweenInfo)
				}
			}
		}
	}
end

return Topbar
