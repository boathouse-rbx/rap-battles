-- So UIStrokes don't scale based on screensize, this module fixes that.

local STUDIO_SCREEN_SIZE = Vector2.new(1341, 815)
local Camera = workspace.CurrentCamera

local function GetAverage(vector)
	return (vector.X + vector.Y) / 2
end

local studioAverage = GetAverage(STUDIO_SCREEN_SIZE)
local currentScreenAverage = GetAverage(Camera.ViewportSize)

local function GetStrokeSize(strokeSize)
	local ratio = strokeSize / studioAverage
	return currentScreenAverage * ratio
end

return GetStrokeSize
