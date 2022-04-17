local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

local Global = Knit.Global
local Logger = Knit.Logger
local Shared = Knit.Shared

local UserPermissions = require(Shared.UserPermissions)

local AwardService = Knit.CreateService {
	Name = "AwardService",
	Client = {},
}

function AwardService:GetBadgeInfoAsync(id)
	return Promise.async(function(resolve, reject)
		local success, badgeInfo = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, id)

		if success then
			resolve(badgeInfo)
		else
			reject(badgeInfo)
		end
	end)
end

function AwardService:PlayerOwnsBadge(player, id)
	return Promise.async(function(resolve, reject)
		local success, result = pcall(function()
			return BadgeService:UserHasBadgeAsync(player.UserId, id)
		end)

		if success then
			resolve(result)
		else
			reject(result)
		end
	end)
end

function AwardService:AwardBadge(player, id)
	self:GetBadgeInfoAsync(id):andThen(function(info)
		self:PlayerOwnsBadge(player, id):andThen(function(owns)
			if not owns then
				if info.IsEnabled then
					local awarded, errorMessage = pcall(BadgeService.AwardBadge, BadgeService, player.UserId, id)

					if awarded then
						Logger:Debug("[AwardService] Successfully awarded {:?} to {:?}", info.Name, player)
						return nil
					else
						Logger:Warn("[AwardService] An error occurred while trying to award {:?} to {:?}, {:?}", info.Name, player, errorMessage)
						return nil
					end
				end
			else
				return true
			end
		end):catch(function(err)
			Logger:Warn("[AwardService] An error occurred while trying to retrieve a badges ownership for {:?}, {:?}", player, err)
			return false
		end)
	end):catch(function(err)
		Logger:Warn("[AwardService] An error occurred while trying to award a badge to {:?}, {:?}", player, err)
		return false
	end)
end

function AwardService:KnitStart()
	local function handlePlayer(player)
		if not self:PlayerOwnsBadge(player, Global.BADGES.WELCOME) then
			self:AwardBadge(player, Global.BADGES.WELCOME)
		end

		if UserPermissions:HasRight(player, "Developer") then
			for _, newPlayer in ipairs(Players:GetPlayers()) do
				self:AwardBadge(newPlayer, Global.BADGES.MET_DEVELOPER)
			end
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(handlePlayer)(player)
	end

	Players.PlayerAdded:Connect(handlePlayer)
end

return AwardService
