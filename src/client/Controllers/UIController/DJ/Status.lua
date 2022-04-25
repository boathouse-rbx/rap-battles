local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local GetStrokeSize = require(Shared.Util.GetStrokeSize)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value

local function Status(props)
	local MusicService = Knit.GetService("MusicService")
	local text = Value("Now Playing - Unknown")

	MusicService.Playing:Connect(function(name)
		if not name then
			text:set("Now Playing - Unknown")
		end

		text:set("Now Playing - " .. name)
	end)

	return {
		New "TextLabel" {
			Text = text,
			Font = Enum.Font.GothamBlack,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = props.TextSize,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.1),

			[Children] = {
				New "UIStroke" {
					LineJoinMode = Enum.LineJoinMode.Bevel,
					Thickness = GetStrokeSize(2),
				},

				New "UIGradient" {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
						ColorSequenceKeypoint.new(0.8, Color3.fromRGB(165, 163, 165)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(145, 145, 145)),
					}),

					Rotation = 90,
				},
			}
		}
	}
end

return Status
