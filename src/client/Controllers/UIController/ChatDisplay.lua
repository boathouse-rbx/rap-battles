local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local GetStrokeSize = require(Shared.Util.GetStrokeSize)

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local Tween = Fusion.Tween
local Computed = Fusion.Computed

local DEFAULT_CLOSED_POSITION = UDim2.fromScale(0.5, 1.2)
local DEFAULT_OPEN_POSITION = UDim2.fromScale(0.5, 0.8)

local function ChatDisplay(props)
	local text = Value("")
	local maxVisibleGraphemes = Value(0)
	local position = Value(DEFAULT_CLOSED_POSITION)
	local info = Value(
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	)

	props.OpenEvent:Connect(function()
		position:set(DEFAULT_OPEN_POSITION)
	end)

	props.CloseEvent:Connect(function()
		position:set(DEFAULT_CLOSED_POSITION)
	end)

	props.ChattedEvent:Connect(function(message)
		local length = utf8.len(message)
		local newInfo = TweenInfo.new(
			utf8.len(message) / 10,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		)

		maxVisibleGraphemes:set(0)
		text:set(message)
		maxVisibleGraphemes:set(length)
		info:set(newInfo)
	end)

	return {
		New "Frame" {
			BackgroundColor3 = Color3.fromRGB(49, 49, 49),
			Size = UDim2.fromScale(0.75, 0.25),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = Tween(position, Global.UI.CHAT_DISPLAY_POSITION_TWEENINFO),

			[Children] = {
				New "UICorner" {
					CornerRadius = UDim.new(0.15)
				},

				New "UIStroke" {
					Color = Color3.fromRGB(33, 33, 33),
					Thickness = GetStrokeSize(4)
				},

				New "TextLabel" {
					Text = text,
					MaxVisibleGraphemes = Tween(maxVisibleGraphemes, info),

					TextWrapped = true,
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 20,
					Font = Enum.Font.GothamBold,
					Size = UDim2.fromScale(0.95, 0.95),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5)
				}
			}
		}
	}
end

return ChatDisplay
