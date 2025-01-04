-- Stonetr03 - GamesKit - Yahtzee Waiting

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local NotoSans = Font.new("rbxassetid://12187370747");

local Module = {
    Visible = Value(true);
    setStyle = nil :: (string) -> ();
    setVis = nil :: (pub: boolean) -> ();
    sentInv = nil :: (p: Player) -> ();
    kickPlr = nil :: (p: Player) -> ();
    start = nil :: () -> ();
}

local menu = Value(0);
local canInvite = Value({});

function Module.Ui(data: table)
    local disc = Fusion.Observer(data.players):onChange(function()
        local plrs = data.players:get();
        local all = game.Players:GetPlayers();

        for _,p in pairs(plrs) do
            if table.find(all,p) then
                table.remove(all,table.find(all,p));
            end
        end

        canInvite:set(all);
    end)

    return New "Frame" {
        Size = UDim2.new(1,0,1,0);
        BackgroundTransparency = 1;
        Visible = Module.Visible;
        [Fusion.Cleanup] = disc;
        [Children] = {
            -- Title
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.Merriweather;
                Size = UDim2.new(1,0,0.15,0);
                Text = "Yahtzee";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
            };
            -- Start
            New "TextButton" {
                AnchorPoint = Vector2.new(0.5,0);
                BackgroundColor3 = Color3.fromRGB(0,85,255);
                FontFace = NotoSans;
                Position = UDim2.new(0.5,0,0.85,0);
                Size = UDim2.new(0.2,0,0.1,0);
                Text = "Start";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                Visible = data.isHost;
                [Event "MouseButton1Up"] = function()
                    Module.start();
                end;
                [Children] = {
                    New "UICorner" {};
                    New "UISizeConstraint" {
                        MinSize = Vector2.new(125,40);
                    }
                }
            };
            -- Settings Button
            New "ImageButton" {
                AnchorPoint = Vector2.new(1,0);
                BackgroundColor3 = Color3.fromRGB(0,85,0);
                Image = "rbxassetid://11293977610";
                Position = UDim2.new(1,-10,0,10);
                Size = UDim2.new(0.06,0,0.06,0);
                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                [Event "MouseButton1Up"] = function()
                    if menu:get() == 1 then
                        menu:set(0);
                    else
                        menu:set(1);
                    end
                end;
                [Children] = {
                    New "UISizeConstraint" {
                        MinSize = Vector2.new(35,35);
                    };

            -- Invite Button
                    New "ImageButton" {
                        BackgroundColor3 = Color3.fromRGB(0,85,0);
                        Image = "rbxassetid://11422144827";
                        ImageColor3 = Computed(function()
                            return #canInvite:get() > 0 and Color3.new(1,1,1) or Color3.new(0.8,0.8,0.8);
                        end);
                        Position = UDim2.new(-1,-10,0,0);
                        Size = UDim2.new(1,0,1,0);
                        Visible = data.isHost;
                        [Event "MouseButton1Up"] = function()
                            if menu:get() == 2 then
                                menu:set(0);
                            elseif #canInvite:get() > 0 then
                                menu:set(2);
                            end
                        end;
                    }
                }
            };
            -- PlayerList
            New "ScrollingFrame" {
                AnchorPoint = Vector2.new(0.5,0);
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                BackgroundTransparency = 1;
                CanvasSize = UDim2.new(0,0,0,0);
                Position = UDim2.new(0.5,0,0.15,0);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                Size = UDim2.new(0.3,0,0.675,0);
                VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
                ScrollBarThickness = 8;
                TopImage = "";
                BottomImage = "";
                [Children] = {
                    New "UIListLayout" {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                    };
                    New "UISizeConstraint" {
                        MinSize = Vector2.new(280,0);
                    };
                    New "TextLabel" {
                        BackgroundTransparency = 1;
                        FontFace = NotoSans;
                        LayoutOrder = -5000;
                        Size = UDim2.new(1,0,0.04,0);
                        Text = Computed(function()
                            return #data.players:get() .. " / 50";
                        end);
                        TextColor3 = Color3.fromRGB(197,197,197);
                        TextScaled = true;
                    };
                    Fusion.ForPairs(data.players,function(i,p)
                        local img = game.Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size180x180);
                        local hov = Value(false);
                        local Offset = Value(Vector2.new());
                        return i, New "Frame" {
                            BackgroundTransparency = 1;
                            LayoutOrder = p.UserId;
                            Size = UDim2.new(1,0,0.15,0);
                            [Event "MouseEnter"] = function()
                                hov:set(true);
                            end;
                            [Event "MouseLeave"] = function()
                                hov:set(false);
                            end;
                            [Fusion.Cleanup] = hov;
                            [Children] = {
                                New "UISizeConstraint" {
                                    MinSize = Vector2.new(0,35);
                                };
                                New "ImageLabel" {
                                    AnchorPoint = Vector2.new(0,0.5);
                                    BackgroundColor3 = Color3.fromRGB(0,70,0);
                                    Image = img;
                                    Position = UDim2.new(0,0,0.5,0);
                                    Size = UDim2.new(0.8,0,0.8,0);
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY;
                                    [Fusion.Out "AbsoluteSize"] = Offset;
                                    [Fusion.Cleanup] = Offset;
                                    [Children] = New "UICorner" {CornerRadius = UDim.new(1,0)};
                                };
                                New "TextLabel" {
                                    AnchorPoint = Vector2.new(0,0.5);
                                    BackgroundTransparency = 1;
                                    FontFace = NotoSans;
                                    Position = Computed(function()
                                        local o = Offset:get()
                                        if typeof(o) ~= "Vector2" then o = Vector2.zero end
                                        return UDim2.new(0,o.X,0.5,0)
                                    end);
                                    Size = Computed(function()
                                        local o = Offset:get()
                                        if typeof(o) ~= "Vector2" then o = Vector2.zero end
                                        return UDim2.new(1,-o.X,0.6,0)
                                    end);
                                    Text = p.Name;
                                    TextColor3 = Color3.new(1,1,1);
                                    TextScaled = true;
                                };
                                -- Close btn
                                New "ImageButton" {
                                    AnchorPoint = Vector2.new(1,0.5);
                                    BackgroundColor3 = Color3.new(0,0,0);
                                    BackgroundTransparency = 0.2;
                                    Image = "rbxassetid://11293981586";
                                    Position = UDim2.new(0.95,0,0.5,0);
                                    Size = UDim2.new(0.5,0,0.5,0);
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY;
                                    Visible = Computed(function()
                                        return hov:get() and data.isHost:get() and p ~= game.Players.LocalPlayer;
                                    end);
                                    [Children] = New "UICorner" {
                                        CornerRadius = UDim.new(0.2,0);
                                    };
                                    [Event "MouseButton1Up"] = function()
                                        -- Kick Player
                                        Module.kickPlr(p);
                                    end
                                }
                            }
                        }
                    end,Fusion.cleanup);
                }
            };

            -- Settings Menu
            New "Frame" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.2;
                Position = UDim2.new(0.5,0,0.5,0);
                Size = UDim2.new(0.3,0,0.2,0);
                Visible = Computed(function()
                    return menu:get() == 1;
                end);
                ZIndex = 10;
                [Children] = {
                    New "UIAspectRatioConstraint" {AspectRatio = 2;};
                    New "UICorner" {CornerRadius = UDim.new(0.05,0)};
                    New "UISizeConstraint" {MinSize = Vector2.new(280,140)};
                    -- Close
                    New "ImageButton" {
                        AnchorPoint = Vector2.new(1,0);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://11293981586";
                        Position = UDim2.new(1,0,0,0);
                        Size = UDim2.new(0.22,0,0.22,0);
                        SizeConstraint = Enum.SizeConstraint.RelativeYY;
                        [Event "MouseButton1Up"] = function()
                            menu:set(0);
                        end;
                    };
                    -- Round Style
                    New "TextLabel" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSansBold;
                        Size = UDim2.new(1,0,0.2,0);
                        Text = "Round Style";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                    };
                    New "TextButton" {
                        BackgroundColor3 = Color3.fromRGB(70,70,70);
                        BackgroundTransparency = 0.3;
                        Font = Enum.Font.SourceSansBold;
                        Position = UDim2.new(0.025,0,0.23,0);
                        Size = UDim2.new(0.3,0,0.25,0);
                        Text = "Turn";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            Module.setStyle("turn");
                        end;
                        [Children] = {
                            New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                            New "UIPadding" {
                                PaddingBottom = UDim.new(0,3);
                                PaddingLeft = UDim.new(0,3);
                                PaddingRight = UDim.new(0,3);
                            };
                            New "UIStroke" {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                Color = Color3.fromRGB(0,170,255);
                                Enabled = Computed(function()
                                    return data.style:get() == "turn"
                                end);
                                Thickness = 2;
                            }
                        }
                    };
                    New "TextButton" {
                        BackgroundColor3 = Color3.fromRGB(70,70,70);
                        BackgroundTransparency = 0.3;
                        Font = Enum.Font.SourceSansBold;
                        Position = UDim2.new(0.35,0,0.23,0);
                        Size = UDim2.new(0.3,0,0.25,0);
                        Text = "Sync";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            Module.setStyle("sync");
                        end;
                        [Children] = {
                            New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                            New "UIPadding" {
                                PaddingBottom = UDim.new(0,3);
                                PaddingLeft = UDim.new(0,3);
                                PaddingRight = UDim.new(0,3);
                            };
                            New "UIStroke" {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                Color = Color3.fromRGB(0,170,255);
                                Enabled = Computed(function()
                                    return data.style:get() == "sync"
                                end);
                                Thickness = 2;
                            }
                        }
                    };
                    New "TextButton" {
                        BackgroundColor3 = Color3.fromRGB(70,70,70);
                        BackgroundTransparency = 0.3;
                        Font = Enum.Font.SourceSansBold;
                        Position = UDim2.new(0.675,0,0.23,0);
                        Size = UDim2.new(0.3,0,0.25,0);
                        Text = "Flow";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            Module.setStyle("flow");
                        end;
                        [Children] = {
                            New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                            New "UIPadding" {
                                PaddingBottom = UDim.new(0,3);
                                PaddingLeft = UDim.new(0,3);
                                PaddingRight = UDim.new(0,3);
                            };
                            New "UIStroke" {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                Color = Color3.fromRGB(0,170,255);
                                Enabled = Computed(function()
                                    return data.style:get() == "flow"
                                end);
                                Thickness = 2;
                            }
                        }
                    };
                    -- Game Visibility
                    New "TextLabel" {
                        BackgroundTransparency = 1;
                        Font = Enum.Font.SourceSansBold;
                        Position = UDim2.new(0,0,0.5,0);
                        Size = UDim2.new(1,0,0.2,0);
                        Text = "Game Visibility";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                    };
                    New "TextButton" {
                        BackgroundColor3 = Color3.fromRGB(70,70,70);
                        BackgroundTransparency = 0.3;
                        Font = Enum.Font.SourceSansBold;
                        Position = UDim2.new(0.033,0,0.71,0);
                        Size = UDim2.new(0.45,0,0.25,0);
                        Text = "Private";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            Module.setVis(false);
                        end;
                        [Children] = {
                            New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                            New "UIPadding" {
                                PaddingBottom = UDim.new(0,3);
                                PaddingLeft = UDim.new(0,3);
                                PaddingRight = UDim.new(0,3);
                            };
                            New "UIStroke" {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                Color = Color3.fromRGB(0,170,255);
                                Enabled = Computed(function()
                                    return data.vis:get() == false
                                end);
                                Thickness = 2;
                            }
                        }
                    };
                    New "TextButton" {
                        BackgroundColor3 = Color3.fromRGB(70,70,70);
                        BackgroundTransparency = 0.3;
                        Font = Enum.Font.SourceSansBold;
                        Position = UDim2.new(0.522,0,0.71,0);
                        Size = UDim2.new(0.45,0,0.25,0);
                        Text = "Public";
                        TextColor3 = Color3.new(1,1,1);
                        TextScaled = true;
                        [Event "MouseButton1Up"] = function()
                            Module.setVis(true);
                        end;
                        [Children] = {
                            New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                            New "UIPadding" {
                                PaddingBottom = UDim.new(0,3);
                                PaddingLeft = UDim.new(0,3);
                                PaddingRight = UDim.new(0,3);
                            };
                            New "UIStroke" {
                                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                Color = Color3.fromRGB(0,170,255);
                                Enabled = Computed(function()
                                    return data.vis:get() == true
                                end);
                                Thickness = 2;
                            }
                        }
                    };
                }
            };

            -- Add Players
            New "Frame" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundColor3 = Color3.new(0,0,0);
                BackgroundTransparency = 0.2;
                Position = UDim2.new(0.5,0,0.5,0);
                Size = UDim2.new(0.3,0,0.9,0);
                Visible = Computed(function()
                    return menu:get() == 2
                end);
                [Children] = {
                    New "UICorner" {CornerRadius = UDim.new(0,10)};
                    New "UISizeConstraint" {
                        MaxSize = Computed(function()
                            return Vector2.new(math.huge,math.max(#canInvite:get() * 47,30));
                        end);
                        MinSize = Vector2.new(280,0);
                    };
                    New "ImageButton" {
                        AnchorPoint = Vector2.new(1,0);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://11293981586";
                        Position = UDim2.new(1,0,0,0);
                        Size = UDim2.new(0.1,0,0.1,0);
                        SizeConstraint = Enum.SizeConstraint.RelativeXX;
                        ZIndex = 2;
                        [Event "MouseButton1Up"] = function()
                            menu:set(0);
                        end;
                    };
                    New "ScrollingFrame" {
                        AutomaticCanvasSize = Enum.AutomaticSize.Y;
                        BackgroundTransparency = 1;
                        CanvasSize = UDim2.new(0,0,0,0);
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        Size = UDim2.new(1,0,1,0);
                        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
                        [Children] = {
                            New "UIListLayout" {
                                Padding = UDim.new(0,2);
                                SortOrder = Enum.SortOrder.LayoutOrder;
                            };
                            Fusion.ForPairs(canInvite,function(i,p)
                                local sent = Value(false);
                                return i, New "TextButton" {
                                    BackgroundTransparency = 1;
                                    FontFace = NotoSans;
                                    Size = UDim2.new(1,0,0,45);
                                    Text = p.Name;
                                    TextColor3 = Computed(function()
                                        return sent:get() and Color3.new(0,0,1) or Color3.new(1,1,1);
                                    end);
                                    TextScaled = true;
                                    [Children] = New "UIPadding" {
                                        PaddingLeft = UDim.new(0,5);
                                        PaddingRight = UDim.new(0,5);
                                    };
                                    [Event "MouseButton1Up"] = function()
                                        Module.sentInv(p);
                                        sent:set(true);
                                        task.delay(45, function()
                                            if sent then
                                                sent:set(false);
                                            end
                                        end)
                                    end;
                                    [Fusion.Cleanup] = sent;
                                }
                            end,Fusion.cleanup)
                        }
                    }
                }
            }
        }
    }
end

return Module;
