-- Stonetr03 - GamesKit - Tic-Tac-Toe

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Board = Value(Api:Invoke("GamesKit-Get-Tic-Tac-Toe",script:WaitForChild("hash").Value))

local lines = { -- Position,Size
    {UDim2.new(0.5,0,0.333,0),UDim2.new(1,0,0,3)};
    {UDim2.new(0.5,0,0.666,0),UDim2.new(1,0,0,3)};
    {UDim2.new(0.333,0,0.5,0),UDim2.new(0,3,1,0)};
    {UDim2.new(0.666,0,0.5,0),UDim2.new(0,3,1,0)};
}
local sqrs = {
    [1] = UDim2.new(0,0,0,0);
    [2] = UDim2.new(0.333,0,0,0);
    [3] = UDim2.new(0.667,0,0,0);
    [4] = UDim2.new(0,0,0.333,0);
    [5] = UDim2.new(0.333,0,0.333,0);
    [6] = UDim2.new(0.667,0,0.333,0);
    [7] = UDim2.new(0,0,0.667,0);
    [8] = UDim2.new(0.333,0,0.667,0);
    [9] = UDim2.new(0.667,0,0.667,0);
}

local gameOver = {
    [1] = {1,2,3};
    [2] = {4,5,6};
    [3] = {7,8,9};
    [4] = {1,4,7};
    [5] = {2,5,8};
    [6] = {3,6,9};
    [7] = {1,5,9};
    [8] = {3,5,7};
    [9] = {};
    [10] = {};
}

local Window = Api:CreateWindow({
    Size = Vector2.new(250,250);
    Title = "Tic-Tac-Toe";
    Position = UDim2.new(0.5,-250/2,0.5,-250/2);
    Resizeable = true;
    ResizeableMinimum = Vector2.new(100,100);
    Buttons = {
        [1] = {
            Text = "?";
            Callback = function()
                
            end
        };
    };
},New "Frame" {
    Size = UDim2.new(1,0,1,0);
    BackgroundTransparency = 1;
    [Children] = {
        -- Topbar
        New "Frame" {
            BackgroundTransparency = 1;
            Size = UDim2.new(1,0,0.15,0);
            [Children] = {
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    Font = Enum.Font.SourceSans;
                    RichText = true;
                    Size = UDim2.new(0.5,0,1,0);
                    Text = Computed(function()
                        return Board:get().p1.Name .. " <b>(X)</b>"
                    end);
                    TextColor3 = Api.Style.TextColor;
                    TextScaled = true;
                    [Children] = {
                        New "UIPadding" {
                            PaddingBottom = UDim.new(0,5);
                            PaddingTop = UDim.new(0,5);
                            PaddingLeft = UDim.new(0,4);
                            PaddingRight = UDim.new(0,4);
                        };
                        New "Frame" {
                            BackgroundColor3 = Api.Style.TextColor;
                            Position = UDim2.new(0,0,1,0);
                            Size = UDim2.new(1,0,0,3);
                            Visible = Computed(function()
                                if Board:get().turn == "X" then
                                    return true
                                end
                                return false
                            end);
                            [Children] = New "UIGradient" {
                                Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.15,0.5),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(0.85,0.5),NumberSequenceKeypoint.new(1,1)})
                            }
                        }
                    }
                };
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    Font = Enum.Font.SourceSans;
                    RichText = true;
                    Size = UDim2.new(0.5,0,1,0);
                    Text = Computed(function()
                        return Board:get().p1.Name .. " <b>(O)</b>"
                    end);
                    TextColor3 = Api.Style.TextColor;
                    TextScaled = true;
                    Position = UDim2.new(0.5,0,0,0);
                    [Children] = {
                        New "UIPadding" {
                            PaddingBottom = UDim.new(0,5);
                            PaddingTop = UDim.new(0,5);
                            PaddingLeft = UDim.new(0,4);
                            PaddingRight = UDim.new(0,4);
                        };
                        New "Frame" {
                            BackgroundColor3 = Api.Style.TextColor;
                            Position = UDim2.new(0,0,1,0);
                            Size = UDim2.new(1,0,0,3);
                            Visible = Computed(function()
                                if Board:get().turn == "O" then
                                    return true
                                end
                                return false
                            end);
                            [Children] = New "UIGradient" {
                                Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.15,0.5),NumberSequenceKeypoint.new(.5,0),NumberSequenceKeypoint.new(0.85,0.5),NumberSequenceKeypoint.new(1,1)})
                            }
                        }
                    }
                }
            }
        };
        -- Board
        New "Frame" {
            AnchorPoint = Vector2.new(0.5,0.5);
            BackgroundTransparency = 1;
            Position = UDim2.new(0.5,0,0.575,0);
            Size = UDim2.new(1,-10,0.8,0);
            [Children] = {
                New "UIAspectRatioConstraint" {
                    DominantAxis = Enum.DominantAxis.Height
                };
                Fusion.ForValues(lines,function(o)
                    return New "Frame" {
                        AnchorPoint = Vector2.new(0.5,0.5);
                        BackgroundColor3 = Api.Style.TextColor;
                        Position = o[1];
                        Size = o[2];
                    }
                end,Fusion.cleanup);
                Fusion.ForPairs(sqrs,function(i,o)
                    return i, New "ImageButton" {
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://15187935675";
                        ImageRectOffset = Computed(function()
                            local b = Board:get()
                            if b and b.board then
                                local off = b.board[i] - 1;
                                return Vector2.new(off * 200,0);
                            end
                            return Vector2.new(-200,0)
                        end);
                        ImageRectSize = Vector2.new(200,200);
                        Position = o;
                        ScaleType = Enum.ScaleType.Fit;
                        Size = UDim2.new(0.333,-1,0.333,-1);
                        ImageTransparency = Computed(function()
                            local b = Board:get()
                            local status = b.status
                            if status ~= "" then
                                local endType = tonumber(string.sub(status,2));
                                if gameOver[endType] then
                                    if endType == 10 then
                                        if string.sub(status,1,1) == "X" then
                                            -- X win
                                            if b.board[i] == 1 then
                                                return 0;
                                            else
                                                return 0.5
                                            end
                                        elseif string.sub(status,1,1) == "O" then
                                            -- O win
                                            if b.board[i] == 2 then
                                                return 0;
                                            else
                                                return 0.5
                                            end
                                        else
                                            return 0.5
                                        end
                                    end
                                    if table.find(gameOver[endType],i) then
                                        return 0;
                                    else
                                        return 0.5;
                                    end
                                else
                                    return 0.5;
                                end
                            end
                            return 0
                        end);
                        [Event "MouseButton1Up"] = function()
                            Api:Fire("GamesKit-Tic-Tac-Toe",script.hash.Value,i)
                        end
                    }
                end,Fusion.cleanup);
            }
        }
    }
})

Window.OnClose:Connect(function()
    if Board:get().status == "" then
        Api:Fire("GamesKit-Quit-Tic-Tac-Toe",script.hash.Value)
    end
    Window.unmount()
    script:Destroy()
end)

Api:OnEvent("GamesKit-Tic-Tac-Toe",function(h,b)
    if h == script.hash.Value then
        Board:set(b)
    end
end)
