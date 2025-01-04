-- Stonetr03 - GamesKit - Yahtzee Scorecard Sync Style

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Tween = Fusion.Tween
local Spring = Fusion.Spring
local Children = Fusion.Children
local Computed = Fusion.Computed

local NotoSans = Font.new("rbxassetid://12187370747");

local Module = {
    View = Value();
    Active = Value(0);
};

local scorecardText = {
    [1] = "Rolls";
    [2] = "Ones";
    [3] = "Twos";
    [4] = "Threes";
    [5] = "Fours";
    [6] = "Fives";
    [7] = "Sixes";
    [8] = "break";
    [9] = "Sum";
    [10] = "Bonus";
    [11] = "break";
    [12] = "Three of a kind";
    [13] = "Four of a kind";
    [14] = "Full house";
    [15] = "Small straight";
    [16] = "Large straight";
    [17] = "Yahtzee";
    [18] = "Chance";
    [19] = "Total Score";
}
local scorecardIndex = {
    [1] = 0;
    [2] = 1;
    [3] = 2;
    [4] = 3;
    [5] = 4;
    [6] = 5;
    [7] = 6;
    [8] = 0;
    [9] = -1;
    [10] = -2;
    [11] = 0;
    [12] = 7;
    [13] = 8;
    [14] = 9;
    [15] = 10;
    [16] = 11;
    [17] = 12;
    [18] = 13;
    [19] = -3;
}

function titleUi(i,o,bg,img,t)
    return i, New "Frame" {
        Size = UDim2.new(1,0,0,35);
        BackgroundTransparency = 1;
        [Children] = {
            New "Frame" {
                AnchorPoint = Vector2.new(0,1);
                BackgroundColor3 = Color3.fromRGB(36,36,36);
                Position = UDim2.new(0,0,1,0);
                Size = t;
                ZIndex = 2;
            };
            New "Frame" {
                BackgroundColor3 = bg or Color3.fromRGB(230,230,230);
                BorderMode = Enum.BorderMode.Middle;
                BorderSizePixel = 2;
                Size = UDim2.new(1,0,1,0);
                LayoutOrder = i;
                [Children] = {
                    New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal;
                        HorizontalAlignment = Enum.HorizontalAlignment.Center;
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        VerticalAlignment = Enum.VerticalAlignment.Center;
                        HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    };
                    New "ImageLabel" {
                        BackgroundColor3 = Color3.fromRGB(200,200,200);
                        Image = img;
                        Size = UDim2.new(0.9,0,0.9,0);
                        SizeConstraint = Enum.SizeConstraint.RelativeYY;
                        [Children] = {
                            New "UICorner" {CornerRadius = UDim.new(1,0)};
                            New "UIAspectRatioConstraint" {}
                        };
                    };
                    New "TextLabel" {
                        LayoutOrder = 1;
                        BackgroundTransparency = 1;
                        FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold);
                        Size = UDim2.new(0,0,1,0);
                        Text = o;
                        TextColor3 = Color3.new(0,0,0);
                        TextScaled = true;
                    }
                }
            };
        }
    }
end

function breakUi(i)
    return i, New "Frame" {
        BackgroundColor3 = Color3.new(0,0,0);
        Size = UDim2.new(1,0,0,2);
        LayoutOrder = i;
    };
end

function textBox(i: number, o: string, bg: Color3)
    return i, New "TextLabel" {
        BackgroundColor3 = bg or Color3.fromRGB(230,230,230);
        BorderMode = Enum.BorderMode.Middle;
        BorderSizePixel = 2;
        FontFace = NotoSans;
        Size = UDim2.new(1,0,0,30);
        Text = o;
        TextColor3 = Color3.new(0,0,0);
        TextScaled = true;
        LayoutOrder = i;
    }
end

-- Used for adding total scores
function convertTable(tab: table): table
    local t = table.clone(tab);
    for i,o in pairs(t) do
        if o == -1 then
            t[i] = 0;
        end
    end
    return t;
end

function update(data: table)
    local sp = data.spectate:get();
    if sp then
        Module.View:set(sp);
    end
end

function Module.Ui(data: table): {GuiObject}
    local v = Value(false);
    local t = Tween(Computed(function()
        return v:get() and UDim2.new(1,0,0,3) or UDim2.new(0,0,0,3);
    end),Computed(function()
        return v:get() and TweenInfo.new(7,Enum.EasingStyle.Linear) or TweenInfo.new(0.001);
    end))
    local disconnect = Fusion.Observer(data.spectate):onChange(function()
        update(data)
    end);
    local co = coroutine.create(function()
        while true do
            -- 0
            v:set(false);
            Module.Active:set(0);
            task.wait(0.01);
            v:set(true);
            task.wait(7.01);
            -- 1
            v:set(false);
            Module.Active:set(1);
            task.wait(0.01);
            v:set(true);
            task.wait(7.01);
            -- 2
            if Module.View:get() ~= nil then
                v:set(false);
                Module.Active:set(2);
                task.wait(0.01);
                v:set(true);
                task.wait(7.01);
            end
        end
    end);
    coroutine.resume(co);
    update(data);
    return {
        -- View 2;
        New "Frame" {
            Size = UDim2.new(1,0,1,0);
            Position = Spring(Computed(function()
                return Module.Active:get() == 2 and UDim2.new(0,0,0,0) or UDim2.new(1,0,0,0);
            end),6,1);
            ZIndex = Computed(function()
                return Module.Active:get() == 2 and 1 or 0;
            end);
            BackgroundTransparency = 1;
            [Fusion.Cleanup] = {disconnect,function()
                coroutine.close(co);
            end};
            [Children] = {
                New "UIListLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    VerticalFlex = Enum.UIFlexAlignment.Fill;
                };
                Fusion.ForPairs(scorecardText,function(i,o)
                    if i == 1 then
                        return titleUi(i,Computed(function()
                            -- Text
                            local p = Module.View:get();
                            if p then
                                return p.Name;
                            end
                            return "";
                        end),Computed(function()
                            -- BG color
                            local p = Module.View:get();
                            if p then
                                if data.data:get().turn == p then
                                    return Color3.fromRGB(255,243,205);
                                end
                            end
                            return Color3.fromRGB(230,230,230);
                        end),Computed(function()
                            -- img
                            local p = Module.View:get();
                            if p then
                                local img = game.Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48);
                                if img then
                                    return img;
                                end
                            end
                            return "";
                        end),t);
                    elseif o == "break" then
                        return breakUi(i);
                    end
                    return textBox(i,Computed(function()
                        local d = data.data:get();
                        local p = Module.View:get();
                        if p then
                            if d.players and d.players[p.UserId] and d.players[p.UserId].score then
                                local dp = convertTable(d.players[p.UserId].score);
                                if scorecardIndex[i] == -1 then
                                    return dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6];
                                elseif scorecardIndex[i] == -2 then
                                    return dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6] >= 63 and 35 or 0;
                                elseif scorecardIndex[i] == -3 then
                                    return dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6] + dp[7] + dp[8] + dp[9] + dp[10] + dp[11] + dp[12] + dp[13] + (dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6] >= 63 and 35 or 0);
                                elseif scorecardIndex[i] == 0 then
                                    return "";
                                else
                                    if d.players[p.UserId].score[ scorecardIndex[i] ] ~= -1 then
                                        return dp[ scorecardIndex[i] ];
                                    end
                                end
                            end
                        end
                        return "";
                    end),Computed(function()
                        -- Background Color
                        local d = data.data:get();
                        local p = Module.View:get();
                        if p then
                            if d.turn == p then
                                return Color3.fromRGB(255,243,205)
                            end
                        end
                        return Color3.fromRGB(230,230,230);
                    end));
                end,Fusion.cleanup)
            }
        };
        -- View 0;
        New "ScrollingFrame" {
            Size = UDim2.new(1,0,1,0);
            Position = Spring(Computed(function()
                return Module.Active:get() == 0 and UDim2.new(0,0,0,0) or UDim2.new(1,0,0,0);
            end),6,1);
            ZIndex = Computed(function()
                return Module.Active:get() == 0 and 1 or 0;
            end);
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = Color3.fromRGB(230,230,230);
            BottomImage = "";
            CanvasSize = UDim2.new(0,0,0,0);
            ScrollBarImageColor3 = Color3.new(0,0,0);
            ScrollBarThickness = 6;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            TopImage = "";
            [Children] = {
                New "UIListLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder;
                };
                New "TextLabel" {
                    BackgroundColor3 = Color3.fromRGB(230,230,230);
                    BorderMode = Enum.BorderMode.Middle;
                    BorderSizePixel = 2;
                    FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold);
                    Size = UDim2.new(1,0,35.0526 / 520,0);
                    Text = "Totals";
                    TextColor3 = Color3.new(0,0,0);
                    TextScaled = true;
                    LayoutOrder = -10000;
                    [Children] = New "Frame" {
                        AnchorPoint = Vector2.new(0,1);
                        BackgroundColor3 = Color3.fromRGB(36,36,36);
                        Position = UDim2.new(0,0,1,0);
                        Size = t;
                    }
                };
                Fusion.ForPairs(Computed(function()
                    local d = data.data:get()
                    return d.players or {};
                end),function(i,o)
                    data.data:get() -- registers with update
                    local dp = convertTable(o.score);
                    local tot = dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6] + dp[7] + dp[8] + dp[9] + dp[10] + dp[11] + dp[12] + dp[13] + (dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6] >= 63 and 35 or 0)
                    local p = game.Players:GetPlayerByUserId(i)
                    local img = ""
                    if p then
                        img = game.Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48);
                    end
                    return i, New "Frame" {
                        BackgroundColor3 = Color3.fromRGB(230,230,230);
                        BorderMode = Enum.BorderMode.Middle;
                        BorderSizePixel = 2;
                        Size = UDim2.new(1,0,30.0526 / 520,0);
                        LayoutOrder = -tot;
                        [Children] = {
                            New "UIListLayout" {
                                FillDirection = Enum.FillDirection.Horizontal;
                                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                VerticalAlignment = Enum.VerticalAlignment.Center;
                                HorizontalFlex = Enum.UIFlexAlignment.Fill;
                            };
                            New "ImageLabel" {
                                BackgroundColor3 = Color3.fromRGB(200,200,200);
                                Image = img;
                                Size = UDim2.new(0.9,0,0.9,0);
                                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                                [Children] = {
                                    New "UICorner" {CornerRadius = UDim.new(1,0)};
                                    New "UIAspectRatioConstraint" {}
                                };
                            };
                            New "TextLabel" {
                                LayoutOrder = 1;
                                BackgroundTransparency = 1;
                                FontFace = NotoSans;
                                Size = UDim2.new(0,0,1,0);
                                Text = tot;
                                TextColor3 = Color3.new(0,0,0);
                                TextScaled = true;
                            }
                        }
                    }
                end,Fusion.cleanup)
            }
        };
        -- View 1;
        New "ScrollingFrame" {
            Size = UDim2.new(1,0,1,0);
            Position = Spring(Computed(function()
                return Module.Active:get() == 1 and UDim2.new(0,0,0,0) or UDim2.new(1,0,0,0);
            end),6,1);
            ZIndex = Computed(function()
                return Module.Active:get() == 1 and 1 or 0;
            end);
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            BackgroundColor3 = Color3.fromRGB(230,230,230);
            BottomImage = "";
            CanvasSize = UDim2.new(0,0,0,0);
            ScrollBarImageColor3 = Color3.new(0,0,0);
            ScrollBarThickness = 6;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            TopImage = "";
            [Children] = {
                New "UIListLayout" {
                    SortOrder = Enum.SortOrder.Name;
                };
                New "TextLabel" {
                    BackgroundColor3 = Color3.fromRGB(230,230,230);
                    BorderMode = Enum.BorderMode.Middle;
                    BorderSizePixel = 2;
                    FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold);
                    Size = UDim2.new(1,0,35.0526 / 520,0);
                    Text = "Round";
                    TextColor3 = Color3.new(0,0,0);
                    TextScaled = true;
                    Name = "-Title";
                    [Children] = New "Frame" {
                        AnchorPoint = Vector2.new(0,1);
                        BackgroundColor3 = Color3.fromRGB(36,36,36);
                        Position = UDim2.new(0,0,1,0);
                        Size = t;
                    }
                };
                Fusion.ForPairs(Computed(function()
                    local d = data.data:get()
                    return d.players or {};
                end),function(i,o)
                    data.data:get() -- registers with update
                    local p = game.Players:GetPlayerByUserId(i)
                    local img = ""
                    local name = "";
                    local c = 0;
                    for _,j in pairs(o.score) do
                        if j ~= -1 then
                            c+=1;
                        end
                    end
                    if p then
                        img = game.Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48);
                        name = p.Name;
                    end
                    return i, New "Frame" {
                        BackgroundColor3 = Color3.fromRGB(230,230,230);
                        BorderMode = Enum.BorderMode.Middle;
                        BorderSizePixel = 2;
                        Size = UDim2.new(1,0,30.0526 / 520,0);
                        Name = name;
                        [Children] = {
                            New "UIListLayout" {
                                FillDirection = Enum.FillDirection.Horizontal;
                                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                VerticalAlignment = Enum.VerticalAlignment.Center;
                                HorizontalFlex = Enum.UIFlexAlignment.Fill;
                            };
                            New "ImageLabel" {
                                BackgroundColor3 = Color3.fromRGB(200,200,200);
                                Image = img;
                                Size = UDim2.new(0.9,0,0.9,0);
                                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                                [Children] = {
                                    New "UICorner" {CornerRadius = UDim.new(1,0)};
                                    New "UIAspectRatioConstraint" {}
                                };
                            };
                            New "TextLabel" {
                                LayoutOrder = 1;
                                BackgroundTransparency = 1;
                                FontFace = NotoSans;
                                Size = UDim2.new(0,0,1,0);
                                Text = c;
                                TextColor3 = c == 13 and Color3.new(0.35,0.35,0.35) or Color3.new(0,0,0);
                                TextScaled = true;
                            }
                        }
                    }
                end,Fusion.cleanup)
            }
        }
    }
end

return Module
