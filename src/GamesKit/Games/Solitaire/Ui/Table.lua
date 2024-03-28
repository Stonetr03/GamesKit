-- Stonetr03

local Module = {}

function Module:Shuffle(t: table): table
    local rt = {}
    for _, v in ipairs(t) do
        local pos = math.random(1, #rt + 1)
        table.insert(rt, pos, v)
    end

    return rt;
end

function Module:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60

    local formattedTime = ""

    if hours > 0 then
        formattedTime = string.format("%d:%02d:%02d", hours, minutes, remainingSeconds)
    else
        formattedTime = string.format("%02d:%02d", minutes, remainingSeconds)
    end

    return formattedTime
end

return Module
