

local minimized = false

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeButton"
MinimizeBtn.Size = UDim2.fromOffset(35, 30)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 10)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(95, 65, 150)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.TextSize = 22
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = Main

Instance.new("UICorner", MinimizeBtn).CornerRadius =
    UDim.new(0, 8)

local function SetMinimized(value)
    minimized = value

    for _, item in ipairs(Main:GetChildren()) do
        if item:IsA("TextButton") and item ~= MinimizeBtn then
            item.Visible = not minimized
        elseif item:IsA("TextLabel") then
            item.Visible = not minimized
        end
    end

    MinimizeBtn.Text = minimized and "+" or "−"

    Main.Size = minimized
        and UDim2.fromOffset(250, 50)
        or UDim2.fromOffset(250, 405)
end

MinimizeBtn.Activated:Connect(function()
    SetMinimized(not minimized)
end)
