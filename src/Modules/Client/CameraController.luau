--!strict
local CameraController = {}
CameraController.__index = CameraController
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

export type CameraController = {
	Player:Player;
	Character:Model;
	Camera:Camera;
	
	shiftLockEnabled:boolean;
	
	NORMAL_FOV:number;
	SPRINTING_FOV:number;
	
	connections:{[string]:RBXScriptConnection};
	
	start:(self:CameraController)->();
	destroy:(self:CameraController)->();
}

function CameraController.new(player:Player, character:Model):CameraController
	local self = setmetatable({}, CameraController) :: CameraController
	
	self.Player = player;
	self.Character = character;
	self.Camera = game:GetService("Workspace"):WaitForChild("Camera")
	
	self.shiftLockEnabled = false
	
	self.NORMAL_FOV = 70
	self.SPRINTING_FOV = 90
	
	self.connections = {}
	
	return self
end

function _bindCameraFOVEvents(self:CameraController)
	local function _changeCameraFOV(self:CameraController,fov:number)
		local tween = TweenService:Create(self.Camera,TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{FieldOfView = fov})
		tween:Play()
	end
	
	self.connections["WhenShiftPressed"] = UserInputService.InputBegan:Connect(function(input:InputObject, gameProcessedEvent:boolean)
		if gameProcessedEvent then return end
		if input.KeyCode ~= Enum.KeyCode.LeftShift then return end
		_changeCameraFOV(self, self.SPRINTING_FOV)
	end)

	self.connections["WhenShiftLifted"] = UserInputService.InputEnded:Connect(function(input:InputObject, gameProcessedEvent:boolean)
		if gameProcessedEvent then return end
		if input.KeyCode ~= Enum.KeyCode.LeftShift then return end
		_changeCameraFOV(self, self.NORMAL_FOV)
	end)
end

function _bindShiftLockEvents(self:CameraController)
	self.connections["WhenCtrlPressed"] = UserInputService.InputBegan:Connect(function(input:InputObject, gameProcessedEvent:boolean)
		if gameProcessedEvent then return end
		if input.KeyCode ~= Enum.KeyCode.LeftControl then return end
		self.shiftLockEnabled = not self.shiftLockEnabled
		
		if self.shiftLockEnabled then
			self.Camera.CameraType = Enum.CameraType.Scriptable
			--self.Camera.CFrame = CFrame.new(self.Character.HumanoidRootPart.Position, 
				--self.Character.HumanoidRootPart.Position + self.Camera.CFrame.LookVector + 3)			
			
			return
		end
		
	end)
end

function CameraController.start(self:CameraController)
	_bindCameraFOVEvents(self)
	_bindShiftLockEvents(self)
end

function CameraController.destroy(self:CameraController)
	for connectionName, connection in pairs(self.connections) do
		if not connection then continue end
		connection:Disconnect()
		self.connections[connectionName] = nil
	end
end

return CameraController