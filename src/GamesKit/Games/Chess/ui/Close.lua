-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))

local New = Fusion.New
local Computed = Fusion.Computed
local Event = Fusion.OnEvent

local Module = {
    ActiveGame = nil;
    ActiveBoard = nil;
    Exit = nil;
}

function Module.Ui()
    return New "ImageButton" {
        AnchorPoint = Vector2.new(1,0);
        BackgroundTransparency = 1;
        Image = "rbxassetid://11293981586";
        Position = UDim2.new(1,-10,0,10);
        Size = UDim2.new(0.05,0,0.05,0);
        SizeConstraint = Enum.SizeConstraint.RelativeYY;
        ZIndex = 1000;
        Visible = Computed(function()
            if Module.ActiveGame:get() ~= "" then
                local board = Module.ActiveBoard:get()
                if board.White == game.Players.LocalPlayer or board.Black == game.Players.LocalPlayer then
                    if board.Status ~= "" then
                        return true
                    end
                else
                    return true
                end
                
            end
            return false
        end);
        [Event "MouseButton1Up"] = function()
            if typeof(Module.Exit) == "function" then
                Module.Exit()
            end
        end;
    }
end
-- Annotation Ui
function Module.AUi()
    return New "ImageButton" {
        AnchorPoint = Vector2.new(0,1);
        BackgroundColor3 = Color3.fromRGB(46,46,46);
        Image = "rbxassetid://11293981586";
        ImageColor3 = Color3.fromRGB(197,197,197);
        Position = UDim2.new(0,0,1,0);
        ScaleType = Enum.ScaleType.Fit;
        Size = UDim2.new(0.12,0,0.08,0);
        Visible = Computed(function()
            if Module.ActiveGame:get() ~= "" then
                local board = Module.ActiveBoard:get()
                if board.White == game.Players.LocalPlayer or board.Black == game.Players.LocalPlayer then
                    if board.Status ~= "" then
                        return true
                    end
                else
                    return true
                end
            end
            return false
        end);
        [Event "MouseButton1Up"] = function()
            if typeof(Module.Exit) == "function" then
                Module.Exit()
            end
        end;
        ZIndex = 6;
    };
end

return Module

