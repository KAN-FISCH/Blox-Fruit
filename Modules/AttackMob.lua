local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

getgenv().BFAttackConfig = getgenv().BFAttackConfig or {
    Enabled = true,
    Distance = 85,
    AttackDelay = 0,
    DamageMultiplier = 5,
    MultiPartHits = false,
    AttackMobs = true,
    AttackPlayers = false,
    AutoEquipWeapon = true,
    WeaponPriority = {"Melee", "Sword"}
}

local AttackConfig = getgenv().BFAttackConfig

local Net = nil
local Global = nil
pcall(function()
    Net = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"))
end)
pcall(function()
    Global = require(ReplicatedStorage:WaitForChild("Global"))
end)

pcall(function()
    if Global then
        Global.checkHits = function() end
        Global.tapCooldown = 0
    end
end)

local function EnsureBuddhaAoeCap()
    pcall(function()
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and not hrp:FindFirstChild("Buddha") then
            local b = Instance.new("BoolValue")
            b.Name = "Buddha"
            b.Value = true
            b.Parent = hrp
        end
    end)
end
task.spawn(EnsureBuddhaAoeCap)
Player.CharacterAdded:Connect(function()
    task.wait(1)
    EnsureBuddhaAoeCap()
end)

local RegisterHit = nil
local RegisterAttack = nil

if Net then
    pcall(function()
        RegisterHit = Net:RemoteEvent("RegisterHit", true) or Net:RemoteEvent("RegisterHit")
        RegisterAttack = Net:RemoteEvent("RegisterAttack", true) or Net:RemoteEvent("RegisterAttack")
    end)
end

if not RegisterHit then
    RegisterHit = ReplicatedStorage:FindFirstChild("RE/RegisterHit", true)
end
if not RegisterAttack then
    RegisterAttack = ReplicatedStorage:FindFirstChild("RE/RegisterAttack", true)
end

local attackThread = nil
local secretToken = nil

if RegisterHit then
    attackThread = coroutine.create(function()
        local ok, err = pcall(function()
            local myId = tostring(Player.UserId)
            local threadId = tostring(coroutine.running())
            secretToken = myId:sub(2, 4) .. threadId:sub(11, 15)

            RegisterHit:FireServer(secretToken)

            while true do
                local hitPart, hitList = coroutine.yield()
                if hitPart and hitList and #hitList > 0 then
                    RegisterHit:FireServer(hitPart, hitList, nil, secretToken)
                end
            end
        end)
        if not ok then
            warn("[AttackMob] Attack thread warning:", err)
        end
    end)
    coroutine.resume(attackThread)
end

local function IsAlive(character)
    if not character or not character.Parent then return false end
    local hum = character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetTargets()
    local myChar = Player.Character
    if not myChar then return nil, {} end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil, {} end

    local targets = {}
    local primaryPart = nil

    local function scanFolder(folder)
        if not folder then return end
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy ~= myChar and IsAlive(enemy) then
                local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("UpperTorso")
                local head = enemy:FindFirstChild("Head") or hrp
                if hrp and head then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist <= AttackConfig.Distance then
                        if not primaryPart then
                            primaryPart = head
                        end

                        if AttackConfig.MultiPartHits then
                            local torso = enemy:FindFirstChild("UpperTorso") or enemy:FindFirstChild("Torso")
                            local partsToHit = { head, torso, hrp }
                            for _, part in ipairs(partsToHit) do
                                if part then
                                    table.insert(targets, { enemy, part })
                                end
                            end
                        else
                            local hitPart = hrp or head
                            table.insert(targets, { enemy, hitPart })
                        end
                    end
                end
            end
        end
    end

    if AttackConfig.AttackMobs then
        scanFolder(workspace:FindFirstChild("Enemies"))
    end
    if AttackConfig.AttackPlayers then
        scanFolder(workspace:FindFirstChild("Characters"))
    end

    return primaryPart, targets
end

local function GetEquippedOrBestWeapon()
    local myChar = Player.Character
    if not myChar then return nil end

    local equipped = myChar:FindFirstChildOfClass("Tool")
    if equipped then
        local wType = equipped:GetAttribute("WeaponType")
        if wType == "Melee" or wType == "Sword" or wType == "Gun" then
            return equipped
        end
        return equipped
    end

    if AttackConfig.AutoEquipWeapon then
        local backpack = Player:FindFirstChild("Backpack")
        if backpack then
            for _, prefType in ipairs(AttackConfig.WeaponPriority) do
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and (tool:GetAttribute("WeaponType") == prefType or tool.ToolTip == prefType or string.find(string.lower(tool.Name), string.lower(prefType))) then
                        pcall(function()
                            local hum = myChar:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum:EquipTool(tool)
                            end
                        end)
                        return tool
                    end
                end
            end
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    pcall(function()
                        local hum = myChar:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum:EquipTool(tool)
                        end
                    end)
                    return tool
                end
            end
        end
    end

    return equipped
end

local AttackMob = {}

function AttackMob:Hit()
    local myChar = Player.Character
    if not IsAlive(myChar) then return false end

    local tool = GetEquippedOrBestWeapon()
    if not tool then return false end

    local primaryPart, targets = GetTargets()
    if not primaryPart or #targets == 0 then
        return false
    end

    if RegisterAttack then
        pcall(function()
            RegisterAttack:FireServer(0)
        end)
    end

    local burstCount = math.max(1, tonumber(AttackConfig.DamageMultiplier) or 5)

    local function sendHitBatch(tList)
        if not tList or #tList == 0 then return end
        local pPart = tList[1] and (tList[1][2] or tList[1][1]:FindFirstChild("Head")) or primaryPart
        for _ = 1, burstCount do
            local sent = false
            if Global and type(Global.SendHitsToServer) == "function" then
                local ok = pcall(function()
                    Global.SendHitsToServer(pPart, tList)
                end)
                sent = ok
            end

            if not sent and attackThread and coroutine.status(attackThread) == "suspended" then
                pcall(function()
                    coroutine.resume(attackThread, pPart, tList)
                end)
            elseif not sent and RegisterHit then
                pcall(function()
                    RegisterHit:FireServer(pPart, tList, nil, secretToken)
                end)
            end
        end
    end

    if #targets <= 6 then
        sendHitBatch(targets)
    else
        for i = 1, #targets, 6 do
            local batch = {}
            for j = i, math.min(i + 5, #targets) do
                table.insert(batch, targets[j])
            end
            sendHitBatch(batch)
        end
    end

    return true
end

if getgenv()._BFAttackLoopRunning then
    getgenv()._BFAttackLoopRunning = false
    task.wait(0.1)
end
getgenv()._BFAttackLoopRunning = true

task.spawn(function()
    while getgenv()._BFAttackLoopRunning do
        if AttackConfig.Enabled then
            pcall(function()
                AttackMob:Hit()
            end)
        end
        task.wait(AttackConfig.AttackDelay)
    end
end)

return AttackMob
