-- Stonetr03 - Manages all clocks

local Module = {
    Games = nil;
    GameOver = nil;
}
local ToClock = {}

-- Clocks
local Run = coroutine.create(function()
    while true do
        if #ToClock == 0 then
            coroutine.yield()
        else
            for _,Hash in pairs(ToClock) do
                if Module.Games[Hash] then
                    if Module.Games[Hash].Turn and Module.Games[Hash].Turn == "w" and Module.Games[Hash].Clocks and Module.Games[Hash].Clocks.w and Module.Games[Hash].Clocks.w.bonus and Module.Games[Hash].Clocks.w.clock then

                        -- Bonus time
                        if Module.Games[Hash].Clocks.w.bonus > 0 then
                            Module.Games[Hash].Clocks.w.bonus -= 0.1
                        elseif Module.Games[Hash].Clocks.w.clock > 0 then
                            Module.Games[Hash].Clocks.w.clock -= 0.1
                        else
                            if typeof(Module.GameOver) == "function" then
                                Module.GameOver(Hash,"w")
                            end
                        end

                    elseif Module.Games[Hash].Clocks and Module.Games[Hash].Clocks.b and Module.Games[Hash].Clocks.b.bonus and Module.Games[Hash].Clocks.b.clock then

                        -- Bonus time
                        if Module.Games[Hash].Clocks.b.bonus > 0 then
                            Module.Games[Hash].Clocks.b.bonus -= 0.1
                        elseif Module.Games[Hash].Clocks.b.clock > 0 then
                            Module.Games[Hash].Clocks.b.clock -= 0.1
                        else
                            if typeof(Module.GameOver) == "function" then
                                Module.GameOver(Hash,"b")
                            end
                        end

                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

function Module:RunClock(Hash)
    table.insert(ToClock,Hash)
    task.spawn(function()
        coroutine.resume(Run)
    end)
end

function Module:StopClock(Hash)
    if table.find(ToClock,Hash) then
        table.remove(ToClock,table.find(ToClock,Hash))
    end
end

return Module
