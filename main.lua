-- ==== UTILITY FUNCTIONS ====
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Teleport helper
local function teleportTo(targetCFrame)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = targetCFrame
    end
end

-- ==== 1) TELEPORT TOOL ====
Section1:Dropdown({
    Title       = "Teleport To Player",
    Description = "Select a player to TP to",
    Items       = function() 
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(list, p.Name) end
        end
        return list
    end,
    Default     = nil,
}, function(playerName)
    local target = Players:FindFirstChild(playerName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        teleportTo(target.Character.HumanoidRootPart.CFrame)
        print("Teleported to", playerName)
    end
end)

-- ==== 2) FLY / NO-CLIP MODE ====
local flying = false
local bv, bg

local function startFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    -- setup BodyVelocity & BodyGyro
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = root

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bg.CFrame = root.CFrame
    bg.Parent = root

    -- no-clip
    RunService.Stepped:Connect(function()
        if flying then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    -- movement
    local direction = Vector3.new()
    local function updateVel()
        local camCF = workspace.CurrentCamera.CFrame
        local move = Vector3.new()
        if direction.Z ~= 0 then move = move + (camCF.LookVector * direction.Z) end
        if direction.X ~= 0 then move = move + (camCF.RightVector * direction.X) end
        bv.Velocity = move * 50 + Vector3.new(0, direction.Y * 50, 0)
        bg.CFrame = CFrame.new(root.Position, root.Position + camCF.LookVector)
    end

    -- input handlers
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.W then direction = direction + Vector3.new(0,0,-1) end
            if input.KeyCode == Enum.KeyCode.S then direction = direction + Vector3.new(0,0,1) end
            if input.KeyCode == Enum.KeyCode.A then direction = direction + Vector3.new(-1,0,0) end
            if input.KeyCode == Enum.KeyCode.D then direction = direction + Vector3.new(1,0,0) end
            if input.KeyCode == Enum.KeyCode.Space then direction = direction + Vector3.new(0,1,0) end
            if input.KeyCode == Enum.KeyCode.LeftControl then direction = direction + Vector3.new(0,-1,0) end
        end
        updateVel()
    end
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.W then direction = direction - Vector3.new(0,0,-1) end
            if input.KeyCode == Enum.KeyCode.S then direction = direction - Vector3.new(0,0,1) end
            if input.KeyCode == Enum.KeyCode.A then direction = direction - Vector3.new(-1,0,0) end
            if input.KeyCode == Enum.KeyCode.D then direction = direction - Vector3.new(1,0,0) end
            if input.KeyCode == Enum.KeyCode.Space then direction = direction - Vector3.new(0,1,0) end
            if input.KeyCode == Enum.KeyCode.LeftControl then direction = direction - Vector3.new(0,-1,0) end
        end
        updateVel()
    end

    UserInputService.InputBegan:Connect(onInputBegan)
    UserInputService.InputEnded:Connect(onInputEnded)
end

local function stopFly()
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    -- restore collisions
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

Section1:Toggle({
    Title       = "Fly Mode",
    Description = "Toggle fly / noclip (Infinite Yield style)",
    Default     = false,
}, function(value)
    flying = value
    if flying then
        startFly()
        print("Fly mode enabled")
    else
        stopFly()
        print("Fly mode disabled")
    end
end)

-- ==== 3) ESP (Extra Sensory Perception) ====
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "AdminESP"

local function createESPBillboard(target)
    if not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bill = Instance.new("BillboardGui")
    bill.Name = "ESP_"..target.Name
    bill.Adornee = hrp
    bill.Size = UDim2.new(0,100,0,40)
    bill.AlwaysOnTop = true
    bill.Parent = espFolder

    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.Text = target.Name
    txt.TextScaled = true
    txt.TextStrokeTransparency = 0
    txt.TextColor3 = Color3.new(1,0,0)
end

local function clearESP()
    espFolder:ClearAllChildren()
end

Section1:Toggle({
    Title       = "ESP",
    Description = "Toggle name ESP on all players",
    Default     = false,
}, function(enabled)
    clearESP()
    if enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then createESPBillboard(p) end
        end
        -- watch for new players
        Players.PlayerAdded:Connect(function(p) createESPBillboard(p) end)
    end
end)

-- ==== 4) GOD MODE / INVINCIBILITY ====
local godEnabled = false
local function onHealthChanged(hum, newHealth)
    if godEnabled and newHealth < hum.MaxHealth then
        hum.Health = hum.MaxHealth
    end
end

Section1:Toggle({
    Title       = "God Mode",
    Description = "Prevents you from taking damage",
    Default     = false,
}, function(enabled)
    godEnabled = enabled
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if enabled then
                hum.MaxHealth = math.huge
                hum.Health = hum.MaxHealth
                hum.HealthChanged:Connect(function(new) onHealthChanged(hum, new) end)
            else
                hum.MaxHealth = 100
                hum.Health = 100
            end
        end
    end
    print("God Mode is now", enabled and "ON" or "OFF")
end)

-- Persist God Mode across respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    if godEnabled then
        local hum = char:WaitForChild("Humanoid")
        hum.MaxHealth = math.huge
        hum.Health = hum.MaxHealth
        hum.HealthChanged:Connect(function(new) onHealthChanged(hum, new) end)
    end
end)
