--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Logger = Knit.Logger
local Shared = Knit.Shared
local Library = Knit.Library

local RegionData = require(Shared.RegionData)
local TopbarPlus = require(Library.TopbarPlus)

local TopbarController = Knit.CreateController { Name = "TopbarController" }

local INITIAL_SERVER_INFO_TEXT = "Getting server info..."
local DEFAULT_SERVER_INFO_TEXT = "Server region: "

local INITIAL_FPS_INFO_TEXT = "Getting FPS..."
local DEFAULT_FPS_INFO_TEXT = "FPS: "

local INITIAL_PING_INFO_TEXT = "Getting ping..."
local DEFAULT_PING_INFO_TEXT = "Ping: "

local UPDATE_PING_NAME = "UPDATE_PING"

local getTime = if RunService:IsRunning() then time else os.clock

local lastFpsIteration
local fpsStart = getTime()
local frameUpdates = {}

local function getAveragePing()
	local players = #Players:GetPlayers()
	local sum = 0

	for _, player in pairs(Players:GetPlayers()) do
		sum += player:GetNetworkPing()
	end

	if players < 2 then
		return sum
	else
		return sum / players
	end
end

function TopbarController:KnitInit()
	self.ServerService = Knit.GetService("ServerService")
end

function TopbarController:CreateButton(text, isSelectable)
	local icon = TopbarPlus.new()
	icon:setLabel(text)

	if not isSelectable then
		icon.selected:Connect(function()
			icon:deselect()
		end)
	end

	return icon
end

function TopbarController:UpdateServerRegion(icon)
	local worked, result = self.ServerService:GetServerLocation():await()

	if worked then
		local countryCode = result.countryCode
		local country = RegionData[countryCode]
		icon:setLabel(DEFAULT_SERVER_INFO_TEXT .. country.Emoji)
	end
end

function TopbarController:UpdateFPS(icon)
	RunService.Heartbeat:Connect(function()
		lastFpsIteration = getTime()

		for i = #frameUpdates, 1, -1 do
			frameUpdates[i + 1] = frameUpdates[i] >= lastFpsIteration - 1 and frameUpdates[i] or nil
		end

		frameUpdates[1] = lastFpsIteration
		icon:setLabel(
			DEFAULT_FPS_INFO_TEXT .. math.floor(getTime() - fpsStart >= 1 and #frameUpdates or #frameUpdates / (getTime() - fpsStart))
		)
	end)
end

function TopbarController:UpdatePing(icon)
	RunService:BindToRenderStep(UPDATE_PING_NAME, 0, function()
		local ping = getAveragePing()
		icon:setLabel(DEFAULT_PING_INFO_TEXT .. math.round(ping * 1000))
	end)
end

function TopbarController:KnitStart()
	local serverRegion = self:CreateButton(INITIAL_SERVER_INFO_TEXT, false)
	local fpsCounter = self:CreateButton(INITIAL_FPS_INFO_TEXT, false)
	local pingCounter = self:CreateButton(INITIAL_PING_INFO_TEXT, false)
	self:UpdateServerRegion(serverRegion)
	self:UpdatePing(pingCounter)
	self:UpdateFPS(fpsCounter)
end

return TopbarController
