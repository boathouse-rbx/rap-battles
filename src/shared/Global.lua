local RunService = game:GetService("RunService")

local Global = {}

Global.PLACES = { -- {PRODUCTION|INTEGRATION|DEBUG_ENABLED_IN}
	PRODUCTION = {}, -- #[int]
	INTEGRATION = {}, -- #[int]
	DEBUG_ENABLED_IN = {} -- #[int]
}

------------
-- BADGES --
------------
Global.BADGES = {
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
