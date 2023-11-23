-- Stonetr03

local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local HowTo = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("GamesKit"):WaitForChild("HowTo"))
local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))
local Picker = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("GamesKit"):WaitForChild("Chess_Picker"))
local ClientCore = require(script:WaitForChild("clientcore"))
local tab = require(script:WaitForChild("tab"))
local GuiService = game:GetService("GuiService")

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value

local Board = require(script:WaitForChild("Board"))
local GameOver = require(script:WaitForChild("GameOver"))
local Letters = require(script:WaitForChild("Letters"))
local Clocks = require(script:WaitForChild("Clocks"))
local Dots = require(script:WaitForChild("Dots"))
local Highlights = require(script:WaitForChild("Highlights"))
local Arrows = require(script:WaitForChild("Arrows"))
local Annotations = require(script:WaitForChild("Annotation"))
local Close = require(script:WaitForChild("Close"))
local Settings = require(script:WaitForChild("Settings"));
local Resize = require(script:WaitForChild("Resize"));

-- Values
local ActiveGame = Value("")
local ActiveBoard = Value({})
local RenderingBoard = Value({
    [1] = "        ";
    [2] = "        ";
    [3] = "        ";
    [4] = "        ";
    [5] = "        ";
    [6] = "        ";
    [7] = "        ";
    [8] = "        ";
})
local BoardFlipped = Value(false)
local Premoves = nil

Board.ActiveGame = ActiveGame
Board.ActiveBoard = ActiveBoard
Board.RenderingBoard = RenderingBoard
Board.BoardFlipped = BoardFlipped

GameOver.ActiveBoard = ActiveBoard
local LastStatus = ""
GameOver:init()

Letters.BoardFlipped = BoardFlipped

Clocks.ActiveBoard = ActiveBoard;
Clocks.BoardFlipped = BoardFlipped;
Clocks:init()

Dots.BoardFlipped = BoardFlipped;
Highlights.BoardFlipped = BoardFlipped;
Arrows.BoardFlipped = BoardFlipped;

Annotations.BoardFlipped = BoardFlipped;
Annotations.ActiveBoard = ActiveBoard;
Annotations:init()

Close.ActiveBoard = ActiveBoard;
Close.ActiveGame = ActiveGame;

-- Ui
local Ui = New "Frame" {
    Size = UDim2.new(1,0,1,0);
    BackgroundTransparency = 1;
    ClipsDescendants = true;
    [Fusion.Out "AbsoluteSize"] = Annotations.ScreenGuiSize;
    [Fusion.Out "AbsolutePosition"] = Annotations.ScreenGuiPos;
    [Children] = {
        Background = New "Frame" {
            Size = UDim2.new(1,0,1,0);
            BackgroundColor3 = Color3.fromRGB(36,36,36);
            ZIndex = 1;
        };
        Board = Board.Ui();
        Close = Close.Ui();
        Settings.Ui();
    };
}
local Window = Api:CreateWindow({
    Size = Vector2.new(250,250);
    Title = "Chess";
    Position = UDim2.new(0.5,-250/2,0.5,-250/2);
    Resizeable = true;
    ResizeableMinimum = Vector2.new(200,200);
    Buttons = {
        [1] = {
            Text = "?";
            Callback = function()
                HowTo:ShowGui("Chess")
            end
        };
    };
},Ui)

Window.OnClose:Connect(function()
    task.wait()
    if ActiveGame:get() ~= "" then
        if ActiveBoard:get().Status == "" then
            Window.SetVis(true);
        else
            Close.Exit()
        end
    end
end)

local FullScreen = false
local LastPos = UDim2.new(0,0,0,0)
local LastSize = UDim2.new(0,0,0,0)
Resize.Fullscreen:Connect(function()
    if FullScreen == false then
        FullScreen = true
        LastPos = Annotations.ScreenGuiPos:get()
        LastSize = Annotations.ScreenGuiSize:get()
        local Inset = GuiService.TopbarInset
        local ViewportSize = game.Workspace.CurrentCamera.ViewportSize
        Window.SetPosition(UDim2.new(0,1,0,1 - Inset.Max.Y))
        Window.SetSize(Vector2.new(ViewportSize.X-2,ViewportSize.Y-23))
    else
        FullScreen = false
        Window.SetPosition(UDim2.new(0,LastPos.X,0,LastPos.Y-21))
        Window.SetSize(Vector2.new(LastSize.X,LastSize.Y))
    end
end)

-- Color Picker
local ColorPick = Picker.New(Ui,game.Players.LocalPlayer:GetMouse(),{
    Draggable = false;
    Position = UDim2.new(0.5,0,0.5,0);
})
ColorPick.Instance.Parent.ZIndex = 300;
ColorPick.Instance.Parent.Visible = false;
Settings.Picker = ColorPick
Settings:Init()

-- Game Update Events
Api:OnEvent("GamesKit-Chess-UpdateGame",function(Hash,Moves,Newboard)
    if ActiveGame:get() == Hash then
        if Premoves ~= nil then
            -- Run Premove
            if typeof(Premoves) == "table" and ((Newboard.Turn == "w" and Newboard.White == game.Players.LocalPlayer) or (Newboard.Turn == "b" and Newboard.Black == game.Players.LocalPlayer)) and ClientCore:CheckMove(Newboard,Premoves[1],Premoves[2]) == true then
                -- Send Move
                task.spawn(function()
                    Board.MakeMove(Premoves[1],Premoves[2],Premoves[3])
                end)
            end
            Board.ClearPremove();
        end
        ActiveBoard:set(Newboard);
        RenderingBoard:set(Newboard.Board)
        if Newboard.Status then
            if Newboard.Status ~= "" and LastStatus == "" then
                GameOver.Visible:set(true);
            elseif Newboard.Status == "" then
                GameOver.Visible:set(false);
            end
            LastStatus = Newboard.Status
        end
        Highlights:SetMoveHighlight(Moves)
    end
end)
Api:OnEvent("GamesKit-Chess-DrawUpdate",function(Hash)
    if ActiveGame:get() == Hash then
        Annotations.Confirmation:set(3)
    end
end)

-- Make Move
Board.MakeMove = function(Sqr,Move,Promote)
    return Api:Invoke("GamesKit-Chess:MakeMove",ActiveGame:get(),Sqr,Move,Promote)
end

Annotations.Resign = function()
    if ActiveGame:get() ~= "" then
        Api:Invoke("GamesKit-Chess:Resign",ActiveGame:get())
    end
end
Annotations.Draw = function(v)
    if ActiveGame:get() ~= "" then
        Api:Invoke("GamesKit-Chess:Draw",ActiveGame:get(),v)
    end
end

-- Stop Listening
Close.Exit = function()
    Api:Invoke("GamesKit-Chess:ListenHash",ActiveGame:get(),false)
    Window.unmount()
    script:Destroy()
end

-- Settings
local ValidSettings = {
    [1] = "standard";
    [2] = "caliente";
    [3] = "california";
    [4] = "cardinal";
    [5] = "cburnett";
    [6] = "disguised";
    [7] = "fresca";
    [8] = "gioco";
    [9] = "kiwen-suwi";
    [10] = "kosal";
    [11] = "letter";
    [12] = "libra";
    [13] = "maestro";
    [14] = "merida";
    [15] = "mono";
    [16] = "mpchess";
    [17] = "pirouetti";
    [18] = "pixel";
    [19] = "shapes";
    [20] = "staunty";
    [21] = "tatiana";
}
function checkHex(str)
    -- Check if the string starts with "#" and is exactly 7 characters long
    if type(str) == "string" and str:match("^%x%x%x%x%x%x$") then
        return true
    else
        return false
    end
end
Api:SetSettingModifier("Piece",{Text = "Pieces",Check = function(v)
    if table.find(ValidSettings,v) then
        return v
    end
    return Api.Settings.Chess.Piece
end,Type = "cycle",Value = ValidSettings},"Chess")
Api:SetSettingModifier("WColor",{Text = "Light Square Color",Check = function(v)
    if checkHex(v) == true then
        return v
    end
    return Api.Settings.Chess.WColor
end,Type = "input"},"Chess")
Api:SetSettingModifier("BColor",{Text = "Dark Square Color",Check = function(v)
    if checkHex(v) == true then
        return v
    end
    return Api.Settings.Chess.BColor
end,Type = "input"},"Chess")
Api:SetSetting("Piece","standard","Chess")
Api:SetSetting("WColor","f0d9b5","Chess")
Api:SetSetting("BColor","b58863","Chess")
Settings.Get = function()
    return {Piece = Api.Settings.Chess.Piece,WColor = Api.Settings.Chess.WColor,BColor = Api.Settings.Chess.BColor};
end;
Settings.Set = function(k,v)
    if k == "Piece" or k == "WColor" or k == "BColor" then
        Api:SetSetting(k,v,"Chess")
    end
end
Settings:Initset()

-- Premoves
Board.SetPremove = function(OldSqr,NewSqr,ExtraCode,Callback)
    Board.ClearPremove();
    Premoves = {OldSqr,NewSqr,ExtraCode,Callback}
end
Board.ClearPremove = function()
    if Premoves ~= nil then
        if typeof(Premoves[4]) == "function" then
            Premoves[4]()
        end
        Premoves = nil
    end
end


-- Start Game
LastStatus = ""
local Newboard = Api:Invoke("GamesKit-Chess:GetBoardFomHash",script:WaitForChild("hash").Value)
if typeof(Newboard) == "table" then
    ActiveBoard:set(Newboard)
    RenderingBoard:set(Newboard.Board)
    if Newboard.Black == game.Players.LocalPlayer then
        BoardFlipped:set(true)
    else
        BoardFlipped:set(false)
    end
    ActiveGame:set(script:WaitForChild("hash").Value)
    -- Cleanup
    Arrows.Rendering:set({});
    Dots.RenderingDots:set({
        Callback = nil;
        ToRender = {};
    });
    Highlights:RemoveClickHighlight();
    Highlights:RemoveMoveHighlight();
    Highlights:RemovePremoveHighlight();
    Highlights:RemoveAll();
    Board.ClearPremove();
end
