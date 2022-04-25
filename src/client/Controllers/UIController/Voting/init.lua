local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local GetStrokeSize = require(Shared.Util.GetStrokeSize)
local Promise = require(Knit.Util.Promise)

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local Tween = Fusion.Tween
local Computed = Fusion.Computed

local Button = require(script.Button)

local CLOSED_POSITION = UDim2.fromScale(-0.5, 0.5)
local OPEN_POSITION = UDim2.fromScale(0.5, 0.5)

local DEFAULT_PROFILE = "rbxasset://textures/ui/GuiImagePlaceholder.png"

local function getProfilePicture(userId)
	return Promise.async(function(resolve, reject)
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
		end)

		if success then
			resolve(result)
		else
			reject(result)
		end
	end)
end

local function Voting(props)
	local position = Value(CLOSED_POSITION)

	local firstPlayerProfile = Value(DEFAULT_PROFILE)
	local secondPlayerProfile = Value(DEFAULT_PROFILE)
	local firstPlayerId = Value(0)
	local secondPlayerId = Value(0)

	local RoundService = Knit.GetService("RoundService")

	props.OpenEvent:Connect(function(firstPlayer, secondPlayer)
		position:set(OPEN_POSITION)

		getProfilePicture(firstPlayer):andThen(function(profile)
			firstPlayerProfile:set(profile)
			firstPlayerId:set(firstPlayer)
		end):catch(warn)

		getProfilePicture(secondPlayer):andThen(function(profile)
			secondPlayerProfile:set(profile)
			secondPlayerId:set(firstPlayer)
		end):catch(warn)
	end)

	props.CloseEvent:Connect(function()
		position:set(CLOSED_POSITION)
	end)

	return {
		New "Frame" {
			Size = UDim2.fromScale(0.19, 0.165),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = Tween(position, Global.UI.VOTING_DISPLAY_POSITION_TWEENINFO),
			BackgroundColor3 = Color3.fromRGB(49, 49, 49),

			[Children] = {
				New "UICorner" {
					CornerRadius = UDim.new(1, 0)
				},

				New "UIAspectRatioConstraint" {
					AspectRatio = 2
				},

				New "UIStroke" {
					Thickness = GetStrokeSize(4),
					Color = Color3.fromRGB(33, 33, 33)
				},

				New "TextLabel" {
					Font = Enum.Font.GothamBold,
					Text = "Vote!",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 20,
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.01),
					Size = UDim2.fromScale(1, 0.2),
				},

				New "Frame" {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(206, 206, 206),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.005, 0.45),
				},

				Button {
					ProfilePicture = firstPlayerProfile,
					Position = UDim2.fromScale(0.25, 0.5),
					Callback = function()
						RoundService:Vote(firstPlayerId:get()):await()
					end
				},

				Button {
					ProfilePicture = secondPlayerProfile,
					Position = UDim2.fromScale(0.75, 0.5),
					Callback = function()
						RoundService:Vote(secondPlayerId:get()):await()
					end
				}
			}
		}
	}
end

return Voting
