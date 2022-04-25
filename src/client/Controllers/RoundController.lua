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
	self.UIController = Knit.GetController("UIController")
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

function RoundController:OpenVotingDisplay(...)
	self.UIController.OpenVotingDisplayEvent:Fire(...)
end

function RoundController:CloseVotingDisplay()
	self.UIController.CloseVotingDisplayEvent:Fire()
end

function RoundController:SendNotification(...)
	self.NotificationSent:Fire(...)
end

function RoundController:DeleteNotification()
	self.NotificationDeleted:Fire()
end

function RoundController:KnitStart()
	self:SendNotification(Global.ROUND_MESSAGES.IDLE)
	self.RoundService.SendNotification:Connect(function(...)
		self:SendNotification(...)
	end)

	self.RoundService.DeleteNotification:Connect(function()
		self:DeleteNotification()
	end)

	self.RoundService.OpenVotingDisplay:Connect(function(...)
		self:OpenVotingDisplay(...)
	end)

	self.RoundService.CloseVotingDisplay:Connect(function()
		self:CloseVotingDisplay()
	end)

	self.RoundService.OpenChatDisplay:Connect(function()
		for _ = 1, 5 do
			self.OpenChatDisplay:Fire()
			task.wait(1)
		end
	end)

	self.RoundService.CloseChatDisplay:Connect(function()
		for _ = 1, 5 do
			self.CloseChatDisplay:Fire()
			task.wait(1)
		end
	end)

	self.RoundService.SendChatDisplayMessage:Connect(function(message)
		self.Chatted:Fire(message)
	end)
end

return RoundController
