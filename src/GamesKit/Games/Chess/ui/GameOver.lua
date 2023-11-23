-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))
local UserInputService = game:GetService("UserInputService")

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value
local Tween = Fusion.Tween

local Module = {
    ActiveBoard = nil;
    Visible = Value(false);
}

-- Values
local Title = Value("White Wins")
local Desc = Value("by checkmate");
local Score = Value("0 - 0")
local WImage = Value("")
local BImage = Value("")
local WColor = Value(Color3.fromRGB(122,122,122))
local BColor = Value(Color3.fromRGB(122,122,122))

local WinColor = Color3.fromRGB(0,170,0);
local DrawColor = Color3.fromRGB(122,122,122);

local CooldownTimer = 0;

Fusion.Observer(Module.Visible):onChange(function()
    CooldownTimer = os.time() + 2
end)

function Module:init()
    Fusion.Observer(Module.ActiveBoard):onChange(function()
        local Board = Module.ActiveBoard:get()
        if Board.Status and Board.Status ~= "" then
            local StatSplit = string.split(Board.Status,";")
            if StatSplit[1] == "checkmate" then
                if Board.White == game.Players.LocalPlayer and StatSplit[2] == "w" then
                    Title:set("You Win!")
                elseif Board.Black == game.Players.LocalPlayer and StatSplit[2] == "b" then
                    Title:set("You Win!")
                elseif StatSplit[2] == "w" then
                    Title:set("White Wins")
                elseif StatSplit[2] == "b" then
                    Title:set("Black Wins")
                end

                if StatSplit[2] == "w" then
                    Score:set("1 - 0")
                    WColor:set(WinColor)
                    BColor:set(DrawColor)
                elseif StatSplit[2] == "b" then
                    Score:set("0 - 1")
                    WColor:set(DrawColor)
                    BColor:set(WinColor)
                end

                Desc:set("by checkmate");
            elseif StatSplit[1] == "resign" then
                if Board.White == game.Players.LocalPlayer and StatSplit[2] == "w" then
                    Title:set("You Win!")
                elseif Board.Black == game.Players.LocalPlayer and StatSplit[2] == "b" then
                    Title:set("You Win!")
                elseif StatSplit[2] == "w" then
                    Title:set("White Wins")
                elseif StatSplit[2] == "b" then
                    Title:set("Black Wins")
                end

                if StatSplit[2] == "w" then
                    Score:set("1 - 0")
                    WColor:set(WinColor)
                    BColor:set(DrawColor)
                elseif StatSplit[2] == "b" then
                    Score:set("0 - 1")
                    WColor:set(DrawColor)
                    BColor:set(WinColor)
                end

                Desc:set("by resignation");
            elseif StatSplit[1] == "draw" then
                Title:set("Draw");
                Desc:set("by " .. tostring(StatSplit[2]))
                Score:set("½ - ½")
                WColor:set(DrawColor)
                BColor:set(DrawColor)
            elseif StatSplit[1] == "timeout" then
                if Board.White == game.Players.LocalPlayer and StatSplit[2] == "w" then
                    Title:set("You Win!")
                elseif Board.Black == game.Players.LocalPlayer and StatSplit[2] == "b" then
                    Title:set("You Win!")
                elseif StatSplit[2] == "w" then
                    Title:set("White Wins")
                elseif StatSplit[2] == "b" then
                    Title:set("Black Wins")
                end

                if StatSplit[2] == "w" then
                    Score:set("1 - 0")
                    WColor:set(WinColor)
                    BColor:set(DrawColor)
                elseif StatSplit[2] == "b" then
                    Score:set("0 - 1")
                    WColor:set(DrawColor)
                    BColor:set(WinColor)
                end

                Desc:set("by timeout");
            end

            WImage:set(game.Players:GetUserThumbnailAsync(Board.White.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150));
            BImage:set(game.Players:GetUserThumbnailAsync(Board.Black.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150));
        end
    end)
end

function Module.Ui()
    return New "Frame" {
        AnchorPoint = Vector2.new(0.5,0.5);
        BackgroundColor3 = Color3.new(0,0,0);
        BackgroundTransparency = 0.2;
        Position = Tween(Computed(function()
            if Module.Visible:get() == true then
                return UDim2.new(0.5,0,0.5,0)
            else
                return UDim2.new(0.5,0,-2.5,0)
            end
        end),TweenInfo.new(0.4));
        Size = UDim2.new(0.4,0,0.3,0);
        ZIndex = 200;

        [Children] = {
            New "UICorner" {
                CornerRadius = UDim.new(0,12);
            };

            -- Main Text
            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSansBold;
                Size = UDim2.new(1,0,0.3,0);
                Text = Title;
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                ZIndex = 201;
            };

            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSans;
                Position = UDim2.new(0,0,0.25,0);
                Size = UDim2.new(1,0,0.15,0);
                Text = Desc;
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                TextTransparency = 0.4;
                ZIndex = 201;
            };

            New "TextLabel" {
                BackgroundTransparency = 1;
                Font = Enum.Font.SourceSans;
                Position = UDim2.new(0.43,0,0.62,0);
                Size = UDim2.new(0.13,0,0.15,0);
                Text = Score;
                TextColor3 = Color3.new(1,1,1);
                TextScaled = true;
                TextTransparency = 0.4;
                ZIndex = 201;
            };

            New "ImageLabel" {
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Position = UDim2.new(0.065,0,0.45,0);
                Size = UDim2.new(0.35,0,0.467,0);
                Image = WImage;
                [Children] = New "UIStroke" {
                    Thickness = 3;
                    Color = WColor;
                };
                ZIndex = 201;
            };

            New "ImageLabel" {
                BackgroundColor3 = Color3.fromRGB(46,46,46);
                Position = UDim2.new(0.575,0,0.45,0);
                Size = UDim2.new(0.35,0,0.467,0);
                Image = BImage;
                [Children] = New "UIStroke" {
                    Thickness = 3;
                    Color = BColor;
                };
                ZIndex = 201;
            };
        }
    }
end

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if Module.Visible:get() == true and CooldownTimer <= os.time() then
            Module.Visible:set(false)
        end
    end
end)

return Module
