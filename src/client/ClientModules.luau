local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local totalModules = 0
local totalModulesLoaded = 0
local ClientModules = {}

for _, module in ipairs(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Client"):GetDescendants()) do
	if not module:IsA("ModuleScript") or module:HasTag("SKIP_LOAD") then continue end
	totalModules += 1
	
	local success, result = pcall(function()
		return require(module)
	end)	
	
	if not success then
		warn(`[!] Failed to require {module.Name}: {result}`)
		continue
	end
	
	totalModulesLoaded += 1
	ClientModules[module.Name] = {
		class = result;
		instance = result.new(player, character);
		tags = module:GetTags();
	}
end

print(`[*] Successfully loaded {totalModulesLoaded}/{totalModules} client modules.`)

for moduleName, module in pairs(ClientModules) do
	module.instance:start()
end

player.CharacterAdded:Connect(function(newCharacter:Model)
	character = newCharacter
	
	for moduleName, module in pairs(ClientModules) do
		if table.find(module.tags, "RELOAD_ON_NEW_CHARACTER") then
			module.instance:destroy()
			module.instance = module.class.new(player, newCharacter)
		end
	end
	
	for moduleName, module in pairs(ClientModules) do
		if table.find(module.tags, "RELOAD_ON_NEW_CHARACTER") then
			module.instance:start()
		end
	end
end)

return ClientModules