--- @source evaera quicksave - https://github.com/evaera/Quicksave/blob/abb7b0b73937c071804f3b8d08ae732759799d63/src/makeEnum.lua
--- @license MIT (c) 2020 eryn L. K.

local function makeEnum(enumName, members)
	local enum = {}

	for _, memberName in ipairs(members) do
		enum[memberName] = memberName
	end

	return setmetatable(enum, {
		__index = function(_, k)
			error(string.format("%s is not in %s!", k, enumName), 2)
		end,

		__newindex = function()
			error(string.format("Creating new members in %s is not allowed!", enumName), 2)
		end,

		__tostring = function()
			return string.format("Enum %s", enumName)
		end,
	})
end

return makeEnum
