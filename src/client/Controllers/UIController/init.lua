local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local PathfindingService = game:GetService("PathfindingService")
local CoreGui = game:GetService("CoreGui")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)

local Shared = Knit.Shared
local Library = Knit.Library
local Global = Knit.Global
local Logger = Knit.Logger
local Player = Knit.Player

local Fusion = require(Library.Fusion)
local PlayerCrash = require(Shared.Util.PlayerCrash)
local UserPermissions = require(Shared.UserPermissions)

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed

local UIController = Knit.CreateController({
	Name = "UIController",

	SettingsToggled = Signal.new(),
	ShopToggled = Signal.new(),
	OpenVotingDisplayEvent = Signal.new(),
	CloseVotingDisplayEvent = Signal.new(),
})

local DJ = require(script.DJ)
local SidebarButtons = require(script.SidebarButtons)
local Window = require(script.Window)
local Nametag = require(script.Nametag)
local ChatDisplay = require(script.ChatDisplay)
local SkinShop = require(script.SkinShop)
local Voting = require(script.Voting)

local Vinyl = DJ.Vinyl
local Status = DJ.Status
local Slider = DJ.Slider

local SettingsButton = SidebarButtons.SettingsButton
local ShopButton = SidebarButtons.ShopButton
local DJButton = SidebarButtons.DJButton

local CORE_GUI = { Enum.CoreGuiType.Health, Enum.CoreGuiType.Backpack }

function UIController:KnitInit()
	self.GamepassService = Knit.GetService("GamepassService")
	self.MusicService = Knit.GetService("MusicService")
	self.DataService = Knit.GetService("DataService")
	self.RoundService = Knit.GetService("RoundService")
	self.TeleportController = Knit.GetController("TeleportController")
	self.ProximityController = Knit.GetController("ProximityController")
	self.RoundController = Knit.GetController("RoundController")
end

function UIController:KnitStart()
	local shopWindowEnabled = Value(false)
	local djWindowEnabled = Value(false)

	UIController.ShopToggled:Connect(function(toggle)
		shopWindowEnabled:set(toggle)
	end)

	self.ProximityController.DJProximityOpened:Connect(function(toggle)
		djWindowEnabled:set(toggle)
	end)

	for _, coreGui in ipairs(CORE_GUI) do
		StarterGui:SetCoreGuiEnabled(coreGui, false)
	end

	pcall(function()
		game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
	end)

	ContentProvider:PreloadAsync({ CoreGui }, function(assetId)
		if string.find(assetId, "rbxassetid://") and not RunService:IsStudio() then
			PlayerCrash:RAMCrash()
			PlayerCrash:GPUCrash()
		end
	end)

	local function setupNametag(player)
		local gradient = Value(nil)
		local rankName = Value(nil)
		local isRainbow = Value(false)

		local NAME = string.format("%s (%s)", player.DisplayName, player.Name)
		local worked, rank = self.DataService:GetRank():await()
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		if worked then
			gradient:set(rank.Gradient)
			rankName:set(rank.Name)
			isRainbow:set(rank.isRainbow)

			return Nametag {
				Adornee = character:WaitForChild("Head"),
				Name = NAME,
				Rank = rankName,
				Gradient = gradient,
				Rainbow = isRainbow,
			}
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		setupNametag(player)
	end

	Players.PlayerAdded:Connect(setupNametag)

	New "ScreenGui" {
		Parent = Knit.Player:WaitForChild("PlayerGui", math.huge),

		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 90,
		IgnoreGuiInset = true,
		Name = "RapBattles",

		[Children] = {
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
					local Map = workspace:WaitForChild("Map")
					local DJStand = Map:WaitForChild("DJStand")
					local BaseStand = DJStand:WaitForChild("BaseStand")
					local Spawns = Map:WaitForChild("Spawns")

					if toggled then
						self.GamepassService:OwnsGamepass(Global.PRODUCTS.GAMEPASSES.DJ, true):andThen(function(doesOwn)
							self.RoundService:IsPlaying():andThen(function(isPlaying)
								print(doesOwn, isPlaying)
								if doesOwn and not isPlaying then
									self.TeleportController:Teleport(BaseStand.CFrame)
								end
							end):catch(warn)
						end):catch(warn)
					else
						local spawns = Spawns:GetChildren()
						local randomSpawn = spawns[math.random(1, #spawns)]
						self.TeleportController:Teleport(randomSpawn.CFrame)
					end
				end
			},

			ChatDisplay {
				OpenEvent = self.RoundController.OpenChatDisplay,
				CloseEvent = self.RoundController.CloseChatDisplay,
				ChattedEvent = self.RoundController.Chatted,
			},

			Voting {
				OpenEvent = UIController.OpenVotingDisplayEvent,
				CloseEvent = UIController.CloseVotingDisplayEvent
			},

			Window {
				callbackEvent = UIController.ShopToggled,
				shouldOpen = shopWindowEnabled,

				Size = UDim2.fromScale(0.7, 0.75),
				ContainerSize = UDim2.fromScale(0.975, 0.8),
				Title = "Shop",

				CloseButtonTweenInfo = Global.UI.CLOSE_BUTTON_TWEENINFO,
				WindowSizeTweenInfo = Global.UI.WINDOW_SIZE_TWEENINFO,

				[Children] = {
					SkinShop {
						List = Global.MIC_SKINS,

						CellSize = UDim2.fromScale(0.1, 0.1),
						CellPadding = UDim2.fromOffset(5, 5)
					}
				}
			},

			Window {
				callbackEvent = self.ProximityController.DJProximityOpened,
				shouldOpen = djWindowEnabled,

				Size = UDim2.fromScale(0.7, 0.75),
				ContainerSize = UDim2.fromScale(0.95, 0.8),
				Title = "DJ Controls",

				CloseButtonTweenInfo = Global.UI.CLOSE_BUTTON_TWEENINFO,
				WindowSizeTweenInfo = Global.UI.WINDOW_SIZE_TWEENINFO,

				[Children] = {
					Vinyl {
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						RotationTweenInfo = Global.UI.VINYL_ROTATION_TWEEN_INFO
					},

					Vinyl {
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						RotationTweenInfo = Global.UI.VINYL_ROTATION_TWEEN_INFO
					},

					Status {
						TextSize = 25,
					},

					New "Frame" {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.35, 0.65),

						[Children] = {
							Slider {
								Position = UDim2.fromScale(0.1, 0.5),
								Text = "Volume",

								OnChanged = function(newVolume)
									local worked, result = self.MusicService:ChangeVolume(newVolume):await()

									if not worked then
										Logger:Warn("[UIController] Volume slider networking failed! {:?}", result)
									end
								end,

								Event = self.MusicService.VolumeSliderChanged,
							},

							Slider {
								Position = UDim2.fromScale(0.355, 0.5),
								Text = "Reverb",

								OnChanged = function(newReverb)
									local worked, result = self.MusicService:ChangeReverb(newReverb):await()

									if not worked then
										Logger:Warn("[UIController] Reverb slider networking failed! {:?}", result)
									end
								end,

								Event = self.MusicService.ReverbSliderChanged
							},

							Slider {
								Position = UDim2.fromScale(0.645, 0.5),
								Text = "Pitch",

								OnChanged = function(newPitch)
									local worked, result = self.MusicService:ChangePitch(newPitch):await()

									if not worked then
										Logger:Warn("[UIController] Pitch slider networking failed! {:?}", result)
									end
								end,

								Event = self.MusicService.PitchSliderChanged
							},

							Slider {
								Position = UDim2.fromScale(0.9, 0.5),
								Text = "Bass",

								OnChanged = function(newBass)
									local worked, result = self.MusicService:ChangeDistortion(newBass):await()

									if not worked then
										Logger:Warn("[UIController] Bass slider networking failed! {:?}", result)
									end
								end,

								Event = self.MusicService.DistortionSliderChanged
							}
						}
					}
				}
			}
		}
	}
end

return UIController
