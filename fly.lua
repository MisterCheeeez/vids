-- Enhanced Fly Script for Roblox
-- Fixes movement issues and notification spam

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local torso = character:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 50
local flyKey = Enum.KeyCode.E
local lastNotificationTime = 0
local notificationCooldown = 3 -- seconds between notifications

-- Function to show notifications with cooldown
local function showNotification(title, text)
    local currentTime = tick()
    if currentTime - lastNotificationTime >= notificationCooldown then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
        lastNotificationTime = currentTime
    end
end

-- Function to enable flying
local function enableFlying()
    if flying then return end
    
    flying = true
    humanoid.PlatformStand = true
    
    -- Create flight controls
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.P = 10000
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    bg.Parent = torso
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.velocity = Vector3.new(0, 0.1, 0) -- Small upward velocity to prevent falling
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = torso
    
    -- Store the original walkspeed
    if not humanoid:FindFirstChild("OriginalWalkSpeed") then
        local originalWalkSpeed = Instance.new("NumberValue")
        originalWalkSpeed.Name = "OriginalWalkSpeed"
        originalWalkSpeed.Value = humanoid.WalkSpeed
        originalWalkSpeed.Parent = humanoid
    end
    
    -- Control flying with WASD and Space/Shift
    local userInputService = game:GetService("UserInputService")
    local connection
    
    connection = userInputService.InputChanged:Connect(function(input)
        if not flying then 
            connection:Disconnect()
            return 
        end
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local direction = Vector3.new(0, 0, 0)
            
            if userInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + (torso
