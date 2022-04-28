local RunService = game:GetService("RunService")

local Global = {}

Global.PLACES = { -- {PRODUCTION|INTEGRATION|DEBUG_ENABLED_IN}
	PRODUCTION = { 9141155067 }, -- #[int]
	INTEGRATION = { 9141286177 }, -- #[int]
	DEBUG_ENABLED_IN = {} -- #[int]
}

------------
-- BADGES --
------------
Global.BADGES = {
	WELCOME = 2125579682,
	MET_DEVELOPER = 2125643917
}

----------
-- DATA --
----------

Global.PROFILE_NAME = "rap.battles"
Global.PLAYER_PROFILE_NAME = "player_"

--------------
-- PRODUCTS --
--------------

Global.PRODUCTS = {
	GAMEPASSES = {
		EXTRA_RAP_TIME = 35516004,
		DJ = 35515748,
		RAINBOW_CHAT = 35994151,
	},

	DEVELOPER_PRODUCT = {
		DOUBLE_CHANCES = 1250143016
	},
}

-------------
-- GENERAL --
-------------

Global.MIC_SKINS = {
	{
		Name = "Default",
		Texture = "rbxassetid://9385010664",
		MinWins = 0,
	},

	{
		Name = "Metal",
		Texture = "rbxassetid://8735849628",
		MinWins = 3,
	},

	{
		Name = "Blue",
		Texture = "rbxassetid://6246710687",
		MinWins = 6,
	},

	{
		Name = "Red",
		Texture = "rbxassetid://1489069889",
		MinWins = 10,
	},
}

Global.PROXIMITY_PROMPTS = {
	DJ = {
		TITLE = "Open",
		DESCRIPTION = "Open DJ Controls",
		DISTANCE = 5,
		DURATION = 0.5,
		KEY = Enum.KeyCode.E
	}
}

Global.GROUP_RANKS = {
	Developer = {
		Name = "Developer 🛠️",
		isRainbow = true,
		MinWins = math.huge,
		MaxWins = math.huge,
		Gradient = ColorSequence.new(
			Color3.fromHex("#b92b27"),
			Color3.fromHex("#1565C0")
		),
	},

	Moderator = {
		Name = "Moderator 🔨",
		isRainbow = true,
		MinWins = math.huge,
		MaxWins = math.huge,
		Gradient = ColorSequence.new(
			Color3.fromHex("#b92b27"),
			Color3.fromHex("#1565C0")
		),
	},

	Friend = {
		Name = "Friend 🤝",
		isRainbow = true,
		MinWins = math.huge,
		MaxWins = math.huge,
		Gradient = ColorSequence.new(
			Color3.fromHex("#b92b27"),
			Color3.fromHex("#1565C0")
		),
	}
}

Global.RANKS = {
	{
		Name = "Rookie 💣",
		isRainbow = false,
		MinWins = 0,
		MaxWins = 5,
		Gradient = ColorSequence.new(
			Color3.fromHex("#FF512F"),
			Color3.fromHex("#F09819")
		)
	},

	{
		Name = "Talented 💡",
		isRainbow = false,
		MinWins = 5,
		MaxWins = 10,
		Gradient = ColorSequence.new(
			Color3.fromHex("#e65c00"),
			Color3.fromHex("#F9D423")
		),
	},

	{
		Name = "Experienced 💎",
		isRainbow = false,
		MinWins = 10,
		MaxWins = 30,
		Gradient = ColorSequence.new(
			Color3.fromHex("#00C6FF"),
			Color3.fromHex("#0072FF")
		)
	},

	{
		Name = "Underground 🎤",
		isRainbow = false,
		MinWins = 30,
		MaxWins = 100,
		Gradient = ColorSequence.new(
			Color3.fromHex("#bdc3c7"),
			Color3.fromHex("#2c3e50")
		),
	},

	{
		Name = "Famous 📷",
		isRainbow = false,
		MinWins = 100,
		MaxWins = 500,
		Gradient = ColorSequence.new(
			Color3.fromHex("#141E30"),
			Color3.fromHex("#243B55")
		),
	},

	{
		Name = "Hall of Famer 🔥",
		isRainbow = false,
		MinWins = 500,
		MaxWins = 1000,
		Gradient = ColorSequence.new(
			Color3.fromHex("#ee0979"),
			Color3.fromHex("#ff6a00")
		),
	},

	{
		Name = "G.O.A.T 🐐",
		isRainbow = true,
		MinWins = 1000,
		MaxWins = 5000,
		Gradient = ColorSequence.new(
			Color3.fromHex("#b92b27"),
			Color3.fromHex("#1565C0")
		),
	},
}

Global.TEMPORARY_LOBBY_MESSAGE = "Servers are restarting, you will be teleported back in a moment."
Global.SERVER_RESTART_MESSAGE = "A new update has dropped, please wait."

Global.UI = {
	SETTINGS_ICON = "rbxassetid://8251178684",
	SHOP_ICON = "rbxassetid://9018904812",
	DJ_ICON = "rbxassetid://9145009250",
	VINYL_ICON = "rbxassetid://9146332166",

	TYPEWRITER_TWEENINFO = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
	CLOSE_BUTTON_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	WINDOW_SIZE_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	CHAT_DISPLAY_POSITION_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	VOTING_DISPLAY_POSITION_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	VINYL_ROTATION_TWEEN_INFO = TweenInfo.new(5),

	NOTIFICATION_TIME = 5,
	NOTIFICATION_DELAY_ADDITION = 0.75,
	NOTIFICATION_CHANGE_TIME = 0.1
}

Global.ROUND_MESSAGES = {
	ROUND_BEGIN = "%s (%s) will be battling %s (%s)",
	IDLE = "The next round will begin shortly...",
	RAPPING = "%s (%s) is rapping, %s left.",
	TURN_ENDED = "%s (%s) finished! Passing over the mic...",
	ROUND_ENDED = "This round has ended! Casting the votes...",

	WON = {
		LANDSLIDE = "%s (%s) has won by a MILE!",
		MARGINAL = "%s (%s) has won, it was a close fight though!",
		REGULAR = "%s (%s) has won.",
		LEFT = "%s (%s) has won by default",
		STALEMATE = "It's a stalemate! Nobody will win."
	}
}

Global.ROUND_TIMES = {
	VOTING_TIME = 15,
	TURNS = 4,
	DEFAULT_LENGTH = 60,
	EXTENDED_LENGTH = 90,
}

Global.ROUND_MUSIC = {
	ROUND_BEATS = {
		-- 1839092699,
		1836497150,
		1846119637,
		9040153041,
		1836402682,
	},

	VICTORY = {
		160737154,
		7082075631
	},

	LOSS = 190705984,
	FINISHED_BEAT = 1836513791,
}

----------------
-- VERSIONING --
----------------
Global.VERSION = "1.0.0"
Global.ENVIRONMENT = (RunService:IsStudio() and "development")
	or (table.find(Global.PLACES.PRODUCTION, game.PlaceId) and "production")
	or "staging"

-----------
-- DEBUG --
-----------
Global.ENABLE_DEBUG_IN_STUDIO = true
Global.DEBUG_ENABLED =
	(table.find(Global.PLACES.DEBUG_ENABLED_IN, game.PlaceId) and true)
	or (RunService:IsStudio() and Global.ENABLE_DEBUG_IN_STUDIO)

----------
-- KNIT --
----------
Global.SERVER_READY_FLAG_NAME = "ServerReady" -- #string

-- Strict
setmetatable(Global, {
	__index = function(_, k)
		error(string.format("'%s' is not a member of Global!", k), 2)
	end,

	__newindex = function()
		error("Creating new members in Global is not allowed!", 2)
	end,
})

setmetatable(_G, {
    __index = Global
})

if Global.DEBUG_ENABLED then
	print("----------------------------------------")
	print("[Global Debug]")
	print(Global)
	print("----------------------------------------")
else
	print("[Global] Debug is not enabled")
end

return Global
