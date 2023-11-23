-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))
local Pieces = require(script.Parent:WaitForChild("Pieces"))

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Event = Fusion.OnEvent
local Value = Fusion.Value

local Module = {
    Visible = Value(false);
    Picker = nil;
    Get = nil;
    Set = nil;
}

local CustomB = Value(Color3.fromRGB(181,136,99));
local CustomW = Value(Color3.fromRGB(240,217,181))
local ActivePicker = true; -- false:w, true:b
local DropdownVis = Value(false)

local CustomPieces = {
    ["standard"] = "rbxassetid://6556269075";
    ["caliente"] = "rbxassetid://14663048421";
    ["california"] = "rbxassetid://14663599426";
    ["cardinal"] = "rbxassetid://14663602790";
    ["cburnett"] = "rbxassetid://14663681677";
    ["disguised"] = "rbxassetid://14663683392";
    ["fresca"] = "rbxassetid://14663685805";
    ["gioco"] = "rbxassetid://14663703453";
    ["kiwen-suwi"] = "rbxassetid://14663704954";
    ["kosal"] = "rbxassetid://14663706620";
    ["letter"] = "rbxassetid://14663719742";
    ["libra"] = "rbxassetid://14663721786";
    ["maestro"] = "rbxassetid://14663723184";
    ["merida"] = "rbxassetid://14663804000";
    ["mono"] = "rbxassetid://14663805688";
    ["mpchess"] = "rbxassetid://14663807414";
    ["pirouetti"] = "rbxassetid://14663899026";
    ["pixel"] = "rbxassetid://14663900789";
    ["shapes"] = "rbxassetid://14663902309";
    ["staunty"] = "rbxassetid://14663962704";
    ["tatiana"] = "rbxassetid://14663964298";
}

function Button(Pos,WColor,BColor)
    return New "ImageButton" {
        BackgroundColor3 = BColor;
        Image = "http://www.roblox.com/asset/?id=14599115588";
        ImageColor3 = WColor;
        Position = Pos;
        ResampleMode = Enum.ResamplerMode.Pixelated;
        Size = UDim2.new(0.2,0,0.18,0);
        SliceScale = 0;
        [Children] = New "UICorner" {
            CornerRadius = UDim.new(0,8);
        };
        [Event "MouseButton1Up"] = function()
            Pieces.BoardWColor:set(WColor);
            Pieces.BoardBColor:set(BColor);
            if typeof(Module.Set) == "function" then
                Module.Set("WColor",WColor:ToHex())
                Module.Set("BColor",BColor:ToHex())
            end
        end;
        ZIndex = 201;
    }
end

function Module.Ui()
    return New "Frame" {
        AnchorPoint = Vector2.new(0.5,0.5);
        BackgroundColor3 = Color3.fromRGB(66,66,66);
        Position = UDim2.new(0.5,0,0.5,0);
        Size = UDim2.new(0.27,0,0.45,0);
        ZIndex = 200;
        Visible = Module.Visible;

        [Children] = {
            New "UICorner" {
                CornerRadius = UDim.new(0.03,0);
            };
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0,0,0,5);
                Size = UDim2.new(1,0,0.1,0);
                Text = "Board Settings";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                ZIndex = 201;
            };
            New "ImageButton" {
                AnchorPoint = Vector2.new(1,0);
                BackgroundTransparency = 1;
                Image = "rbxassetid://11293981586";
                Position = UDim2.new(1,-5,0,5);
                Size = UDim2.new(0.1,0,0.1,0);
                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                [Event "MouseButton1Up"] = function()
                    Module.Visible:set(false)
                end;
                ZIndex = 201;
            };

            -- Piece Selection
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSans;
                Position = UDim2.new(0,5,0.12,5);
                Size = UDim2.new(0.5,-5,0.1,0);
                Text = "Pieces";
                TextColor3 = Color3.fromRGB(197,197,197);
                TextScaled = true;
                ZIndex = 201;
            };
            New "TextButton" {
                BackgroundColor3 = Color3.new(1,1,1);
                BackgroundTransparency = 0.9;
                Font = Enum.Font.SourceSans;
                Position = UDim2.new(0.5,-5,0.11,5);
                Size = UDim2.new(0.5,0,0.12,0);
                Text = Computed(function()
                    local FindImageId = Pieces.ImageId:get();
                    for i,o in pairs(CustomPieces) do
                        if o == FindImageId then
                            return i
                        end
                    end
                    return ""
                end);
                ZIndex = 201;
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(0,8);
                    };
                    New "UIPadding" {
                        PaddingBottom = UDim.new(0.1,0);
                        PaddingTop = UDim.new(0.1,0);
                        PaddingLeft = UDim.new(0,5);
                    };
                    New "ImageLabel" {
                        AnchorPoint = Vector2.new(1,0);
                        BackgroundTransparency = 1;
                        Image = Pieces.ImageId;
                        ImageRectOffset = Pieces.N;
                        ImageRectSize = Vector2.new(175,175);
                        Position = UDim2.new(0.97,0,-0.1,0);
                        ScaleType = Enum.ScaleType.Fit;
                        Size = UDim2.new(0.28,0,1.2,0);
                        ZIndex = 202;
                    }
                };
                [Event "MouseButton1Up"] = function()
                    DropdownVis:set(true)
                end
            };

            -- Dropdown
            New "Frame" {
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Position = UDim2.new(0.5,-5,0.11,5);
                Size = UDim2.new(0.5,0,0.72,0);
                ZIndex = 210;
                Visible = DropdownVis;
                [Children] = {
                    New "UICorner" {
                        CornerRadius = UDim.new(0,8);
                    };
                    New "ScrollingFrame" {
                        BackgroundTransparency = 1;
                        BottomImage = "";
                        CanvasSize = UDim2.new(0,0,20 * 0.125,20 * 5);
                        ScrollBarThickness = 5;
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        Size = UDim2.new(1,0,1,0);
                        TopImage = "";
                        ZIndex = 211;
                        [Children] = {
                            New "UIListLayout" {
                                Padding = UDim.new(0,5);
                                SortOrder = Enum.SortOrder.Name;
                            };
                            New "UIPadding" {
                                PaddingLeft = UDim.new(0,5);
                                PaddingRight = UDim.new(0,5);
                                PaddingTop = UDim.new(0,5);
                            };
                            Fusion.ForPairs(CustomPieces,function(i,o)
                                local name = i
                                if name == "standard" then
                                    name = "_" .. name
                                end
                                return i, New "TextButton" {
                                    BackgroundColor3 = Color3.new(1,1,1);
                                    BackgroundTransparency = 0.9;
                                    Font = Enum.Font.SourceSans;
                                    Size = UDim2.new(1,0,0.05,-5);
                                    Text = i;
                                    Name = name;
                                    TextColor3 = Color3.new(1,1,1);
                                    TextScaled = true;
                                    TextTruncate = Enum.TextTruncate.AtEnd;
                                    TextXAlignment = Enum.TextXAlignment.Left;
                                    ZIndex = 212;
                                    [Children] = {
                                        New "UICorner" {
                                            CornerRadius = UDim.new(0,8)
                                        };
                                        New "UIPadding" {
                                            PaddingBottom = UDim.new(0.1,0);
                                            PaddingLeft = UDim.new(0,5);
                                            PaddingTop = UDim.new(0.1,0);
                                        };
                                        New "ImageLabel" {
                                            AnchorPoint = Vector2.new(1,0);
                                            BackgroundTransparency = 1;
                                            Image = o;
                                            ImageRectOffset = Pieces.N;
                                            ImageRectSize = Vector2.new(175,175);
                                            Position = UDim2.new(0.97,0,-0.1,0);
                                            Size = UDim2.new(0.28,0,1.2,0);
                                            ScaleType = Enum.ScaleType.Fit;
                                            ZIndex = 213;
                                        }
                                    };
                                    [Event "MouseButton1Up"] = function()
                                        task.wait()
                                        Pieces.ImageId:set(o)
                                        DropdownVis:set(false)
                                        if typeof(Module.Set) == "function" then
                                            Module.Set("Piece",i)
                                        end
                                    end;
                                }
                            end,Fusion.cleanup)
                        }
                    };
                }
            };

            -- Board Colors
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSans;
                Position = UDim2.new(0,0,0.25,0);
                Size = UDim2.new(1,0,0.06,0);
                Text = "Board Colors";
                TextColor3 = Color3.fromRGB(197,197,197);
                TextScaled = true;
                ZIndex = 201;
            };
            Button(UDim2.new(0.04,0,0.33,0),Color3.fromRGB(240,217,181),Color3.fromRGB(181,136,99));
            Button(UDim2.new(0.28,0,0.33,0),Color3.fromRGB(195,205,215),Color3.fromRGB(70,120,170));
            Button(UDim2.new(0.52,0,0.33,0),Color3.fromRGB(240,240,210),Color3.fromRGB(120,150,80));
            Button(UDim2.new(0.76,0,0.33,0),Color3.fromRGB(245,220,196),Color3.fromRGB(190,90,70));
            Button(UDim2.new(0.04,0,0.55,0),Color3.fromRGB(212,212,212),Color3.fromRGB(57,57,57));
            Button(UDim2.new(0.28,0,0.55,0),Color3.fromRGB(225,215,235),Color3.fromRGB(155,125,180));
            Button(UDim2.new(0.52,0,0.55,0),Color3.fromRGB(250,230,175),Color3.fromRGB(210,140,20));
            Button(UDim2.new(0.76,0,0.55,0),Color3.fromRGB(215,215,215),Color3.fromRGB(170,170,170));

            -- Custom Board Colors
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSans;
                Position = UDim2.new(0,0,0.75,0);
                Size = UDim2.new(1,0,0.06,0);
                Text = "Custom Board Colors";
                TextColor3 = Color3.fromRGB(197,197,197);
                TextScaled = true;
                ZIndex = 201;
            };
            New "ImageLabel" {
                BackgroundColor3 = Pieces.BoardBColor;
                Image = "http://www.roblox.com/asset/?id=14599115588";
                ImageColor3 = Pieces.BoardWColor;
                Position = UDim2.new(0.04,0,0.8,0);
                ResampleMode = Enum.ResamplerMode.Pixelated;
                Size = UDim2.new(0.2,0,0.18,0);
                SliceScale = 0;
                ZIndex = 201;
                [Children] = New "UICorner" {
                    CornerRadius = UDim.new(0,8);
                };
            };

            New "TextButton" { -- W
                BackgroundColor3 = CustomB;
                Position = UDim2.new(0.28,0,0.82,0);
                Size = UDim2.new(0.32,0,0.15,0);
                Text = "";
                ZIndex = 201;
                [Event "MouseButton1Down"] = function()
                    -- Color Picker
                    ActivePicker = true
                    Module.Picker:SetColor(Pieces.BoardBColor:get())
                    Module.Picker.Instance.Parent.Visible = true;
                end;
                [Children] = New "UICorner" {
                    CornerRadius = UDim.new(0,8);
                };
            }; -- B
            New "TextButton" {
                BackgroundColor3 = CustomW;
                Position = UDim2.new(0.64,0,0.82,0);
                Size = UDim2.new(0.32,0,0.15,0);
                Text = "";
                ZIndex = 201;
                [Event "MouseButton1Down"] = function()
                    -- Color Picker
                    ActivePicker = false;
                    Module.Picker:SetColor(Pieces.BoardWColor:get())
                    Module.Picker.Instance.Parent.Visible = true;
                end;
                [Children] = New "UICorner" {
                    CornerRadius = UDim.new(0,8);
                };
            };
        }
    }
end

function Module.Button()
    return New "ImageButton" {
        Size = UDim2.new(0,20,0,20);
        Position = UDim2.new(1,5,0,0);
        BackgroundColor3 = Color3.new(0,0,0);
        BackgroundTransparency = 0.5;
        Image = "rbxassetid://11293977610";
        [Event "MouseButton1Up"] = function()
            Module.Visible:set(not Module.Visible:get());
        end;
        ZIndex = 15;
    }
end

-- Picker Events
function Module:Init()
    Module.Picker.Finished:Connect(function(Color: Color3)
        task.wait()
        Module.Picker.Instance.Parent.Visible = false;
        if ActivePicker == true then
            Pieces.BoardBColor:set(Color)
            CustomB:set(Color)
            if typeof(Module.Set) == "function" then
                Module.Set("BColor",Color:ToHex())
            end
        else
            Pieces.BoardWColor:set(Color)
            CustomW:set(Color)
            if typeof(Module.Set) == "function" then
                Module.Set("WColor",Color:ToHex())
            end
        end
    end);
    Module.Picker.Updated:Connect(function(Color: Color3)
        if ActivePicker == true then
            CustomB:set(Color)
        else
            CustomW:set(Color)
        end
    end)
    Module.Picker.Canceled:Connect(function()
        task.wait()
        Module.Picker.Instance.Parent.Visible = false;
        if ActivePicker == true then
            CustomB:set(Pieces.BoardBColor:get())
        else
            CustomW:set(Pieces.BoardWColor:get())
        end
    end);
end

function checkHex(str)
    -- Check if the string starts with "#" and is exactly 7 characters long
    if type(str) == "string" and str:match("^%x%x%x%x%x%x$") then
        return true
    else
        return false
    end
end
function Module:Initset()
    local CurrentSettings = Module.Get();
    if CurrentSettings.Piece then
        if CustomPieces[CurrentSettings.Piece] then
            Pieces.ImageId:set(CustomPieces[CurrentSettings.Piece])
        end
    end
    if CurrentSettings.WColor and checkHex(CurrentSettings.WColor) == true then
        local NewColor = Color3.fromHex(CurrentSettings.WColor);
        CustomW:set(NewColor);
        Pieces.BoardWColor:set(NewColor)
    end
    if CurrentSettings.BColor and checkHex(CurrentSettings.BColor) == true then
        local NewColor = Color3.fromHex(CurrentSettings.BColor)
        CustomB:set(NewColor);
        Pieces.BoardBColor:set(NewColor)
    end
end

return Module
