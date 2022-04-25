local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local GetStrokeSize = require(Shared.Util.GetStrokeSize)

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Tween = Fusion.Tween
local OnChange = Fusion.OnChange

local INITIAL_BUTTON_POSITION = UDim2.fromScale(0.957, 0.067)
local END_BUTTON_POSITION = UDim2.fromScale(0.957, 0.075)

local DEFAULT_WINDOW_SIZE = UDim2.fromScale(0.7, 0.75)
local CLOSED_WINDOW_SIZE = UDim2.fromScale(0, 0)

local DEFAULT_WINDOW_POSITION = UDim2.fromScale(0.5, 0.5)

local DEFAULT_STROKE_SIZE = GetStrokeSize(4)
local DEFAULT_TITLE_STROKE_SIZE = GetStrokeSize(2)
local CLOSED_STROKE_SIZE = 0

local EMPTY_STRING = ""

local TEXT_SIZE_DIVISOR = math.pi / 2
local TITLE_TEXT_SIZE_DIVISOR = 1.1

local function Window(props)
	local windowEnabled = Value(if not props.shouldOpen then true else false)
	local windowSize = Value(if props.shouldOpen then CLOSED_WINDOW_SIZE else DEFAULT_WINDOW_SIZE)
	local windowStrokeSize = Value(if props.shouldOpen then CLOSED_STROKE_SIZE else DEFAULT_STROKE_SIZE)
	local windowPosition = Value(props.WindowPosition or DEFAULT_WINDOW_POSITION)
	local closeButtonPosition = Value(INITIAL_BUTTON_POSITION)

	local closeButtonTextSize = Value(30)
	local closeButtonText = Value(if props.shouldOpen then EMPTY_STRING else "X")

	local titleTextSize = Value(30)

	local isDragging = Value(false)
	local dragInput = Value(nil)
	local dragStart = Value(nil)
	local dragStartPosition = Value(nil)

	if props.callbackEvent then
		props.callbackEvent:Connect(function(toggle)
			windowEnabled:set(toggle)

			if windowEnabled:get() then
				windowSize:set(props.Size or DEFAULT_WINDOW_SIZE)
				windowStrokeSize:set(DEFAULT_STROKE_SIZE)
				closeButtonText:set("X")
			end
		end)
	end

	return {
		New "Frame" {
			Position = windowPosition,
			BackgroundColor3 = Color3.fromRGB(49, 49, 49),
			AnchorPoint = Vector2.new(0.5, 0.5),

			Size = Tween(windowSize, props.WindowSizeTweenInfo),
			Visible = windowEnabled,

			[OnEvent "InputBegan"] = function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
					local position = windowPosition:get()
					isDragging:set(true)
					dragStart:set(input.Position)
					dragStartPosition:set(position)

					UserInputService.InputChanged:Connect(function(input)
						if input == dragInput:get() and isDragging:get() then
							local delta = input.Position - dragStart:get()
							local start = dragStartPosition:get()
							windowPosition:set(
								UDim2.new(
									start.X.Scale,
									start.X.Offset + delta.X,
									start.Y.Scale,
									start.Y.Offset + delta.Y
								)
							)
						end
					end)

					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							isDragging:set(false)
						end
					end)
				end
			end,

			[OnEvent "InputChanged"] = function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch then
					dragInput:set(input)
				end
			end,

			[Children] = {
				New "UIStroke" {
					Color = Color3.fromRGB(33, 33, 33),
					Thickness = Tween(windowStrokeSize, props.WindowSizeTweenInfo),
				},

				New "UICorner" {
					CornerRadius = UDim.new(0.03, 0)
				},

				New "Frame" {
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.55),
					Size = props.ContainerSize or UDim2.fromScale(0.875, 0.7),

					[Children] = props[Children],
				},

				New "TextLabel" {
					Font = Enum.Font.GothamBlack,
					Text = string.upper(props.Title),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = titleTextSize,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0, 0.067),
					Size = UDim2.fromScale(0.6, 0.0827),

					[OnChange "AbsoluteSize"] = function(size)
						titleTextSize:set(size.Y / TITLE_TEXT_SIZE_DIVISOR)
					end,

					[Children] = {
					  	New "UIStroke" {
							LineJoinMode = Enum.LineJoinMode.Bevel,
							Thickness = DEFAULT_TITLE_STROKE_SIZE,
					  	},

					  	New "UIGradient" {
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
								ColorSequenceKeypoint.new(0.8, Color3.fromRGB(165, 163, 165)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(145, 145, 145)),
							}),

							Rotation = 90,
					  	},

					  	New "UIPadding" {
							PaddingLeft = UDim.new(0.05, 0),
						},
					}
				},

				New "TextButton" {
					Font = Enum.Font.GothamBlack,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 65, 65),
					ZIndex = 3,

					Size = UDim2.fromScale(0.054, 0.0827),

					Text = closeButtonText,
					TextSize = closeButtonTextSize,
					Position = Tween(closeButtonPosition, props.CloseButtonTweenInfo),

					[OnEvent "Activated"] = function()
						closeButtonPosition:set(END_BUTTON_POSITION)
						task.wait(props.CloseButtonTweenInfo.Time)
						closeButtonPosition:set(INITIAL_BUTTON_POSITION)
						task.wait(props.CloseButtonTweenInfo.Time * 2)

						windowSize:set(CLOSED_WINDOW_SIZE)
						windowStrokeSize:set(CLOSED_STROKE_SIZE)
						closeButtonText:set(EMPTY_STRING)

						task.wait(props.CloseButtonTweenInfo.Time)
						windowEnabled:set(false)

						if props.callbackEvent then
							props.callbackEvent:Fire(false)
						end
					end,

					[OnChange "AbsoluteSize"] = function(size)
						closeButtonTextSize:set(size.Y / TEXT_SIZE_DIVISOR)
					end,

					[Children] = {
					  	New "UICorner" {},
						New "UIAspectRatioConstraint" {}
					}
				},

				New "TextButton" {
					Text = "",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(157, 38, 38),
					Position = UDim2.fromScale(0.957, 0.075),
					Size = UDim2.fromScale(0.054, 0.0827),

					[Children] = {
						New "UICorner" {},
						New "UIAspectRatioConstraint" {}
					}
				},
			}
		}
	}
end

return Window
