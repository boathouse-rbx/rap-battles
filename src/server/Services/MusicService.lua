local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Global = Knit.Global

local MusicService = Knit.CreateService {
	Name = "MusicService",
	Client = {},
}

local Queue = {}

local DEFAULT_LENGTH = 60
local DEFAULT_VOLUME = 0.6

local SOUND_TWEEN_INFO = TweenInfo.new(math.pi, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

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

function MusicService:Play(id: string, length: number?)
	length = length or DEFAULT_LENGTH

	self.Sound.SoundId = id
	self.Sound:Play()

	while self.Sound.Playing do
		if self.Sound.TimePosition >= length then
			self:Stop(true)
			break
		end

		task.wait()
	end
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

function MusicService:Pause()
	self.Sound:Pause()
end

function MusicService:HardStop()
	self.Sound:Stop()
	self.SoundId = ""
end

function MusicService:CreateSound()
	local sound = Instance.new("Sound")
	sound.Parent = workspace

	local echo = Instance.new("EchoSoundEffect")
	echo.Parent = sound
	echo.Enabled = false

	local reverb = Instance.new("ReverbSoundEffect")
	reverb.Parent = sound
	reverb.Enabled = false

	local pitch = Instance.new("PitchShiftSoundEffect")
	pitch.Parent = sound
	pitch.Enabled = false

	self.Reverb = reverb
	self.Pitch = pitch
	self.Sound = sound
	self.Echo = echo
end

function MusicService:KnitStart()
	self:CreateSound()
	--self:Play(Global.ROUND_MUSIC.ROUND_BEATS[5], 30)
end

return MusicService
