-- Stonetr03

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Module = {
    Size = Value(2);
    Color = Value(false);
}

Api.Settings.Changed:Connect(function(Name,v,Cat)
    if Cat == "Solitaire" then
        if Name == "IndexSize" then
            Module.Size:set(v)
        elseif Name == "ColoredCards" then
            Module.Color:set(v)
        end
    end
end)
Api:SetSettingModifier("IndexSize",{Text = "Index Size",Check = function(v)
    if typeof(v) == "number" and v > 0 and v < 4 then
        return v
    end
    return Api.Settings.Solitaire.IndexSize
end,Type = "cycle",Value = {1,2,3}},"Solitaire")
if Api.Settings.Solitaire == nil or Api.Settings.Solitaire.IndexSize == nil then
    Api:SetSetting("IndexSize",2,"Solitaire")
else
    Module.Size:set(Api.Settings.Solitaire.IndexSize)
end
Api:SetSettingModifier("ColoredCards",{Text = "Four Color Deck",Check = function(v)
    if typeof(v) == "boolean" then
        return v
    end
    return Api.Settings.Solitaire.ColoredCards
end,Type = "cycle",Value = {true, false}},"Solitaire")
if Api.Settings.Solitaire == nil or Api.Settings.Solitaire.ColoredCards == nil then
    Api:SetSetting("ColoredCards",false,"Solitaire")
else
    Module.Color:set(Api.Settings.Solitaire.ColoredCards)
end

function Module.Ui(SettingsVis)
    return New "Frame" {
        AnchorPoint = Vector2.new(0.5,0.5);
        BackgroundColor3 = Color3.new(0,0,0);
        BackgroundTransparency = 0.2;
        Position = UDim2.new(0.5,0,0.5,0);
        Size = UDim2.new(0.45,0,0.2,0);
        Visible = SettingsVis;
        ZIndex = 10;
        [Children] = {
            New "UISizeConstraint" {MinSize = Vector2.new(100,50)};
            New "UICorner" {CornerRadius = UDim.new(0.05,0)};
            New "ImageButton" {
                AnchorPoint = Vector2.new(1,0);
                BackgroundTransparency = 1;
                Image = "rbxassetid://11293981586";
                Position = UDim2.new(1,0,0,0);
                Size = UDim2.new(0.22,0,0.22,0);
                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                [Event "MouseButton1Up"] = function()
                    SettingsVis:set(false)
                end;
            };
            -- Index Size
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSansBold;
                Size = UDim2.new(1,0,0.2,0);
                Text = "Index Size";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
            };
            New "TextButton" {
                BackgroundColor3 = Color3.fromRGB(70,70,70);
                BackgroundTransparency = 0.3;
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0.025,0,0.23,0);
                Size = UDim2.new(0.3,0,0.25,0);
                Text = "Normal";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                [Children] = {
                    New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                    New "UIPadding" {PaddingRight = UDim.new(0,3),PaddingLeft = UDim.new(0,3),PaddingBottom = UDim.new(0,3)};
                    New "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        Color = Color3.fromRGB(0,170,255);
                        Thickness = 2;
                        Enabled = Computed(function()
                            if Module.Size:get() == 1 then
                                return true
                            end
                            return false
                        end);
                    }
                };
                [Event "MouseButton1Up"] = function()
                    Api:SetSetting("IndexSize",1,"Solitaire")
                end;
            };
            New "TextButton" {
                BackgroundColor3 = Color3.fromRGB(70,70,70);
                BackgroundTransparency = 0.3;
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0.35,0,0.23,0);
                Size = UDim2.new(0.3,0,0.25,0);
                Text = "Medium";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                [Children] = {
                    New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                    New "UIPadding" {PaddingRight = UDim.new(0,3),PaddingLeft = UDim.new(0,3),PaddingBottom = UDim.new(0,3)};
                    New "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        Color = Color3.fromRGB(0,170,255);
                        Thickness = 2;
                        Enabled = Computed(function()
                            if Module.Size:get() == 2 then
                                return true
                            end
                            return false
                        end);
                    }
                };
                [Event "MouseButton1Up"] = function()
                    Api:SetSetting("IndexSize",2,"Solitaire")
                end;
            };
            New "TextButton" {
                BackgroundColor3 = Color3.fromRGB(70,70,70);
                BackgroundTransparency = 0.3;
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0.675,0,0.23,0);
                Size = UDim2.new(0.3,0,0.25,0);
                Text = "Large";
                TextColor3 = Color3.new(0.5,0.5,0.5);
                TextScaled = true;
                [Children] = {
                    New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                    New "UIPadding" {PaddingRight = UDim.new(0,3),PaddingLeft = UDim.new(0,3),PaddingBottom = UDim.new(0,3)};
                    New "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        Color = Color3.fromRGB(0,170,255);
                        Thickness = 2;
                        Enabled = Computed(function()
                            if Module.Size:get() == 3 then
                                return true
                            end
                            return false
                        end);
                    }
                };
                [Event "MouseButton1Up"] = function()
                    Api:SetSetting("IndexSize",3,"Solitaire")
                end;
            };
            -- Color
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSansBold;
                Size = UDim2.new(1,0,0.2,0);
                Position = UDim2.new(0,0,0.5,0);
                Text = "Four Color Deck";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
            };
            New "TextButton" {
                BackgroundColor3 = Color3.fromRGB(70,70,70);
                BackgroundTransparency = 0.3;
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0.033,0,0.71,0);
                Size = UDim2.new(0.45,0,0.25,0);
                Text = "Off";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                [Children] = {
                    New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                    New "UIPadding" {PaddingRight = UDim.new(0,3),PaddingLeft = UDim.new(0,3),PaddingBottom = UDim.new(0,3)};
                    New "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        Color = Color3.fromRGB(0,170,255);
                        Thickness = 2;
                        Enabled = Computed(function()
                            return not Module.Color:get()
                        end);
                    }
                };
                [Event "MouseButton1Up"] = function()
                    Api:SetSetting("ColoredCards",false,"Solitaire")
                end;
            };
            New "TextButton" {
                BackgroundColor3 = Color3.fromRGB(70,70,70);
                BackgroundTransparency = 0.3;
                Font = Enum.Font.SourceSansBold;
                Position = UDim2.new(0.522,0,0.71,0);
                Size = UDim2.new(0.45,0,0.25,0);
                Text = "On";
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                [Children] = {
                    New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                    New "UIPadding" {PaddingRight = UDim.new(0,3),PaddingLeft = UDim.new(0,3),PaddingBottom = UDim.new(0,3)};
                    New "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        Color = Color3.fromRGB(0,170,255);
                        Thickness = 2;
                        Enabled = Module.Color;
                    }
                };
                [Event "MouseButton1Up"] = function()
                    Api:SetSetting("ColoredCards",true,"Solitaire")
                end;
            };
        }
    }
end

return Module
