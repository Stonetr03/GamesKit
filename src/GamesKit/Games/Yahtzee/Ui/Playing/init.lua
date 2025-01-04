-- Stonetr03 - GamesKit - Yahtzee Playing Ui

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local DiceUi = require(script.Parent:WaitForChild("dice"));
local score = require(script.Parent:WaitForChild("score"));

local turnCardUi = require(script:WaitForChild("turn"));
local syncCardUi = require(script:WaitForChild("sync"));
local flowCardUi = require(script:WaitForChild("flow"));

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local NotoSans = Font.new("rbxassetid://12187370747");

local Module = {
    Visible = Value(false);
    Roll = nil :: () -> ();
    Score = nil :: (i: number) -> ();
};

local SpecName = Value("");
local SpecImg = Value("");

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

function getDblScore(i: number, dice: {number}): number
    if i < 7 then
        return i * 5;
    elseif i == 9 then
        return 25;
    elseif i == 10 then
        return 30;
    elseif i == 11 then
        return 40;
    else
        return score(i,dice,0);
    end
end

function titleUi(i,o,bg)
    return i, New "TextLabel" {
        BackgroundColor3 = bg or Color3.fromRGB(230,230,230);
        BorderMode = Enum.BorderMode.Middle;
        BorderSizePixel = 2;
        FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold);
        Size = UDim2.new(1,0,0,35);
        Text = o;
        TextColor3 = Color3.new(0,0,0);
        TextScaled = true;
        LayoutOrder = i;
    };
end

function breakUi(i)
    return i, New "Frame" {
        BackgroundColor3 = Color3.new(0,0,0);
        Size = UDim2.new(1,0,0,2);
        LayoutOrder = i;
    };
end

function convertTable(tab: table): table
    local t = table.clone(tab);
    for i,o in pairs(t) do
        if o == -1 then
            t[i] = 0;
        end
    end
    return t;
end

function textBox(i: number, o: string, f: ()->()?, bg: Color3?, tc: Color3?)
    local cn = typeof(f) == "function" and "TextButton" or "TextLabel";
    return i, New(cn) {
        BackgroundColor3 = bg or Color3.fromRGB(230,230,230);
        BorderMode = Enum.BorderMode.Middle;
        BorderSizePixel = 2;
        FontFace = NotoSans;
        Size = UDim2.new(1,0,0,30);
        Text = o;
        TextColor3 = tc or Color3.new(0,0,0);
        TextScaled = true;
        LayoutOrder = i;
        [Event "MouseButton1Up"] = typeof(f) == "function" and f or nil;
    }
end

function Module.Ui(data: table)
    local scSize = Value(Vector2.zero);
    local spSize = Value(Vector2.zero);
    local ob = Fusion.Observer(data.spectate):onChange(function()
        local sp = data.spectate:get();
        if typeof(sp) == "Instance" and sp:IsA("Player") then
            SpecName:set(sp.Name);
            local img = game.Players:GetUserThumbnailAsync(sp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48);
            SpecImg:set(img);
        end
    end)
    return New "Frame" {
        Size = UDim2.new(1,0,1,0);
        BackgroundTransparency = 1;
        Visible = Module.Visible;
        [Fusion.Cleanup] = {DiceUi.cleanup,ob};
        [Children] = {
            -- Scorecard
            New "Frame" {
                AnchorPoint = Vector2.new(1,0.5);
                BackgroundColor3 = Color3.new(1,1,1);
                Position = UDim2.new(1,-10,0.5,0);
                Size = UDim2.new(0.5,-10,1,-8);
                [Fusion.Out "AbsoluteSize"] = scSize;
                [Fusion.Cleanup] = scSize;
                [Children] = {
                    New "UISizeConstraint" {
                        MaxSize = Computed(function()
                            local d = data.data:get()
                            local max = 380;
                            if d.players then
                                local c = 0
                                for _,_ in pairs(d.players) do
                                    c+=1;
                                end
                                if c == 1 then
                                    max = 280;
                                end
                                local nc = true
                                for pId,_ in pairs(d.players) do
                                    if pId == game.Players.LocalPlayer.UserId then
                                        nc = false;
                                        break;
                                    end
                                end
                                if nc then
                                    max = 280;
                                end
                            end
                            return Vector2.new(max,520);
                        end);
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
                        BackgroundColor3 = Color3.new(.75,0,0);
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
                                    return titleUi(i,o);
                                elseif o == "break" then
                                    return breakUi(i);
                                end
                                return textBox(i,o);
                            end,Fusion.cleanup);
                        };
                    };
                    -- You
                    New "Frame" {
                        LayoutOrder = 2;
                        Size = UDim2.new(0.5,0,1,0);
                        BackgroundColor3 = Color3.new(0,0,0.75);
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
                                    return titleUi(i,"You",Computed(function()
                                        local t = data.isTurn:get();
                                        if typeof(t) ~= "boolean" then t = false end;
                                        return t and Color3.fromRGB(255,243,205) or Color3.fromRGB(230,230,230);
                                    end));
                                elseif o == "break" then
                                    return breakUi(i);
                                end
                                return textBox(i,Computed(function()
                                    local d = data.data:get();
                                    local t = data.isTurn:get();
                                    local dbl = data.pickDbl:get();
                                    if dbl ~= 0 then
                                        if ((dbl == 1 and scorecardIndex[i] <= 6) or (dbl == 2 and scorecardIndex[i] > 6)) and d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] == -1 then
                                            return getDblScore(scorecardIndex[i], {DiceUi.dice[1].number:get(),DiceUi.dice[2].number:get(),DiceUi.dice[3].number:get(),DiceUi.dice[4].number:get(),DiceUi.dice[5].number:get()});
                                        end
                                    end
                                    if d.players and d.players[game.Players.LocalPlayer.UserId] and d.players[game.Players.LocalPlayer.UserId].score then
                                        local dp = convertTable(d.players[game.Players.LocalPlayer.UserId].score);
                                        if scorecardIndex[i] == -1 then
                                            return dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6];
                                        elseif scorecardIndex[i] == -2 then
                                            return dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6] >= 63 and 35 or 0;
                                        elseif scorecardIndex[i] == -3 then
                                            return dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6] + dp[7] + dp[8] + dp[9] + dp[10] + dp[11] + dp[12] + dp[13] + (dp[1] + dp[2] + dp[3] + dp[4] + dp[5] + dp[6] >= 63 and 35 or 0);
                                        elseif scorecardIndex[i] == 0 then
                                            return "";
                                        else
                                            if t then
                                                if (d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] == -1 or
                                                    (scorecardIndex[i] == 12 and
                                                    d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] >= 50 and
                                                    d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] < score(scorecardIndex[i],{DiceUi.dice[1].number:get(),DiceUi.dice[2].number:get(),DiceUi.dice[3].number:get(),DiceUi.dice[4].number:get(),DiceUi.dice[5].number:get()},d.players[game.Players.LocalPlayer.UserId].score[ 12 ]))) and
                                                    data.roll:get() > 0
                                                then
                                                    return score(scorecardIndex[i],{DiceUi.dice[1].number:get(),DiceUi.dice[2].number:get(),DiceUi.dice[3].number:get(),DiceUi.dice[4].number:get(),DiceUi.dice[5].number:get()},d.players[game.Players.LocalPlayer.UserId].score[ 12 ])
                                                elseif d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] ~= -1 then
                                                    return d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ];
                                                end
                                            elseif d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] ~= -1 then
                                                return dp[ scorecardIndex[i] ];
                                            end
                                        end
                                    end
                                    return "";
                                end),function()
                                    local d = data.data:get();
                                    local t = data.isTurn:get();
                                    local dbl = data.pickDbl:get();
                                    if dbl ~= 0 then
                                        if ((dbl == 1 and scorecardIndex[i] <= 6) or (dbl == 2 and scorecardIndex[i] > 6)) and d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] == -1 then
                                            Module.Score(scorecardIndex[i]);
                                        end
                                    end
                                    if d.players and d.players[game.Players.LocalPlayer.UserId] and d.players[game.Players.LocalPlayer.UserId].score then
                                        if scorecardIndex[i] > 0 then
                                            if t then
                                                if (d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] == -1 or
                                                    (scorecardIndex[i] == 12 and
                                                    d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] >= 50 and
                                                    d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] < score(scorecardIndex[i],{DiceUi.dice[1].number:get(),DiceUi.dice[2].number:get(),DiceUi.dice[3].number:get(),DiceUi.dice[4].number:get(),DiceUi.dice[5].number:get()},d.players[game.Players.LocalPlayer.UserId].score[ 12 ]))) and
                                                    data.roll:get() > 0
                                                then
                                                    Module.Score(scorecardIndex[i]);
                                                end
                                            end
                                        end
                                    end
                                end,Computed(function()
                                    -- Background Color
                                    local t = data.isTurn:get();
                                    if typeof(t) ~= "boolean" then t = false end;
                                    return t and Color3.fromRGB(255,243,205) or Color3.fromRGB(230,230,230);
                                end),Computed(function()
                                    -- Text Color - Red 1,0,0 if can score
                                    local d = data.data:get();
                                    local t = data.isTurn:get();
                                    local dbl = data.pickDbl:get();
                                    if dbl ~= 0 then
                                        if ((dbl == 1 and scorecardIndex[i] <= 6) or (dbl == 2 and scorecardIndex[i] > 6)) and d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] == -1 then
                                            return Color3.new(1,0,0);
                                        end
                                        return Color3.new(0,0,0);
                                    end
                                    if d.players and d.players[game.Players.LocalPlayer.UserId] and d.players[game.Players.LocalPlayer.UserId].score then
                                        if scorecardIndex[i] > 0 then
                                            if t then
                                                if (d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] == -1 or (scorecardIndex[i] == 12 and d.players[game.Players.LocalPlayer.UserId].score[ scorecardIndex[i] ] > 0 and score(scorecardIndex[i],{DiceUi.dice[1].number:get(),DiceUi.dice[2].number:get(),DiceUi.dice[3].number:get(),DiceUi.dice[4].number:get(),DiceUi.dice[5].number:get()},d.players[game.Players.LocalPlayer.UserId].score[ 12 ]) > d.players[game.Players.LocalPlayer.UserId].score[ 12 ] )) and data.roll:get() > 0 then
                                                    return Color3.new(1,0,0)
                                                end
                                            end
                                        end
                                    end
                                    return Color3.new(0,0,0);
                                end));
                            end,Fusion.cleanup);
                        };
                    };
                    -- Other
                    New "Frame" {
                        LayoutOrder = 3;
                        Size = UDim2.new(0.5,0,1,0);
                        BackgroundColor3 = Color3.fromRGB(197, 197, 197);
                        ClipsDescendants = true;
                        Visible = Computed(function()
                            local s = scSize:get();
                            local d = data.data:get();
                            local sglOnly = false;
                            local plrOnly = false;
                            if d.players then
                                local c = 0;
                                local hlp = false
                                for pId,_ in pairs(d.players) do
                                    if pId == game.Players.LocalPlayer.UserId then
                                        hlp = true;
                                    end
                                    c+=1;
                                end
                                if c == 1 and hlp then
                                    plrOnly = true;
                                elseif c == 1 then
                                    sglOnly = true;
                                end
                            end
                            if typeof(s) ~= "Vector2" then s = Vector2.zero end
                            if sglOnly then
                                return true;
                            elseif plrOnly then
                                return false;
                            end
                            return s.X >= 250;
                        end);
                        [Children] = {
                            New "UISizeConstraint" {
                                MaxSize = Vector2.new(100,math.huge);
                            };
                            Computed(function()
                                if Module.Visible:get() then
                                    local sty = data.style:get();
                                    if sty == "turn" then
                                        return turnCardUi.Ui(data);
                                    elseif sty == "sync" then
                                        return syncCardUi.Ui(data);
                                    elseif sty == "flow" then
                                        return flowCardUi.Ui(data);
                                    end
                                end
                                return nil;
                            end,Fusion.cleanup);
                        };
                    };

                };
            };
            -- Playing Area
            New "Frame" {
                Size = Computed(function()
                    local sc = scSize:get()
                    if typeof(sc) ~= "Vector2" then sc = Vector2.zero end;
                    return UDim2.new(1,-20 - sc.X,1,-10);
                end);
                Position = UDim2.new(0,5,0,5);
                BackgroundTransparency = 1;
                [Children] = {
                    New "TextLabel" {
                        BackgroundTransparency = 1;
                        AnchorPoint = Vector2.new(0,1);
                        FontFace = NotoSans;
                        Position = UDim2.new(0,0,1,0);
                        Size = UDim2.new(1,0,0,20);
                        Text = Computed(function()
                            return data.clock:get() .. " — " .. data.roll:get() .. "/3"
                        end);
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                    };
                    New "TextButton" {
                        AnchorPoint = Vector2.new(0.5,1);
                        BackgroundColor3 = Color3.fromRGB(0,85,255);
                        BackgroundTransparency = Computed(function()
                            local t = data.isTurn:get();
                            if data.roll:get() == 3 then return 0.5 end;
                            return t and 0 or 0.5;
                        end);
                        TextTransparency = Computed(function()
                            local t = data.isTurn:get();
                            if data.roll:get() == 3 then return 0.5 end;
                            return t and 0 or 0.5;
                        end);
                        Visible = Computed(function()
                            return data.spectate:get() == nil;
                        end);
                        FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold);
                        Position = UDim2.new(0.5,0,1,-22);
                        Size = UDim2.new(0,130,0,50);
                        Text = "Roll";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            Module.Roll();
                        end;
                        [Children] = {
                            New "UICorner" {CornerRadius = UDim.new(0,12)};
                        }
                    };
                    -- Spectate
                    New "Frame" {
                        Visible = Computed(function()
                            return data.spectate:get() ~= nil
                        end);
                        BackgroundTransparency = 1;
                        Size = UDim2.new(1,0,0,50);
                        [Fusion.Cleanup] = spSize;
                        [Fusion.Out "AbsoluteSize"] = spSize;
                        [Children] = {
                            New "UIListLayout" {
                                FillDirection = Enum.FillDirection.Horizontal;
                                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                                SortOrder = Enum.SortOrder.LayoutOrder;
                                VerticalAlignment = Enum.VerticalAlignment.Center;
                                Padding = UDim.new(0,10);
                            };
                            New "ImageLabel" {
                                LayoutOrder = 1;
                                Image = SpecImg;
                                Size = UDim2.new(0.8,0,0.8,0);
                                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                                BackgroundColor3 = Color3.fromRGB(0,170,0);
                                [Children] = {
                                    New "UICorner" {CornerRadius = UDim.new(1,0)};
                                    New "UIAspectRatioConstraint" {};
                                };
                            };
                            New "TextLabel" {
                                LayoutOrder = 2;
                                AutomaticSize = Enum.AutomaticSize.X;
                                BackgroundTransparency = 1;
                                FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold);
                                Size = UDim2.new(0,0,0.8,0);
                                Text = SpecName;
                                TextColor3 = Color3.new(1,1,1);
                                TextScaled = true;
                                [Children] = New "UISizeConstraint" {
                                    MaxSize = Computed(function()
                                        local s = spSize:get();
                                        if typeof(s) ~= "Vector2" then s = Vector2.one end;
                                        return Vector2.new(math.max(s.X - 52,1),50);
                                    end)
                                }
                            }
                        }
                    };
                    -- Dice Area
                    New "Frame" {
                        Size = UDim2.new(1,0,1,-77);
                        BackgroundTransparency = 1;
                        Position = Computed(function()
                            return data.spectate:get() == nil and UDim2.new(0,0,0,0) or UDim2.new(0,0,0,52);
                        end);
                        [Fusion.Out "AbsolutePosition"] = DiceUi.relPos;
                        [Fusion.Out "AbsoluteSize"] = DiceUi.relSize;
                        [Children] = {
                            DiceUi.Ui(data);
                        }
                    };
                }
            };
        }
    }
end

return Module;
