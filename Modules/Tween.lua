local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local TweenModule = {
    Speed = 350,
    IsTweening = false,
    CurrentTween = nil,
    TelePart = nil,
    NoClipConn = nil
}

local function GetHRP()
    local char = Player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function EnableNoClip()
    if TweenModule.NoClipConn then return end
    TweenModule.NoClipConn = RunService.Stepped:Connect(function()
        if TweenModule.IsTweening and Player.Character then
            for _, part in ipairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoClip()
    if TweenModule.NoClipConn then
        TweenModule.NoClipConn:Disconnect()
        TweenModule.NoClipConn = nil
    end
end

function TweenModule:Stop()
    self.IsTweening = false
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
    if distance <= 8 then
        hrp.CFrame = targetCFrame
        if onComplete then onComplete() end
        return true
    end

    self:Stop()
    self.IsTweening = true
    EnableNoClip()

    local speed = tonumber(customSpeed) or self.Speed or 350
    local duration = distance / math.max(1, speed)

    local part = Instance.new("Part")
    part.Name = "BFTweenPart"
    part.Size = Vector3.new(6, 1, 6)
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CFrame = hrp.CFrame
    part.Parent = char
    self.TelePart = part

    local cframeConn
    cframeConn = part:GetPropertyChangedSignal("CFrame"):Connect(function()
        if not self.IsTweening then
            if cframeConn then cframeConn:Disconnect() end
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
        if cframeConn then cframeConn:Disconnect() end
        if self.TelePart then
            self.TelePart:Destroy()
            self.TelePart = nil
        end
        self.CurrentTween = nil
        self.IsTweening = false
        DisableNoClip()

        if playbackState == Enum.PlaybackState.Completed then
            local finalHrp = GetHRP()
            if finalHrp then
                finalHrp.CFrame = targetCFrame
            end
            if onComplete then
                onComplete()
            end
        end
    end)

    tween:Play()
    return true
end

return TweenModule
