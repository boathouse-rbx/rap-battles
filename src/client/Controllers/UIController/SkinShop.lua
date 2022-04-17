local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global
local Assets = Knit.Assets

local New = Fusion.New
local Children = Fusion.Children
local ComputedPairs = Fusion.ComputedPairs

local SkinCell = require(script.Parent.SkinCell)

local MicMesh = Assets:WaitForChild("MicrophoneMesh")

local function SkinShop(props)
	local DataService = Knit.GetService("DataService")
	local ToolService = Knit.GetService("ToolService")

	return {
		New "ScrollingFrame" {
			Size = UDim2.fromScale(0.975, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 6,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),

			[Children] = {
				New "UIGridLayout" {
					CellSize = props.CellSize,
					CellPadding = props.CellPadding or UDim2.fromOffset(5, 5)
				},

				ComputedPairs(props.List, function(_, skin)
					local text = skin.MinWins .. " Wins"
					local hoverTextEnabled = true

					if skin.Name == "Default" then
						text = "Default"
						hoverTextEnabled = false
					end

					return SkinCell {
						Wins = skin.MinWins,
						Model = MicMesh,
						Text = skin.Name,
						HoverText = text,
						Texture = skin.Texture,
						HoverTextEnabled = hoverTextEnabled,

						OnActivation = function()
							local getWinsWorked, wins = DataService:GetWins():await()

							if getWinsWorked then
								if skin.MinWins <= wins then
									ToolService:ChangeSkin(skin.Texture):await()
								else
									print("player cant own", skin.Name)
								end
							end
						end
					}
				end)
			}
		}
	}
end

return SkinShop
