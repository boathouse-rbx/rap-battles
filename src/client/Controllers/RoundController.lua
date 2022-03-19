--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.signal)

local Logger = Knit.Logger
local Global = Knit.Global

local RoundController = Knit.CreateController {
	Name = "RoundController",

	NotificationSent = Signal.new(),
	NotificationDeleted = Signal.new()
}

local TYPEWRITER_TWEENINFO = Global.UI.TYPEWRITER_TWEENINFO

local LOADING_TIME = 5

local NOTIFICATION_TIME = 5
local NOTIFICATION_DELAY = TYPEWRITER_TWEENINFO.Time + 0.75

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
	task.wait(LOADING_TIME)
	self:SendNotification(Global.ROUND_MESSAGES.IDLE)

	self:QueueNotifications({
		string.format(Global.ROUND_MESSAGES.ROUND_BEGIN, "Ewanophobia", "Ewan", "undrscrhiko", "Josh"),
		"bazinga message 666 pro gamer fart lol",
		"peter griffin الله بونغ ضرطة براز الجنس"
	})

	self.RoundService.RoundStarted:Connect(function(player1, player2)
		self:SendNotification(
			string.format(
				Global.ROUND_MESSAGES.ROUND_BEGIN,
				player1.DisplayName,
				player1.Name,
				player2.DisplayName,
				player2.Name
			)
		)
	end)
end

return RoundController
