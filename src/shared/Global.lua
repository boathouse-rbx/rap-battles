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
	WELCOME = 2125579682
}

--------------
-- PRODUCTS --
--------------

Global.PRODUCTS = {
	GAMEPASSES = {
		EXTRA_RAP_TIME = 35516004,
		DJ = 35515748,
	},

	DEVELOPER_PRODUCT = {
		DOUBLE_CHANCES = 1250143016
	},
}

-------------
-- GENERAL --
-------------

Global.PROXIMITY_PROMPTS = {
	DJ = {
		TITLE = "Open",
		DESCRIPTION = "Open DJ Controls",
		DISTANCE = 5,
		DURATION = 0.5,
		KEY = Enum.KeyCode.E
	}
}

Global.TEMPORARY_LOBBY_MESSAGE = "Servers are restarting, you will be teleported back in a moment."
Global.SERVER_RESTART_MESSAGE = "A new update has dropped, please wait."

Global.UI = {
	SETTINGS_ICON = "rbxassetid://8251178684",
	SHOP_ICON = "rbxassetid://9018904812",
	DJ_ICON = "rbxassetid://9145009250",

	TYPEWRITER_TWEENINFO = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 1),
	CLOSE_BUTTON_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 1),
	WINDOW_SIZE_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 1)
}

Global.ROUND_MESSAGES = {
	ROUND_BEGIN = "%s (%s) will be battling %s (%s)",
	ROUND_TURN_END = "%s (%s) finished rapping, it is now %s's (%s) turn.",
	IDLE = "The next round will begin shortly...",
	RAPPING = "%s (%s) is rapping, %d seconds left.",
	FINISHED_RAPPING = "%s (%s) has finished! Lets see how %s (%s) does...",

	WON = {
		LANDSLIDE = "%s (%s) has won by a MILE!",
		MARGINAL = "%s (%s) has won, it was a close fight though!",
		REGULAR = "%s (%s) has won."
	}
}

Global.ROUND_MUSIC = {
	ROUND_BEATS = {
		"rbxassetid://1839092699",
		"rbxassetid://1836497150",
		"rbxassetid://9040153041",
		"rbxassetid://1836402682",
		"rbxassetid://9063855475",
	},

	VICTORY = {
		"rbxassetid://160737154",
		"rbxassetid://7082075631"
	},

	FINISHED_BEAT = "rbxassetid://1836513791",
	LOSS = "rbxassetid://190705984",
}

----------------
-- VERSIONING --
----------------
Global.VERSION = "0.0.0"
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
