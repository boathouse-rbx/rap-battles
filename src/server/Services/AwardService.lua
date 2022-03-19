local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

local Global = Knit.Global
local Logger = Knit.Logger

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

function AwardService:AwardBadge(player, id)
	self:GetBadgeInfoAsync(id):andThen(function(info)
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
	end):catch(function(err)
		Logger:Warn("[AwardService] An error occurred while trying to award a badge to {:?}, {:?}", player, err)
		return false
	end)
end

function AwardService:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		self:AwardBadge(player, Global.BADGES.WELCOME)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:AwardBadge(player, Global.BADGES.WELCOME)
	end
end

return AwardService
