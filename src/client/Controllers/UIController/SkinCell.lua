local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local Fusion = require(ReplicatedStorage.Library.Fusion)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Shared = Knit.Shared
local Global = Knit.Global

local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Tween = Fusion.Tween
local Value = Fusion.Value
local Observer = Fusion.Observer
local Computed = Fusion.Computed

local GetStrokeSize = require(Shared.Util.GetStrokeSize)
local ViewportModel = require(Shared.Util.ViewportModel)

local TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
local INITIAL_OFFSET = Vector2.new(-2, 0)
local OFFSET_GOAL = Vector2.new(2, 0)

-- many sacrifices were made.

local function SkinCell(props)
	local offset = Value(INITIAL_OFFSET)
	local shouldAnimate = Value(true)
	local text = Value(props.Text)
	local offsetObserver = Observer(offset)

	local clone = props.Model:Clone()
	clone.PrimaryPart.TextureID = props.Texture

	local viewportFrameChildren = Value({
		clone,

		New "UICorner" {
			CornerRadius = UDim.new(0.2, 0)
		},

		New "UIGradient" {
			Rotation = 45,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(
					0,
					Color3.fromRGB(33, 33, 33)
				),

				ColorSequenceKeypoint.new(
					0.5,
					Color3.fromRGB(255, 255, 255)
				),

				ColorSequenceKeypoint.new(
					1,
					Color3.fromRGB(33, 33, 33)
				)
			}),

			Offset = Tween(offset, TWEEN_INFO),
			Transparency = NumberSequence.new(0.4),
		},

		New "TextLabel" {
			BackgroundTransparency = 1,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			ZIndex = 2,
			Size = UDim2.fromScale(1, 0.2),
			Text = text,
		}
	})

	local camera = New "Camera" {
		FieldOfView = 70,
	}

	local viewport = Value({
		New "ViewportFrame" {
			ZIndex = 2,
			BackgroundColor3 = Color3.fromRGB(33, 33, 33),
			Name = props.Name,
			ClipsDescendants = true,
			CurrentCamera = camera,
			Ambient = Color3.fromRGB(255, 255, 255),
			LightColor = Color3.fromRGB(255, 255, 255),
			LightDirection = Vector3.new(),

			[OnEvent "InputBegan"] = function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or Enum.UserInputType.Touch then
					if input.UserInputState == Enum.UserInputState.Begin then
						props.OnActivation()
					end
				end
			end,

			[OnEvent "MouseEnter"] = function()
				offset:set(OFFSET_GOAL)
				shouldAnimate:set(true)

				if props.HoverTextEnabled then
					text:set(props.HoverText)
				end
			end,

			[OnEvent "MouseLeave"] = function()
				offset:set(INITIAL_OFFSET)
				shouldAnimate:set(false)

				if props.HoverTextEnabled then
					text:set(props.Text)
				end
			end,

			[Children] = viewportFrameChildren:get()
		}
	})

	local theta = 0

	local model = props.Model
	local frame = viewport:get()[1]
	local vpfModel = ViewportModel.new(frame, camera)
	local cframe, size = model:GetBoundingBox()
	local distance = vpfModel:GetFitDistance(cframe.Position)
	local orientation = CFrame.new()

	camera.Parent = frame
	camera.FieldOfView = 1
	vpfModel:SetModel(props.Model)

	RunService.RenderStepped:Connect(function(deltaTime)
		theta += math.rad(20 * deltaTime)
		orientation = CFrame.fromEulerAnglesYXZ(math.rad(-20), theta, 0)
		camera.CFrame = CFrame.new(cframe.Position) * orientation * CFrame.new(0, 0, distance * 15)
	end)

	offsetObserver:onChange(function()
		if offset:get() == OFFSET_GOAL then
			task.wait(2.5)
			offset:set(INITIAL_OFFSET)
		end
	end)

	return frame
end

return SkinCell
