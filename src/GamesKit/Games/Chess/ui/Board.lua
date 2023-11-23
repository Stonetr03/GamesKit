-- Stonetr03

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Signal"))
local ClientCore = require(script.Parent:WaitForChild("clientcore"))
local UserInputService = game:GetService("UserInputService")

local Pieces = require(script.Parent:WaitForChild("Pieces"))
local Modifiers = require(script.Parent:WaitForChild("MoveModifier"))
local GameOver = require(script.Parent:WaitForChild("GameOver"))
local Letters = require(script.Parent:WaitForChild("Letters"))
local Clocks = require(script.Parent:WaitForChild("Clocks"))
local Dots = require(script.Parent:WaitForChild("Dots"))
local Highlights = require(script.Parent:WaitForChild("Highlights"))
local Arrows = require(script.Parent:WaitForChild("Arrows"))
local Annotations = require(script.Parent:WaitForChild("Annotation"))
local Resize = require(script.Parent:WaitForChild("Resize"))
local Settings = require(script.Parent:WaitForChild("Settings"))

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Event = Fusion.OnEvent

local Module = {
    ActiveGame = nil;
    ActiveBoard = nil;
    RenderingBoard = nil;
    BoardFlipped = nil;
    MakeMove = nil;

    ClearPremove = nil;
    SetPremove = nil;
}

local BoardAbsSize = Value()
local BoardAbsPos = Value()

Annotations.BoardAbsSize = BoardAbsSize;
Annotations.BoardAbsPos = BoardAbsPos;

local PieceColors = {
    w = {"R","N","B","Q","K","P"};
    b = {"r","n","b","q","k","p"};
}

local MouseButtonSignal = Signal.new()
local PromoteSignal = Signal.new()

local PromoteOffset = Value(0)
local PromoteVis = Value(false)
local PromotePosition = Value(UDim2.new(0,0,0,0))
local RightClickDown = ""

MouseButtonSignal:Connect(function()
    if PromoteVis:get() == true then
        PromoteSignal:Fire("")
        task.wait()
        PromoteVis:set(false)
    end
    Dots.RenderingDots:set({
        Callback = nil;
        ToRender = {};
    })
    Highlights:RemoveClickHighlight()
end);

function PromoteUi()
    return New "Frame" {
        BackgroundColor3 = Color3.fromRGB(162,162,162);
        BorderColor3 = Color3.fromRGB(27,42,53);
        BorderMode = Enum.BorderMode.Outline;
        BorderSizePixel = 5;
        Size = UDim2.new(0.125,0,4 * 0.125,0);
        ZIndex = 101;
        Visible = PromoteVis;
        Position = PromotePosition;
        AnchorPoint = Computed(function()
            if PromotePosition:get().Y.Scale == 0.875 then
                return Vector2.new(0,0.75);
            end
            return Vector2.new(0,0)
        end);

        [Children] = {
            New "ImageButton" {
                BackgroundTransparency = 1;
                BackgroundColor3 = Color3.new(0,0,0);
                Image = Pieces.ImageId;
                ImageRectOffset = Computed(function()
                    return Vector2.new(Pieces.Q.X,PromoteOffset:get());
                end);
                ImageRectSize = Vector2.new(175,175);
                Size = UDim2.new(1,0,0.25,0);
                Position = Computed(function()
                    if PromotePosition:get().Y.Scale == 0.875 then
                        return UDim2.new(0,0,0.75,0);
                    end
                    return UDim2.new(0,0,0,0)
                end);
                [Event "MouseButton1Down"] = function()
                    PromoteSignal:Fire("Q")
                end;
                ZIndex = 102;
            };
            New "ImageButton" {
                BackgroundTransparency = 0.8;
                BackgroundColor3 = Color3.new(0,0,0);
                Image = Pieces.ImageId;
                ImageRectOffset = Computed(function()
                    return Vector2.new(Pieces.N.X,PromoteOffset:get());
                end);
                ImageRectSize = Vector2.new(175,175);
                Size = UDim2.new(1,0,0.25,0);
                Position = Computed(function()
                    if PromotePosition:get().Y.Scale == 0.875 then
                        return UDim2.new(0,0,0.5,0);
                    end
                    return UDim2.new(0,0,0.25,0)
                end);
                [Event "MouseButton1Down"] = function()
                    PromoteSignal:Fire("N")
                end;
                ZIndex = 102;
            };
            New "ImageButton" {
                BackgroundTransparency = 1;
                BackgroundColor3 = Color3.new(0,0,0);
                Image = Pieces.ImageId;
                ImageRectOffset = Computed(function()
                    return Vector2.new(Pieces.R.X,PromoteOffset:get());
                end);
                ImageRectSize = Vector2.new(175,175);
                Size = UDim2.new(1,0,0.25,0);
                Position = Computed(function()
                    if PromotePosition:get().Y.Scale == 0.875 then
                        return UDim2.new(0,0,0.25,0);
                    end
                    return UDim2.new(0,0,0.5,0)
                end);
                [Event "MouseButton1Down"] = function()
                    PromoteSignal:Fire("R")
                end;
                ZIndex = 102;
            };
            New "ImageButton" {
                BackgroundTransparency = 0.8;
                BackgroundColor3 = Color3.new(0,0,0);
                Image = Pieces.ImageId;
                ImageRectOffset = Computed(function()
                    return Vector2.new(Pieces.B.X,PromoteOffset:get());
                end);
                ImageRectSize = Vector2.new(175,175);
                Size = UDim2.new(1,0,0.25,0);
                Position = Computed(function()
                    if PromotePosition:get().Y.Scale == 0.875 then
                        return UDim2.new(0,0,0,0);
                    end
                    return UDim2.new(0,0,0.75,0)
                end);
                [Event "MouseButton1Down"] = function()
                    PromoteSignal:Fire("B")
                end;
                ZIndex = 102;
            }
        }
    }
end

function RenderBoardBG()
    local Squares = {}

    local color = true
    for i = 0,7,1 do
        for o = 0,7,1 do
            local Bgcolor = Pieces.BoardWColor
            if color == true then
                local Ui = New "Frame" {
                    BackgroundColor3 = Bgcolor;
                    Size = UDim2.new(0.125,0,0.125);
                    Position = UDim2.new(0.125 * i,0,0.125 * o,0);
                    ZIndex = 6;
                }
                table.insert(Squares,Ui)
            end

            color = not color
        end
        color = not color
    end

    return Squares
end

local Flipped = {
    [1] = 8;
    [2] = 7;
    [3] = 6;
    [4] = 5;
    [5] = 4;
    [6] = 3;
    [7] = 2;
    [8] = 1;
}
function GetXPos(y)
    if Module.BoardFlipped:get() == false then
        return y
    end
    return Flipped[y]
end
function GetYPos(y)
    if Module.BoardFlipped:get() == true then
        return y
    end
    return Flipped[y]
end

-- Get Square From Position
local FileNumToTxt = {
    [1] = "a";
    [2] = "b";
    [3] = "c";
    [4] = "d";
    [5] = "e";
    [6] = "f";
    [7] = "g";
    [8] = "h";
}
local FileTxtToNum = {
    ["a"] = 1;
    ["b"] = 2;
    ["c"] = 3;
    ["d"] = 4;
    ["e"] = 5;
    ["f"] = 6;
    ["g"] = 7;
    ["h"] = 8;
}
function GetPosition(Code: string)
    local File = GetXPos(FileTxtToNum[string.sub(Code,1,1)]) - 1
    local Rank = GetYPos(tonumber(string.sub(Code,2,2))) - 1
    return UDim2.new(0.125 * File,0, 0.125 * Rank,0)
end
function GetNewSquare(Position: Vector2)
    if typeof(Position) ~= "Vector2" then
        return nil
    end
    local BoardSize = BoardAbsSize:get()
    local BoardPosition = BoardAbsPos:get()
    local PieceSize = BoardSize / 8

    for file = 0,7,1 do
        local PosX = BoardPosition.X + (file * PieceSize.X)
        local PosBX = BoardPosition.X + PieceSize.X + (file * PieceSize.X)
        if Position.X >= PosX and Position.X < PosBX then
            -- Found File
            for rank = 0,7,1 do
                local PosY = BoardPosition.Y + (rank * PieceSize.Y)
                local PosBY = BoardPosition.Y + PieceSize.Y + (rank * PieceSize.Y)
                if Position.Y >= PosY and Position.Y < PosBY then
                    -- Found Rank
                    local NewFile = FileNumToTxt[GetXPos(file + 1)]
                    local NewRank = GetYPos(rank + 1)
                    return NewFile .. tostring(NewRank)
                end
            end
        end
    end
    return nil
end

function Module.Ui()
    return New "Frame" {
        BackgroundTransparency = 1;
        Visible = Computed(function()
            if Module.ActiveGame:get() ~= "" then
                return true
            end
            return false
        end);
        Size = UDim2.new(1,0,1,0);
        [Children] = {
            Board = New "ImageButton" {
                AnchorPoint = Vector2.new(0,0.5);
                BackgroundColor3 = Pieces.BoardBColor;
                Position = UDim2.new(0,20,0.48,0);
                Size = Resize.BoardSize;
                SizeConstraint = Enum.SizeConstraint.RelativeXY;
                ZIndex = 5;
                [Fusion.Out "AbsoluteSize"] = BoardAbsSize;
                [Fusion.Out "AbsolutePosition"] = BoardAbsPos;
                [Children] = {
                    New "UIAspectRatioConstraint" {
                        DominantAxis = Enum.DominantAxis.Height
                    };
                    Squares = RenderBoardBG();
                    Promote = PromoteUi();
                    GameOver = GameOver.Ui();
                    Letters = Letters.Ui();
                    Clocks = Clocks.Ui();
                    Dots = Dots.Ui();
                    Highlights = Highlights.Ui();
                    Arrows = Arrows.Ui();
                    Annotations = Annotations.Ui();
                    Settings.Button();
                    Resize.Ui();
                    Pieces = Computed(function()
                        local NewPieces = {}
                        local board = Module.RenderingBoard:get()
                        if not board then
                            return {}
                        end
                        for rank = 1,8,1 do
                            for file = 1,8,1 do
                                if string.sub(board[rank],file,file) ~= " " then
                                    table.insert(NewPieces,{
                                        Piece = string.sub(board[rank],file,file);
                                        File = file;
                                        Rank = rank;
                                    })
                                end
                            end
                        end
                        local Ui = {}

                        for i,o in pairs(NewPieces) do
                            if Pieces[o.Piece] then
                                -- Button
                                local Position = Value(UDim2.new(0.125 * (GetXPos(o.File)-1),0,0.125 * (GetYPos(o.Rank)-1),0))
                                local PieceRef = Value()

                                -- Dragging
                                local dragging
                                local dragInput
                                local dragStart
                                local startPos
                                local mousePos
                                local mouseOffset

                                local OldSqr = FileNumToTxt[o.File] .. tostring(o.Rank)

                                local function update(input)
                                    local delta = input.Position - dragStart
                                    mousePos = Vector2.new(input.Position.X,input.Position.Y)
                                    Position:set(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + mouseOffset.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y + mouseOffset.Y))
                                end

                                local Con1
                                Con1 = UserInputService.InputChanged:Connect(function(input)
                                    if input == dragInput and dragging then
                                        update(input)
                                    end
                                end)

                                local function MakeMove(NewSqr)
                                    NewSqr = Modifiers(o.Piece,OldSqr,NewSqr)
                                    local Color = ""
                                    if Module.ActiveBoard:get().White and Module.ActiveBoard:get().White == game.Players.LocalPlayer then
                                        Color = "w"
                                    elseif Module.ActiveBoard:get().Black and Module.ActiveBoard:get().Black == game.Players.LocalPlayer then
                                        Color = "b"
                                    end
                                    if (Module.ActiveBoard:get().Turn == Color and ClientCore:CheckMove(Module.ActiveBoard:get(),OldSqr,NewSqr) == false) or PromoteVis:get() == true or Module.ActiveBoard:get().Status ~= "" then
                                        Position:set(startPos)
                                        return
                                    end
                                    -- Make sure its your piece and not opponants piece
                                    if Module.ActiveBoard:get().White and Module.ActiveBoard:get().White == game.Players.LocalPlayer then
                                        -- Is the w player
                                        if table.find(PieceColors.w,o.Piece) then
                                            -- Can Move
                                            Position:set(GetPosition(NewSqr))
                                            if NewSqr ~= OldSqr then
                                                -- Moved Piece
                                                if Module.ActiveBoard:get().Turn == "w" then
                                                    -- Make Move
                                                    -- Check if premoves first
                                                    local ExtraCode = ""
                                                    if o.Piece == "P" and tonumber(string.sub(NewSqr,2,2)) == 8 then
                                                        -- Promote
                                                        task.wait()
                                                        PromoteVis:set(true)
                                                        PromoteOffset:set(0)
                                                        PromotePosition:set(Position:get())
                                                        local Yield = false
                                                        PromoteSignal:Once(function(Piece)
                                                            ExtraCode = Piece
                                                            Yield = true
                                                        end)
                                                        repeat
                                                            task.wait()
                                                        until Yield == true
                                                        if ExtraCode == "" then
                                                            Position:set(startPos)
                                                            return
                                                        end
                                                    end
                                                    if Module.MakeMove(OldSqr,NewSqr,ExtraCode) == false then
                                                        Position:set(startPos)
                                                    else
                                                        OldSqr = NewSqr
                                                        Dots.RenderingDots:set({
                                                            Callback = nil;
                                                            ToRender = {};
                                                        })
                                                        Highlights:RemoveClickHighlight()
                                                    end
                                                else
                                                    -- Premove
                                                    local ExtraCode = ""
                                                    if o.Piece == "P" and tonumber(string.sub(NewSqr,2,2)) == 8 then
                                                        -- Promote
                                                        task.wait()
                                                        PromoteVis:set(true)
                                                        PromoteOffset:set(0)
                                                        PromotePosition:set(Position:get())
                                                        local Yield = false
                                                        PromoteSignal:Once(function(Piece)
                                                            ExtraCode = Piece
                                                            Yield = true
                                                        end)
                                                        repeat
                                                            task.wait()
                                                        until Yield == true
                                                        if ExtraCode == "" then
                                                            Position:set(startPos)
                                                            Dots.RenderingDots:set({
                                                                Callback = nil;
                                                                ToRender = {};
                                                            })
                                                            Highlights:RemoveClickHighlight()
                                                            return
                                                        end
                                                    end
                                                    -- Premove
                                                    Highlights:SetPremoveHighlight(NewSqr,OldSqr)
                                                    Module.SetPremove(OldSqr,NewSqr,ExtraCode,function()
                                                        Position:set(startPos)
                                                        Highlights:RemovePremoveHighlight()
                                                    end)
                                                    --Position:set(startPos)
                                                    Dots.RenderingDots:set({
                                                        Callback = nil;
                                                        ToRender = {};
                                                    })
                                                    Highlights:RemoveClickHighlight()
                                                end
                                            end
                                        else
                                            Position:set(startPos)
                                        end
                                    elseif Module.ActiveBoard:get().Black and Module.ActiveBoard:get().Black == game.Players.LocalPlayer then
                                        -- Is the b player
                                        if table.find(PieceColors.b,o.Piece) then
                                            -- Can Move
                                            Position:set(GetPosition(NewSqr))
                                            if NewSqr ~= OldSqr then
                                                -- Moved Piece
                                                if Module.ActiveBoard:get().Turn == "b" then
                                                    -- Make Move
                                                    -- Check if premoves first
                                                    local ExtraCode = ""
                                                    if o.Piece == "p" and tonumber(string.sub(NewSqr,2,2)) == 1 then
                                                        -- Promote
                                                        task.wait()
                                                        PromoteVis:set(true)
                                                        PromoteOffset:set(175)
                                                        PromotePosition:set(Position:get())
                                                        local Yield = false
                                                        PromoteSignal:Once(function(Piece)
                                                            ExtraCode = Piece
                                                            Yield = true
                                                        end)
                                                        repeat
                                                            task.wait()
                                                        until Yield == true
                                                        if ExtraCode == "" then
                                                            Position:set(startPos)
                                                            return
                                                        end
                                                    end
                                                    if Module.MakeMove(OldSqr,NewSqr,ExtraCode) == false then
                                                        Position:set(startPos)
                                                    else
                                                        OldSqr = NewSqr
                                                        Dots.RenderingDots:set({
                                                            Callback = nil;
                                                            ToRender = {};
                                                        })
                                                        Highlights:RemoveClickHighlight()
                                                    end
                                                else
                                                    -- Premove
                                                    local ExtraCode = ""
                                                    if o.Piece == "p" and tonumber(string.sub(NewSqr,2,2)) == 1 then
                                                        -- Promote
                                                        task.wait()
                                                        PromoteVis:set(true)
                                                        PromoteOffset:set(175)
                                                        PromotePosition:set(Position:get())
                                                        local Yield = false
                                                        PromoteSignal:Once(function(Piece)
                                                            ExtraCode = Piece
                                                            Yield = true
                                                        end)
                                                        repeat
                                                            task.wait()
                                                        until Yield == true
                                                        if ExtraCode == "" then
                                                            Position:set(startPos)
                                                            Dots.RenderingDots:set({
                                                                Callback = nil;
                                                                ToRender = {};
                                                            })
                                                            Highlights:RemoveClickHighlight()
                                                            return
                                                        end
                                                    end
                                                    -- Premove
                                                    Highlights:SetPremoveHighlight(NewSqr,OldSqr)
                                                    Module.SetPremove(OldSqr,NewSqr,ExtraCode,function()
                                                        Position:set(startPos)
                                                        Highlights:RemovePremoveHighlight()
                                                    end)
                                                    --Position:set(startPos)
                                                    Dots.RenderingDots:set({
                                                        Callback = nil;
                                                        ToRender = {};
                                                    })
                                                    Highlights:RemoveClickHighlight()
                                                end
                                            end
                                        else
                                            Position:set(startPos)
                                        end
                                    else
                                        Position:set(startPos)
                                    end
                                end

                                local inCheck = false
                                local sqrSize = UDim2.new(0.125,0,0.125,0);
                                local newPos = Position:get()
                                if o.Piece == "K" then
                                    if ClientCore:CheckifCheck(Module.ActiveBoard:get(),OldSqr,"w") == true then
                                        inCheck = true
                                        sqrSize = UDim2.new(1,0,1,0)
                                        Position:set(UDim2.new(0,0,0,0))
                                    end
                                elseif o.Piece == "k" then
                                    if ClientCore:CheckifCheck(Module.ActiveBoard:get(),OldSqr,"b") == true then
                                        inCheck = true
                                        sqrSize = UDim2.new(1,0,1,0)
                                        Position:set(UDim2.new(0,0,0,0))
                                    end
                                end

                                local NewUi = New "ImageButton" {
                                    Name = o.Piece;
                                    BackgroundTransparency = 1;
                                    Size = sqrSize;
                                    Position = Position;
                                    Image = Pieces.ImageId;
                                    ImageRectSize = Vector2.new(175, 175);
                                    ImageRectOffset = Pieces[o.Piece];
                                    ZIndex = 9;
                                    [Fusion.Ref] = PieceRef;
                                    [Fusion.Cleanup] = {
                                        Con1;
                                        Position;
                                        PieceRef;
                                    };

                                    -- Dots
                                    [Event "MouseButton1Down"] = function()
                                        if (Module.ActiveBoard:get().White and Module.ActiveBoard:get().White == game.Players.LocalPlayer and table.find(PieceColors.w,o.Piece)) or (Module.ActiveBoard:get().Black and Module.ActiveBoard:get().Black == game.Players.LocalPlayer and table.find(PieceColors.b,o.Piece)) then
                                            task.wait()
                                            Dots.RenderingDots:set({
                                                Callback = function(NewSqr)
                                                    MakeMove(NewSqr)
                                                end;
                                                ToRender = ClientCore:GetLegalMoves(Module.ActiveBoard:get(),FileNumToTxt[o.File] .. tostring(o.Rank),true);
                                            })
                                            Highlights:SetClickHighlight(FileNumToTxt[o.File] .. tostring(o.Rank))
                                        end
                                    end;

                                    -- Drag
                                    [Event "InputBegan"] = function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch and PromoteVis:get() ~= true then
                                            dragging = true
                                            dragStart = input.Position
                                            startPos = Position:get()
                                            mousePos = Vector2.new(input.Position.X,input.Position.Y)

                                            -- Offset
                                            mouseOffset = Vector2.new( input.Position.X - (PieceRef:get().AbsolutePosition.X + (PieceRef:get().AbsoluteSize.X / 2)), input.Position.Y -  (PieceRef:get().AbsolutePosition.Y + (PieceRef:get().AbsoluteSize.Y / 2)) )

                                            local con
                                            con = input.Changed:Connect(function()
                                                if input.UserInputState == Enum.UserInputState.End then
                                                    dragging = false
                                                    -- Cleanup
                                                    if con then
                                                        con:Disconnect()
                                                        con = nil;
                                                    end
                                                    -- Get Nearest Square
                                                    local NewSqr = GetNewSquare(mousePos)
                                                    if NewSqr then
                                                        MakeMove(NewSqr)
                                                    else
                                                        Position:set(startPos)
                                                    end
                                                end
                                            end)
                                        end
                                    end;
                                    [Event "InputChanged"] = function(input)
                                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                            dragInput = input
                                        end
                                    end;
                                };

                                if inCheck == true then
                                    Ui[i] = New "ImageLabel" {
                                        Name = o.Piece;
                                        BackgroundTransparency = 1;
                                        Size = UDim2.new(0.125,0,0.125,0);
                                        Position = newPos;
                                        ZIndex = 8;
                                        Image = "rbxassetid://14747375562";
                                        ImageColor3 = Color3.new(1,0,0);
                                        [Children] = NewUi;
                                    }
                                else
                                    Ui[i] = NewUi
                                end
                            end
                        end

                        return Ui
                    end,Fusion.cleanup)
                }
            };
        }
    }
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MouseButtonSignal:Fire()
        Highlights:RemoveAll()
        Arrows.Rendering:set({})
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        -- Highlight / Arrows
        if typeof(Module.ClearPremove) == "function" then
            Module.ClearPremove()
        end
        if Module.ActiveGame:get() ~= "" then
            local NewSqr = GetNewSquare(Vector2.new(input.Position.X,input.Position.Y))
            if NewSqr then
                RightClickDown = NewSqr
            end
        end
    end
    if input.UserInputType == Enum.UserInputType.Touch then
        Module.ClearPremove()
    end
end)

-- Highlights / Arrows
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if RightClickDown ~= "" then
            local NewSqr = GetNewSquare(Vector2.new(input.Position.X,input.Position.Y))
            if NewSqr then
                if RightClickDown == NewSqr then
                    -- Highlight
                    local Color = "Red"
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) then
                        Color = "Blue"
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                        Color = "Orange"
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                        Color = "Green"
                    end
                    local render = Highlights.Rendering:get()
                    if render[NewSqr] == Color then
                        -- Remove Highlight
                        Highlights:RemoveHighlight(NewSqr)
                    else
                        -- New Highlight
                        render[NewSqr] = Color;
                        Highlights.Rendering:set(render);
                    end
                else
                    -- Arrow
                    local Color = "Orange"
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) then
                        Color = "Blue"
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                        Color = "Red"
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                        Color = "Green"
                    end
                    local o = Arrows:GetArrow(RightClickDown,NewSqr)
                    if o and o.C == Color then
                        -- Remove Arrow
                        Arrows:RemoveArrow(RightClickDown,NewSqr)
                    elseif o then
                        Arrows:RemoveArrow(RightClickDown,NewSqr)
                        o.C = Color
                        local render = Arrows.Rendering:get()
                        table.insert(render,o)
                        Arrows.Rendering:set(render);
                    else
                        local render = Arrows.Rendering:get()
                        table.insert(render,{
                            P1 = RightClickDown;
                            P2 = NewSqr;
                            C = Color;
                        })
                        Arrows.Rendering:set(render);
                    end
                end
            end
        end
        RightClickDown = ""
    end
end)

return Module
