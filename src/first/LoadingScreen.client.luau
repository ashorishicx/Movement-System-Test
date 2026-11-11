local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")

ReplicatedFirst:RemoveDefaultLoadingScreen()
if not game:IsLoaded() then game.Loaded:Wait() end

local assets = game:GetDescendants()	-- can later improver by having for loop only consider certain services
local totalAssets = #assets
local totalAssetsLoaded = 0

local LoadingScreenGui = script:WaitForChild("LoadingScreenGui")
local LoadingScreenProgress = LoadingScreenGui:WaitForChild("Frame"):WaitForChild("TextLabel")
LoadingScreenProgress.Text = `Loading Assets ({totalAssetsLoaded}/{totalAssets})`
LoadingScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

for _, asset in ipairs(assets) do
	local success, result = pcall(function()
		return ContentProvider:PreloadAsync({asset}) -- downloads asset from roblox server to client before rendered in game
	end)
	
	if not success then
		warn(`[!] Failed to load {asset.Name}: {result}`)
		continue
	end
	
	totalAssetsLoaded += 1
	LoadingScreenProgress.Text = `Loading Assets ({totalAssetsLoaded}/{totalAssets})`
end

print(`[*] Successfully loaded {totalAssetsLoaded}/{totalAssets} assets`)
task.wait(0.5)	-- allow the client to have the satisfaction of seeing it completed lol
LoadingScreenGui:Destroy()