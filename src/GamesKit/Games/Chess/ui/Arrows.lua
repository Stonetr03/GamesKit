-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))

local New = Fusion.New
local Computed = Fusion.Computed
local Value = Fusion.Value

local Module = {
    Rendering = Value({});
    BoardFlipped = nil;

    Colors = {
        Red = Value(Color3.fromRGB(235,100,80));
        Blue = Value(Color3.fromRGB(80, 180, 220));
        Green = Value(Color3.fromRGB(170,200,90));
        Orange = Value(Color3.fromRGB(255,170,0));
    };
}

local FileTxtToNum = {
    ["a"] = 1;
    ["b"] = 2;
    ["c"] = 3;
    ["d"] = 4;
    ["e"] = 5;
    ["f"] = 6;
    ["g"] = 7;
    ["h"] = 8;
}

local Flipped = {
    [1] = 8;
    [2] = 7;
    [3] = 6;
    [4] = 5;
    [5] = 4;
    [6] = 3;
    [7] = 2;
    [8] = 1;
}
function GetXPos(y)
    if Module.BoardFlipped:get() == false then
        return y
    end
    return Flipped[y]
end
function GetYPos(y)
    if Module.BoardFlipped:get() == true then
        return y
    end
    return Flipped[y]
end

function Module:GetArrow(Sq1,Sq2)
    local render = Module.Rendering:get()
    for _,o in pairs(render) do
        if o.P1 == Sq1 and o.P2 == Sq2 then
            return o
        end
    end
    return
end

function Module:RemoveArrow(Sq1,Sq2)
    local o = Module:GetArrow(Sq1,Sq2)
    if o then
        local render = Module.Rendering:get()
        table.remove(render,table.find(render,o))
        Module.Rendering:set(render);
    end
end

function Module.Ui()
    return Fusion.ForPairs(Computed(function()
        return Module.Rendering:get()
    end),function(i,o)
        local P1X = (0.125 * (GetXPos(FileTxtToNum[string.sub(o.P1,1,1)])-1)) + 0.0625
        local P1Y = (0.125 * (GetYPos(tonumber(string.sub(o.P1,2,2)))-1)) + 0.0625
        local P2X = (0.125 * (GetXPos(FileTxtToNum[string.sub(o.P2,1,1)])-1)) + 0.0625
        local P2Y = (0.125 * (GetYPos(tonumber(string.sub(o.P2,2,2)))-1)) + 0.0625

        local Position = UDim2.new((P1X + P2X) / 2,0,(P1Y + P2Y) / 2,0)
        local D = math.sqrt( (P2X - P1X)^2 + (P2Y - P1Y)^2 )
        local M = (math.atan2((P2Y-P1Y),(P2X-P1X))) * 180 / math.pi

        return i, New "ImageLabel" {
            AnchorPoint = Vector2.new(0.5,0.5);
            BackgroundTransparency = 1;
            Size = UDim2.new(D,0,0.1,0);
            Position = Position;
            Rotation = M + 180;
            ZIndex = 150;

            Image = "rbxassetid://14513733853";
            ImageColor3 = Module.Colors[o.C];
            ScaleType = Enum.ScaleType.Slice;
            SliceCenter = Rect.new(86, 120, 86, 120);
            ImageTransparency = 0.2;
        }
    end,Fusion.cleanup)
end

return Module
