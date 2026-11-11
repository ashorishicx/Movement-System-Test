--!strict
local StaminaSystem = {}
StaminaSystem.__index = StaminaSystem
local UserInputService = game:GetService("UserInputService")

export type StaminaSystem = {
	Player:Player;
	Character:Model;
	Humanoid:Humanoid;
	
	isSprinting:boolean;
	isShiftKeyDown:boolean;
	isMoving:boolean;
	
	WALK_SPEED:number;
	SPRINT_SPEED:number;
	
	StaminaAmount:number;
	StaminaExhaustionTimer:number;	-- if stamina is exhausted this is > 0
	MAX_STAMINA_AMOUNT:number;
	MIN_STAMINA_AMOUNT:number;
	STAMINA_DEPLETION_RATE:number; -- how much stamina is lost per second?
	STAMINA_REGENERATION_RATE:number; -- how much stamina is regained per second?
	MAX_STAMINA_EXHAUSTION_TIMER:number; -- how much time until regen stamina if it was exhausted?
	
	connections:{[string]:RBXScriptConnection};
	
	start:(self:StaminaSystem)->();
	destroy:(self:StaminaSystem)->();	
}

function StaminaSystem.new(player:Player, character:Model)
	local self = setmetatable({}, StaminaSystem)::StaminaSystem
	
	self.Player = player
	self.Character = character
	self.Humanoid = character:WaitForChild("Humanoid")
	
	self.isShiftKeyDown = false
	self.isMoving = false
	self.isSprinting = false
	
	self.WALK_SPEED = 12
	self.SPRINT_SPEED = 26
	
	self.StaminaAmount = 100
	self.StaminaExhaustionTimer = 0
	self.MAX_STAMINA_AMOUNT = 100
	self.MIN_STAMINA_AMOUNT = 0 
	self.STAMINA_DEPLETION_RATE = 10
	self.STAMINA_REGENERATION_RATE = 20
	self.MAX_STAMINA_EXHAUSTION_TIMER = 2	
	
	self.connections = {}
	
	return self
end

local function _updateSprintState(self:StaminaSystem)
	if self.isShiftKeyDown and self.isMoving and self.StaminaExhaustionTimer <= 0 then
		--warn("you would be able to run")
		self.isSprinting = true
		self.Humanoid.WalkSpeed = self.SPRINT_SPEED
	else
		--warn("you would not be able to run!")
		self.isSprinting = false
		self.Humanoid.WalkSpeed = self.WALK_SPEED
	end
end

function StaminaSystem.start(self:StaminaSystem)
	
	self.Humanoid.WalkSpeed = self.WALK_SPEED
	
	self.connections["ShiftKeyBegan"] = UserInputService.InputBegan:Connect(function(input:InputObject, gameProcessedEvent:boolean)
		if gameProcessedEvent then return end
		if input.KeyCode ~= Enum.KeyCode.LeftShift and input.KeyCode ~= Enum.KeyCode.RightShift then return end
		self.isShiftKeyDown = true
		_updateSprintState(self)
	end)

	self.connections["ShiftKeyEnded"] = UserInputService.InputEnded:Connect(function(input:InputObject, gameProcessedEvent:boolean)
		if gameProcessedEvent then return end
		if input.KeyCode ~= Enum.KeyCode.LeftShift and input.KeyCode ~= Enum.KeyCode.RightShift then return end
		self.isShiftKeyDown = false
		_updateSprintState(self)
	end)
	
	self.connections["MovementChanged"] = self.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()	
		if self.Humanoid.MoveDirection.Magnitude > 0 then
			self.isMoving = true
			_updateSprintState(self)
		else
			self.isMoving = false
			_updateSprintState(self)
		end
	end)
	
	self.connections["UpdateStamina"] = game:GetService("RunService").Heartbeat:Connect(function(deltaTime:number)
		if self.StaminaExhaustionTimer > 0 then
			self.StaminaExhaustionTimer -= deltaTime
			if self.StaminaExhaustionTimer <= 0 then
				self.isSprinting = false
			end
		elseif self.isSprinting then
			self.StaminaAmount = math.clamp(
				self.StaminaAmount - self.STAMINA_DEPLETION_RATE * deltaTime,
				self.MIN_STAMINA_AMOUNT,
				self.MAX_STAMINA_AMOUNT
			)
			game:GetService("ReplicatedStorage"):WaitForChild("updatestam"):Fire(self.StaminaAmount)
			
			if self.StaminaAmount == self.MIN_STAMINA_AMOUNT then 
				warn(`{self.Player.Name} depleted all their stamina!`)
				self.isSprinting = false
				self.StaminaExhaustionTimer = 2
			end
		else
			self.StaminaAmount = math.clamp(
				self.StaminaAmount + self.STAMINA_REGENERATION_RATE * deltaTime, 
				self.MIN_STAMINA_AMOUNT,
				self.MAX_STAMINA_AMOUNT
			)
			game:GetService("ReplicatedStorage"):WaitForChild("updatestam"):Fire(self.StaminaAmount)			
		end
	end)
	
end

function StaminaSystem.destroy(self:StaminaSystem)
	for connectionName, connection in pairs(self.connections) do
		if not connection then continue end
		connection:Disconnect()
		self.connections[connectionName] = nil
	end
end

return StaminaSystem