local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Promise = require(Knit.Util.Promise)

local Logger = Knit.Logger
local Global = Knit.Global

local ServerService = Knit.CreateService {
	Name = "ServerService",
	Client = {},
}

local IP_API = "http://ip-api.com/json/"

local temporaryLobbyWaitTime = 5

local function httpGet(url)
	return Promise.async(function(resolve, reject)
		local success, result = pcall(function()
			return HttpService:GetAsync(url)
		end)

		if success then
			resolve(result)
		else
			reject(result)
		end
	end)
end

function ServerService:GetServerLocation()
	httpGet(IP_API):andThen(function(result)
		local info = HttpService:JSONDecode(result)
		local country = info.countryCode
		return country
	end):catch(function(err)
		warn(err)
	end)
end

function ServerService.Client:GetServerLocation()
	local success, result = httpGet(IP_API):await()

	if success then
		return HttpService:JSONDecode(result)
	end

	return nil
end

function ServerService:KnitStart()
	---@diagnostic disable-next-line: deprecated
	if (not game.VIPServerId == "" and game.VIPServerOwnerId == 0) then
		local message = Instance.new("Message")
		message.Text = Global.TEMPORARY_LOBBY_MESSAGE
		message.Parent = workspace

		local function onPlayerAdded(player)
			task.wait(temporaryLobbyWaitTime)
			temporaryLobbyWaitTime /= 2
			TeleportService:Teleport(game.PlaceId, player)
		end

		Players.PlayerAdded:Connect(onPlayerAdded)

		for _, player in pairs(Players:GetPlayers()) do
			onPlayerAdded(player)
		end
	else
		game:BindToClose(function()
			if #Players:GetPlayers() == 0 or RunService:IsStudio() then
				return
			end

			local message = Instance.new("Message")
			message.Text = Global.SERVER_RESTART_MESSAGE
			message.Parent = workspace

			task.wait(2)

			local reservedServerCode = TeleportService:ReserveServer(game.PlaceId)

			local function onPlayerAdded(player)
				TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
			end

			Players.PlayerAdded:Connect(onPlayerAdded)

			for _, player in pairs(Players:GetPlayers()) do
				onPlayerAdded(player)
			end

			while #Players:GetPlayers() > 0 do
				task.wait(1)
			end
		end)
	end

	self:GetServerLocation()
end

return ServerService
