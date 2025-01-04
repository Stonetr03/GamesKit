-- Stonetr03 - GamesKit - Yahtzee Turn Style
    -- One player goes at a time, other players wait for player to finish

local Module = {
    Finish = nil :: (table,table) -> ();
    Timeout = nil :: (table,Player) -> ();
}

local r = Random.new(math.floor(tick() * math.random()));
local getScore = require(script.Parent.Parent:WaitForChild("score"));

local timeouts = {};

function Module.CreateInitData(g: table)
    g.data = {
        style = "turn";
        turn = nil;
        round = 1;
        players = {};
    }
    for _,p in pairs(g.players) do
        g.data.players[p.UserId] = {
            score = table.create(13,-1);
            dice = table.create(5,0);
            frozen = table.create(5,false);
            roll = 0;
            timeout = os.time() + 90;
        }
    end
    timeouts[g] = coroutine.create(function()
        while task.wait(1) do
            if g.data.players[g.data.turn.UserId].timeout < os.time() then
                -- Time out
                g.data.players[g.data.turn.UserId] = nil;
                Module.NextPlr(g);
                Module.Timeout(g,g.data.turn);
            end
        end
    end);
    coroutine.resume(timeouts[g]);
    Module.NextPlr(g);
end

function Module.HandlePlayerLeave(g: table, p: Player)
    if not g.pending then
        if g.data.players[p.UserId] then
            g.data.players[p.UserId] = nil;
        end
        if g.data.turn == p then
            Module.NextPlr(g);
        end
    end
end

function Module.Roll(g: table, p: Player, f1: boolean, f2: boolean, f3: boolean, f4: boolean, f5: boolean): boolean
    if g.data.players[p.UserId] then
        -- Check if player can roll
        if g.data.turn == p and g.data.players[p.UserId].roll < 3 then
            -- No die can be frozen on the first roll, all dice must be rolled
            if g.data.players[p.UserId].roll == 0 then
                f1 = false; f2 = false; f3 = false; f4 = false; f5 = false;
            end
            -- Roll dice
            g.data.players[p.UserId].roll += 1;
            g.data.players[p.UserId].frozen[1] = f1;
            g.data.players[p.UserId].frozen[2] = f2;
            g.data.players[p.UserId].frozen[3] = f3;
            g.data.players[p.UserId].frozen[4] = f4;
            g.data.players[p.UserId].frozen[5] = f5;
            if not f1 then
                g.data.players[p.UserId].dice[1] = r:NextInteger(1,6);
            end
            if not f2 then
                g.data.players[p.UserId].dice[2] = r:NextInteger(1,6);
            end
            if not f3 then
                g.data.players[p.UserId].dice[3] = r:NextInteger(1,6);
            end
            if not f4 then
                g.data.players[p.UserId].dice[4] = r:NextInteger(1,6);
            end
            if not f5 then
                g.data.players[p.UserId].dice[5] = r:NextInteger(1,6);
            end
            -- update
            return true
        end
    end
    return false;
end

function Module.NextPlr(g: table)
    -- go to next player
    for pId,o in pairs(g.data.players) do
        local c = 0
        for _,s in pairs(o.score) do
            if s ~= -1 then
                c+=1;
            end
        end
        local p = game.Players:GetPlayerByUserId(pId);
        if p and c < g.data.round then
            g.data.turn = p;
            g.data.players[p.UserId].timeout = os.time() + 90;
            return;
        end
    end
    -- all players have completed round
    if g.data.round == 13 then
        -- FINISH GAME
        local finTab = {}
        for pId,o in pairs(g.data.players) do
            finTab[pId] = {
                score = o.score[1] + o.score[2] + o.score[3] + o.score[4] + o.score[5] + o.score[6] + o.score[7] + o.score[8] + o.score[9] + o.score[10] + o.score[11] + o.score[12] + o.score[13] + (o.score[1] + o.score[2] + o.score[3] + o.score[4] + o.score[5] + o.score[6] >= 63 and 35 or 0);
                card = o.score;
            };
        end
        Module.Finish(g,finTab);
    else
        g.data.round += 1
        Module.NextPlr(g);
    end
end

function Module.Score(g: table, p: Player, i: number, dblIndex: number?): boolean
    if typeof(dblIndex) ~= "number" then dblIndex = 0 end;
    if dblIndex < 0 or dblIndex > 13 or dblIndex == 12 then return false end;
    if i < 1 or i > 13 then return false end;

    if g.data.players[p.UserId] then
        -- Check if player can roll
        for _,o in pairs(g.data.players[p.UserId].dice) do
            if o == 0 then
                return false;
            end
        end
        if g.data.turn == p and g.data.players[p.UserId].roll > 0 and (g.data.players[p.UserId].score[i] == -1 or (i == 12 and getScore(i,g.data.players[p.UserId].dice,g.data.players[p.UserId].score[12]) > g.data.players[p.UserId].score[12])) then
            if i == 12 and g.data.players[p.UserId].score[i] > 0 then
                -- dbl
                if g.data.players[p.UserId].score[ g.data.players[p.UserId].dice[1] ] == -1 then
                    -- Score double on top section
                    g.data.players[p.UserId].score[ g.data.players[p.UserId].dice[1] ] = g.data.players[p.UserId].dice[1] * 5;
                elseif dblIndex > 6 then
                    -- Score bottom section
                    if g.data.players[p.UserId].score[dblIndex] == -1 then
                        if dblIndex == 7 or dblIndex == 8 or dblIndex == 13 then
                            g.data.players[p.UserId].score[dblIndex] = g.data.players[p.UserId].dice[1] * 5;
                        elseif dblIndex == 9 then
                            g.data.players[p.UserId].score[dblIndex] = 25;
                        elseif dblIndex == 10 then
                            g.data.players[p.UserId].score[dblIndex] = 30;
                        elseif dblIndex == 11 then
                            g.data.players[p.UserId].score[dblIndex] = 40;
                        end
                    else
                        return false -- Cannot score already filled box.
                    end
                elseif dblIndex < 7 then
                    -- Score top section, all bottom must be filled
                    for j = 7,13,1 do
                        if g.data.players[p.UserId].score[j] == -1 then
                            return false; -- not all bottom filled;
                        end
                    end;
                    if g.data.players[p.UserId].score[dblIndex] == -1 then
                        -- Score
                        g.data.players[p.UserId].score[dblIndex] = dblIndex * 5;
                    else
                        return false;
                    end
                else
                    return false;
                end
            end
            g.data.players[p.UserId].score[i] = getScore(i,g.data.players[p.UserId].dice,g.data.players[p.UserId].score[12])
            -- reset
            g.data.players[p.UserId].dice = table.create(5,0);
            g.data.players[p.UserId].frozen = table.create(5,false);
            g.data.players[p.UserId].roll = 0;
            -- next player
            Module.NextPlr(g);
            -- update
            return true
        end
    end
    return false;
end

function Module.cleanup(g: table)
    if timeouts[g] then
        coroutine.close(timeouts[g])
        timeouts[g] = nil;
    end
end

return Module;
