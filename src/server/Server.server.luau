local loadedModules = {}
local totalModules = 0
local totalModulesLoaded = 0

for _, module in ipairs((game:GetService("ServerScriptService").Server.Modules):GetChildren()) do
	if not module:IsA("ModuleScript") or module:HasTag("SKIP_LOAD") then continue end
	if module:HasTag("SKIP_LOAD") then continue end
	
	totalModules += 1
	
	local success, result = pcall(function()
		return require(module)
	end)
	
	if not success then
		warn(`[!] Failed to require {module.Name}: {result}`)
		continue
	end
	
	totalModulesLoaded += 1
	loadedModules[module.Name] = {
		class = result,
		instance = result.new(),
		tags = module:GetTags()
	}
end

print(`[*] Successfully loaded {totalModulesLoaded}/{totalModules} server modules`)

for moduleName, module in pairs(loadedModules) do
	if loadedModules[moduleName].instance.start then loadedModules[moduleName].instance:start() end
end