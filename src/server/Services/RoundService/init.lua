local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Logger = Knit.Logger
local Global = Knit.Global

local RoundService = Knit.CreateService {
	Name = "RoundService",

	Client = {
		SendNotification = Knit.CreateSignal(),
		DeleteNotification = Knit.CreateSignal(),
		OpenChatDisplay = Knit.CreateSignal(),
		CloseChatDisplay = Knit.CreateSignal(),
		SendChatDisplayMessage = Knit.CreateSignal(),

		Teleport = Knit.CreateSignal()
	},
}

local PlayersList = {}

local RANDOM = Random.new()

local TeleportLocations = require(script.TeleportLocations)

local ROUND_DELAY = 15

function RoundService:KnitInit()
	self.GamepassService = Knit.GetService("GamepassService")
	self.ToolService = Knit.GetService("ToolService")
end

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

	local function listenToPlayer(player)
		return player.Chatted:Connect(function(message, recipient)
			if not recipient then
				self.Client.SendChatDisplayMessage:FireAll(message)
			end
		end)
	end

	task.wait(2)

	local initialHumanoids = {}

	for _, player in ipairs(players) do
		local character = player.Character
		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid then
			initialHumanoids[player] = {
				INITIAL_JUMP_POWER = humanoid.JumpPower,
				INITIAL_WALK_SPEED = humanoid.WalkSpeed,
				INITIAL_AUTO_ROTATE = humanoid.AutoRotate
			}

			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.AutoRotate = false
		end
	end

	for index, player in ipairs(players) do
		self.Client.Teleport:Fire(player, TeleportLocations[index], true)
		self.ToolService:EquipMicrophone(player)
	end

	
end

function RoundService:GetRapTime(player)
	if self.GamepassService:PlayerOwnGamepass(player, Global.PRODUCTS.GAMEPASSES.EXTRA_RAP_TIME) then
		return Global.ROUND_TIMES.EXTENDED_LENGTH + ROUND_DELAY
	end

	return Global.ROUND_TIMES.DEFAULT_LENGTH + ROUND_DELAY
end

function RoundService:KnitStart()
	local function onPlayerAdded(player)
		table.insert(PlayersList, {
			Player = player,
			Chance = 100 / #Players:GetPlayers()
		})

		if #Players:GetPlayers() >= 2 then
			task.wait(5)
			self:StartRound()
			self.Client.DeleteNotification:FireAll()
		elseif #Players:GetPlayers() < 2 then
			task.wait(5)
			self.Client.SendNotification:Fire(player, Global.ROUND_MESSAGES.IDLE, true, false)
		end
	end

	local function onPlayerRemoved(player)
		for index, listedPlayer in ipairs(PlayersList) do
			if listedPlayer.Player == player then
				table.remove(PlayersList, index)
			end
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		coroutine.wrap(onPlayerAdded)(player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoved)
end

return RoundService
