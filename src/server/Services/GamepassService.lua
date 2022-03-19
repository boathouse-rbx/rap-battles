--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)
local Promise = require(Knit.Util.Promise)

local Logger = Knit.Logger
local Global = Knit.Global
local Shared = Knit.Shared

local UserPermissions = require(Shared.UserPermissions)

local GamepassService = Knit.CreateService({
	Name = "GamepassService",

	Client = {
		GamepassBought = Knit.CreateSignal()
	},
})

local function doesPlayerOwnGamepass(player, id)
	return Promise.async(function(resolve, reject)
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
		end)

		if success then
			resolve(result)
		else
			reject(result)
		end
	end)
end

function GamepassService:PlayerOwnGamepass(player, id)
	if UserPermissions:HasRight(player, "Developer") then
		return true
	end

	doesPlayerOwnGamepass(player, id):andThen(function(result)
		if result then
			return true
		end

		return false
	end):catch(function(err)
		warn(err)
	end)
end

function GamepassService.Client:OwnsGamepass(player, id, shouldPromptIfNotOwned)
	local result = GamepassService:PlayerOwnGamepass(player, id)

	if not result and shouldPromptIfNotOwned then
		GamepassService:PromptPurchase(player, id)
	end

	return result
end

function GamepassService:PromptPurchase(player, id)
	if UserPermissions:HasRight(player, "Developer") then
		return
	end

	MarketplaceService:PromptPurchase(player, id)
end

function GamepassService:KnitStart()
	MarketplaceService.PromptPurchaseFinished:Connect(function(player, id, isPurchased)
		if isPurchased then
			GamepassService.Client.GamepassBought:Fire(player, id)
		end
	end)
end

return GamepassService
