local RunService = game:GetService("RunService")

local UserPermissions = {}

local GROUP_ID = 13352380

-- CONSTANTS --

UserPermissions.Rights = {
	"Friend", -- noted member + contributor
	"BetaTester", -- gives access to staging-restricted

	"Moderator",

	"Developer", -- VIP and a few extra perms
	"Vanguard", -- Gives a few debugging related permissions (e.g. cmdr)
	"Soothsayer", -- gives everything for free

	"Cogent", -- includes all rights
}

UserPermissions.Users = {
	[484080249] = { "Cogent" }, -- Ewanophobia
	[133322177] = { "Cogent" } -- saotosune
}

UserPermissions.InheritedPerms = {
	["Influencer"] = {},
	["Friend"] = {},
	["BetaTester"] = {},
	["Moderation"] = {},
	["SeniorModerator"] = { "Friend", "Moderator" },
	["Developer"] = { "Friend", "BetaTester" },
	["Vanguard"] = {},
	["Soothsayer"] = {},
	["Cogent"] = { "Friend", "BetaTester", "BetaAdmin", "Moderator", "Developer", "Vanguard", "Soothsayer" }
}


-- METHODS --

function UserPermissions:GetUserRights(player)
	local rank = player:GetRankInGroup(GROUP_ID)
	local perms = {}

	if UserPermissions.Users[player.UserId] and rank >= 3 then
		perms = UserPermissions.Users[player.UserId]
	end

	if rank == 2 or rank == 3 then
		table.insert(perms, "Friend")
	end

	for _, heldRight in ipairs(perms) do
		if UserPermissions.InheritedPerms[heldRight] then
			for _, childRight in ipairs(UserPermissions.InheritedPerms[heldRight]) do
				if not table.find(perms, childRight) then
					table.insert(perms, childRight)
				end
			end
		end
	end

	return perms
end

function UserPermissions:HasRight(player, right)
	if RunService:IsStudio() then
		return true
	end

	if not table.find(self.Rights, right) then
		error("That user right does not exist!", 2)
	end

	local rights = self:GetUserRights(player)
	return table.find(rights, right) and true or false
end

function UserPermissions:HasRightFromArray(player, rightArray)
	local rights = self:GetUserRights(player)

	for _, right in ipairs(rightArray) do
		if not table.find(self.Rights, right) then
			error("That user right does not exist!", 2)
		end

		if (table.find(rights, right)) then
			return true
		end
	end

	return false
end

return UserPermissions
