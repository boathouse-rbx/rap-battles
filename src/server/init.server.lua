local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local function startServer()
	local Knit = require(ReplicatedStorage.Packages.Knit)
	local recursive = require(ReplicatedStorage.Shared.knitLoader)(Knit)

	-- Server-side folder injection
	Knit.Helpers = script.Helpers

	-- Load services
	recursive(script.Services, require)

	-- Start Knit
	Knit.Start():andThen(function()
		Knit.Logger:Info("[smain] Server has started! Running version {:?} in environment {:?}.", Knit.Global.VERSION, Knit.Global.ENVIRONMENT)

		local serverReady = Instance.new("BoolValue")
		serverReady.Name = Knit.Global.SERVER_READY_FLAG_NAME
		serverReady.Value = true
		serverReady.Parent = ReplicatedStorage
	end):catch(function(err)
		Knit.Logger:Warn("[smain] A fatal error occurred while starting Knit: {:?}", err)

		-- Shut down server if the game won't load
		local function kickPlayer(player)
			player:Kick("A fatal error occurred while starting the game and the server has been shut down, please rejoin.")
		end

		Players.PlayerAdded:Connect(kickPlayer)
		for _, player in ipairs(Players:GetPlayers()) do
			kickPlayer(player)
		end
	end)
end

startServer()
