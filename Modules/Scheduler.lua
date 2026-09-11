local u2 = false
local u3 = nil
local u4 = 15
local u5 = 0
local activeTimeout = nil

local function shouldYieldToHost()
    return u5 <= os.clock() * 1000
end

local function forceFrameRate(p6)
    if p6 < 0 or p6 > 125 then
        return
    end
    if p6 > 0 then
        u4 = math.floor(1000 / p6)
        return
    end
    u4 = 5
end

local function performWorkUntilDeadline()
    if u3 == nil then
        u2 = false
    else
        local u7 = os.clock() * 1000
        u5 = u7 + u4
        local function doWork()
            if u3(true, u7) then
                task.delay(0, performWorkUntilDeadline)
            else
                u2 = false
                u3 = nil
            end
            return nil
        end
        local ok, err = pcall(doWork)
        if not ok then
            task.delay(0, performWorkUntilDeadline)
            warn(tostring(err))
        end
    end
end

return {
    requestHostCallback = function(p16)
        u3 = p16
        if not u2 then
            u2 = true
            task.delay(0, performWorkUntilDeadline)
        end
    end,

    cancelHostCallback = function()
        u3 = nil
    end,

    requestHostTimeout = function(u17, p18)
        activeTimeout = task.delay((p18 or 0) / 1000, function()
            u17(os.clock() * 1000)
        end)
    end,

    cancelHostTimeout = function()
        if activeTimeout then
            pcall(function() task.cancel(activeTimeout) end)
            activeTimeout = nil
        end
    end,

    shouldYieldToHost = shouldYieldToHost,
    requestPaint = function() end,
    getCurrentTime = function()
        return os.clock() * 1000
    end,
    forceFrameRate = forceFrameRate
}
