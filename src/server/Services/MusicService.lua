local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

local Global = Knit.Global

local MusicService = Knit.CreateService {
	Name = "MusicService",
	Client = {
		Playing = Knit.CreateSignal(),
		Ended = Knit.CreateSignal(),

		VolumeSliderChanged = Knit.CreateSignal(),
		ReverbSliderChanged = Knit.CreateSignal(),
		DistortionSliderChanged = Knit.CreateSignal(),
		PitchSliderChanged = Knit.CreateSignal()
	},
}

local Queue = {}

local DEFAULT_LENGTH = 60
local DEFAULT_VOLUME = 0.6

local MAX_VOLUME = 3
local MIN_VOLUME = 0.2

local DEFAULT_DRYLEVEL = 15
local DEFAULT_DIFFUSION = 0

local DENSITY_MIN = 0
local DENSITY_MAX = 1

local REVERB_MULTIPLIER = 10

local PITCH_DIVISOR = 2

local SOUND_TWEEN_INFO = TweenInfo.new(math.pi, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

function MusicService:KnitInit()
	self.GamepassService = Knit.GetService("GamepassService")
	self.RoundService = Knit.GetService("RoundService")
end

function MusicService:AddToQueue(id)
	for _, song in ipairs(Queue) do
		if song == id then
			return
		else
			table.insert(Queue, id)
			return
		end
	end
end

function MusicService:Play(id: number, length: number?)
	length = length or DEFAULT_LENGTH

	self.Sound.SoundId = "rbxassetid://" .. id
	self.Sound:Play()

	local name = self:GetSoundName()
	MusicService.Client.Playing:FireAll(name)

	local onPlayerAdded = Players.PlayerAdded:Connect(function(player)
		MusicService.Client.Playing:Fire(player, name)
	end)

	self.Sound.Paused:Connect(function()
		onPlayerAdded:Disconnect()
		MusicService.Client.Ended:FireAll()
	end)

	self.Sound.Ended:Connect(function()
		onPlayerAdded:Disconnect()
		MusicService.Client.Ended:FireAll()
	end)
end

function MusicService:TweenVolume(volume)
	volume = volume or DEFAULT_VOLUME

	local tween = TweenService:Create(self.Sound, SOUND_TWEEN_INFO, {
		Volume = volume
	})

	tween:Play()
	tween.Completed:Wait()
end

function MusicService:Stop(transition: boolean?)
	transition = transition or false

	if not transition then
		self:HardStop()
	else
		self:TweenVolume(0)
		self:HardStop()
	end
end

function MusicService:GetSoundName()
	local id = MusicService:GetSoundId()

	local function getInfo()
		return Promise.async(function(resolve, reject)
			local success, result = pcall(function()
				return MarketplaceService:GetProductInfo(id)
			end)

			if success then
				resolve(result)
			else
				reject(result)
			end
		end)
	end

	local success, result = getInfo():await()

	if success then
		return result.Name
	else
		warn(result)
		return "Unknown"
	end
end

function MusicService.Client:GetSoundName()
	return MusicService:GetSoundName()
end

function MusicService:Pause()
	self.Sound:Pause()
end

function MusicService:HardStop()
	self.Sound:Stop()
	self.Sound.SoundId = ""
end

function MusicService:ConvertID(id)
	local omitted = string.gsub(id, "rbxassetid://", "")
	return tonumber(omitted)
end

function MusicService:GetSoundId()
	local omitted = string.gsub(self.Sound.SoundId, "rbxassetid://", "")
	return tonumber(omitted)
end

function MusicService:PlayerIsDJ(player)
	return self.GamepassService:PlayerOwnGamepass(player, Global.PRODUCTS.GAMEPASSES.DJ)
end

function MusicService.Client:ChangeVolume(player, newVolume)
	if MusicService:PlayerIsDJ(player) then
		MusicService.Sound.Volume = math.clamp(newVolume * 2, MIN_VOLUME, MAX_VOLUME)

		for _, filteredPlayer in ipairs(Players:GetPlayers()) do
			if MusicService:PlayerIsDJ(filteredPlayer) and not filteredPlayer == player then
				MusicService.Client.VolumeSliderChanged:Fire(filteredPlayer, newVolume)
			end
		end
	end
end

function MusicService.Client:ChangeReverb(player, newReverb)
	if MusicService:PlayerIsDJ(player) then
		local density = math.clamp(
			newReverb,
			DENSITY_MIN,
			DENSITY_MAX
		)

		MusicService.Reverb.Enabled = if newReverb == 0 then false else true
		MusicService.Reverb.Density = density
		MusicService.Reverb.DryLevel = density + math.sin(density) * REVERB_MULTIPLIER

		for _, filteredPlayer in ipairs(Players:GetPlayers()) do
			if MusicService:PlayerIsDJ(filteredPlayer) and not filteredPlayer == player then
				MusicService.Client.ReverbSliderChanged:Fire(filteredPlayer, newReverb)
			end
		end
	end
end

function MusicService.Client:ChangePitch(player, newPitch)
	if MusicService:PlayerIsDJ(player) then
		MusicService.Pitch.Enabled = if newPitch == 0 then false else true
		MusicService.Pitch.Octave = newPitch + math.sin(newPitch) / PITCH_DIVISOR

		for _, filteredPlayer in ipairs(Players:GetPlayers()) do
			if MusicService:PlayerIsDJ(filteredPlayer) and not filteredPlayer == player then
				MusicService.Client.PitchSliderChanged:Fire(filteredPlayer, newPitch)
			end
		end
	end
end

function MusicService.Client:ChangeDistortion(player, newDistortion)
	if MusicService:PlayerIsDJ(player) then
		MusicService.Distortion.Enabled = if newDistortion == 0 then false else true
		MusicService.Distortion.Level = newDistortion

		for _, filteredPlayer in ipairs(Players:GetPlayers()) do
			if MusicService:PlayerIsDJ(filteredPlayer) and not filteredPlayer == player then
				MusicService.Client.BassSliderChanged:Fire(filteredPlayer, newDistortion)
			end
		end
	end
end

function MusicService:CreateSound()
	local sound = Instance.new("Sound")
	sound.Parent = workspace

	local distortion = Instance.new("DistortionSoundEffect")
	distortion.Parent = sound
	distortion.Enabled = false

	local reverb = Instance.new("ReverbSoundEffect")
	reverb.Parent = sound
	reverb.Enabled = false
	reverb.DryLevel = DEFAULT_DRYLEVEL
	reverb.Diffusion = DEFAULT_DIFFUSION

	local pitch = Instance.new("PitchShiftSoundEffect")
	pitch.Parent = sound
	pitch.Enabled = false

	self.Sound = sound
	self.Reverb = reverb
	self.Pitch = pitch
	self.Distortion = distortion
end

function MusicService:KnitStart()
	self:CreateSound()

	local function getRandomSound()
		local list = Global.ROUND_MUSIC.ROUND_BEATS
		return list[math.random(1, #list)]
	end

	self.RoundService.TurnBegan:Connect(function(player)
		local sound = getRandomSound()
		local length = self.RoundService:GetRapTime(player)
		self:Play(sound, length)
	end)

	self.RoundService.TurnEnded:Connect(function()
		self:Stop(true)
	end)
end

return MusicService
