local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local RoundService = Knit.CreateService {
	Name = "RoundService",

	Client = {
		RoundStarted = Knit.CreateSignal()
	},
}

local PlayersList = {}

local RANDOM = Random.new()

function RoundService:PickPlayers(pickCount)
	local players = Players:GetPlayers()
	local selectedPlayers = {}
	local clonedList = { table.unpack(PlayersList) }

	if #players >= 2 then
		return players
	end

	table.sort(clonedList, function(a, b)
		return a.Chance > b.Chance
	end)

	for index = 1, pickCount do
		local listObject = clonedList[index]
		table.insert(selectedPlayers, listObject.Player)
	end

	return selectedPlayers
end

function RoundService:IncreaseChances(player)
	local playersCount = #Players:GetPlayers()
	local proportion = 100 / playersCount

	for _, list in ipairs(PlayersList) do
		if list.Player == player then
			list.Chance += proportion
			return list
		end
	end
end

function RoundService:ResetChances(player)
	local playersCount = #Players:GetPlayers()
	local proportion = 100 / playersCount

	for _, list in ipairs(PlayersList) do
		if list.Player == player then
			list.Chance = proportion
		end
	end
end

function RoundService:StartRound()
	local players = self:PickPlayers(2)

	for _, pickedPlayer in ipairs(players) do
		for _, player in ipairs(Players:GetPlayers()) do
			if not player == pickedPlayer then
				self:IncreaseChances(player)
			else
				self:ResetChances(player)
			end
		end
	end

	local firstPlayer = players[1]
	local secondPlayer = players[2]
	local selectedPlayers = { firstPlayer, secondPlayer }

	self.RoundStarted:FireAll(firstPlayer, secondPlayer)
end

function RoundService:KnitStart()
	for _, player in ipairs(Players:GetPlayers()) do
		table.insert(PlayersList, {
			Player = player,
			Chance = 100 / #Players:GetPlayers()
		})
	end

	Players.PlayerAdded:Connect(function(joiningPlayer)
		table.insert(PlayersList, {
			Player = joiningPlayer,
			Chance = 100 / #Players:GetPlayers()
		})

		if #Players:GetPlayers() >= 2 then
			self:StartRound()
		end
	end)

	Players.PlayerRemoving:Connect(function(leavingPlayer)
		for index, player in ipairs(PlayersList) do
			if player.Player == leavingPlayer then
				table.remove(PlayersList, index)
			end
		end
	end)
end

return RoundService
