-- Stonetr03 - GamesKit - Yahtzee Scorecard Sync Style

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
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

function titleUi(i,o,bg,img)
    return i, New "Frame" {
        BackgroundColor3 = bg or Color3.fromRGB(230,230,230);
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
        Module.Active:set(1);
    else
        Module.Active:set(0);
    end
end

function Module.Ui(data: table): {GuiObject}
    local disconnect = Fusion.Observer(data.spectate):onChange(function()
        update(data)
    end);
    update(data);
    return {
        -- View 1;
        New "Frame" {
            Size = UDim2.new(1,0,1,0);
            Position = Spring(Computed(function()
                return Module.Active:get() == 1 and UDim2.new(0,0,0,0) or UDim2.new(1,0,0,0);
            end),6,1);
            BackgroundTransparency = 1;
            [Fusion.Cleanup] = disconnect;
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
                        end))
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
        }
    }
end

return Module
