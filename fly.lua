-- Fly Script for Roblox
-- Put this in a LocalScript or add to your Script Hub

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local torso = character:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 50
local flyKey = Enum.KeyCode.E -- Change this to your preferred activation key

-- Function to enable flying
local function enableFlying()
    if flying then return end
    
    flying = true
    humanoid.PlatformStand = true
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.P = 10000
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = torso.CFrame
    bg.Parent = torso
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.velocity = Vector3.new(0, 0, 0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = torso
    
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
                direction = direction + (torso.CFrame.LookVector * flySpeed)
            end
            if userInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction + (torso.CFrame.LookVector * -flySpeed)
            end
            if userInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction + (torso.CFrame.RightVector * -flySpeed)
            end
            if userInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + (torso.CFrame.RightVector * flySpeed)
            end
            if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + (Vector3.new(0, flySpeed, 0))
            end
            if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction + (Vector3.new(0, -flySpeed, 0))
            end
            
            bv.velocity = direction
            bg.cframe = torso.CFrame
        end
    end)
    
    -- Notify player
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fly Enabled",
        Text = "Press "..tostring(flyKey).." to disable. WASD+Space/Shift to move.",
        Duration = 5
    })
end

-- Function to disable flying
local function disableFlying()
    if not flying then return end
    
    flying = false
    humanoid.PlatformStand = false
    
    if torso:FindFirstChild("FlyGyro") then
        torso.FlyGyro:Destroy()
    end
    
    if torso:FindFirstChild("FlyVelocity") then
        torso.FlyVelocity:Destroy()
    end
    
    -- Notify player
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fly Disabled",
        Text = "Press "..tostring(flyKey).." to enable flying again.",
        Duration = 5
    })
end

-- Toggle flying with the flyKey
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == flyKey then
        if flying then
            disableFlying()
        else
            enableFlying()
        end
    end
end)

-- Clean up when character respawns
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    torso = character:WaitForChild("HumanoidRootPart")
    disableFlying()
end)
