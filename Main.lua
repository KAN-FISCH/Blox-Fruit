local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

getgenv().AutoFarmConfig = getgenv().AutoFarmConfig or {
    AutoFarm = false,
    AutoQuest = true,
    BringMob = true,
    FastAttack = true,
    DamageMultiplier = 5,
    MultiPartHits = true,
    AttackDistance = 65,
    FarmDistance = 25,
    TweenSpeed = 200,
    AttackMobs = true,
    AttackPlayers = false,
    AutoEquipWeapon = true,
    WeaponType = "Melee"
}

local Config = getgenv().AutoFarmConfig

local function loadModule(name)
    local localCandidates = {
        "Blox Fruit Script/Modules/" .. name .. ".lua",
        "Modules/" .. name .. ".lua",
        "ShielDTeam/Blox Fruit Script/Modules/" .. name .. ".lua",
        name == "AttackMob" and "BFAttackMob.lua" or nil,
        name == "AttackMob" and "ShielDTeam/BFAttackMob.lua" or nil
    }
    for _, path in ipairs(localCandidates) do
        if path and readfile and isfile and isfile(path) then
            local ok, res = pcall(function()
                return loadstring(readfile(path))()
            end)
            if ok and res then return res end
        end
    end

    if game and game.HttpGet then
        local url = "https://raw.githubusercontent.com/KAN-FISCH/Blox-Fruit/refs/heads/main/Modules/" .. name .. ".lua"
        local ok, res = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if ok and res then return res end
    end
    return nil
end

local Tween = loadModule("Tween")
if Tween then
    _G.BFTween = Tween
    Tween.Speed = math.clamp(tonumber(Config.TweenSpeed) or 200, 10, 200)
end
local AttackMob = loadModule("AttackMob")
local AutoQuest = loadModule("AutoQuest")

local CommF_ = nil
pcall(function()
    CommF_ = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("CommF_", 5)
end)
if not CommF_ then
    pcall(function()
        CommF_ = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    end)
end
if not CommF_ then
    pcall(function()
        CommF_ = ReplicatedStorage:FindFirstChild("CommF_", true)
    end)
end

local Speed_Library = nil
pcall(function()
    Speed_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KAN-FISCH/Fisch/refs/heads/main/cukimaier235"))()
end)

if not Speed_Library then
    pcall(function()
        if readfile and isfile and isfile("GUIENC.lua") then
            Speed_Library = loadstring(readfile("GUIENC.lua"))()
        end
    end)
end

local executorName = "Potassium"
pcall(function()
    if identifyexecutor then
        executorName = identifyexecutor()
    end
end)

local Window = nil
if Speed_Library then
    Window = Speed_Library:CreateWindow({
        Title = "ShieldTeam || Blox Fruit || Executor : " .. executorName,
        Description = "Blox Fruit • Shield Edition • " .. os.date("%A"),
        SizeUi = UDim2.fromOffset(660, 420),
        Visible = true
    })
end

local function GetNearestMob(monName, maxDist)
    local myChar = Player.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end

    local nearestMob = nil
    local shortestDist = maxDist or math.huge

    local function scan(folder)
        if not folder then return end
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy ~= myChar then
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    if not monName or string.find(string.lower(enemy.Name), string.lower(monName)) then
                        local dist = (hrp.Position - myHrp.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            nearestMob = enemy
                        end
                    end
                end
            end
        end
    end

    scan(workspace:FindFirstChild("Enemies"))
    if not nearestMob then
        scan(workspace:FindFirstChild("Characters"))
    end

    return nearestMob
end

local isnetworkowner = isnetworkowner or function() return true end

local bossBlacklist = {
    ["Ice Admiral"] = true,
    ["Don Swan"] = true,
    ["Saber Expert"] = true,
    ["Longma"] = true,
    ["Greybeard"] = true,
    ["The Gorilla King"] = true,
    ["Bobby"] = true,
    ["Soul Reaper"] = true,
    ["Darkbeard"] = true,
    ["Order"] = true,
    ["Cursed Captain"] = true
}

local BringPos = nil
local NameMon = nil
local currentMobInstance = nil
local lockedGroundY = nil

local function BringMob(huh)
    if not Config.BringMob then return end
    local localPlr = Player
    if not localPlr or not localPlr.Character or not localPlr.Character:FindFirstChild("HumanoidRootPart") then return end
    if not BringPos then return end

    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _, v in pairs(enemies:GetChildren()) do
        if v ~= localPlr.Character and not bossBlacklist[v.Name] then
            if (v.Name == huh or (huh and string.find(string.lower(v.Name), string.lower(huh)))) and v.Parent and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and (v.HumanoidRootPart.Position - localPlr.Character.HumanoidRootPart.Position).Magnitude <= 350 then
                pcall(function()
                    if isnetworkowner(v.HumanoidRootPart) then
                        v.HumanoidRootPart.CFrame = BringPos
                        v.Humanoid.JumpPower = 0
                        v.Humanoid.WalkSpeed = 0
                        v.HumanoidRootPart.Transparency = 1
                        for _, part in ipairs(v:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        if v.Humanoid:FindFirstChild("Animator") then
                            v.Humanoid.Animator:Destroy()
                        end
                        if not v.HumanoidRootPart:FindFirstChild("Lock") then
                            local lock = Instance.new("BodyVelocity")
                            lock.Parent = v.HumanoidRootPart
                            lock.Name = "Lock"
                            lock.MaxForce = Vector3.new(100000, 100000, 100000)
                            lock.Velocity = Vector3.new(0, 0, 0)
                        end
                        pcall(function()
                            if sethiddenproperty then
                                sethiddenproperty(localPlr, "SimulationRadius", math.huge)
                            end
                        end)
                        v.Humanoid:ChangeState(11)
                    end
                end)
            end
        end
    end
end

task.spawn(function()
    while task.wait() do
        pcall(function()
            if Config.BringMob and BringPos and NameMon then
                BringMob(NameMon)
            end
        end)
    end
end)

local currentFarmTarget = nil

local function SetPlayerFloat(enabled)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = hrp:FindFirstChild("PlayerFarmFloat")
    if enabled then
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "PlayerFarmFloat"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
        end
    else
        if bv then
            bv:Destroy()
        end
    end
end

RunService.Stepped:Connect(function()
    if Config.AutoFarm and Player.Character then
        for _, part in ipairs(Player.Character:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Config.AutoFarm and currentFarmTarget and not (Tween and Tween.IsTweening) then
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = currentFarmTarget
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end
end)

Player.CharacterAdded:Connect(function()
    currentFarmTarget = nil
    BringPos = nil
    SetPlayerFloat(false)
end)

if Window then
    local FarmTab = Window:CreateTab({ "Auto Farm", "rbxassetid://10709768641" })
    local CombatTab = Window:CreateTab({ "Combat", "rbxassetid://10709768824" })
    local TeleportTab = Window:CreateTab({ "Teleport", "rbxassetid://10709769018" })
    local SettingsTab = Window:CreateTab({ "Settings", "rbxassetid://10709769205" })

    local SecFarmLeft = FarmTab:AddSection("Auto Quest & Level Farm", true)
    local SecFarmRight = FarmTab:AddSection("Farm Position & Tweaks", false)

    SecFarmLeft:AddToggle({
        [1] = "Auto Farm Level",
        Title = "Auto Farm Level",
        Name = "Auto Farm Level",
        Default = Config.AutoFarm,
        Callback = function(v)
            Config.AutoFarm = v
            if not v then
                currentMobInstance = nil
                lockedGroundY = nil
                currentFarmTarget = nil
                BringPos = nil
                SetPlayerFloat(false)
                if Tween then
                    Tween:Stop()
                end
            end
        end
    })

    SecFarmLeft:AddToggle({
        [1] = "Auto Quest",
        Title = "Auto Quest",
        Name = "Auto Quest",
        Default = Config.AutoQuest,
        Callback = function(v)
            Config.AutoQuest = v
        end
    })

    SecFarmLeft:AddToggle({
        [1] = "Bring Mob",
        Title = "Bring Mob",
        Name = "Bring Mob",
        Default = Config.BringMob,
        Callback = function(v)
            Config.BringMob = v
        end
    })

    SecFarmLeft:AddToggle({
        [1] = "Auto Equip Weapon",
        Title = "Auto Equip Weapon",
        Name = "Auto Equip Weapon",
        Default = Config.AutoEquipWeapon,
        Callback = function(v)
            Config.AutoEquipWeapon = v
            if getgenv().BFAttackConfig then
                getgenv().BFAttackConfig.AutoEquipWeapon = v
            end
        end
    })

    SecFarmLeft:AddDropdown({
        [1] = "Weapon Type",
        Title = "Weapon Type",
        Name = "Weapon Type",
        Options = { "Melee", "Sword", "Gun" },
        Default = Config.WeaponType,
        Callback = function(v)
            Config.WeaponType = v
            if getgenv().BFAttackConfig then
                getgenv().BFAttackConfig.WeaponPriority = { v }
            end
        end
    })

    SecFarmRight:AddSlider({
        [1] = "Farm Distance (Y-Offset)",
        Title = "Farm Distance (Y-Offset)",
        Name = "Farm Distance (Y-Offset)",
        Min = 10,
        Max = 45,
        Default = Config.FarmDistance,
        Increment = 1,
        Callback = function(v)
            Config.FarmDistance = v
        end
    })

    SecFarmRight:AddSlider({
        [1] = "Tween Speed",
        Title = "Tween Speed",
        Name = "Tween Speed",
        Min = 50,
        Max = 200,
        Default = math.clamp(tonumber(Config.TweenSpeed) or 200, 50, 200),
        Increment = 5,
        Callback = function(v)
            v = math.clamp(tonumber(v) or 200, 50, 200)
            Config.TweenSpeed = v
            if Tween then
                Tween.Speed = v
            end
        end
    })

    SecFarmRight:AddButton({
        [1] = "Abandon Current Quest",
        Title = "Abandon Current Quest",
        Name = "Abandon Current Quest",
        Callback = function()
            if AutoQuest then
                AutoQuest:AbandonQuest()
            end
        end
    })

    local SecCombatLeft = CombatTab:AddSection("Fast Attack Settings", true)
    local SecCombatRight = CombatTab:AddSection("Attack Targets", false)

    SecCombatLeft:AddToggle({
        [1] = "Fast Attack",
        Title = "Fast Attack",
        Name = "Fast Attack",
        Default = Config.FastAttack,
        Callback = function(v)
            Config.FastAttack = v
            if getgenv().BFAttackConfig then
                getgenv().BFAttackConfig.Enabled = v
            end
        end
    })

    SecCombatLeft:AddSlider({
        [1] = "Damage Multiplier (Burst)",
        Title = "Damage Multiplier (Burst)",
        Name = "Damage Multiplier (Burst)",
        Min = 1,
        Max = 10,
        Default = Config.DamageMultiplier,
        Increment = 1,
        Callback = function(v)
            Config.DamageMultiplier = v
            if getgenv().BFAttackConfig then
                getgenv().BFAttackConfig.DamageMultiplier = v
            end
        end
    })

    SecCombatLeft:AddToggle({
        [1] = "Triple Hitbox Stacking",
        Title = "Triple Hitbox Stacking",
        Name = "Triple Hitbox Stacking",
        Default = Config.MultiPartHits,
        Callback = function(v)
            Config.MultiPartHits = v
            if getgenv().BFAttackConfig then
                getgenv().BFAttackConfig.MultiPartHits = v
            end
        end
    })

    SecCombatLeft:AddSlider({
        [1] = "Attack Range",
        Title = "Attack Range",
        Name = "Attack Range",
        Min = 30,
        Max = 100,
        Default = Config.AttackDistance,
        Increment = 5,
        Callback = function(v)
            Config.AttackDistance = v
            if getgenv().BFAttackConfig then
                getgenv().BFAttackConfig.Distance = v
            end
        end
    })

    SecCombatRight:AddToggle({
        [1] = "Attack Mobs",
        Title = "Attack Mobs",
        Name = "Attack Mobs",
        Default = Config.AttackMobs,
        Callback = function(v)
            Config.AttackMobs = v
            if getgenv().BFAttackConfig then
                getgenv().BFAttackConfig.AttackMobs = v
            end
        end
    })

    SecCombatRight:AddToggle({
        [1] = "Attack Players",
        Title = "Attack Players",
        Name = "Attack Players",
        Default = Config.AttackPlayers,
        Callback = function(v)
            Config.AttackPlayers = v
            if getgenv().BFAttackConfig then
                getgenv().BFAttackConfig.AttackPlayers = v
            end
        end
    })

    SecCombatRight:AddButton({
        [1] = "Trigger Attack Once",
        Title = "Trigger Attack Once",
        Name = "Trigger Attack Once",
        Callback = function()
            if AttackMob then
                AttackMob:Hit()
            end
        end
    })

    local SecTPLeft = TeleportTab:AddSection("Quest & Mob Teleport", true)
    local SecTPRight = TeleportTab:AddSection("Island Teleport (Sea 1)", false)

    SecTPLeft:AddButton({
        [1] = "Tween to Current Quest NPC",
        Title = "Tween to Current Quest NPC",
        Name = "Tween to Current Quest NPC",
        Callback = function()
            if AutoQuest and Tween then
                local q = AutoQuest:GetQuestData()
                if q and q.CFrameQuest then
                    Tween:To(q.CFrameQuest)
                end
            end
        end
    })

    SecTPLeft:AddButton({
        [1] = "Tween to Current Mob Area",
        Title = "Tween to Current Mob Area",
        Name = "Tween to Current Mob Area",
        Callback = function()
            if AutoQuest and Tween then
                local q = AutoQuest:GetQuestData()
                if q and q.CFrameMon then
                    Tween:To(q.CFrameMon)
                end
            end
        end
    })

    SecTPLeft:AddButton({
        [1] = "Stop All Tweens",
        Title = "Stop All Tweens",
        Name = "Stop All Tweens",
        Callback = function()
            if Tween then
                Tween:Stop()
            end
        end
    })

    local islandSpawns = {
        ["Pirate Starter"] = CFrame.new(1059.37, 15.45, 1550.42),
        ["Marine Starter"] = CFrame.new(-2855.20, 7.39, 5354.52),
        ["Jungle"] = CFrame.new(-1598.09, 35.55, 153.38),
        ["Pirate Village"] = CFrame.new(-1141.07, 4.10, 3831.55),
        ["Desert"] = CFrame.new(894.49, 5.14, 4392.43),
        ["Snow Mountain"] = CFrame.new(1389.74, 88.15, -1298.91),
        ["Marine Fortress"] = CFrame.new(-5039.59, 27.35, 4324.68),
        ["Skylands"] = CFrame.new(-4839.53, 716.37, -2619.44),
        ["Prison"] = CFrame.new(5308.93, 1.66, 475.12),
        ["Colosseum"] = CFrame.new(-1580.05, 6.35, -2986.48),
        ["Magma Village"] = CFrame.new(-5313.37, 10.95, 8515.29),
        ["Underwater City"] = CFrame.new(61122.65, 18.50, 1569.40),
        ["Fountain City"] = CFrame.new(5259.82, 37.35, 4050.03)
    }

    local islandNames = {}
    for name, _ in pairs(islandSpawns) do
        table.insert(islandNames, name)
    end
    table.sort(islandNames)

    SecTPRight:AddDropdown({
        [1] = "Select Island",
        Title = "Select Island",
        Name = "Select Island",
        Options = islandNames,
        Default = islandNames[1],
        Callback = function(v)
            local cf = islandSpawns[v]
            if cf and Tween then
                Tween:To(cf)
            end
        end
    })

    local SecInfoLeft = SettingsTab:AddSection("Player Stats", true)
    local SecInfoRight = SettingsTab:AddSection("About Script", false)

    local LvlLabel = SecInfoLeft:AddParagraph({ [1] = "Player Level", [2] = "Loading...", Title = "Player Level", Content = "Loading..." })
    local QuestLabel = SecInfoLeft:AddParagraph({ [1] = "Target Quest", [2] = "Loading...", Title = "Target Quest", Content = "Loading..." })

    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local lvl = AutoQuest and AutoQuest:GetPlayerLevel() or 1
                local q = AutoQuest and AutoQuest:GetQuestData()
                if LvlLabel and LvlLabel.Set then
                    LvlLabel:Set("Level: " .. tostring(lvl))
                end
                if QuestLabel and QuestLabel.Set and q then
                    QuestLabel:Set(tostring(q.NameMon) .. " (" .. tostring(q.NameQuest) .. ")")
                end
            end)
        end
    end)

    SecInfoRight:AddParagraph({ [1] = "ShieldTeam Blox Fruits", [2] = "Clean Modular Auto Farm Engine\nPotassium Decompile Protocol", Title = "ShieldTeam Blox Fruits", Content = "Clean Modular Auto Farm Engine\nPotassium Decompile Protocol" })
end

local lastAbandonTime = 0

local function HasActiveQuest(qData)
    local has = false
    local questText = ""
    pcall(function()
        local pg = Player:FindFirstChild("PlayerGui") or Player.PlayerGui
        if not pg then return end

        local tqf = pg:FindFirstChild("TrackedQuestFrame")
        if tqf and not (tqf:IsA("ScreenGui") and tqf.Enabled == false) then
            local frame = tqf:FindFirstChild("Frame")
            if frame and frame.Visible ~= false then
                local header = frame:FindFirstChild("header")
                if header and header.Visible ~= false then
                    has = true
                end
                for _, desc in ipairs(frame:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
                        questText = questText .. " " .. desc.Text
                        has = true
                    end
                end
            end
        end

        local main = pg:FindFirstChild("Main")
        local qGui = main and main:FindFirstChild("Quest")
        if qGui and qGui.Visible == true then
            has = true
            local titleObj = qGui:FindFirstChild("Container")
                and qGui.Container:FindFirstChild("QuestTitle")
                and qGui.Container.QuestTitle:FindFirstChild("Title")
            if titleObj and titleObj.Text and titleObj.Text ~= "" then
                questText = questText .. " " .. titleObj.Text
            end
            for _, desc in ipairs(qGui:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
                    questText = questText .. " " .. desc.Text
                end
            end
        end
    end)

    if not has then
        return false
    end

    if questText ~= "" and qData and qData.NameMon then
        local lowerText = string.lower(questText)
        local lowerMon = string.lower(qData.NameMon)
        local lowerMonMen = string.gsub(lowerMon, "man", "men")
        local lowerQuest = qData.NameQuest and string.lower(qData.NameQuest) or ""

        local matches = false
        if string.find(lowerText, lowerMon, 1, true) then
            matches = true
        elseif string.find(lowerText, lowerMonMen, 1, true) then
            matches = true
        elseif lowerQuest ~= "" and string.find(lowerText, lowerQuest, 1, true) then
            matches = true
        end

        if not matches then
            -- Outdated or mismatched quest detected! Abandon old quest so new quest can be taken
            if tick() - lastAbandonTime > 1 then
                lastAbandonTime = tick()
                if CommF_ then
                    pcall(function()
                        CommF_:InvokeServer("AbandonQuest")
                    end)
                end
            end
            currentMobInstance = nil
            lockedGroundY = nil
            currentFarmTarget = nil
            BringPos = nil
            NameMon = nil
            SetPlayerFloat(false)
            return false
        end
    end

    return true
end

if getgenv()._BFMainLoopRunning then
    getgenv()._BFMainLoopRunning = false
    task.wait(0.2)
end
getgenv()._BFMainLoopRunning = true

task.spawn(function()
    while getgenv()._BFMainLoopRunning do
        pcall(function()
            if Config.AutoFarm and AutoQuest then
                local char = Player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    local qData = AutoQuest:GetQuestData()
                    if qData then
                        local hasQuest = HasActiveQuest(qData)

                        if Config.AutoQuest and not hasQuest then
                            currentMobInstance = nil
                            lockedGroundY = nil
                            currentFarmTarget = nil
                            BringPos = nil
                            NameMon = nil
                            SetPlayerFloat(false)
                            local distToQuest = (qData.CFrameQuest.Position - hrp.Position).Magnitude
                            if distToQuest > 30 and Tween then
                                Tween:To(qData.CFrameQuest)
                            else
                                if Tween then Tween:Stop() end
                                hrp.CFrame = qData.CFrameQuest
                                hrp.Velocity = Vector3.zero
                                if CommF_ then
                                    pcall(function()
                                        CommF_:InvokeServer("StartQuest", qData.NameQuest, qData.LevelQuest)
                                    end)
                                end
                                task.wait(0.3)

                                local targetMob = GetNearestMob(qData.NameMon)
                                if targetMob then
                                    local mobHrp = targetMob:FindFirstChild("HumanoidRootPart")
                                    if mobHrp and Tween then
                                        local tPos = mobHrp.Position + Vector3.new(0, tonumber(Config.FarmDistance) or 25, 0)
                                        Tween:To(CFrame.new(tPos))
                                    end
                                elseif qData.CFrameMon and hrp and Tween then
                                    local tPos = qData.CFrameMon.Position + Vector3.new(0, tonumber(Config.FarmDistance) or 25, 0)
                                    Tween:To(CFrame.new(tPos))
                                end
                            end
                        else
                            local targetMob = GetNearestMob(qData.NameMon)
                            if targetMob then
                                local mobHrp = targetMob:FindFirstChild("HumanoidRootPart")
                                local mobHum = targetMob:FindFirstChildOfClass("Humanoid")

                                if mobHrp and mobHum and mobHum.Health > 0 then
                                    if currentMobInstance ~= targetMob or not lockedGroundY then
                                        currentMobInstance = targetMob
                                        lockedGroundY = mobHrp.Position.Y
                                    end

                                    local farmDist = tonumber(Config.FarmDistance) or 25
                                    local stableY = lockedGroundY + farmDist

                                    if not currentFarmTarget then
                                        currentFarmTarget = CFrame.new(mobHrp.Position.X, stableY, mobHrp.Position.Z)
                                    else
                                        local hDist = (Vector3.new(currentFarmTarget.Position.X, 0, currentFarmTarget.Position.Z) - Vector3.new(mobHrp.Position.X, 0, mobHrp.Position.Z)).Magnitude
                                        if hDist > 15 then
                                            currentFarmTarget = CFrame.new(mobHrp.Position.X, stableY, mobHrp.Position.Z)
                                        end
                                    end

                                    local farmPos = currentFarmTarget
                                    local distToTarget = (farmPos.Position - hrp.Position).Magnitude

                                    if Tween and Tween.IsTweening then
                                        if distToTarget <= 20 then
                                            Tween:Stop()
                                            hrp.CFrame = farmPos
                                            hrp.Velocity = Vector3.zero
                                        end
                                    else
                                        if distToTarget > 40 and Tween then
                                            currentFarmTarget = nil
                                            BringPos = nil
                                            SetPlayerFloat(false)
                                            Tween:To(farmPos)
                                        else
                                            SetPlayerFloat(true)
                                            hrp.CFrame = farmPos
                                            hrp.Velocity = Vector3.zero

                                            BringPos = CFrame.new(mobHrp.Position.X, lockedGroundY, mobHrp.Position.Z)
                                            NameMon = qData.NameMon
                                            BringMob(qData.NameMon)

                                            if Config.FastAttack and AttackMob then
                                                AttackMob:Hit()
                                            end
                                        end
                                    end
                                else
                                    currentMobInstance = nil
                                    lockedGroundY = nil
                                    currentFarmTarget = nil
                                    BringPos = nil
                                    SetPlayerFloat(false)
                                end
                            else
                                currentMobInstance = nil
                                lockedGroundY = nil
                                currentFarmTarget = nil
                                BringPos = nil
                                SetPlayerFloat(false)
                                if qData.CFrameMon and hrp and Tween then
                                    local distToSpawn = (qData.CFrameMon.Position - hrp.Position).Magnitude
                                    if distToSpawn > 30 then
                                        local tPos = qData.CFrameMon.Position + Vector3.new(0, tonumber(Config.FarmDistance) or 25, 0)
                                        Tween:To(CFrame.new(tPos))
                                    end
                                end
                            end
                        end
                    end
                end
            else
                currentMobInstance = nil
                lockedGroundY = nil
                currentFarmTarget = nil
                BringPos = nil
                SetPlayerFloat(false)
                if Tween and Tween.IsTweening then
                    Tween:Stop()
                end
            end
        end)
        task.wait(0.05)
    end
end)

return {
    Tween = Tween,
    AttackMob = AttackMob,
    AutoQuest = AutoQuest,
    Config = Config,
    Window = Window
}
