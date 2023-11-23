-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))
local Close = require(script.Parent:WaitForChild("Close"))

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Observe = Fusion.Observer
local Value = Fusion.Value
local Event = Fusion.OnEvent

local Module = {
    BoardFlipped = nil;
    ActiveBoard = nil;
    ScreenGuiSize = Value();
    ScreenGuiPos = Value();
    BoardAbsSize = nil;
    BoardAbsPos = nil;
    Confirmation = Value(0); -- 0:Not Visible, 1:Resign, 2:Draw, 3:Draw Offer

    Resign = nil;
    Draw = nil;
}

local rendering = Value({})
local scrollSize = Value()
local DownloadVis = Value(false)

function Module:init()
    Observe(Module.ActiveBoard):onChange(function()
        local board = Module.ActiveBoard:get()
        if board.PGN then
            local toRenderPGN = {}
            local temp = nil--{
                --n = nil;
                --w = nil;
                --b = nil;
            --}
            local split = string.split(board.PGN," ");
            for _,o in pairs(split) do
                if o == "1/2-1/2" or o == "0-1" or o == "1-0" then
                    o = ""
                end
                if string.sub(o,string.len(o),string.len(o)) == "." and o ~= "..." then
                    -- Save Old
                    if temp and temp.n and temp.w then
                        table.insert(toRenderPGN,temp)
                    end
                    -- New
                    temp = {n = string.sub(o,1,string.len(o) - 1), w = nil, b = nil;};
                else
                    -- Move
                    if temp and temp.w and temp.b == nil then
                        -- black
                        temp.b = o;
                    elseif temp and temp.w == nil then
                        -- white
                        temp.w = o;
                    end
                end
            end
            if temp and temp.n and temp.w then
                table.insert(toRenderPGN,temp)
            end
            -- Save
            rendering:set(toRenderPGN)
        end
    end)
end

local AnnFrameVis = Value()
function Module.Ui()
    return New "Frame" {
        ZIndex = 5;
        BackgroundColor3 = Color3.fromRGB(46,46,46);
        AnchorPoint = Vector2.new(0,0.5);
        Position = UDim2.new(1,5,0.5,0);
        Size = Computed(function()
            local ScreenGuiSize = Module.ScreenGuiSize:get()
            local ScreenGuiPos = Module.ScreenGuiPos:get()
            local BoardSize = Module.BoardAbsSize:get()
            local BoardPos = Module.BoardAbsPos:get()
            if ScreenGuiSize and ScreenGuiPos and BoardSize and BoardPos then
                local size = (((ScreenGuiSize.X + ScreenGuiPos.X) - BoardPos.X) - BoardSize.X) - 10
                if size < 20 then
                    -- Vis False
                    AnnFrameVis:set(false)
                else
                    -- Vis True
                    AnnFrameVis:set(true)
                end
                return UDim2.new(0,size,0.6,0)
            end
            return UDim2.new(0,0,0,0)
        end);
        Visible = AnnFrameVis;

        [Children] = {
            -- Buttons
            -- Draw
            New "TextButton" {
                AnchorPoint = Vector2.new(0,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0,0,1,0);
                Size = UDim2.new(0.44,0,0.08,0);
                Text = "Draw";
                TextColor3 = Color3.fromRGB(197,197,197);
                TextScaled = true;
                Visible = Computed(function()
                    local board = Module.ActiveBoard:get()
                    if board.Status == "" and (board.White == game.Players.LocalPlayer or board.Black == game.Players.LocalPlayer) then
                        return true
                    end
                    return false
                end);
                [Event "MouseButton1Up"] = function()
                    if Module.Confirmation:get() == 2 then
                        Module.Confirmation:set(0)
                    else
                        Module.Confirmation:set(2)
                    end
                end;
                [Children] = New "UIPadding" {
                    PaddingBottom = UDim.new(0.03,0)
                };
                ZIndex = 6;
            };
            -- Resign
            New "TextButton" {
                AnchorPoint = Vector2.new(0,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0.44,0,1,0);
                Size = UDim2.new(0.44,0,0.08,0);
                Text = "Resign";
                TextColor3 = Color3.fromRGB(197,197,197);
                TextScaled = true;
                Visible = Computed(function()
                    local board = Module.ActiveBoard:get()
                    if board.Status == "" and (board.White == game.Players.LocalPlayer or board.Black == game.Players.LocalPlayer) then
                        return true
                    end
                    return false
                end);
                [Event "MouseButton1Up"] = function()
                    if Module.Confirmation:get() == 1 then
                        Module.Confirmation:set(0)
                    else
                        Module.Confirmation:set(1)
                    end
                end;
                [Children] = New "UIPadding" {
                    PaddingBottom = UDim.new(0.03,0)
                };
                ZIndex = 6;
            };
            -- Flip Board
            New "ImageButton" {
                AnchorPoint = Vector2.new(0,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Image = "rbxassetid://11419667031";
                ImageColor3 = Color3.fromRGB(197,197,197);
                Position = UDim2.new(0.88,0,1,0);
                ScaleType = Enum.ScaleType.Fit;
                Size = UDim2.new(0.12,0,0.08,0);
                [Event "MouseButton1Up"] = function()
                    Module.BoardFlipped:set(not Module.BoardFlipped:get())
                end;
                ZIndex = 6;
            };


            -- Confirmation
            New "Frame" {
                AnchorPoint = Vector2.new(0.5,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Position = UDim2.new(0.5,0,0.9,0);
                Size = UDim2.new(0.95,0,0.2,0);
                ZIndex = 10;
                Visible = Computed(function()
                    if Module.Confirmation:get() == 0 then
                        return false
                    end
                    return true
                end);
                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(0.12,0);
                    };
                    
                    New "TextLabel" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSansBold;
                        Size = UDim2.new(1,0,0.5,0);
                        Text = Computed(function()
                            local v = Module.Confirmation:get()
                            if v == 1 then
                                return "Are you sure you want to resign?"
                            elseif v == 2 then
                                return "Are you sure you want to offer a draw?"
                            elseif v == 3 then
                                return "Would you like to accept a draw?";
                            end;
                            return ""
                        end);
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Children] = New "UIPadding" {
                            PaddingBottom = UDim.new(0.03,0);
                            PaddingLeft = UDim.new(0,5);
                            PaddingRight = UDim.new(0,5);
                        };
                        ZIndex = 11;
                    };
                    -- Yes
                    New "TextButton" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSans;
                        Position = UDim2.new(0,0,0.5,0);
                        Size = UDim2.new(0.5,0,0.5,0);
                        Text = "Yes";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            local v = Module.Confirmation:get()
                            if v == 1 then
                                -- Resign
                                Module.Resign()
                            elseif v == 2 then
                                -- Draw
                                Module.Draw(true)
                            elseif v == 3 then
                                -- Draw
                                Module.Draw(true)
                            end;
                            Module.Confirmation:set(0)
                        end;
                        [Children] = New "UIPadding" {
                            PaddingBottom = UDim.new(0.1,0);
                            PaddingLeft = UDim.new(0,5);
                            PaddingRight = UDim.new(0,5);
                            PaddingTop = UDim.new(0.05,0);
                        };
                        ZIndex = 11;
                    };
                    -- No
                    New "TextButton" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSans;
                        Position = UDim2.new(0.5,0,0.5,0);
                        Size = UDim2.new(0.5,0,0.5,0);
                        Text = "No";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            if Module.Confirmation:get() == 3 then
                                -- Draw
                                Module.Draw(false)
                            end
                            Module.Confirmation:set(0)
                        end;
                        [Children] = New "UIPadding" {
                            PaddingBottom = UDim.new(0.1,0);
                            PaddingLeft = UDim.new(0,5);
                            PaddingRight = UDim.new(0,5);
                            PaddingTop = UDim.new(0.05,0);
                        };
                        ZIndex = 11;
                    }
                }
            };


            -- Annotation
            New "ScrollingFrame" {
                BackgroundColor3 = Color3.fromRGB(66,66,66);
                BottomImage = "";
                CanvasSize = Computed(function()
                    local v = scrollSize:get()
                    if v and v.Y then
                        return UDim2.new(0,0,0,v.Y)
                    end
                    return UDim2.new(0,0,0,0);
                end);
                CanvasPosition = Computed(function()
                    local v = scrollSize:get()
                    if v and v.Y then
                        return Vector2.new(0,v.Y)
                    end
                    return Vector2.new(0,0)
                end);
                ScrollBarThickness = 5;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                Size = UDim2.new(1,0,0.92,0);
                TopImage = "";
                ScrollBarImageColor3 = Color3.new(1,1,1);
                ZIndex = 6;

                [Children] = {
                    New "UIListLayout" {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        [Fusion.Out "AbsoluteContentSize"] = scrollSize
                    };
                    Fusion.ForPairs(rendering,function(i,o)
                        return i, New "Frame" {
                            BackgroundTransparency = 1;
                            Size = UDim2.new(1,0,0,30);
                            LayoutOrder = tonumber(o.n);
                            ZIndex = 7;
                            [Children] = {
                                New "TextLabel" {
                                    BackgroundColor3 = Color3.fromRGB(57,57,57);
                                    Font = Enum.Font.SourceSansBold;
                                    Size = UDim2.new(0,35,1,0);
                                    Text = tostring(o.n);
                                    TextColor3 = Color3.new(1,1,1);
                                    TextSize = 25;
                                    ZIndex = 8;
                                };
                                New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    Font = Enum.Font.SourceSans;
                                    Position = UDim2.new(0,35,0,0);
                                    Size = UDim2.new(0.5,-17,1,0);
                                    Text = o.w or "";
                                    TextColor3 = Color3.new(1,1,1);
                                    TextSize = 25;
                                    ZIndex = 8;
                                };
                                New "TextLabel" {
                                    BackgroundTransparency = 1;
                                    Font = Enum.Font.SourceSans;
                                    Position = UDim2.new(0.5,17,0,0);
                                    Size = UDim2.new(0.5,-17,1,0);
                                    Text = o.b or "";
                                    TextColor3 = Color3.new(1,1,1);
                                    TextSize = 25;
                                    ZIndex = 8;
                                };
                            }
                        }
                    end,Fusion.cleanup)
                }
            };

            -- Move Download
            New "ImageButton" {
                AnchorPoint = Vector2.new(0,1);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Image = "rbxassetid://11295288311";
                ImageColor3 = Color3.fromRGB(197,197,197);
                Position = UDim2.new(0.76,0,1,0);
                ScaleType = Enum.ScaleType.Fit;
                Size = UDim2.new(0.12,0,0.08,0);
                Visible = Computed(function()
                    if Module.ActiveBoard:get().Status ~= "" then
                        return true
                    end
                    return false
                end);
                [Event "MouseButton1Up"] = function()
                    DownloadVis:set(not DownloadVis:get())
                end;
                ZIndex = 6;
            };
            New "TextBox" {
                Visible = Computed(function()
                    if DownloadVis:get() == true and Module.ActiveBoard:get().Status ~= "" then
                        return true
                    end
                    return false
                end);
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                ClearTextOnFocus = false;
                Font = Enum.Font.SourceSans;
                MultiLine = true;
                Position = UDim2.new(0.5,0,0.5,0);
                Size = UDim2.new(0.85,0,0.75,0);
                Text = Computed(function()
                    local board = Module.ActiveBoard:get()
                    local txt = ""
                    if board and board.PGN and board.White and board.Black then
                        local split = string.split(board.PGN," ");
                        txt = '[Event "Live Chess"]\n[Site "Roblox Chess"]\n[Date "' .. os.date("%Y.%m.%d") .. '"]\n[White "' .. tostring(board.White) .. '"]\n[Black "' .. tostring(board.Black) .. '"]\n[Result "' .. split[#split] .. '"]\n\n' .. board.PGN;
                    end
                    return txt
                end);
                TextColor3 = Color3.new(1,1,1);
                TextEditable = false;
                TextSize = 14;
                TextWrapped = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Top;
                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(0.05,0);
                    };
                    New "UIPadding" {
                        PaddingLeft = UDim.new(0,3);
                        PaddingRight = UDim.new(0,3);
                        PaddingTop = UDim.new(0,2);
                    };
                    New "ImageButton" {
                        AnchorPoint = Vector2.new(1,0);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://11293981586";
                        Position = UDim2.new(1,0,0,0);
                        Size = UDim2.new(0.1,0,0.1,0);
                        SizeConstraint = Enum.SizeConstraint.RelativeXX;
                        [Event "MouseButton1Up"] = function()
                            DownloadVis:set(false)
                        end;
                        ZIndex = 11;
                    }
                };
                ZIndex = 10;
            };

            Close.AUi();
        }
    }
end

return Module
