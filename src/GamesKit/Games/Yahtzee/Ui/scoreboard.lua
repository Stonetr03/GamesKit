-- Stonetr03 - GamesKit - Yahtzee Scoreboard

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local NotoSans = Font.new("rbxassetid://12187370747");

local Module = {
    Visible = Value(false);
    Score = Value({});
    Close = nil :: () -> ();
    ToShow = Value({});
    ToShowName = Value("");
}

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

function getIndex(s: {[string]: {score: number, card: {[number]: number}}}, ind: string): number
    if s[ind] then
        local i = 1;
        for _,n in pairs(s) do
            if n.score > s[ind].score then
                i+=1;
            end
        end
        return i;
    end
    return 51;
end

function titleUi(i,o,img)
    return i, New "Frame" {
        BackgroundColor3 = Color3.fromRGB(230,230,230);
        BorderMode = Enum.BorderMode.Middle;
        BorderSizePixel = 2;
        Size = UDim2.new(1,0,0,35);
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
end

function breakUi(i)
    return i, New "Frame" {
        BackgroundColor3 = Color3.new(0,0,0);
        Size = UDim2.new(1,0,0,2);
        LayoutOrder = i;
    };
end

function textBox(i: number, o: string)
    return i, New "TextLabel" {
        BackgroundColor3 = Color3.fromRGB(230,230,230);
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


function Module.Ui(): GuiObject
    return New "Frame" {
        Visible = Module.Visible;
        Size = UDim2.new(1,0,1,0);
        BackgroundTransparency = 1;
        [Children] = {
            -- Title
            New "TextLabel" {
                BackgroundTransparency = 1;
                FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold);
                Size = UDim2.new(1,0,0.1,0);
                Text = "Leaderboard";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
            };
            -- Close
            New "ImageButton" {
                AnchorPoint = Vector2.new(1,0);
                BackgroundColor3 = Color3.fromRGB(0,85,0);
                Image = "rbxassetid://11293981586";
                Position = UDim2.new(1,-10,0,10);
                Size = UDim2.new(0.06,0,0.06,0);
                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                ZIndex = 10;
                [Event "MouseButton1Up"] = function()
                    if Module.ToShowName:get() == "" then
                        Module.Close();
                    else
                        Module.ToShowName:set("");
                    end
                end;
                [Children] = {
                    New "UISizeConstraint" {
                        MinSize = Vector2.new(35,35);
                    };
                }
            };
            -- Scoreboard
            New "ScrollingFrame" {
                AnchorPoint = Vector2.new(0.5,0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                CanvasSize = UDim2.new(0,0,0,0);
                Position = UDim2.new(0.5,0,0.11,0);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                Size = UDim2.new(0.8,0,0.87,0);
                VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
                ScrollBarThickness = 8;
                TopImage = "";
                BottomImage = "";
                [Children] = {
                    New "UIListLayout" {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        Padding = UDim.new(0,4);
                    };
                    New "UISizeConstraint" {
                        MinSize = Vector2.new(280,0);
                    };
                    Fusion.ForPairs(Module.Score,function(i: number,o: {score: number, card: {[number]: number}})
                        local plr = game.Players:GetPlayerByUserId(i);
                        local name = ""
                        local img = game.Players:GetUserThumbnailAsync(i,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size180x180);
                        local Offset = Value(Vector2.new());
                        if plr then
                            name = plr.Name;
                        end
                        local ind = getIndex(Module.Score:get(),i);
                        return i, New "TextButton" {
                            BackgroundTransparency = 0.5;
                            BackgroundColor3 = (ind == 1 and Color3.fromRGB(255,202,9) or (ind == 2 and Color3.fromRGB(182,181,184)) or (ind == 3 and Color3.fromRGB(161,113,68)) or Color3.new(0,0,0));
                            LayoutOrder = ind;
                            Size = UDim2.new(1,0,0.08,0);
                            Text = "";
                            [Event "MouseButton1Up"] = function()
                                if Module.ToShowName:get() == name then
                                    Module.ToShowName:set("")
                                else
                                    Module.ToShowName:set(name);
                                    Module.ToShow:set(o.card)
                                end
                            end;
                            [Children] = {
                                New "UISizeConstraint" {
                                    MinSize = Vector2.new(0,35);
                                };
                                New "ImageLabel" {
                                    AnchorPoint = Vector2.new(0,0.5);
                                    BackgroundColor3 = Color3.fromRGB(82,82,82);
                                    Image = img;
                                    Position = UDim2.new(0,0,0.5,0);
                                    Size = UDim2.new(0.8,0,0.8,0);
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY;
                                    [Fusion.Out "AbsoluteSize"] = Offset;
                                    [Fusion.Cleanup] = Offset;
                                    [Children] = New "UICorner" {CornerRadius = UDim.new(1,0)};
                                };
                                -- Name
                                New "TextLabel" {
                                    AnchorPoint = Vector2.new(0,0.5);
                                    BackgroundTransparency = 1;
                                    FontFace = NotoSans;
                                    Position = Computed(function()
                                        local of = Offset:get()
                                        if typeof(of) ~= "Vector2" then of = Vector2.zero end
                                        return UDim2.new(0,of.X,0.5,0)
                                    end);
                                    Size = Computed(function()
                                        local of = Offset:get()
                                        if typeof(of) ~= "Vector2" then of = Vector2.zero end
                                        return UDim2.new(0.8,-of.X/2,0.6,0)
                                    end);
                                    Text = name;
                                    TextColor3 = Color3.new(1,1,1);
                                    TextScaled = true;
                                };
                                -- Score
                                New "TextLabel" {
                                    AnchorPoint = Vector2.new(0,0.5);
                                    BackgroundTransparency = 1;
                                    FontFace = NotoSans;
                                    Position = Computed(function()
                                        local of = Offset:get()
                                        if typeof(of) ~= "Vector2" then of = Vector2.zero end
                                        return UDim2.new(0.8,of.X/2,0.5,0)
                                    end);
                                    Size = Computed(function()
                                        local of = Offset:get()
                                        if typeof(of) ~= "Vector2" then of = Vector2.zero end
                                        return UDim2.new(0.2,-of.X/2,0.6,0)
                                    end);
                                    Text = o.score;
                                    TextColor3 = Color3.new(1,1,1);
                                    TextScaled = true;
                                };
                                ind < 4 and New "UICorner" {CornerRadius = UDim.new(0,10)} or nil;
                                New "UIPadding" {
                                    PaddingLeft = UDim.new(0,8);
                                }
                            }
                        }
                    end,Fusion.cleanup)
                }
            };
            -- Scorecard
            New "Frame" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundColor3 = Color3.new(1,1,1);
                Position = UDim2.new(0.5,0,0.5,0);
                Size = UDim2.new(0.8,-10,1,-8);
                Visible = Computed(function()
                    return Module.ToShowName:get() ~= "";
                end);
                [Children] = {
                    New "UISizeConstraint" {
                        MaxSize = Vector2.new(280,520);
                    };
                    New "UIListLayout" {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        FillDirection = Enum.FillDirection.Horizontal;
                        HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    };
                    -- Index
                    New "Frame" {
                        LayoutOrder = 1;
                        Size = UDim2.new(0.5,0,1,0);
                        [Children] = {
                            New "UISizeConstraint" {
                                MaxSize = Vector2.new(180,math.huge);
                            };
                            New "UIListLayout" {
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                VerticalFlex = Enum.UIFlexAlignment.Fill;
                            };
                            Fusion.ForPairs(scorecardText,function(i,o)
                                if i == 1 then
                                    return i, New "TextLabel" {
                                        BackgroundColor3 = Color3.fromRGB(230,230,230);
                                        BorderMode = Enum.BorderMode.Middle;
                                        BorderSizePixel = 2;
                                        FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold);
                                        Size = UDim2.new(1,0,0,35);
                                        Text = o;
                                        TextColor3 = Color3.new(0,0,0);
                                        TextScaled = true;
                                        LayoutOrder = i;
                                    };
                                elseif o == "break" then
                                    return breakUi(i);
                                end
                                return textBox(i,o);
                            end,Fusion.cleanup);
                        };
                    };
                    -- Player
                    New "Frame" {
                        LayoutOrder = 2;
                        Size = UDim2.new(0.5,0,1,0);
                        ZIndex = 2;
                        [Children] = {
                            New "UISizeConstraint" {
                                MaxSize = Vector2.new(100,math.huge);
                            };
                            New "UIListLayout" {
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                VerticalFlex = Enum.UIFlexAlignment.Fill;
                            };
                            Fusion.ForPairs(scorecardText,function(i,o)
                                if i == 1 then
                                    return titleUi(i,Module.ToShowName,Computed(function()
                                        -- img
                                        local n = Module.ToShowName:get();
                                        local p = game.Players:FindFirstChild(n);
                                        if p then
                                            local img = game.Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48);
                                            if img then
                                                return img;
                                            end
                                        end
                                        return "";
                                    end));
                                elseif o == "break" then
                                    return breakUi(i);
                                end
                                return textBox(i,Computed(function()
                                    local sc = Module.ToShow:get()
                                    if #sc == 13 then
                                        local scI = scorecardIndex[i];
                                        if scI > 0 then
                                            return sc[scI];
                                        elseif scI == -1 then
                                            return sc[1] + sc[2] + sc[3] + sc[4] + sc[5] + sc[6];
                                        elseif scI == -2 then
                                            return sc[1] + sc[2] + sc[3] + sc[4] + sc[5] + sc[6] >= 63 and 35 or 0;
                                        elseif scI == -3 then
                                            return sc[1] + sc[2] + sc[3] + sc[4] + sc[5] + sc[6] + sc[7] + sc[8] + sc[9] + sc[10] + sc[11] + sc[12] + sc[13] + (sc[1] + sc[2] + sc[3] + sc[4] + sc[5] + sc[6] >= 63 and 35 or 0);
                                        end
                                    end
                                    return "";
                                end));
                            end,Fusion.cleanup);
                        };
                    };

                };
            };
        }
    }
end

return Module
