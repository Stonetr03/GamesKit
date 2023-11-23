-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Signal"))

local New = Fusion.New
local Event = Fusion.OnEvent

local Module = {
    BoardSize = UDim2.new(0.7,0,0.7,0);
    Fullscreen = Signal.new()
}

function Module.Ui()
    return New "ImageButton" {
        Size = UDim2.new(0,20,0,20);
        Position = UDim2.new(1,5,0,25);
        BackgroundColor3 = Color3.new(0,0,0);
        BackgroundTransparency = 0.5;
        Image = "rbxassetid://11295287825";
        [Event "MouseButton1Up"] = function()
            Module.Fullscreen:Fire()
        end;
        ZIndex = 15;
    }
end

return Module
