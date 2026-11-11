--!strict
local MovementController = {}
MovementController.__index = MovementController

export type MovementController = {
	Player:Player;
	Character:Model;
	Humanoid:Humanoid;
	
	FIRST_JUMP_POWER:number;
	DOUBLE_JUMP_POWER:number;
	JUMP_COOLDOWN:number;
	jumpButtonPresses:number;
	doubleJumpCooldownTimer:number;
	
	connections:{[string]:RBXScriptConnection?};
	
	start:(self:MovementController) -> ();
	destroy:(self:MovementController) -> ();
}

function MovementController.new(player:Player, character:Model):MovementController
	local self = setmetatable({}, MovementController)::MovementController
	
	self.Player = player;
	self.Character = character;
	self.Humanoid = character:WaitForChild("Humanoid")
	
	self.FIRST_JUMP_POWER = 50;
	self.DOUBLE_JUMP_POWER = 150;
	self.JUMP_COOLDOWN = 0.2;
	self.jumpButtonPresses = 0;
	self.doubleJumpCooldownTimer = 0;
	
	self.connections = {};
	
	return self
end

local function _bindDoubleJumpEvents(self:MovementController)
	self.connections["WhenJumpButtonPressed"] = game:GetService("UserInputService").InputBegan:Connect(function(input:InputObject, ganeProcessed:boolean)
		if ganeProcessed then return end
		if input.KeyCode ~= Enum.KeyCode.Space then return end
		if self.jumpButtonPresses >= 2 or self.doubleJumpCooldownTimer > 0 then return end
		self.jumpButtonPresses += 1
		
		-- if second valid jump press, then double jump
		if self.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall or self.jumpButtonPresses == 1 then return end
		self.Humanoid.JumpPower = self.DOUBLE_JUMP_POWER
		self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		self.doubleJumpCooldownTimer = self.JUMP_COOLDOWN
		warn("double jumped")
	end)
	
	self.connections["WhenHumanoidHitGround"] = self.Humanoid.StateChanged:Connect(function(old:Enum.HumanoidStateType, new:Enum.HumanoidStateType)
		if new ~= Enum.HumanoidStateType.Landed then return end
		self.jumpButtonPresses = 0
		self.Humanoid.JumpPower = self.FIRST_JUMP_POWER
	end)
	
	self.connections["UpdateDoubleJumpCooldown"] = game:GetService("RunService").Heartbeat:Connect(function(deltaTime:number)
		if self.doubleJumpCooldownTimer <= 0 then return end
		self.doubleJumpCooldownTimer -= deltaTime
	end)
end

function MovementController.start(self:MovementController)
	self.Humanoid.UseJumpPower = true
	self.Humanoid.JumpPower = self.FIRST_JUMP_POWER
	
	_bindDoubleJumpEvents(self)
	-- SPRINTING IS HANDLED BY A SEPARATE MODULE
end

function MovementController.destroy(self:MovementController)
	for connectionName, connection in pairs(self.connections) do
		if not connection then continue end
		connection:Disconnect()
		self.connections[connectionName] = nil
	end
end

return MovementController