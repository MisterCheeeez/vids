-- Pure server-side infinite jump
-- Place in ServerScriptService

local Players = game:GetService("Players")
local JumpDebounce = 0.2 -- Prevent jump spamming

-- Configuration
local JUMP_POWER_MULTIPLIER = 1.5
local MAX_JUMP_TIME = 1 -- Seconds before auto-disable

local playerStates = {}

local function enableInfiniteJump(player)
    local state = playerStates[player]
    if not state or state.enabled then return end
    
    state.enabled = true
    local humanoid = state.humanoid
    state.originalJumpPower = humanoid.JumpPower
    humanoid.JumpPower = state.originalJumpPower * JUMP_POWER_MULTIPLIER
    
    -- Notify player through chat
    player:SendSystemMessage("Infinite Jump: ON (Auto-disables after "..MAX_JUMP_TIME.."s)")
    
    -- Auto-disable after time limit
    state.jumpEndTime = os.time() + MAX_JUMP_TIME
end

local function disableInfiniteJump(player)
    local state = playerStates[player]
    if not state or not state.enabled then return end
    
    state.enabled = false
    local humanoid = state.humanoid
    if state.originalJumpPower then
        humanoid.JumpPower = state.originalJumpPower
    end
    
    -- Notify player through chat
    player:SendSystemMessage("Infinite Jump: OFF")
end

local function onCharacterAdded(player, character)
    local humanoid = character:WaitForChild("Humanoid")
    
    playerStates[player] = {
        humanoid = humanoid,
        enabled = false,
        lastJumpTime = 0,
        jumpEndTime = 0
    }
    
    -- Detect jumping state
    humanoid.StateChanged:Connect(function(oldState, newState)
        local state = playerStates[player]
        if not state then return end
        
        local currentTime = os.time()
        
        -- Detect when player starts jumping
        if newState == Enum.HumanoidStateType.Jumping then
            if currentTime - state.lastJumpTime > JumpDebounce then
                state.lastJumpTime = currentTime
                enableInfiniteJump(player)
            end
        end
        
        -- Detect when player lands
        if newState == Enum.HumanoidStateType.Landed then
            if state.enabled and currentTime >= state.jumpEndTime then
                disableInfiniteJump(player)
            end
        end
    end)
    
    -- Clean up when character dies
    humanoid.Died:Connect(function()
        disableInfiniteJump(player)
    end)
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)
    
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
    
    -- Clean up when player leaves
    player.PlayerRemoving:Connect(function()
        playerStates[player] = nil
    end)
end

-- Initialize for all players
Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
