local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PlayerService = Knit.CreateService {
	Name = "PlayerService",
	Client = {},
}

function PlayerService.OnPlayerAdded(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local Wins = Instance.new("IntValue")
	Wins.Name = "Wins"
	Wins.Value = 0
	Wins.Parent = leaderstats
end

function PlayerService:ChangeWins(player, Wins)
	local leaderstats = player:WaitForChild("leaderstats")
	local wins = player:WaitForChild("Wins")

	if wins then
		wins.Value = Wins
	end
end

function PlayerService.Client:UpdateNeck(player, C0)
	local character = player.Character or player.CharacterAdded:Wait()
	local Head = character:FindFirstChild("Head")
	local Neck = Head:WaitForChild("Neck")

	if Neck then
		Neck.C0 = C0
	end
end

function PlayerService:KnitStart()
	for _, player in ipairs(Players:GetPlayers()) do
		self.OnPlayerAdded(player)
	end

	Players.PlayerAdded:Connect(self.OnPlayerAdded)
end

return PlayerService
