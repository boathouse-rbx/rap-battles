local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function knitLoader(Knit)
	Knit.Shared = ReplicatedStorage:WaitForChild("Shared")
	Knit.Packages = ReplicatedStorage:WaitForChild("Packages")
	Knit.Library = ReplicatedStorage:WaitForChild("Library")
	Knit.Assets = ReplicatedStorage:WaitForChild("Assets")

	-- It's safe for us to inject these dependencies as they will be used universally
	Knit.Logger = require(Knit.Shared.Logger)
	Knit.Global = require(Knit.Shared.Global)

	-- Returns a common loader for services and controllers
	local function recursive(parent, callback)
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("ModuleScript") then
				callback(child)
			elseif child:IsA("Folder") then
				recursive(child, callback)
			end
		end
	end

	return recursive
end

return knitLoader
