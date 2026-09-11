local Players = game:GetService("Players")
local Player = Players.LocalPlayer

getgenv().AutoFarmConfig = getgenv().AutoFarmConfig or {
    AutoFarm = true,
    AutoQuest = true,
    FastAttack = true,
    AttackDistance = 65,
    DamageMultiplier = 3,
    FarmDistance = 25,
    TweenSpeed = 350
}

local Config = getgenv().AutoFarmConfig

local function loadModule(relPath)
    local content = nil
    if readfile and isfile and isfile(relPath) then
        content = readfile(relPath)
    elseif readfile and isfile and isfile("Blox Fruit Script/" .. relPath) then
        content = readfile("Blox Fruit Script/" .. relPath)
    end
    if content then
        local fn, err = loadstring(content)
        if fn then
            return fn()
        else
            warn("[Main Loader] Error loading " .. relPath .. ":", err)
        end
    end
    return nil
end

local Tween = loadModule("Modules/Tween.lua")
local AttackMob = loadModule("Modules/AttackMob.lua")
local AutoQuest = loadModule("Modules/AutoQuest.lua")

if not Tween or not AttackMob or not AutoQuest then
    warn("[Blox Fruit Script] Failed to load one or more sub-modules!")
    return
end

if Tween then
    Tween.Speed = Config.TweenSpeed or 350
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

if getgenv()._BFMainLoopRunning then
    getgenv()._BFMainLoopRunning = false
    task.wait(0.2)
end
getgenv()._BFMainLoopRunning = true

task.spawn(function()
    while getgenv()._BFMainLoopRunning do
        if Config.AutoFarm then
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

                            if dist > 35 then
                                Tween:To(farmPos)
                            else
                                hrp.CFrame = farmPos
                                if Config.FastAttack then
                                    AttackMob:Hit()
                                end
                            end
                        end
                    elseif qData.CFrameMon and hrp then
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
    Config = Config
}
