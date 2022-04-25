local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local Tween = Fusion.Tween

local UPDATE_RAINBOW_NAME = "UPDATE_RAINBOW_NAMETAG"
local RAINBOW_TIME = 5

local function Nametag(props)
	local rainbowColor = Value(
		ColorSequence.new(Color3.new(), Color3.new())
	)

	RunService:BindToRenderStep(UPDATE_RAINBOW_NAME, 0, function()
		local hue = os.clock() % RAINBOW_TIME / RAINBOW_TIME
		local color = Color3.fromHSV(hue, 1, 1)
		rainbowColor:set(
			ColorSequence.new(color, color)
		)
	end)

	return New "BillboardGui" {
		Adornee = props.Adornee,
		Size = UDim2.fromScale(5, 2.5),
		StudsOffset = Vector3.new(0, 3, 0),
		Parent = Knit.Player:WaitForChild("PlayerGui"),
		MaxDistance = 30,

		[Children] = {
			New "TextLabel" {
				Name = "Title",
				Font = Enum.Font.GothamSemibold,
				Text = props.Name,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextWrapped = true,
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.8),
				Size = UDim2.fromScale(1, 0.2),
			},

			New "TextLabel" {
				Name = "Rank",
				Font = Enum.Font.GothamSemibold,
				Text = string.upper(props.Rank:get()),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextWrapped = true,
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.6),
				Size = UDim2.fromScale(0.5, 0.15),

				[Children] = {
					New "UIGradient" {
						Color = if props.Rainbow then rainbowColor else props.Gradient:get(),
						Rotation = 90,
					},
				}
			},
		}
	}
end

return Nametag
