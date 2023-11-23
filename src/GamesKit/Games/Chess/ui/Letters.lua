-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local Module = {
    BoardFlipped = nil;
}

local InvertRank = {
    [1] = 8;
    [2] = 7;
    [3] = 6;
    [4] = 5;
    [5] = 4;
    [6] = 3;
    [7] = 2;
    [8] = 1;
}

local InvertFile = {
    ["a"] = "h";
    ["b"] = "g";
    ["c"] = "f";
    ["d"] = "e";
    ["e"] = "d";
    ["f"] = "c";
    ["g"] = "b";
    ["h"] = "a";
}

local FileNumToTxt = {
    [1] = "a";
    [2] = "b";
    [3] = "c";
    [4] = "d";
    [5] = "e";
    [6] = "f";
    [7] = "g";
    [8] = "h";
}

function Rank(Text)
    local Position = Text - 1
    return New "TextLabel" {
        BackgroundTransparency = 1;
        Font = Enum.Font.SourceSansBold;
        Size = UDim2.new(1,0,0.125,0);
        Position = UDim2.new(0,0,0.125 * Position,0);
        Text = Computed(function()
            if Module.BoardFlipped:get() == true then
                return tostring(Text)
            end
            return tostring(InvertRank[Text])
        end);
        TextColor3 = Color3.fromRGB(166,166,166);
        TextSize = 26;
        TextWrapped = false;
    }
end

function File(Pos)
    local Position = Pos - 1
    local Text = FileNumToTxt[Pos]
    return New "TextLabel" {
        BackgroundTransparency = 1;
        Font = Enum.Font.SourceSansBold;
        Size = UDim2.new(0.125,0,1,0);
        Position = UDim2.new(0.125 * Position,0,0,0);
        Text = Computed(function()
            if Module.BoardFlipped:get() == true then
                return InvertFile[Text]
            end
            return Text
        end);
        TextColor3 = Color3.fromRGB(166,166,166);
        TextSize = 26;
        TextWrapped = false;
    }
end

function Module.Ui()
    return {
        New "Frame" {
            AnchorPoint = Vector2.new(1,0);
            BackgroundTransparency = 1;
            Position = UDim2.new(0,-5,0,0);
            Size = UDim2.new(0,12,1,0);

            [Children] = {
                Rank(1);
                Rank(2);
                Rank(3);
                Rank(4);
                Rank(5);
                Rank(6);
                Rank(7);
                Rank(8);
            }
        };
        New "Frame" {
            BackgroundTransparency = 1;
            Position = UDim2.new(0,0,1,7);
            Size = UDim2.new(1,0,0,12);

            [Children] = {
                File(1);
                File(2);
                File(3);
                File(4);
                File(5);
                File(6);
                File(7);
                File(8);
            }
        }
    }
end

return Module
