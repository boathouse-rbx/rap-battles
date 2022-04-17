local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Global = Knit.Global
local Assets = Knit.Assets

local ToolService = Knit.CreateService {
	Name = "ToolService",
	Client = {},
}

local Microphone = Assets:WaitForChild("Microphone", 1)

function ToolService:GiveMicrophone(player)
	if self:HasMicrophone(player) then
		return
	end

	local clone = Microphone:Clone()
	clone.Parent = player:WaitForChild("Backpack")
end

function ToolService:EquipMicrophone(player)
	local playerMicrophone = self:GetMicrophone(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")

	if playerMicrophone and humanoid then
		humanoid:EquipTool(playerMicrophone)
	end
end

function ToolService:UnequipMicrophone(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid:UnequipTools()
	end
end

function ToolService:HasMicrophone(player)
	return if self:GetMicrophone(player) then true else false
end

function ToolService:GetMicrophone(player)
	local character = player.Character or player.CharacterAdded:Wait()
	return player.Backpack:FindFirstChild("Microphone") or character:FindFirstChild("Microphone")
end

function ToolService:GetSkin(player)
	local playerMicrophone = ToolService:GetMicrophone(player)
	local handle = playerMicrophone:FindFirstChild("Handle")

	if playerMicrophone then
		return handle.TextureID
	end
end

function ToolService:ChangeSkin(player, newSkin)
	local playerMicrophone = ToolService:GetMicrophone(player)
	local handle = playerMicrophone:FindFirstChild("Handle")

	if handle then
		handle.TextureID = newSkin
	end
end

function ToolService.Client:GetSkin(player)
	return ToolService:GetSkin(player)
end

function ToolService.Client:ChangeSkin(player, newSkin)
	ToolService:ChangeSkin(player, newSkin)
end

function ToolService:KnitStart()
	local DataService = Knit.GetService("DataService")

	local function onPlayerAdded(player)
		local skin = DataService:GetSkin(player) or Global.MIC_SKINS[1].Texture
		self:GiveMicrophone(player)
		self:ChangeSkin(player, skin)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
end

return ToolService
