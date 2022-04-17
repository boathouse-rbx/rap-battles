local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local SliderUtil = require(Shared.Util.Slider)
local GetStrokeSize = require(Shared.Util.GetStrokeSize)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local State = Fusion.State
local Tween = Fusion.Tween
local OnChange = Fusion.OnChange

local function Slider(props)
	local nozzle = State(
		New "ImageButton" {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(26, 26, 26),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(2.5, 0.075),

			[Children] = {
				New "UICorner" {
					CornerRadius = UDim.new(0.4, 0),
				},
			}
		}
	)

	local container = State(
		New "Frame" {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(33, 33, 33),
			Position = props.Position,
			Size = UDim2.fromScale(0.075, 1),

			[Children] = {
				New "UICorner" {
					CornerRadius = UDim.new(0.35, 0),
				},

				New "TextLabel" {
					Font = Enum.Font.GothamBlack,
					Text = props.Text,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 1.05),
					Size = UDim2.fromScale(3, 0.1),

					[Children] = {
						New "UIStroke" {
							LineJoinMode = Enum.LineJoinMode.Bevel,
							Thickness = GetStrokeSize(1.5),
						},

						New "UIGradient" {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
								ColorSequenceKeypoint.new(0.8, Color3.fromRGB(165, 163, 165)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(145, 145, 145)),
							}),

							Rotation = 90,
						},

						New "UITextSizeConstraint" {
							MaxTextSize = 15,
							MinTextSize = 5
						}
					}
				},

				nozzle:get()
			}
		}
	)

	local sliderComponent, onChanged = SliderUtil.new(
		container:get(),
		nozzle:get(),
		1,
		0,
		false,
		props.OnChanged
	)

	props.Event:Connect(function(result)
		if result then
			sliderComponent:Set(result, true)
		end
	end)

	return {
		container:get()
	}
end

return Slider
