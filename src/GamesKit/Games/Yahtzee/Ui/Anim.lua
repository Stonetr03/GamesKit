-- Stonetr03 - GamesKit - Animation

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Tween = Fusion.Tween
local Children = Fusion.Children

local Module = {}

local WAIT_TIME = 0.5;

local Position = Value(UDim2.new(1,0,0,0));
local Visible = Value(false);
local PosTween = Tween(Position,TweenInfo.new(WAIT_TIME,Enum.EasingStyle.Linear));

function Module.Ui(): GuiObject
    return New "Frame" {
        Visible = Visible;
        BackgroundColor3 = Color3.fromRGB(0,170,0);
        Position = PosTween;
        Size = UDim2.new(1,0,1,0);
        [Children] = New "Frame" {
            AnchorPoint = Vector2.new(0.5,0.5);
            BackgroundColor3 = Color3.fromRGB(0,85,0);
            Position = UDim2.new(0.5,0,0.5,0);
            Size = UDim2.new(0.5,0,1,0);
        };
    }
end

local debounce = false
function Module.Play()
    if debounce then return 0 end;
    debounce = true;
    Visible:set(true);
    Position:set(UDim2.new(-1,0,0,0));
    task.delay(WAIT_TIME,function()
        Visible:set(false);
        Position:set(UDim2.new(1,0,0,0));
        debounce = false;
    end)
    return WAIT_TIME;
end

return Module;
