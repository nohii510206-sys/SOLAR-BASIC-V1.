
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Config = {
    NormalSpeed = 16,
    FastSpeed = 50,
    NormalJump = 50,
    HighJump = 100,
    FlySpeed = 50
}

local State = {
    Fly = false,
    Speed = false,
    HighJump = false,
    InfiniteJump = false,
    FPSTest = false
}

local Character, Humanoid, Root
local FlyVelocity, FlyAttachment
local Vertical = 0

local function GetCharacter()
    Character = Player.Character
    if not Character then return false end

    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    Root = Character:FindFirstChild("HumanoidRootPart")

    return Humanoid ~= nil and Root ~= nil
end

local function UpdateMovement()
    if not GetCharacter() then return end

    Humanoid.WalkSpeed =
        State.Speed and Config.FastSpeed or Config.NormalSpeed

    Humanoid.UseJumpPower = true
    Humanoid.JumpPower =
        State.HighJump and Config.HighJump or Config.NormalJump
end

-- FLY

local function StopFly()
    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyAttachment then
        FlyAttachment:Destroy()
        FlyAttachment = nil
    end

    Vertical = 0
end

local function StartFly()
    if not GetCharacter() then return end

    StopFly()

    FlyAttachment = Instance.new("Attachment")
    FlyAttachment.Parent = Root

    FlyVelocity = Instance.new("LinearVelocity")
    FlyVelocity.Attachment0 = FlyAttachment
    FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    FlyVelocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Vector
    FlyVelocity.ForceLimitsEnabled = false
    FlyVelocity.VectorVelocity = Vector3.zero
    FlyVelocity.Parent = Root
end

local function SetFly(enabled)
    State.Fly = enabled

    if enabled then
        StartFly()
    else
        StopFly()
    end
end

RunService.Heartbeat:Connect(function()
    if not State.Fly or not FlyVelocity then return end
    if not GetCharacter() then return end

    local direction = Humanoid.MoveDirection

    FlyVelocity.VectorVelocity = Vector3.new(
        direction.X * Config.FlySpeed,
        Vertical * Config.FlySpeed,
        direction.Z * Config.FlySpeed
    )
end)

-- INFINITE JUMP

UIS.JumpRequest:Connect(function()
    if not State.InfiniteJump then return end
    if not GetCharacter() then return end

    Humanoid:ChangeState(
        Enum.HumanoidStateType.Jumping
    )
end)

-- UI

local GUI = Instance.new("ScreenGui")
GUI.Name = "SOLAR_V2"
GUI.ResetOnSpawn = false
GUI.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(250, 370)
Main.Position = UDim2.new(0, 15, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(25, 22, 38)
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(160, 115, 255)
Stroke.Parent = Main

local function CreateButton(name, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 38)
    button.Position = UDim2.new(0, 10, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(48, 42, 65)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Text = name .. " : OFF"
    button.Parent = Main

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    return button
end

local Title = CreateButton("SOLAR V2", 10)
local FlyBtn = CreateButton("FLY", 55)
local SpeedBtn = CreateButton("SPEED", 100)
local JumpBtn = CreateButton("HIGH JUMP", 145)
local InfiniteBtn = CreateButton("INFINITE JUMP", 190)
local FPSBtn = CreateButton("FPS TEST", 235)
local UpBtn = CreateButton("FLY UP", 280)
local DownBtn = CreateButton("FLY DOWN", 325)

local function UpdateButton(button, name, enabled)
    button.Text = name .. " : " ..
        (enabled and "ON" or "OFF")

    button.BackgroundColor3 = enabled
        and Color3.fromRGB(95, 65, 150)
        or Color3.fromRGB(48, 42, 65)
end

FlyBtn.Activated:Connect(function()
    SetFly(not State.Fly)
    UpdateButton(FlyBtn, "FLY", State.Fly)
end)

SpeedBtn.Activated:Connect(function()
    State.Speed = not State.Speed
    UpdateMovement()
    UpdateButton(SpeedBtn, "SPEED", State.Speed)
end)

JumpBtn.Activated:Connect(function()
    State.HighJump = not State.HighJump
    UpdateMovement()
    UpdateButton(JumpBtn, "HIGH JUMP", State.HighJump)
end)

InfiniteBtn.Activated:Connect(function()
    State.InfiniteJump = not State.InfiniteJump
    UpdateButton(
        InfiniteBtn,
        "INFINITE JUMP",
        State.InfiniteJump
    )
end)

-- FPS TEST

local frames = 0
local elapsed = 0

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1, -20, 0, 25)
FPSLabel.Position = UDim2.new(0, 10, 0, 370)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
FPSLabel.Parent = Main

Main.Size = UDim2.fromOffset(250, 405)

FPSBtn.Activated:Connect(function()
    State.FPSTest = not State.FPSTest
    UpdateButton(FPSBtn, "FPS TEST", State.FPSTest)

    if not State.FPSTest then
        FPSLabel.Text = ""
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not State.FPSTest then return end

    frames += 1
    elapsed += dt

    if elapsed >= 0.5 then
        FPSLabel.Text =
            "FPS: " .. math.floor(frames / elapsed)

        frames = 0
        elapsed = 0
    end
end)

-- FLY UP / DOWN

local function HoldVertical(button, value)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            Vertical = value
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if Vertical == value then
                Vertical = 0
            end
        end
    end)
end

HoldVertical(UpBtn, 1)
HoldVertical(DownBtn, -1)

-- MINIMIZE

local minimized = false

Title.Activated:Connect(function()
    minimized = not minimized

    for _, item in ipairs(Main:GetChildren()) do
        if item:IsA("TextButton") and item ~= Title then
            item.Visible = not minimized
        end

        if item:IsA("TextLabel") then
            item.Visible = not minimized
        end
    end

    Main.Size = minimized
        and UDim2.fromOffset(250, 50)
        or UDim2.fromOffset(250, 405)

    Title.Text = minimized
        and "SOLAR V2 : OPEN"
        or "SOLAR V2 : MINIMIZE"
end)

-- RESPAWN

Player.CharacterAdded:Connect(function()
    task.wait(0.5)

    if GetCharacter() then
        UpdateMovement()

        if State.Fly then
            StartFly()
        end
    end
end)

if GetCharacter() then
    UpdateMovement()
end

print("SOLAR V2 LOADED")
