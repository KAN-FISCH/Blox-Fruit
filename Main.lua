local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

getgenv().AutoFarmConfig = getgenv().AutoFarmConfig or {
    AutoFarm = false,
    AutoQuest = true,
    FastAttack = true,
    DamageMultiplier = 3,
    MultiPartHits = true,
    AttackDistance = 65,
    FarmDistance = 25,
    TweenSpeed = 350,
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
        "ShielDTeam/Blox Fruit Script/Modules/" .. name .. ".lua"
    }
    for _, path in ipairs(localCandidates) do
        if readfile and isfile and isfile(path) then
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
local AttackMob = loadModule("AttackMob")
local AutoQuest = loadModule("AutoQuest")

if Tween then
    Tween.Speed = Config.TweenSpeed or 350
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

    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, enemy in ipairs(enemies:GetChildren()) do
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                if not monName or string.find(enemy.Name, monName) then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        nearestMob = enemy
                    end
                end
            end
        end
    end

    return nearestMob
end

if Window then
    local FarmTab = Window:CreateTab({ "Auto Farm", "rbxassetid://10709768641" })
    local CombatTab = Window:CreateTab({ "Combat", "rbxassetid://10709768824" })
    local TeleportTab = Window:CreateTab({ "Teleport", "rbxassetid://10709769018" })
    local SettingsTab = Window:CreateTab({ "Settings", "rbxassetid://10709769205" })

    local SecFarmLeft = FarmTab:AddSection("Auto Quest & Level Farm", true)
    local SecFarmRight = FarmTab:AddSection("Farm Position & Tweaks", false)

    SecFarmLeft:AddToggle({
        Name = "Auto Farm Level",
        Default = Config.AutoFarm,
        Callback = function(v)
            Config.AutoFarm = v
            if not v and Tween then
                Tween:Stop()
            end
        end
    })

    SecFarmLeft:AddToggle({
        Name = "Auto Quest",
        Default = Config.AutoQuest,
        Callback = function(v)
            Config.AutoQuest = v
        end
    })

    SecFarmLeft:AddToggle({
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
        Name = "Tween Speed",
        Min = 200,
        Max = 500,
        Default = Config.TweenSpeed,
        Increment = 10,
        Callback = function(v)
            Config.TweenSpeed = v
            if Tween then
                Tween.Speed = v
            end
        end
    })

    SecFarmRight:AddButton({
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
        Name = "Damage Multiplier (Burst)",
        Min = 1,
        Max = 5,
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

    local LvlLabel = SecInfoLeft:AddParagraph({ "Player Level", "Loading..." })
    local QuestLabel = SecInfoLeft:AddParagraph({ "Target Quest", "Loading..." })

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

    SecInfoRight:AddParagraph({ "ShieldTeam Blox Fruits", "Clean Modular Auto Farm Engine\nPotassium Decompile Protocol" })
end

if getgenv()._BFMainLoopRunning then
    getgenv()._BFMainLoopRunning = false
    task.wait(0.2)
end
getgenv()._BFMainLoopRunning = true

task.spawn(function()
    while getgenv()._BFMainLoopRunning do
        if Config.AutoFarm and AutoQuest then
            local qData = AutoQuest:GetQuestData()
            if qData then
                if Config.AutoQuest and not AutoQuest:HasQuest(qData) then
                    AutoQuest:TakeQuest()
                else
                    local targetMob = GetNearestMob(qData.NameMon)
                    local char = Player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if targetMob and hrp then
                        local mobHrp = targetMob:FindFirstChild("HumanoidRootPart")
                        if mobHrp then
                            local farmPos = mobHrp.CFrame * CFrame.new(0, tonumber(Config.FarmDistance) or 25, 0)
                            local dist = (mobHrp.Position - hrp.Position).Magnitude

                            if dist > 35 and Tween then
                                Tween:To(farmPos)
                            else
                                hrp.CFrame = farmPos
                                if Config.FastAttack and AttackMob then
                                    AttackMob:Hit()
                                end
                            end
                        end
                    elseif qData.CFrameMon and hrp and Tween then
                        local dist = (qData.CFrameMon.Position - hrp.Position).Magnitude
                        if dist > 20 then
                            Tween:To(qData.CFrameMon)
                        end
                    end
                end
            end
        end
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
