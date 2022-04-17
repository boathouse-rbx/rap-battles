local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local function startClient()
	local Knit = require(ReplicatedStorage.Packages.Knit)
	local recursive = require(ReplicatedStorage.Shared.knitLoader)(Knit)

	-- Client-side folder injection
	Knit.Helpers = script.Helpers

	-- Load controllers
	-- ⚠ This means that controllers will sometimes be required BEFORE the server
	--- is ready.
	recursive(script.Controllers, require)

	-- Wait for server before we start Knit.
	-- The 'math.huge' is to surpress 'Infinite yield possible' warnings.
	ReplicatedStorage:WaitForChild(Knit.Global.SERVER_READY_FLAG_NAME, math.huge)

	-- Start Knit
	Knit.Start():andThen(function()
		Knit.Logger:Info("[cmain] Client has started! Running version {:?} in environment {:?}.", Knit.Global.VERSION, Knit.Global.ENVIRONMENT)
	end):catch(function(err)
		Knit.Logger:Warn("[cmain] A fatal error occurred while starting Knit: {:?}", err)

		-- Disconnnect client if the game won't load
		Players.LocalPlayer:Kick("A fatal error occurred while starting the game, please rejoin. If this keeps happening, please report it in the community server.")
	end)
end

startClient()
