local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)

local Shared = Knit.Shared
local Library = Knit.Library
local Global = Knit.Global

local Fusion = require(Library.Fusion)
local PlayerCrash = require(Shared.Util.PlayerCrash)

local New = Fusion.New
local Children = Fusion.Children
local State = Fusion.State
local Computed = Fusion.Computed

local UIController = Knit.CreateController({
	Name = "UIController",

	SettingsToggled = Signal.new(),
	ShopToggled = Signal.new(),
})

local SidebarButtons = require(script.SidebarButtons)
local Window = require(script.Window)
local Topbar = require(script.Topbar)

local SettingsButton = SidebarButtons.SettingsButton
local ShopButton = SidebarButtons.ShopButton
local DJButton = SidebarButtons.DJButton

local CORE_GUI = { Enum.CoreGuiType.Health }

function UIController:KnitInit()
	self.GamepassService = Knit.GetService("GamepassService")
	self.TeleportController = Knit.GetController("TeleportController")
	self.ProximityController = Knit.GetController("ProximityController")
end

function UIController:KnitStart()
	local shopWindowEnabled = State(false)
	local djWindowEnabled = State(false)

	UIController.ShopToggled:Connect(function(toggle)
		shopWindowEnabled:set(toggle)
	end)

	self.ProximityController.DJProximityOpened:Connect(function(toggle)
		djWindowEnabled:set(toggle)
	end)

	for _, coreGui in ipairs(CORE_GUI) do
		StarterGui:SetCoreGuiEnabled(coreGui, false)
	end

	ContentProvider:PreloadAsync({ CoreGui }, function(assetId)
		if string.find(assetId, "rbxassetid://") and not RunService:IsStudio() then
			PlayerCrash:RAMCrash()
			PlayerCrash:GPUCrash()
		end
	end)

	New "ScreenGui" {
		Parent = Knit.Player:WaitForChild("PlayerGui", math.huge),

		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 90,
		IgnoreGuiInset = true,
		Name = "RapBattles",

		[Children] = {
			Topbar {
				TypewriterTweenInfo = Global.UI.TYPEWRITER_TWEENINFO
			},

			ShopButton {
				OnActivation = function()
					shopWindowEnabled:set(true)
					UIController.ShopToggled:Fire(true)
				end
			},

			SettingsButton {
				OnActivation = function()

				end
			},

			DJButton {
				OnActivation = function(toggled)
					local success, ownsGamepass = self.GamepassService:OwnsGamepass(Global.PRODUCTS.GAMEPASSES.DJ, true):await()

					local Map = workspace:WaitForChild("Map")
					local Stage = Map:WaitForChild("Stage")
					local Spawns = Map:WaitForChild("Spawns")
					local DJStandBase = Stage:WaitForChild("DJStandBase")

					if success then
						if toggled and ownsGamepass then
							self.TeleportController:Teleport(DJStandBase.Position)
						elseif not toggled and ownsGamepass then
							local randomSpawn = Spawns:GetChildren()[math.random(1, #Spawns:GetChildren())]
							self.TeleportController:Teleport(randomSpawn.Position)
						end
					end
				end
			},

			Window {
				callbackEvent = UIController.ShopToggled,
				shouldOpen = shopWindowEnabled,

				Size = UDim2.fromScale(0.7, 0.75),
				Title = "Shop",

				CloseButtonTweenInfo = Global.UI.CLOSE_BUTTON_TWEENINFO,
				WindowSizeTweenInfo = Global.UI.WINDOW_SIZE_TWEENINFO,
			},

			Window {
				callbackEvent = self.ProximityController.DJProximityOpened,
				shouldOpen = djWindowEnabled,

				Size = UDim2.fromScale(0.7, 0.75),
				Title = "DJ Controls",

				CloseButtonTweenInfo = Global.UI.CLOSE_BUTTON_TWEENINFO,
				WindowSizeTweenInfo = Global.UI.WINDOW_SIZE_TWEENINFO,
			}
		}
	}
end

return UIController
