--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Logger = Knit.Logger
local Shared = Knit.Shared
local Library = Knit.Library
local Global = Knit.Global

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

local statusText = ""

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
	self.RoundController = Knit.GetController("RoundController")
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

function TopbarController:Typewrite(icon, message, interval, shouldAnimate, shouldDeleteOnCompletion)
	if not shouldAnimate then icon:setLabel(message) return end

	for i = 1, #message do
		icon:setLabel(
			string.sub(message, 0, i)
		)

		task.wait(interval)
	end

	if shouldDeleteOnCompletion then
		self:TypewriteDelete(icon, interval)
	end

	statusText = message
end

function TopbarController:TypewriteDelete(icon, interval)
	for i = #statusText, 0, -1 do
		icon:setLabel(
			string.sub(statusText, 0, i)
		)

		task.wait(interval)
	end

	statusText = ""
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
	local status = self:CreateButton(Global.ROUND_MESSAGES.IDLE, false)

	self:UpdateServerRegion(serverRegion)
	self:UpdatePing(pingCounter)
	self:UpdateFPS(fpsCounter)

	status:setMid()

	self.RoundController.NotificationSent:Connect(function(message, shouldAnimate, shouldDelete)
		self:Typewrite(status, message, Global.UI.NOTIFICATION_CHANGE_TIME, shouldAnimate, shouldDelete)
	end)

	self.RoundController.NotificationDeleted:Connect(function()
		self:TypewriteDelete(status, Global.UI.NOTIFICATION_CHANGE_TIME)
	end)
end

return TopbarController
