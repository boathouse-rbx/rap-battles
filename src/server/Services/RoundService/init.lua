local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)

local Logger = Knit.Logger
local Global = Knit.Global

local Promise = require(Knit.Util.Promise)

local RoundService = Knit.CreateService {
	Name = "RoundService",

	TurnBegan = Signal.new(),
	TurnEnded = Signal.new(),

	Client = {
		SendNotification = Knit.CreateSignal(),
		DeleteNotification = Knit.CreateSignal(),
		OpenChatDisplay = Knit.CreateSignal(),
		CloseChatDisplay = Knit.CreateSignal(),
		SendChatDisplayMessage = Knit.CreateSignal(),
		OpenVotingDisplay = Knit.CreateSignal(),
		CloseVotingDisplay = Knit.CreateSignal(),

		Teleport = Knit.CreateSignal()
	},
}

local PlayersList = {}

local RANDOM = Random.new()

local TeleportLocations = require(script.TeleportLocations)

local ROUND_DELAY = 15

function RoundService:KnitInit()
	self.DataService = Knit.GetService("DataService")
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

function RoundService:SendNotification(message, shouldWait, ...)
	self.Client.SendNotification:FireAll(
		message,
		...
	)

	if shouldWait then
		local pause = (utf8.len(message) * Global.UI.NOTIFICATION_CHANGE_TIME * 2) + Global.UI.NOTIFICATION_DELAY_ADDITION
		task.wait(pause)
	end
end

function RoundService:StartRound()
	local initialHumanoids = {}
	local shouldBeStill = true
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

	local function filterMessage(player, message)
		return Promise.async(function(resolve, reject)
			local successfulFilter, filterResult = pcall(function()
				return TextService:FilterStringAsync(
					message,
					player.UserId
				)
			end)

			if successfulFilter then
				local nonStringSuccess, result = pcall(filterResult.GetNonChatStringForBroadcastAsync, filterResult)

				if nonStringSuccess then
					resolve(result)
				end
			else
				reject(filterResult)
			end
		end)
	end

	local function listenToPlayer(player)
		return player.Chatted:Connect(function(message, recipient)
			if not recipient then
				filterMessage(player, message):andThen(function(filteredMessage)
					self.Client.SendChatDisplayMessage:FireAll(filteredMessage)
				end):catch(warn)
			end
		end)
	end

	local function getPauseTime(message)
		return ((utf8.len(message) * Global.UI.NOTIFICATION_CHANGE_TIME) * 2) + Global.UI.NOTIFICATION_DELAY_ADDITION
	end

	local function formatSeconds(elapsed)
		local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)
		return string.format("%i:%.2i", minutes, seconds)
	end

	local function toggleMovement()
		for _, player in ipairs(players) do
			local character = player.Character
			local humanoid = character:FindFirstChild("Humanoid")

			if humanoid then
				initialHumanoids[player] = {
					INITIAL_JUMP_POWER = humanoid.JumpPower,
					INITIAL_WALK_SPEED = humanoid.WalkSpeed,
					INITIAL_AUTO_ROTATE = humanoid.AutoRotate
				}

				local entry = initialHumanoids[player]
				humanoid.WalkSpeed = if shouldBeStill then 0 else 16
				humanoid.JumpPower = if shouldBeStill then 0 else 50
				humanoid.AutoRotate = if shouldBeStill then false else true
			end
		end

		shouldBeStill = not shouldBeStill
	end

	for index, player in ipairs(players) do
		self.Client.Teleport:Fire(player, TeleportLocations[index], true)
		self.ToolService:EquipMicrophone(player)
	end

	toggleMovement()

	local function createPersistentEvent(event, ...)
		local args = {...}
		event:FireAll(
			table.unpack(args)
		)

		return Players.PlayerAdded:Connect(function(player)
			event:Fire(
				player,
				table.unpack(args)
			)
		end)
	end

	local openChatDisplay = createPersistentEvent(self.Client.OpenChatDisplay)

	local function endGame()
		local spawns = workspace.Map.Spawns:GetChildren()
		RoundService.CanVote = false
		RoundService.Playing = nil
		RoundService.Votes = nil
		openChatDisplay:Disconnect()

		for _, player in ipairs(players) do
			local spawn = spawns[math.random(1, #spawns)]
			self.Client.Teleport:Fire(player, CFrame.new(spawn.Position) * CFrame.new(0, 3, 0))
			self.ToolService:UnequipMicrophone(player)
		end

		toggleMovement()
	end

	local function makeTurn(player, isFinal, isDecider)
		isDecider = isDecider or false

		local rapTime = self:GetRapTime(player)
		local chatted = listenToPlayer(player)
		self.TurnBegan:Fire(player, rapTime)

		for elapsed = rapTime, 0, -1 do
			local formatted = formatSeconds(elapsed)
			local notification = string.format(
				Global.ROUND_MESSAGES.RAPPING,
				player.DisplayName,
				player.Name,
				formatted
			)
			self:SendNotification(notification, false, false, false)
			task.wait(1)
		end

		if not isDecider then
			self.TurnEnded:Fire()
		else
			self:SendNotification(
				Global.ROUND_MESSAGES.WON.Stalemate,
				true,
				true,
				true
			)
		end

		if not isFinal then
			self:SendNotification(
				string.format(
					Global.ROUND_MESSAGES.TURN_ENDED,
					player.DisplayName,
					player.Name
				),

				true,
				true,
				true
			)
		else
			self:SendNotification(
				Global.ROUND_MESSAGES.ROUND_ENDED,
				true,
				true,
				false
			)
		end

		chatted:Disconnect()
	end

	local firstPlayer = players[1]
	local secondPlayer = players[2]

	RoundService.Playing = {
		firstPlayer,
		secondPlayer
	}

	RoundService.Votes = {
		[firstPlayer.UserId] = 0,
		[secondPlayer.UserId] = 0,

		Voters = {}
	}

	RoundService.CanVote = false

	for turnIndex = 1, Global.ROUND_TIMES.TURNS do
		local isFinalTurn = if turnIndex == Global.ROUND_TIMES.TURNS then true else false

		self.TurnEnded:Connect(function()
			if isFinalTurn then
				task.wait(
					getPauseTime(Global.ROUND_MESSAGES.ROUND_ENDED)
				)

				RoundService.CanVote = true

				self.Client.OpenVotingDisplay:FireFilter(function(player)
					return not (player == firstPlayer) or (player == secondPlayer)
				end)

				for _ = 1, 5 do -- Global.ROUND_TIMES.VOTING_TIME
					task.wait(1)
				end

				self.Client.CloseVotingDisplay:FireAll()

				local info = self:TallyVotes()
				local winner = info.Winner

				for _, player in ipairs(Players:GetPlayers()) do
					if player.UserId == winner then
						if not info.AreEqual then
							local formattedMessage = string.format(
								info.Message,
								player.DisplayName,
								player.Name
							)

							self:SendNotification(formattedMessage, true, true, true)
							self.DataService:GiveWin(player)

							endGame()
						else
							self:SendNotification(Global.ROUND_MESSAGES.WON.STALEMATE, true, true, true)
							endGame()
						end

						break
					end
				end

				return
			else
				task.wait(
					getPauseTime(Global.ROUND_MESSAGES.TURN_ENDED)
				)
			end
		end)

		if turnIndex % 2 == 1 then
			makeTurn(firstPlayer, isFinalTurn)
		else
			makeTurn(secondPlayer, isFinalTurn)
		end

		task.wait()
	end

	task.wait(10)
end

function RoundService.Client:Vote(player, candidateId)
	if RoundService.Votes and
		RoundService.Playing and
		RoundService.CanVote and
		not RoundService.Votes.Voters[player.UserId] then

		local candidate = RoundService.Votes[candidateId]
		local hasVoted = RoundService.Votes.Voters[player.UserId]

		if candidate and not hasVoted then
			RoundService.Votes[candidateId] += 1
			RoundService.Votes.Voters[player.UserId] = true
		end
	end
end

function RoundService:TallyVotes()
	local Votes = {}
	local areEqual = false
	local message = Global.ROUND_MESSAGES.WON.REGULAR

	for key, value in pairs(RoundService.Votes) do
		if typeof(value) == "number" then
			table.insert(Votes, {
				ID = key,
				Votes = value
			})
		end
	end

	table.sort(Votes, function(a, b)
		return a.Votes < b.Votes
	end)

	local other = Votes[1]
	local winner = Votes[2]

	local winningPlayer = winner.ID
	local difference = math.abs(other.Votes - winner.Votes)

	if other.Votes == winner.Votes then
		areEqual = true
	end

	if difference <= 2 then
		message = Global.ROUND_MESSAGES.WON.MARGINAL
	elseif difference <= (difference / 2) then
		message = Global.ROUND_MESSAGES.WON.REGULAR
	elseif difference >= (difference / 2) then
		message = Global.ROUND_MESSAGES.WON.LANDSLIDE
	end

	return {
		Winner = winningPlayer,
		AreEqual = areEqual,
		Message = message
	}
end

function RoundService.Client:IsPlaying(player)
	return true --if table.find(RoundService.Playing, player) then
end

function RoundService:GetRapTime(player)
	if self.GamepassService:PlayerOwnGamepass(player, Global.PRODUCTS.GAMEPASSES.EXTRA_RAP_TIME) then
		return Global.ROUND_TIMES.EXTENDED_LENGTH
	end

	return Global.ROUND_TIMES.DEFAULT_LENGTH
end

function RoundService:KnitStart()
	local function onPlayerAdded(player)
		table.insert(PlayersList, {
			Player = player,
			Chance = 100 / #Players:GetPlayers()
		})

		for _, joinedPlayer in ipairs(Players:GetPlayers()) do
			self:ResetChances(joinedPlayer)
		end

		if #Players:GetPlayers() >= 3 then
			task.wait(5)
			self:StartRound()
			self.Client.DeleteNotification:FireAll()
		elseif #Players:GetPlayers() < 3 then
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
