--[[
    Logger - A utility that allows different levels of log to be output.
    The cutoff for message logging can be dictated on the fly,a llowing easy
    debugging for developers.
]]
local Logger = {}

local RunService = game:GetService("RunService")

local display = require(script.display)

--- @todo MAGE team to split this off into its own library

Logger.LOG_LEVEL = {
  Silly = 0,
	Trace = 1,
	Debug = 2,
	Info = 3,
	Warn = 4
}
Logger.cutOff = Logger.LOG_LEVEL.Trace

local corePrefix = ""
if RunService:IsStudio() then
	if RunService:IsServer() and RunService:IsClient() then
			corePrefix = "[DUAL] "
	elseif RunService:IsServer() then
		corePrefix = "[SERVER] "
	elseif RunService:IsClient() then
		corePrefix = "[CLIENT] "
	else
		corePrefix = "[SHARED] "
	end
end

--[[
	Does fancy formatting stuff
]]
local function format(template, ...)
	local values = {...}
	local matchCount = 0

	local result = template:gsub("{([^}]*)}", function(args)
		matchCount = matchCount + 1
		local value = values[matchCount]

		if args == ":?" then
			return display(value)
		elseif args == "" then
			return tostring(value)
		else
			error(("Invalid format string %q"):format(args))
		end
	end)

	return result
end

--[[
	Grabs the name of the script calling logger using debug.traceback
]]
local function getScriptName()
	local stackTrace = debug.traceback()
	local scriptName
	local lineNumber = 0
	for trace in stackTrace:gmatch("([%a%p]+:)") do
		lineNumber = lineNumber + 1
		-- Need to find the third trace to ignore the logger script
		if lineNumber == 3 then
			-- Need to reverse the string and result to get the last match
			scriptName = string.match(trace:reverse(), "(%a+)%."):reverse()
			break
		end
	end
	-- Command line will not return a valid scriptName
	return scriptName or "Command"
end

--[[
	Sets the cut off for logging messages, allowing only a specific level of message to go through
]]
function Logger:SetCutoff(cutOff)
	if cutOff < self.LOG_LEVEL.Silly or cutOff > self.LOG_LEVEL.Warn then
		self:Warn("[Logger] Tried to set Logger cutoff to an invalid number")
		return
	end
	self.cutOff = cutOff
end

--[[
    Prints formatted string output with specified level
]]
function Logger:Raise(level, _, template, ...) --: string, ...any => void
	local prefix = string.format("%s[%s] ", corePrefix, level:upper())
	local output = level == "Warn" and warn or print
	output(format(prefix .. template, ...))
end

--[[
    Checks cut off, then sends a Silly log
]]
function Logger:Silly(...) --: ...any => void
	if self.cutOff <= self.LOG_LEVEL.Silly then
		local scriptName = getScriptName()
		self:Raise("Silly", scriptName, ...)
	end
end

--[[
    Checks cut off, then sends a Trace log
]]
function Logger:Trace(...) --: ...any => void
	if self.cutOff <= self.LOG_LEVEL.Trace then
		local scriptName = getScriptName()
		self:Raise("Trace", scriptName, ...)
	end
end

--[[
    Checks cut off, then sends a Debug log
]]
function Logger:Debug(...) --: ...any => void
	if self.cutOff <= self.LOG_LEVEL.Debug then
		local scriptName = getScriptName()
		self:Raise("Debug", scriptName, ...)
	end
end

--[[
    Checks cut off, then sends an Info log
]]
function Logger:Info(...) --: ...any => void
	if self.cutOff <= self.LOG_LEVEL.Info then
		local scriptName = getScriptName()
		self:Raise("Info", scriptName, ...)
	end
end

--[[
    Checks cut off, then sends a Warn log
]]
function Logger:Warn(...) --: ...any => void
	if self.cutOff <= self.LOG_LEVEL.Warn then
		local scriptName = getScriptName()
		self:Raise("Warn", scriptName, ...)
	end
end

return Logger
