-- will learn how to code ui controllers later, so ignore that the existence of this script is terrible architecture 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local ScreenGui = PlayerGui:WaitForChild("ScreenGui")
local StaminaBar = ScreenGui:WaitForChild("StaminaAmount")
local StaminaNumber = ScreenGui:WaitForChild("amount")


ReplicatedStorage:WaitForChild("updatestam").Event:Connect(function(staminaAmount)
	StaminaBar.Size = UDim2.new(0.2 * (0.01 * staminaAmount), 0, 0.05, 0)
	StaminaNumber.Text = `Stamina: {math.round(staminaAmount)}`
end)
