--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)

local Logger = Knit.Logger
local Global = Knit.Global
local Shared = Knit.Shared

local RoundController = Knit.CreateController {
	Name = "RoundController",

	NotificationSent = Signal.new(),
	NotificationDeleted = Signal.new(),
	OpenChatDisplay = Signal.new(),
	CloseChatDisplay = Signal.new(),
	Chatted = Signal.new(),
}

local TYPEWRITER_TWEENINFO = Global.UI.TYPEWRITER_TWEENINFO

local NOTIFICATION_TIME = Global.UI.NOTIFICATION_TIME
local NOTIFICATION_DELAY = TYPEWRITER_TWEENINFO.Time + Global.UI.NOTIFICATION_DELAY_ADDITION

local isChatDisplayOpen = false
local lastNotification = ""

function RoundController:KnitInit()
	self.RoundService = Knit.GetService("RoundService")
end

function RoundController:QueueNotifications(notifications)
	self:DeleteNotification()
	task.wait(NOTIFICATION_DELAY)

	for _, message in ipairs(notifications) do
		self:SendNotification(message)
		task.wait(NOTIFICATION_TIME)
		self:DeleteNotification()
		task.wait(NOTIFICATION_DELAY)
	end
end

function RoundController:SendNotification(message)
	self.NotificationSent:Fire(message)
end

function RoundController:DeleteNotification()
	self.NotificationDeleted:Fire()
end

function RoundController:KnitStart()
	self:SendNotification(Global.ROUND_MESSAGES.IDLE)

	self.RoundService.SendNotification:Connect(function(message)
		self:SendNotification(message)
	end)

	self.RoundService.DeleteNotification:Connect(function()
		self:DeleteNotification()
	end)

	self.RoundService.OpenChatDisplay:Connect(function()
		isChatDisplayOpen = true
		self.OpenChatDisplay:Fire()
	end)

	self.RoundService.CloseChatDisplay:Connect(function()
		isChatDisplayOpen = false
		self.CloseChatDisplay:Fire()
	end)

	self.RoundService.SendChatDisplayMessage:Connect(function(message)
		if isChatDisplayOpen then
			self.Chatted:Fire(message)
		end
	end)
end

return RoundController
