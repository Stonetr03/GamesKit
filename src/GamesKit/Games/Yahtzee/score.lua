-- Stonetr03 - GamesKit - Yahtzee Score Indexing

return function (index: number, dice: {number}, dbl: number): number
    if #dice ~= 5 then
        return 0;
    end
    for _,o in pairs(dice) do
        if o == 0 then
            return 0;
        end
    end

    local sorted = table.create(6,0);
    for _,o in pairs(dice) do
        if sorted[o] then
            sorted[o]+=1;
        end
    end;

    if index >= 1 and index <= 6 then
        -- ones - sixes
        return sorted[index] * index;
    elseif index == 7 then
        -- three of a kind
        for _,o in pairs(sorted) do
            if o >= 3 then
                -- total of all dice
                return dice[1] + dice[2] + dice[3] + dice[4] + dice[5];
            end
        end
    elseif index == 8 then
        -- four of a kind
        for _,o in pairs(sorted) do
            if o >= 4 then
                -- total of all dice
                return dice[1] + dice[2] + dice[3] + dice[4] + dice[5];
            end
        end
    elseif index == 9 then
        -- full house
        local high,low = false,false
        for _,o in pairs(sorted) do
            if o == 3 then
                high = true;
            elseif o == 2 then
                low = true
            end
        end
        if high and low then
            return 25;
        end
    elseif index == 10 then
        -- small straight
        local c = 0
        for i = 1, #sorted do
            if sorted[i] > 0 then
                c = c + 1
                if c >= 4 then
                    return 30;
                end
            else
                c = 0 -- reset, gap
            end
        end
    elseif index == 11 then
        -- large straight
        local c = 0
        for i = 1, #sorted do
            if sorted[i] > 0 then
                c = c + 1
                if c >= 5 then
                    return 40;
                end
            else
                c = 0 -- reset, gap
            end
        end
    elseif index == 12 then
        -- Yahtzee
        for _,o in pairs(sorted) do
            if o == 5 then
                if dbl > 0 then
                    return dbl + 100;
                else
                    return 50;
                end
            end
        end
    elseif index == 13 then
        -- Chance
        return dice[1] + dice[2] + dice[3] + dice[4] + dice[5];
    end

    return 0;
end
