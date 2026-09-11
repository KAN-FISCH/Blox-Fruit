local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local TweenModule = nil
pcall(function()
    if _G.BFTween then
        TweenModule = _G.BFTween
    elseif readfile and isfile and isfile("Blox Fruit Script/Modules/Tween.lua") then
        TweenModule = loadstring(readfile("Blox Fruit Script/Modules/Tween.lua"))()
    elseif readfile and isfile and isfile("Modules/Tween.lua") then
        TweenModule = loadstring(readfile("Modules/Tween.lua"))()
    elseif game and game.HttpGet then
        TweenModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/KAN-FISCH/Blox-Fruit/refs/heads/main/Modules/Tween.lua"))()
    end
end)

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

local AutoQuest = {
    IsTakingQuest = false,
    QuestList = {
        { MinLevel = 1, MaxLevel = 9, Mon = "Bandit", LevelQuest = 1, NameQuest = "BanditQuest1", NameMon = "Bandit",
          CFrameQuest = CFrame.new(1059.37, 15.45, 1550.42),
          CFrameMon = CFrame.new(1045.96, 27.00, 1560.82) },
        { MinLevel = 10, MaxLevel = 14, Mon = "Monkey", LevelQuest = 1, NameQuest = "JungleQuest", NameMon = "Monkey",
          CFrameQuest = CFrame.new(-1598.09, 35.55, 153.38),
          CFrameMon = CFrame.new(-1448.52, 67.85, 11.47) },
        { MinLevel = 15, MaxLevel = 29, Mon = "Gorilla", LevelQuest = 2, NameQuest = "JungleQuest", NameMon = "Gorilla",
          CFrameQuest = CFrame.new(-1598.09, 35.55, 153.38),
          CFrameMon = CFrame.new(-1129.88, 40.46, -525.42) },
        { MinLevel = 30, MaxLevel = 39, Mon = "Pirate", LevelQuest = 1, NameQuest = "BuggyQuest1", NameMon = "Pirate",
          CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.55),
          CFrameMon = CFrame.new(-1103.51, 13.75, 3896.09) },
        { MinLevel = 40, MaxLevel = 59, Mon = "Brute", LevelQuest = 2, NameQuest = "BuggyQuest1", NameMon = "Brute",
          CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.55),
          CFrameMon = CFrame.new(-1140.08, 14.81, 4322.92) },
        { MinLevel = 60, MaxLevel = 74, Mon = "Desert Bandit", LevelQuest = 1, NameQuest = "DesertQuest", NameMon = "Desert Bandit",
          CFrameQuest = CFrame.new(894.49, 5.14, 4392.43),
          CFrameMon = CFrame.new(924.80, 6.45, 4481.59) },
        { MinLevel = 75, MaxLevel = 89, Mon = "Desert Officer", LevelQuest = 2, NameQuest = "DesertQuest", NameMon = "Desert Officer",
          CFrameQuest = CFrame.new(894.49, 5.14, 4392.43),
          CFrameMon = CFrame.new(1608.28, 8.61, 4371.01) },
        { MinLevel = 90, MaxLevel = 99, Mon = "Snow Bandit", LevelQuest = 1, NameQuest = "SnowQuest", NameMon = "Snow Bandit",
          CFrameQuest = CFrame.new(1389.74, 88.15, -1298.91),
          CFrameMon = CFrame.new(1354.35, 87.27, -1393.95) },
        { MinLevel = 100, MaxLevel = 119, Mon = "Snowman", LevelQuest = 2, NameQuest = "SnowQuest", NameMon = "Snowman",
          CFrameQuest = CFrame.new(1389.74, 88.15, -1298.91),
          CFrameMon = CFrame.new(1201.64, 144.58, -1550.07) },
        { MinLevel = 120, MaxLevel = 149, Mon = "Chief Petty Officer", LevelQuest = 1, NameQuest = "MarineQuest2", NameMon = "Chief Petty Officer",
          CFrameQuest = CFrame.new(-5039.59, 27.35, 4324.68),
          CFrameMon = CFrame.new(-4881.23, 22.65, 4273.75) },
        { MinLevel = 150, MaxLevel = 174, Mon = "Sky Bandit", LevelQuest = 1, NameQuest = "SkyQuest", NameMon = "Sky Bandit",
          CFrameQuest = CFrame.new(-4839.53, 716.37, -2619.44),
          CFrameMon = CFrame.new(-4953.21, 295.74, -2899.23) },
        { MinLevel = 175, MaxLevel = 189, Mon = "Dark Master", LevelQuest = 2, NameQuest = "SkyQuest", NameMon = "Dark Master",
          CFrameQuest = CFrame.new(-4839.53, 716.37, -2619.44),
          CFrameMon = CFrame.new(-5259.84, 391.40, -2229.04) },
        { MinLevel = 190, MaxLevel = 209, Mon = "Prisoner", LevelQuest = 1, NameQuest = "PrisonerQuest", NameMon = "Prisoner",
          CFrameQuest = CFrame.new(5308.93, 1.66, 475.12),
          CFrameMon = CFrame.new(5098.97, -0.32, 474.24) },
        { MinLevel = 210, MaxLevel = 249, Mon = "Dangerous Prisoner", LevelQuest = 2, NameQuest = "PrisonerQuest", NameMon = "Dangerous Prisoner",
          CFrameQuest = CFrame.new(5308.93, 1.66, 475.12),
          CFrameMon = CFrame.new(5654.56, 15.63, 866.30) },
        { MinLevel = 250, MaxLevel = 274, Mon = "Toga Warrior", LevelQuest = 1, NameQuest = "ColosseumQuest", NameMon = "Toga Warrior",
          CFrameQuest = CFrame.new(-1580.05, 6.35, -2986.48),
          CFrameMon = CFrame.new(-1820.21, 51.68, -2740.67) },
        { MinLevel = 275, MaxLevel = 299, Mon = "Gladiator", LevelQuest = 2, NameQuest = "ColosseumQuest", NameMon = "Gladiator",
          CFrameQuest = CFrame.new(-1580.05, 6.35, -2986.48),
          CFrameMon = CFrame.new(-1292.84, 56.38, -3339.03) },
        { MinLevel = 300, MaxLevel = 324, Mon = "Military Soldier", LevelQuest = 1, NameQuest = "MagmaQuest", NameMon = "Military Soldier",
          CFrameQuest = CFrame.new(-5313.37, 10.95, 8515.29),
          CFrameMon = CFrame.new(-5411.16, 11.08, 8454.29) },
        { MinLevel = 325, MaxLevel = 374, Mon = "Military Spy", LevelQuest = 2, NameQuest = "MagmaQuest", NameMon = "Military Spy",
          CFrameQuest = CFrame.new(-5313.37, 10.95, 8515.29),
          CFrameMon = CFrame.new(-5802.87, 86.26, 8828.86) },
        { MinLevel = 375, MaxLevel = 399, Mon = "Fishman Warrior", LevelQuest = 1, NameQuest = "FishmanQuest", NameMon = "Fishman Warrior",
          CFrameQuest = CFrame.new(61122.65, 18.50, 1569.40),
          CFrameMon = CFrame.new(60878.30, 18.48, 1543.76) },
        { MinLevel = 400, MaxLevel = 449, Mon = "Fishman Commando", LevelQuest = 2, NameQuest = "FishmanQuest", NameMon = "Fishman Commando",
          CFrameQuest = CFrame.new(61122.65, 18.50, 1569.40),
          CFrameMon = CFrame.new(61922.63, 18.48, 1493.93) },
        { MinLevel = 450, MaxLevel = 474, Mon = "God's Guard", LevelQuest = 1, NameQuest = "SkyExp1Quest", NameMon = "God's Guard",
          CFrameQuest = CFrame.new(-4721.89, 843.87, -1949.97),
          CFrameMon = CFrame.new(-4710.04, 845.28, -1927.31) },
        { MinLevel = 475, MaxLevel = 524, Mon = "Shanda", LevelQuest = 2, NameQuest = "SkyExp1Quest", NameMon = "Shanda",
          CFrameQuest = CFrame.new(-7859.10, 5544.19, -381.48),
          CFrameMon = CFrame.new(-7678.49, 5566.40, -497.22) },
        { MinLevel = 525, MaxLevel = 549, Mon = "Royal Squad", LevelQuest = 1, NameQuest = "SkyExp2Quest", NameMon = "Royal Squad",
          CFrameQuest = CFrame.new(-7906.82, 5634.66, -1411.99),
          CFrameMon = CFrame.new(-7624.25, 5658.13, -1467.35) },
        { MinLevel = 550, MaxLevel = 624, Mon = "Royal Soldier", LevelQuest = 2, NameQuest = "SkyExp2Quest", NameMon = "Royal Soldier",
          CFrameQuest = CFrame.new(-7906.82, 5634.66, -1411.99),
          CFrameMon = CFrame.new(-7836.75, 5645.66, -1790.62) },
        { MinLevel = 625, MaxLevel = 649, Mon = "Galley Pirate", LevelQuest = 1, NameQuest = "FountainQuest", NameMon = "Galley Pirate",
          CFrameQuest = CFrame.new(5259.82, 37.35, 4050.03),
          CFrameMon = CFrame.new(5551.02, 78.90, 3930.41) },
        { MinLevel = 650, MaxLevel = 9999, Mon = "Galley Captain", LevelQuest = 2, NameQuest = "FountainQuest", NameMon = "Galley Captain",
          CFrameQuest = CFrame.new(5259.82, 37.35, 4050.03),
          CFrameMon = CFrame.new(5441.95, 42.50, 4950.09) }
    }
}

function AutoQuest:GetPlayerLevel()
    local data = Player:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        return tonumber(data.Level.Value) or 1
    end
    return 1
end

function AutoQuest:GetQuestData(level)
    local myLvl = level or self:GetPlayerLevel()
    for _, q in ipairs(self.QuestList) do
        if myLvl >= q.MinLevel and myLvl <= q.MaxLevel then
            return q
        end
    end
    return self.QuestList[#self.QuestList]
end

function AutoQuest:HasQuest(questData)
    local qData = questData or self:GetQuestData()
    local text = ""
    local isVisible = false

    pcall(function()
        local pg = Player:FindFirstChild("PlayerGui") or Player.PlayerGui
        if not pg then return end

        local tqf = pg:FindFirstChild("TrackedQuestFrame")
        if tqf and (not tqf:IsA("ScreenGui") or tqf.Enabled ~= false) then
            local frame = tqf:FindFirstChild("Frame")
            if frame and frame.Visible ~= false then
                isVisible = true
                for _, desc in ipairs(frame:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Visible ~= false and desc.Text and desc.Text ~= "" then
                        text = text .. " " .. desc.Text
                    end
                end
            end
        end

        local main = pg:FindFirstChild("Main")
        local qGui = main and main:FindFirstChild("Quest")
        if qGui and qGui.Visible == true then
            isVisible = true
            for _, desc in ipairs(qGui:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Visible ~= false and desc.Text and desc.Text ~= "" then
                    text = text .. " " .. desc.Text
                end
            end
        end
    end)

    if not isVisible then
        return false
    end

    if qData then
        local monName = string.lower(qData.NameMon or "")
        local questName = string.lower(qData.NameQuest or "")
        local qText = string.lower(text)

        local isMatch = false
        if monName ~= "" and string.find(qText, monName, 1, true) then
            isMatch = true
        elseif questName ~= "" and string.find(qText, questName, 1, true) then
            isMatch = true
        end

        if qText ~= "" and #qText > 2 and not isMatch then
            self:AbandonQuest()
            task.wait(0.2)
            return false
        end
    end

    return true
end

function AutoQuest:AbandonQuest()
    pcall(function()
        CommF_:InvokeServer("AbandonQuest")
    end)
end

function AutoQuest:TakeQuest(onComplete)
    local qData = self:GetQuestData()
    if not qData then return false end

    if self:HasQuest(qData) then
        self.IsTakingQuest = false
        if onComplete then onComplete(qData) end
        return true
    end

    if self.IsTakingQuest then
        return false
    end

    self.IsTakingQuest = true

    task.spawn(function()
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            AutoQuest.IsTakingQuest = false
            return
        end

        local distToNpc = (qData.CFrameQuest.Position - hrp.Position).Magnitude

        if distToNpc > 30 then
            if TweenModule then
                TweenModule:To(qData.CFrameQuest)
                local timeout = 0
                while distToNpc > 30 and timeout < 100 and AutoQuest.IsTakingQuest and getgenv().AutoFarmConfig and getgenv().AutoFarmConfig.AutoFarm do
                    task.wait(0.1)
                    timeout = timeout + 1
                    char = Player.Character
                    hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        distToNpc = (qData.CFrameQuest.Position - hrp.Position).Magnitude
                    else
                        break
                    end
                end
            else
                hrp.CFrame = qData.CFrameQuest
                task.wait(0.5)
            end
        end

        if distToNpc <= 30 then
            if TweenModule and TweenModule.IsTweening then
                TweenModule:Stop()
            end
            hrp.CFrame = qData.CFrameQuest
            pcall(function()
                CommF_:InvokeServer("StartQuest", qData.NameQuest, qData.LevelQuest)
            end)
            task.wait(0.4)
        end

        AutoQuest.IsTakingQuest = false
        if onComplete then
            onComplete(qData)
        end
    end)

    return true
end

return AutoQuest
