local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local GetStrokeSize = require(Shared.Util.GetStrokeSize)

local New = Fusion.New
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

local function Button(props)
	return {
		New "ImageButton" {
			Image = props.ProfilePicture,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Position = props.Position,
			Size = UDim2.fromScale(0.75, 0.75),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,

			[OnEvent "Activated"] = props.Callback,

			[Children] = {
			  	New "UICorner" {
					CornerRadius = UDim.new(1, 0),
				},
			}
		  }
	}
end

return Button
