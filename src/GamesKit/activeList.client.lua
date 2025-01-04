-- Stonetr03

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"));
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"));

local New = Fusion.New;
local Value = Fusion.Value;
local Computed = Fusion.Computed;
local Children = Fusion.Children;

local ActiveGames = Value({});
local GameInfo = {};

function Refresh()
    local a,b = Api:Invoke("GamesKit-activeGames");
    GameInfo = b;
    ActiveGames:set(a);
end

local Window = Api:CreateWindow({
    Size = Vector2.new(200,300);
    Title = "Active Games";
    Resizeable = false;
    Buttons = {
        [1] = {
            Text = "rbxassetid://11293978505";
            Callback = function()
                Refresh();
            end;
            Padding = 2;
            Type = "Image";
        };
    };
},New "Frame" {
    Size = UDim2.new(1,0,1,0);
    BackgroundTransparency = 1;
    [Children] = {
        -- Title
        New "TextLabel" {
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxassetid://12187370747",Enum.FontWeight.Bold,Enum.FontStyle.Normal);
            Size = UDim2.new(1,0,0,20);
            Text = "Active Games";
            TextColor3 = Api.Style.TextColor;
            TextScaled = true;
            [Children] = New "Frame" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundColor3 = Api.Style.ButtonSubColor;
                Position = UDim2.new(0.5,0,1,0);
                Size = UDim2.new(0.8,0,0,2);
            }
        };
        -- Footer
        New "TextLabel" {
            BackgroundTransparency = 1;
            FontFace = Font.new("rbxassetid://12187370747");
            Position = UDim2.new(0,0,1,-16);
            Size = UDim2.new(1,0,0,15);
            Text = Computed(function()
                local c = 0
                for _,_ in pairs(ActiveGames:get()) do
                    c+=1;
                end
                return "GamesKit — " .. c .. " games";
            end);
            TextColor3 = Api.Style.ButtonSubColor;
            TextScaled = true;
        };
        -- List
        New "ScrollingFrame" {
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            BackgroundTransparency = 1;
            BottomImage = "";
            CanvasSize = UDim2.new(0,0,0,0);
            Position = UDim2.new(0,0,0,22);
            ScrollBarThickness = 5;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            Size = UDim2.new(1,0,1,-38);
            TopImage = "";

            [Children] = {
                New "UIListLayout" {};
                Fusion.ForPairs(ActiveGames,function(i,o)
                    local isOpen = Value(false);
                    local absSize = Value(Vector2.new(0,0));
                    local Ico1 = "";
                    if GameInfo[o.Type] and GameInfo[o.Type].PlayersAmt == 2 and GameInfo[o.Type].PlayersRequired == true then
                        -- Duel
                        Ico1 = "rbxassetid://16095745392";
                    elseif o.Pending == true then
                        Ico1 = "rbxassetid://11432865972";
                    end
                    return i, New "Frame" {
                        BackgroundTransparency = 1;
                        Size = Computed(function()
                            local abs = absSize:get();
                            if typeof(abs) ~= "Vector2" then
                                abs = Vector2.zero;
                            end
                            return isOpen:get() and UDim2.new(1,0,0,22 + abs.Y) or UDim2.new(1,0,0,18);
                        end);
                        [Fusion.Cleanup] = {isOpen,absSize};
                        [Children] = {
                            -- Title
                            New "TextLabel" {
                                BackgroundTransparency = 1;
                                FontFace = Font.new("rbxassetid://12187370747");
                                Size = UDim2.new(0,100,0,18);
                                Text = o.Type;
                                TextColor3 = Api.Style.TextColor;
                                TextScaled = true;
                            };
                            -- Players
                            New "ImageLabel" {
                                BackgroundTransparency = 1;
                                Image = "rbxassetid://11295273292";
                                Position = UDim2.new(0.5,0,0,1);
                                Size = UDim2.new(0,16,0,16);
                                ImageColor3 = Api.Style.TextColor;
                            };
                            New "TextLabel" {
                                BackgroundTransparency = 1;
                                FontFace = Font.new("rbxassetid://12187370747");
                                Position = UDim2.new(0,118,0,0);
                                Size = UDim2.new(0,30,0,18);
                                Text = #o.Players;
                                TextColor3 = Api.Style.TextColor;
                                TextScaled = true;
                            };
                            -- Icons
                            New "ImageLabel" {
                                BackgroundTransparency = 1;
                                Image = Ico1;
                                Position = UDim2.new(0,158,0,1);
                                Size = UDim2.new(0,16,0,16);
                                ImageColor3 = Api.Style.TextColor;
                            };
                            New "ImageLabel" {
                                BackgroundTransparency = 1;
                                Image = o.Public and "rbxassetid://11422925441" or "rbxassetid://11419715564";
                                Position = UDim2.new(0,178,0,1);
                                Size = UDim2.new(0,16,0,16);
                                ImageColor3 = Api.Style.TextColor;
                            };

                            -- List
                            New "TextButton" {
                                BackgroundTransparency = 1;
                                ZIndex = 2;
                                Size = UDim2.new(1,0,0,18);
                                Text = "";
                                [Fusion.OnEvent "MouseButton1Up"] = function()
                                    isOpen:set(not isOpen:get());
                                end;
                            };
                            New "Frame" {
                                AutomaticSize = Enum.AutomaticSize.Y;
                                BackgroundColor3 = Color3.new(0,0,1);
                                BackgroundTransparency = 0.7;
                                Position = UDim2.new(0,2,0,20);
                                Size = UDim2.new(1,-4,0,0);
                                Visible = isOpen;
                                [Fusion.Out "AbsoluteSize"] = absSize;
                                [Children] = {
                                    New "UICorner" {CornerRadius = UDim.new(0,6)};
                                    New "UIListLayout" {};
                                    Fusion.ForValues(o.Players,function(p)
                                        return New "TextLabel" {
                                            BackgroundTransparency = 1;
                                            FontFace = Font.new("rbxassetid://12187370747");
                                            Size = UDim2.new(1,0,0,18);
                                            Text = p.Name;
                                            Name = p.Name;
                                            TextColor3 = Api.Style.TextColor;
                                            TextScaled = true;
                                            [Children] = New "UITextSizeConstraint" {MaxTextSize = 16};
                                        };
                                    end,Fusion.cleanup);
                                    New "TextLabel" {
                                        BackgroundTransparency = 1;
                                        FontFace = Font.new("rbxassetid://12187370747");
                                        Size = UDim2.new(1,0,0,18);
                                        Text = i;
                                        Name = i;
                                        TextColor3 = Api.Style.ButtonSubColor;
                                        TextScaled = true;
                                        [Children] = New "UITextSizeConstraint" {MaxTextSize = 16};
                                    };
                                }
                            }
                        }
                    }
                end,Fusion.cleanup);
            }
        }
    }
})

Window.OnClose:Connect(function()
    Window.unmount()
    script:Destroy()
end)

Refresh()
