local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local State = Fusion.State
local Tween = Fusion.Tween
local OnChange = Fusion.OnChange

local DEFAULT_BUTTON_POSITION = UDim2.fromScale(0.5, 0.5)
local DEFAULT_CONTAINER_SIZE = UDim2.fromScale(0.075, 1)

local function Slider(props)
	local dragging = State(false)
	local position = State(DEFAULT_BUTTON_POSITION)

	local realContainerSize = State(DEFAULT_CONTAINER_SIZE)
	local realContainerPosition = State(nil)

	return {
		New "Frame" {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(33, 33, 33),
			Position = props.Position,
			Size = UDim2.fromScale(0.075, 1),

			[OnChange "AbsoluteSize"] = function(size)
				realContainerSize:set(size)
			end,

			[OnChange "AbsolutePosition"] = function(position)
				realContainerPosition:set(position)
			end,

			[Children] = {
				New "UICorner" {
					CornerRadius = UDim.new(0.35, 0),
				},

				New "ImageButton" {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(26, 26, 26),
					Position = position,
					Size = UDim2.fromScale(2.5, 0.075),

					[OnEvent "InputBegan"] = function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
							dragging:set(true)

							input.Changed:Connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									dragging:set(false)
								end
							end)
						end
					end,

					[Children] = {
						New "UICorner" {
							CornerRadius = UDim.new(0.4, 0),
						},
					}
				}
			}
		}
	}
end

return Slider
