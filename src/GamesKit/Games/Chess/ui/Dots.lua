-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Event = Fusion.OnEvent
local Value = Fusion.Value

local Module = {
    RenderingDots = Value({
        Callback = nil;
        ToRender = {};
    });
    BoardFlipped = nil;
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

function Module.Ui()
    return Fusion.ForPairs(Computed(function()
        return Module.RenderingDots:get().ToRender
    end),function(i,o)
        if typeof(o) == "table" then
            o = o[1]
        end
        return i, New "ImageButton" {
            BackgroundTransparency = 1;
            Image = "";
            Size = UDim2.new(0.125,0,0.125,0);
            Position = UDim2.new(0.125 * (GetXPos(FileTxtToNum[string.sub(o,1,1)])-1),0,0.125 * (GetYPos(tonumber(string.sub(o,2,2)))-1),0);
            ZIndex = 100;
            [Event "MouseButton1Down"] = function()
                if typeof(Module.RenderingDots:get().Callback) == "function" then
                    Module.RenderingDots:get().Callback(o)
                end
            end;
            [Children] = New "Frame" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.7;
                Position = UDim2.new(0.5,0,0.5,0);
                Size = UDim2.new(0.33333,0,0.33333,0);
                ZIndex = 101;
                [Children] = New "UICorner" {
                    CornerRadius = UDim.new(1,0);
                }
            }
        }
    end,Fusion.cleanup)
end

return Module
