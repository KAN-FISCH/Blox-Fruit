local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local TweenModule = {
    Speed = 200,
    IsTweening = false,
    CurrentTween = nil,
    TelePart = nil,
    TargetCFrame = nil,
    HeartbeatConn = nil,
    NoClipConn = nil
}

local function GetHRP()
    local char = Player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

function TweenModule.SetFloat(enabled)
    local hrp = GetHRP()
    if not hrp then return end
    local bv = hrp:FindFirstChild("BFTweenFloat")
    if enabled then
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "BFTweenFloat"
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

local function EnableNoClip()
    if TweenModule.NoClipConn then return end
    TweenModule.NoClipConn = RunService.Stepped:Connect(function()
        local autoFarmActive = getgenv().AutoFarmConfig and getgenv().AutoFarmConfig.AutoFarm
        if (TweenModule.IsTweening or autoFarmActive) and Player.Character then
            for _, part in ipairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoClip()
    local autoFarmActive = getgenv().AutoFarmConfig and getgenv().AutoFarmConfig.AutoFarm
    if not autoFarmActive and TweenModule.NoClipConn then
        TweenModule.NoClipConn:Disconnect()
        TweenModule.NoClipConn = nil
    end
end

function TweenModule:Stop()
    self.IsTweening = false
    self.TargetCFrame = nil
    if self.HeartbeatConn then
        self.HeartbeatConn:Disconnect()
        self.HeartbeatConn = nil
    end
    if self.CurrentTween then
        self.CurrentTween:Cancel()
        self.CurrentTween = nil
    end
    if self.TelePart and self.TelePart.Parent then
        self.TelePart:Destroy()
        self.TelePart = nil
    end
    DisableNoClip()
end

function TweenModule:To(targetCFrame, customSpeed, onComplete)
    if not targetCFrame then return false end
    
    local hrp = GetHRP()
    if not hrp then return false end

    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    if typeof(targetCFrame) == "Vector3" then
        targetCFrame = CFrame.new(targetCFrame)
    end

    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    if distance <= 10 then
        self:Stop()
        hrp.CFrame = targetCFrame
        hrp.Velocity = Vector3.zero
        if onComplete then onComplete() end
        return true
    end

    if self.IsTweening and self.TargetCFrame then
        local diff = (targetCFrame.Position - self.TargetCFrame.Position).Magnitude
        if diff < 15 then
            return true
        end
    end

    self:Stop()
    self.IsTweening = true
    self.TargetCFrame = targetCFrame
    EnableNoClip()
    self.SetFloat(true)

    local speed = math.clamp(tonumber(customSpeed) or self.Speed or 200, 10, 200)
    local duration = distance / math.max(1, speed)

    local part = Instance.new("Part")
    part.Name = "BFTweenPart"
    part.Size = Vector3.new(4, 1, 4)
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CFrame = hrp.CFrame
    part.Parent = workspace
    self.TelePart = part

    self.HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not self.IsTweening or not self.TelePart then
            if self.HeartbeatConn then
                self.HeartbeatConn:Disconnect()
                self.HeartbeatConn = nil
            end
            return
        end
        local currentHrp = GetHRP()
        if currentHrp and self.TelePart then
            currentHrp.CFrame = self.TelePart.CFrame
            currentHrp.Velocity = Vector3.zero
            currentHrp.RotVelocity = Vector3.zero
        end
    end)

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(part, tweenInfo, { CFrame = targetCFrame })
    self.CurrentTween = tween

    tween.Completed:Connect(function(playbackState)
        if self.HeartbeatConn then
            self.HeartbeatConn:Disconnect()
            self.HeartbeatConn = nil
        end
        if self.TelePart then
            self.TelePart:Destroy()
            self.TelePart = nil
        end
        self.CurrentTween = nil
        self.IsTweening = false
        self.TargetCFrame = nil

        if playbackState == Enum.PlaybackState.Completed then
            local finalHrp = GetHRP()
            if finalHrp then
                finalHrp.CFrame = targetCFrame
                finalHrp.Velocity = Vector3.zero
            end
            if onComplete then
                onComplete()
            end
        end
    end)

    tween:Play()
    return true
end

_G.BFTween = TweenModule
return TweenModule
