-- Stonetr03

local Settings = require(script.Parent:WaitForChild("Settings"));

local Module = {}

local Letters = {
    [""] = 0;
    ["A"] = 1;
    ["T"] = 10;
    ["J"] = 11;
    ["Q"] = 12;
    ["K"] = 13;
    [" "] = 14;
}
local Numbers = {
    [0] = "";
    [1] = "A";
    [10] = "T";
    [11] = "J";
    [12] = "Q";
    [13] = "K";
    [14] = " ";
}

function Module:ToNumber(s: string): number
    if Letters[s] then
        return Letters[s]
    end
    return tonumber(s)
end

function Module:ToLetter(n: number): string
    if Numbers[n] then
        return Numbers[n];
    end
    return tostring(n)
end

function Module:ToColor(s: string): number
    if s == "S" or s == "C" then
        return 0;
    elseif s == "H" or s == "D" then
        return 1;
    end
    return 2;
end

function Module:IsOpposite(s1: string, s2: string): boolean
    if Module:ToColor(string.sub(s1,2,2)) + Module:ToColor(string.sub(s2,2,2)) == 1 then
        return true
    end
    return false
end

local SuitNums = {
    [1] = "S";
    [2] = "H";
    [3] = "C";
    [4] = "D";
}
function Module:SuitToLetter(n: number): string
    if SuitNums[n] then
        return SuitNums[n]
    end
    return ""
end

-- Images
local ImgMap = {
    [1] = {1,1}; -- Normal, Colored
    [2] = {3,3};
    [3] = {3,3};
}
function Module:GetImage(Card: string): number
    if Card == "" or Card == "empty" or Card == "B1" or Card == "B2" then
        return 1;
    end
    local CardSize = Settings.Size:get() -- 1:Normal, 2:Medium, ~~3:Large~~
    if Settings.Color:get() == true then
        return ImgMap[CardSize][2]
    end
    return ImgMap[CardSize][1]
end

return Module
