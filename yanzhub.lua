-- ══════════════════════════════════════════════════════════════════════════════
-- Yanz⚡ HUB v2.0 — STEAL AN EGG EDITION
-- Inspirasi: Miranda, Chilli, Ouroboros
-- Fitur: Auto Steal, Instant Steal, Auto Hatch, ESP, WalkSpeed, Anti Guard, dll.
-- ══════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════════════
-- KONFIGURASI
-- ══════════════════════════════════════════════════════════════════════════════
local CFG = {
    NAME = "Yanz⚡ Hub",
    VERSION = "2.0",
    AUTHOR = "Dev Yan",
    KEY = "YANZ-2024",
    -- URL untuk modul game lain (opsional)
    MODULE_BASE = "https://raw.githubusercontent.com/YanzHub/Modules/main/",
}

-- ══════════════════════════════════════════════════════════════════════════════
-- DATABASE GAME (fokus Steal an Egg dulu)
-- ══════════════════════════════════════════════════════════════════════════════
local GAMES = {
    [107778070777162] = { name = "Steal an Egg", icon = "🥚", module = "StealAnEgg" },
    [10563114921]     = { name = "Steal an Egg", icon = "🥚", module = "StealAnEgg" },
}

-- ══════════════════════════════════════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════════════════════════════════════
local State = {
    AutoSteal = false,
    InstantSteal = false,
    AutoReturn = false,
    AutoHatch = false,
    AutoSellEggs = false,
    AutoEquipBest = false,
    AntiGuard = false,
    ESP = false,
    SpeedEnabled = false,
    SpeedValue = 55,
    FlyEnabled = false,
    currentTab = nil,
    gui = nil,
}

-- ══════════════════════════════════════════════════════════════════════════════
-- HELPER
-- ══════════════════════════════════════════════════════════════════════════════
local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function notify(title, text, duration)
    duration = duration or 3
    local gui = State.gui
    if not gui then return end
    local notif = create("Frame", {
        Size = UDim2.new(0, 280, 0, 70),
        Position = UDim2.new(1, 300, 0, 20),
        BackgroundColor3 = Color3.fromRGB(25, 25, 32),
        BorderSizePixel = 0,
        Parent = gui,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = notif})
    create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = Color3.fromRGB(130, 80, 255),
        BorderSizePixel = 0,
        Parent = notif,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 15, 0, 8),
        Text = title,
        TextColor3 = Color3.fromRGB(130, 80, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = notif,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 15, 0, 32),
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Parent = notif,
    })
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, -300, 0, 20)
    }):Play()
    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Position = UDim2.new(1, 300, 0, 20)
        }):Play()
        task.wait(0.4)
        notif:Destroy()
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- FITUR STEAL AN EGG (berdasarkan fitur hub populer) [reference:0][reference:1]
-- ══════════════════════════════════════════════════════════════════════════════

-- Auto Steal (loop sederhana: cari egg terdekat, teleport, ambil)
local function startAutoSteal()
    spawn(function()
        while State.AutoSteal do
            task.wait(0.5)
            local char = LP.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local root = char.HumanoidRootPart
            -- Cari egg terdekat (contoh: objek bernama "Egg")
            local nearestEgg = nil
            local minDist = 50
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("egg") then
                    local eggRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Handle")
                    if eggRoot then
                        local dist = (eggRoot.Position - root.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearestEgg = eggRoot
                        end
                    end
                end
            end
            if nearestEgg then
                root.CFrame = CFrame.new(nearestEgg.Position)
                task.wait(0.1)
                -- Panggil remote steal jika ada
                for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                    if remote:IsA("RemoteEvent") and remote.Name:lower():find("steal") then
                        remote:FireServer(nearestEgg.Parent)
                        break
                    end
                end
            end
        end
    end)
end

-- Instant Steal (langsung teleport ke egg dan ambil)
local function instantSteal()
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("egg") then
            local eggRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Handle")
            if eggRoot then
                root.CFrame = CFrame.new(eggRoot.Position)
                task.wait(0.05)
                for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                    if remote:IsA("RemoteEvent") and remote.Name:lower():find("steal") then
                        remote:FireServer(obj)
                        break
                    end
                end
                notify("Instant Steal", "Egg berhasil diambil!", 2)
                return
            end
        end
    end
end

-- Auto Return to Base (kembali ke plot)
local function autoReturn()
    spawn(function()
        while State.AutoReturn do
            task.wait(1)
            local char = LP.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local root = char.HumanoidRootPart
            -- Cari plot atau base pemain
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("plot") or obj.Name:lower():find("base")) then
                    if obj:FindFirstChild("HumanoidRootPart") then
                        root.CFrame = CFrame.new(obj.HumanoidRootPart.Position)
                        break
                    end
                end
            end
        end
    end)
end

-- Auto Hatch (hatch egg yang siap)
local function autoHatch()
    spawn(function()
        while State.AutoHatch do
            task.wait(2)
            for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if remote:IsA("RemoteEvent") and remote.Name:lower():find("hatch") then
                    remote:FireServer()
                    break
                end
            end
        end
    end)
end

-- Auto Sell Eggs
local function autoSellEggs()
    spawn(function()
        while State.AutoSellEggs do
            task.wait(3)
            for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if remote:IsA("RemoteEvent") and remote.Name:lower():find("sell") then
                    remote:FireServer()
                    break
                end
            end
        end
    end)
end

-- Auto Equip Best Pet
local function autoEquipBest()
    spawn(function()
        while State.AutoEquipBest do
            task.wait(5)
            for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if remote:IsA("RemoteEvent") and remote.Name:lower():find("equip") then
                    remote:FireServer("best")
                    break
                end
            end
        end
    end)
end

-- Anti Guard (menjauh dari guard)
local function antiGuard()
    spawn(function()
        while State.AntiGuard do
            task.wait(0.3)
            local char = LP.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local root = char.HumanoidRootPart
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("guard") or obj.Name:lower():find("guardian")) then
                    local gRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                    if gRoot and (gRoot.Position - root.Position).Magnitude < 25 then
                        local dir = (root.Position - gRoot.Position).Unit
                        root.CFrame = CFrame.new(root.Position + dir * 35)
                    end
                end
            end
        end
    end)
end

-- ESP (Highlight semua egg, guard, pet, player) [reference:2]
local function toggleESP()
    local folder = workspace:FindFirstChild("YanzESP") or create("Folder", {Name = "YanzESP", Parent = workspace})
    folder:ClearAllChildren()
    if State.ESP then
        spawn(function()
            while State.ESP do
                task.wait(0.5)
                -- Egg ESP
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find("egg") then
                        if not folder:FindFirstChild(obj.Name) then
                            create("Highlight", {
                                Name = obj.Name,
                                FillColor = Color3.fromRGB(255, 200, 0),
                                OutlineColor = Color3.new(1, 1, 1),
                                Adornee = obj,
                                Parent = folder,
                            })
                        end
                    end
                    -- Guard ESP
                    if obj:IsA("Model") and obj.Name:lower():find("guard") then
                        if not folder:FindFirstChild(obj.Name) then
                            create("Highlight", {
                                Name = obj.Name,
                                FillColor = Color3.fromRGB(255, 0, 0),
                                OutlineColor = Color3.new(1, 1, 1),
                                Adornee = obj,
                                Parent = folder,
                            })
                        end
                    end
                end
                -- Player ESP
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        if not folder:FindFirstChild(p.Name) then
                            create("Highlight", {
                                Name = p.Name,
                                FillColor = Color3.fromRGB(0, 150, 255),
                                OutlineColor = Color3.new(1, 1, 1),
                                Adornee = p.Character,
                                Parent = folder,
                            })
                        end
                    end
                end
            end
            folder:ClearAllChildren()
        end)
    end
end

-- WalkSpeed Bypass
local function toggleSpeed()
    spawn(function()
        while State.SpeedEnabled do
            task.wait(0.1)
            local char = LP.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = State.SpeedValue
            end
        end
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
        end
    end)
end

-- Fly (dengan BodyVelocity + BodyGyro)
local function toggleFly()
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    if State.FlyEnabled then
        if root:FindFirstChild("YanzFlyVel") then root.YanzFlyVel:Destroy() end
        if root:FindFirstChild("YanzFlyGyro") then root.YanzFlyGyro:Destroy() end
        local bv = create("BodyVelocity", {
            Name = "YanzFlyVel",
            MaxForce = Vector3.new(math.huge, math.huge, math.huge),
            P = 10000, D = 500,
            Parent = root,
        })
        local bg = create("BodyGyro", {
            Name = "YanzFlyGyro",
            MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
            P = 10000, D = 100,
            CFrame = workspace.CurrentCamera.CFrame,
            Parent = root,
        })
        spawn(function()
            while State.FlyEnabled do
                task.wait()
                local cam = workspace.CurrentCamera
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                bv.Velocity = dir * 60
                bg.CFrame = cam.CFrame
            end
        end)
    else
        if root:FindFirstChild("YanzFlyVel") then root.YanzFlyVel:Destroy() end
        if root:FindFirstChild("YanzFlyGyro") then root.YanzFlyGyro:Destroy() end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════
-- GUI BUILDER
-- ══════════════════════════════════════════════════════════════════════════════
local function buildGUI()
    local gui = create("ScreenGui", {
        Name = "YanzHub",
        ResetOnSpawn = false,
        Parent = game.CoreGui or LP:WaitForChild("PlayerGui"),
    })
    State.gui = gui

    -- Main Frame
    local main = create("Frame", {
        Size = UDim2.new(0, 480, 0, 420),
        Position = UDim2.new(0.5, -240, 0.5, -210),
        BackgroundColor3 = Color3.fromRGB(12, 12, 18),
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Parent = gui,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = main})

    -- Header
    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(130, 80, 255),
        BorderSizePixel = 0,
        Parent = main,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = header})

    create("TextLabel", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        Text = "⚡ Yanz Hub — Steal an Egg",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Parent = header,
    })

    local closeBtn = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 8),
        BackgroundColor3 = Color3.fromRGB(220, 60, 60),
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        BorderSizePixel = 0,
        Parent = header,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 15), Parent = closeBtn})
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Tab Bar
    local tabBar = create("Frame", {
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 56),
        BackgroundColor3 = Color3.fromRGB(20, 20, 26),
        BorderSizePixel = 0,
        Parent = main,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = tabBar})

    -- Content
    local content = create("Frame", {
        Size = UDim2.new(1, -20, 1, -120),
        Position = UDim2.new(0, 10, 0, 100),
        BackgroundColor3 = Color3.fromRGB(20, 20, 26),
        BorderSizePixel = 0,
        Parent = main,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = content})

    -- Tabs
    local tabs = {}
    local tabButtons = {}
    local currentTabFrame = nil

    local function switchTab(name)
        if currentTabFrame then currentTabFrame.Visible = false end
        if tabs[name] then tabs[name].Visible = true; currentTabFrame = tabs[name] end
        for n, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = (n == name) and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(30, 30, 38)
            btn.TextColor3 = (n == name) and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
        end
    end

    local tabNames = {"Steal", "Automation", "Visual", "Movement", "Settings"}
    for i, name in ipairs(tabNames) do
        local btn = create("TextButton", {
            Size = UDim2.new(1/#tabNames - 0.01, 0, 1, -6),
            Position = UDim2.new((i-1)/#tabNames, 2, 0, 3),
            Text = name,
            TextColor3 = Color3.new(0.7, 0.7, 0.7),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            BackgroundColor3 = (i == 1) and Color3.fromRGB(130, 80, 255) or Color3.fromRGB(30, 30, 38),
            BorderSizePixel = 0,
            Parent = tabBar,
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        tabButtons[name] = btn

        local tabFrame = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(20, 20, 26),
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 500),
            Visible = (i == 1),
            Parent = content,
        })
        tabs[name] = tabFrame
        if i == 1 then currentTabFrame = tabFrame end
    end

    -- ═══ TAB STEAL ═══
    local function addToggle(parent, text, y, stateKey, callback)
        local btn = create("TextButton", {
            Size = UDim2.new(1, -20, 0, 34),
            Position = UDim2.new(0, 10, 0, y),
            Text = text .. " [OFF]",
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            BackgroundColor3 = Color3.fromRGB(40, 40, 48),
            BorderSizePixel = 0,
            Parent = parent,
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
        btn.MouseButton1Click:Connect(function()
            State[stateKey] = not State[stateKey]
            btn.Text = text .. " [" .. (State[stateKey] and "ON" or "OFF") .. "]"
            btn.BackgroundColor3 = State[stateKey] and Color3.fromRGB(60, 200, 90) or Color3.fromRGB(40, 40, 48)
            if callback then callback(State[stateKey]) end
        end)
    end

    addToggle(tabs["Steal"], "🥚 Auto Steal", 10, "AutoSteal", function(v)
        if v then startAutoSteal() end
    end)
    addToggle(tabs["Steal"], "⚡ Instant Steal", 50, "InstantSteal", function(v)
        if v then instantSteal() end
    end)
    addToggle(tabs["Steal"], "🏠 Auto Return to Base", 90, "AutoReturn", function(v)
        if v then autoReturn() end
    end)

    -- ═══ TAB AUTOMATION ═══
    addToggle(tabs["Automation"], "🐣 Auto Hatch", 10, "AutoHatch", function(v)
        if v then autoHatch() end
    end)
    addToggle(tabs["Automation"], "💰 Auto Sell Eggs", 50, "AutoSellEggs", function(v)
        if v then autoSellEggs() end
    end)
    addToggle(tabs["Automation"], "🐾 Auto Equip Best Pet", 90, "AutoEquipBest", function(v)
        if v then autoEquipBest() end
    end)

    -- ═══ TAB VISUAL ═══
    addToggle(tabs["Visual"], "👁️ ESP (Egg/Guard/Player)", 10, "ESP", function(v)
        toggleESP()
    end)
    addToggle(tabs["Visual"], "🛡️ Anti Guard", 50, "AntiGuard", function(v)
        if v then antiGuard() end
    end)

    -- ═══ TAB MOVEMENT ═══
    addToggle(tabs["Movement"], "⚡ WalkSpeed", 10, "SpeedEnabled", function(v)
        toggleSpeed()
    end)
    addToggle(tabs["Movement"], "🕊️ Fly", 50, "FlyEnabled", function(v)
        toggleFly()
    end)

    -- Speed slider
    local speedLabel = create("TextLabel", {
        Size = UDim2.new(0, 120, 0, 24),
        Position = UDim2.new(0, 10, 0, 94),
        Text = "Speed: " .. State.SpeedValue,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        BackgroundTransparency = 1,
        Parent = tabs["Movement"],
    })
    local speedDown = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 135, 0, 94),
        Text = "-",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        BackgroundColor3 = Color3.fromRGB(40, 40, 48),
        BorderSizePixel = 0,
        Parent = tabs["Movement"],
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = speedDown})
    local speedUp = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 170, 0, 94),
        Text = "+",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        BackgroundColor3 = Color3.fromRGB(40, 40, 48),
        BorderSizePixel = 0,
        Parent = tabs["Movement"],
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = speedUp})
    speedDown.MouseButton1Click:Connect(function()
        State.SpeedValue = math.max(1, State.SpeedValue - 5)
        speedLabel.Text = "Speed: " .. State.SpeedValue
    end)
    speedUp.MouseButton1Click:Connect(function()
        State.SpeedValue = math.min(200, State.SpeedValue + 5)
        speedLabel.Text = "Speed: " .. State.SpeedValue
    end)

    -- ═══ TAB SETTINGS ═══
    create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromRGB(30, 30, 38),
        Text = "⚙️ Yanz Hub v" .. CFG.VERSION .. "\nAuthor: " .. CFG.AUTHOR,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        BorderSizePixel = 0,
        Parent = tabs["Settings"],
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabs["Settings"]})

    notify("Yanz Hub", "Steal an Egg edition loaded!", 3)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- MAIN
-- ══════════════════════════════════════════════════════════════════════════════
local gameData = GAMES[game.PlaceId]
if gameData then
    buildGUI()
    print("Yanz⚡ Hub: " .. gameData.name .. " terdeteksi")
else
    buildGUI()
    print("Yanz⚡ Hub: Universal mode (Steal an Egg features)")
end
