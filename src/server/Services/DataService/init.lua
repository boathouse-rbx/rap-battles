local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)

local Global = Knit.Global
local Logger = Knit.Logger
local Shared = Knit.Shared

local DataService = Knit.CreateService {
	Name = "DataService",
	Client = {},

	PlayerAdded = Signal.new(),

	WinsChanged = Signal.new(),
}

local UserPermissions = require(Shared.UserPermissions)
local ProfileService = require(script.ProfileService)
local DataTemplate = require(script.DataTemplate)

local ProfileStore = ProfileService.GetProfileStore(Global.PROFILE_NAME, DataTemplate)
local profiles = {}

local function getServerType()
	if game.PrivateServerId ~= "" then
		if game.PrivateServerOwnerId ~= 0 then
			return "VIPServer"
		else
			return "ReservedServer"
		end
	else
		return "StandardServer"
	end
end

local function onProfileLoaded(player, profile)
	profile.Data.LoginTimes += 1
	profile.Data.LastSeen = os.time()

	if profile.Data.FirstLogin == 0 then
		profile.Data.FirstLogin = os.time()
	end

	Logger:Info("[DataService] {:?}'s profile has been loaded", player.Name)
	DataService.PlayerAdded:Fire(player, profile)
end

local function loadProfile(player)
	local profile = ProfileStore:LoadProfileAsync(Global.PLAYER_PROFILE_NAME .. player.UserId)

	if profile then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			player:Kick("Profile was unloaded. Try rejoining.")
		end)

		if player:IsDescendantOf(Players) then
			profiles[player] = profile
			onProfileLoaded(player, profile)
		else
			profile:Release()
		end
	else
		player:Kick("Could not load profile. Try rejoining.")
	end
end

function DataService:GetProfile(player)
	return profiles[player]
end

function DataService:SetSkin(player, newSkin)
	local profile = self:GetProfile(player)
	profile.Data.MicSkin = newSkin
end

function DataService:GiveWin(player)
	if getServerType() == "VIPServer" then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	local wins = leaderstats:FindFirstChild("Wins")
	local profile = DataService:GetProfile(player)
	profile.Data.Wins += 1

	if wins then
		wins.Value = profile.Data.Wins
	end
end

function DataService:GetSkin(player)
	local profile = self:GetProfile(player)
	return profile.Data.MicSkin
end

function DataService:GetWins(player)
	local profile = DataService:GetProfile(player)
	return profile.Data.Wins
end

function DataService.Client:GetWins(player)
	return DataService:GetWins(player)
end

function DataService.Client:GetRank(player)
	local wins = self:GetWins(player)
	local permissions = UserPermissions:GetUserRights(player)

	if UserPermissions:HasRight(player, "Developer") then
		return Global.GROUP_RANKS.Developer
	elseif UserPermissions:HasRight(player, "Moderator") then
		return Global.GROUP_RANKS.Moderator
	elseif UserPermissions:HasRight(player, "Friend") then
		return Global.GROUP_RANKS.Friend
	end

	for _, rank in ipairs(Global.RANKS) do
		if wins <= rank.MaxWins and wins >= rank.MinWins then
			return rank
		end
	end
end

function DataService:KnitStart()
	if Global.ENVIRONMENT == "staging" then return end

	local function onPlayerAdded(player)
		loadProfile(player)

		local profile = profiles[player]

		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local wins = Instance.new("IntValue")
		wins.Name = "Wins"
		wins.Value = profile.Wins
		wins.Parent = leaderstats
	end

	Players.PlayerAdded:Connect(onPlayerAdded)

	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(onPlayerAdded)(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		if profiles[player] then
			profiles[player]:Release()
		end
	end)
end

return DataService
