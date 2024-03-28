-- Stonetr03

local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local HowTo = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("GamesKit"):WaitForChild("HowTo"))
local tbl = require(script:WaitForChild("Table"));
local Images = require(script:WaitForChild("Images"));
local Mappings = require(script:WaitForChild("Mappings"));
local Settings = require(script:WaitForChild("Settings"));

local New = Fusion.New
local Value = Fusion.Value
local Tween = Fusion.Tween
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local Status = Value(1) --1:Playing, 2:GameOver
local SettingsVis = Value(false)
local StartTime = os.time()
local EndTime = 0;
local ActionName = "SolitaireInput" .. HttpService:GenerateGUID() -- ActionName for ContextActionService
local TimerText = Value("00:00:00")
local Moves = Value(0)

local ActiveInput = Value("Keyboard"); -- Keyboard, Drag
local KeyboardSelection = Value("00");
local KeyboardEditMode = Value(0); -- 0:not editing; 1:selecting; 2:moving
local KeyboardEditSelection = Value("");

local RefSize = {
    Piles = {Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0))};
    Cols = {Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0))}
}
local RefPosition = {
    Piles = {Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0))};
    Cols = {Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0)),Value(Vector2.new(0,0))}
}
-- Cards - Shuffle / Deal
local Deck = Value(tbl:Shuffle({"AS","2S","3S","4S","5S","6S","7S","8S","9S","TS","JS","QS","KS","AH","2H","3H","4H","5H","6H","7H","8H","9H","TH","JH","QH","KH","AD","2D","3D","4D","5D","6D","7D","8D","9D","TD","JD","QD","KD","AC","2C","3C","4C","5C","6C","7C","8C","9C","TC","JC","QC","KC"}))
local Discard = Value({})
local Piles = Value({{},{},{},{}}) -- /foundations
local Cols = Value({{{},{}},{{},{}},{{},{}},{{},{}},{{},{}},{{},{}},{{},{}}}); -- Shown, Hidden
for i = 1,7,1 do
    local tmpCol = table.clone(Cols:get())
    local tmpDeck = table.clone(Deck:get())
    table.insert(tmpCol[i][1],1,tmpDeck[1]);
    table.remove(tmpDeck,1);
    for _ = 1,i-1,1 do
        table.insert(tmpCol[i][2],1,tmpDeck[1]);
        table.remove(tmpDeck,1);
    end
    Deck:set(tmpDeck)
    Cols:set(tmpCol)
end

local Sorting = false
function AutoSort()
    if Sorting == true then
        return false;
    end
    Sorting = true
    local Indexes = {0,0,0,0} -- S,H,C,D
    local tmpPile = Piles:get()
    local Remaining = {1,2,3,4}
    -- Get Foundation Indexes / Suit
    for i = 1,4,1 do
        if #tmpPile[i] ~= 0 then
            table.remove(Remaining,table.find(Remaining,i))
            local str = string.sub(tmpPile[i][1],2,2)
            if str == "S" then
                Indexes[1] = i;
            elseif str == "H" then
                Indexes[2] = i;
            elseif str == "C" then
                Indexes[3] = i;
            elseif str == "D" then
                Indexes[4] = i;
            end
        end
    end
    -- Fill in Missing Indexes
    for i = 1,4,1 do
        if Indexes[i] == 0 and #Remaining ~= 0 then
            Indexes[i] = Remaining[1];
            table.remove(Remaining,1);
        end
    end

    local tmpCols = Cols:get()
    for i = 1,13,1 do
        for s = 1,4,1 do -- Suit
            for c = 1,7,1 do -- Col
                if #tmpCols[c][1] > 0 and string.sub(tmpCols[c][1][1],2,2) == Mappings:SuitToLetter(s) and string.sub(tmpCols[c][1][1],1,1) == Mappings:ToLetter(i) then
                    -- Is Same Suit and Card
                    table.insert(tmpPile[ Indexes[s] ],1,tmpCols[c][1][1])
                    table.remove(tmpCols[c][1],1)
                    Piles:set(tmpPile);
                    Cols:set(tmpCols);
                    Moves:set(Moves:get() + 1)
                    task.wait(0.2);
                end
            end
        end
    end
    Sorting = false;
end

function CheckWin(): boolean
    local tmp = Cols:get()
    for i = 1,7,1 do
        if #tmp[i][2] ~= 0 then
            return false;
        end
    end
    if #Discard:get() == 0 and #Deck:get() == 0 then
        return true
    end
    return false
end

function EndOfTurn()
    if CheckWin() == true then
        EndTime = os.time()
        Status:set(2)
        ActiveInput:set("KeyboardWin")
        KeyboardSelection:set("1")
        AutoSort();
    end
end

function GetDropZone(Position: Vector3): (number,number)
    for i = 1,4,1 do
        if Position.X >= RefPosition.Piles[i]:get().X and Position.Y >= RefPosition.Piles[i]:get().Y then
            -- Is within min bounds
            if Position.X <= RefPosition.Piles[i]:get().X + RefSize.Piles[i]:get().X and Position.Y <= RefPosition.Piles[i]:get().Y + RefSize.Piles[i]:get().Y then
                -- Is within max bounds
                return 1,i;
            end
        end
    end
    for i = 1,7,1 do
        if Position.X >= RefPosition.Cols[i]:get().X and Position.Y >= RefPosition.Cols[i]:get().Y then
            -- Is within min bounds
            if Position.X <= RefPosition.Cols[i]:get().X + RefSize.Cols[i]:get().X and Position.Y <= RefPosition.Cols[i]:get().Y + RefSize.Cols[i]:get().Y then
                -- Is within max bounds
                return 2,i;
            end
        end
    end
    return 0,0
end

function DiscardUi(): ImageButton
    local dragging
    local dragInput
    local dragStart
    local startPos

    local moved = false
    local Position = Value(UDim2.new(0.02*2 + 0.12*1,0,0.015,0))

    local function update(input)
        moved = true
        local delta = input.Position - dragStart
        Position:set(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
    end

    local toClean = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return New "ImageButton" {
        Size = UDim2.new(0.12,0,0.17,0);
        Position = Position;
        BackgroundTransparency = 1;
        Image = Computed(function()
            if #Discard:get() > 0 then
                return Images[Discard:get()[1]][Mappings:GetImage(Discard:get()[1])];
            end
            return Images["empty"][1];
        end);
        ImageRectSize = Vector2.new(200, 280);
        ImageRectOffset = Computed(function()
            if #Discard:get() > 0 then
                return Vector2.new(200*Images[Discard:get()[1]][2].X,280*Images[Discard:get()[1]][2].Y)
            end
            return Vector2.new(200*Images["empty"][2].X,280*Images["empty"][2].Y);
        end);
        ZIndex = 3;
        [Children] = {
            New "UICorner" {CornerRadius = UDim.new(0.05,0)};
            New "UIStroke" {
                Color = Computed(function()
                    if string.sub(KeyboardEditSelection:get(),1,2) == "01" and ActiveInput:get() == "Keyboard" then
                        return Color3.fromRGB(85, 255, 0);
                    end
                    return Color3.fromRGB(0,170,255)
                end);
                Thickness = 2;
                Enabled = Computed(function()
                    if (string.sub(KeyboardSelection:get(),1,2) == "01" or string.sub(KeyboardEditSelection:get(),1,2) == "01") and ActiveInput:get() == "Keyboard" then
                        return true
                    end
                    return false
                end);
            };
        };
        [Event "InputBegan"] = function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and ActiveInput:get() == "Drag" and #Discard:get() > 0 then
                dragging = true
                moved = false
                dragStart = input.Position
                startPos = Position:get()

                local con
                con = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        con:Disconnect()
                        if moved then
                            local a,b = GetDropZone(input.Position)
                            if a == 1 then
                                -- Move to pile/foundation
                                local tmpPile = Piles:get()
                                local tmpCard = Discard:get()
                                if string.sub(tmpCard[1],1,1) == "A" then
                                    if #tmpPile[b] == 0 then
                                        -- Can Move
                                        table.insert(tmpPile[b],1,tmpCard[1])
                                        table.remove(tmpCard,1)
                                        Piles:set(tmpPile)
                                        Discard:set(tmpCard)
                                        Moves:set(Moves:get() + 1)
                                    end
                                elseif #tmpPile[b] > 0 then
                                    -- Not Ace
                                    if string.sub(tmpCard[1],2,2) == string.sub(tmpPile[b][1],2,2) and string.sub(tmpCard[1],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpPile[b][1],1,1)) + 1) then
                                        -- Same Suit and Next Card
                                        table.insert(tmpPile[b],1,tmpCard[1])
                                        table.remove(tmpCard,1)
                                        Piles:set(tmpPile)
                                        Discard:set(tmpCard)
                                        Moves:set(Moves:get() + 1)
                                    end
                                end
                            elseif a == 2 then
                                -- Move to col/table
                                local tmpCard = Discard:get()
                                local tmpCol = Cols:get()
                                if #tmpCol[b][1] == 0 then
                                    if string.sub(tmpCard[1],1,1) == "K" and #tmpCol[b][2] == 0 then -- Needs to be King
                                        -- Is Empty
                                        table.insert(tmpCol[b][1],1,tmpCard[1])
                                        table.remove(tmpCard,1)
                                        Cols:set(tmpCol)
                                        Discard:set(tmpCard)
                                    end
                                elseif string.sub(tmpCard[1],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpCol[b][1][1],1,1)) - 1) and Mappings:IsOpposite(tmpCard[1],tmpCol[b][1][1]) then -- -1 number and Opposite Color
                                    table.insert(tmpCol[b][1],1,tmpCard[1])
                                    table.remove(tmpCard,1)
                                    Cols:set(tmpCol)
                                    Discard:set(tmpCard)
                                end
                            end
                        else
                            -- Clicked
                            -- Move card to Pile/Foundation
                            local tmpPile = Piles:get()
                            local tmpCard = Discard:get()
                            local found = false
                            for f = 1,4,1 do
                                if string.sub(tmpCard[1],1,1) == "A" then
                                    if #tmpPile[f] == 0 then
                                        -- Can Move
                                        table.insert(tmpPile[f],1,tmpCard[1])
                                        table.remove(tmpCard,1)
                                        Piles:set(tmpPile)
                                        Discard:set(tmpCard)
                                        found = true
                                        Moves:set(Moves:get() + 1)
                                        break
                                    end
                                elseif #tmpPile[f] > 0 then
                                    -- Not Ace
                                    if string.sub(tmpCard[1],2,2) == string.sub(tmpPile[f][1],2,2) and string.sub(tmpCard[1],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpPile[f][1],1,1)) + 1) then
                                        -- Same Suit and Next Card
                                        table.insert(tmpPile[f],1,tmpCard[1])
                                        table.remove(tmpCard,1)
                                        Piles:set(tmpPile)
                                        Discard:set(tmpCard)
                                        found = true
                                        Moves:set(Moves:get() + 1)
                                        break
                                    end
                                end
                            end
                            -- Move card to Table
                            local tmpCol = Cols:get()
                            if not found then
                                for c = 1,7,1 do
                                    if #tmpCol[c][1] == 0 then
                                        if string.sub(tmpCard[1],1,1) == "K" and #tmpCol[c][2] == 0 then -- Needs to be King
                                            -- Is Empty
                                            table.insert(tmpCol[c][1],1,tmpCard[1])
                                            table.remove(tmpCard,1)
                                            Cols:set(tmpCol)
                                            Discard:set(tmpCard)
                                            Moves:set(Moves:get() + 1)
                                            break
                                        end
                                    elseif string.sub(tmpCard[1],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpCol[c][1][1],1,1)) - 1) and Mappings:IsOpposite(tmpCard[1],tmpCol[c][1][1]) then -- -1 number and Opposite Color
                                        table.insert(tmpCol[c][1],1,tmpCard[1])
                                        table.remove(tmpCard,1)
                                        Cols:set(tmpCol)
                                        Discard:set(tmpCard)
                                        Moves:set(Moves:get() + 1)
                                        break
                                    end
                                end
                            end
                        end
                        EndOfTurn()
                        Position:set(startPos)
                    end
                end)
            end
        end;
        [Event "InputChanged"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end;
        [Fusion.Cleanup] = toClean;
    };
end

function Restart()
    repeat
        task.wait()
    until Sorting == false
    Discard:set({})
    Piles:set({{},{},{},{}})
    Cols:set({{{},{}},{{},{}},{{},{}},{{},{}},{{},{}},{{},{}},{{},{}}});
    Deck:set(tbl:Shuffle({"AS","2S","3S","4S","5S","6S","7S","8S","9S","TS","JS","QS","KS","AH","2H","3H","4H","5H","6H","7H","8H","9H","TH","JH","QH","KH","AD","2D","3D","4D","5D","6D","7D","8D","9D","TD","JD","QD","KD","AC","2C","3C","4C","5C","6C","7C","8C","9C","TC","JC","QC","KC"}));
    for i = 1,7,1 do
        local tmpCol = table.clone(Cols:get())
        local tmpDeck = table.clone(Deck:get())
        table.insert(tmpCol[i][1],1,tmpDeck[1]);
        table.remove(tmpDeck,1);
        for _ = 1,i-1,1 do
            table.insert(tmpCol[i][2],1,tmpDeck[1]);
            table.remove(tmpDeck,1);
        end
        Deck:set(tmpDeck)
        Cols:set(tmpCol)
    end;
    KeyboardSelection:set("00");
    KeyboardEditMode:set(0);
    KeyboardEditSelection:set("");
    Status:set(1);
    StartTime = os.time()
    EndTime = 0;
    Moves:set(0)
end

function PileUi(i)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local moved = false
    local Position = Value(UDim2.new(0.02*(3+i) + 0.12*(2+i),0,0.015,0))

    local function update(input)
        moved = true
        local delta = input.Position - dragStart
        Position:set(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
    end

    local toClean = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return New "ImageButton" {
        Size = UDim2.new(0.12,0,0.17,0);
        Position = Position;
        BackgroundTransparency = 1;
        Image = Computed(function()
            local Pile = Piles:get()[i]
            if #Pile > 0 then
                return Images[Pile[1]][Mappings:GetImage(Pile[1])];
            end
            return Images["empty"][1];
        end);
        ImageRectSize = Vector2.new(200, 280);
        ImageRectOffset = Computed(function()
            local Pile = Piles:get()[i]
            if #Pile > 0 then
                return Vector2.new(200*Images[Pile[1]][2].X,280*Images[Pile[1]][2].Y)
            end
            return Vector2.new(200*Images["empty"][2].X,280*Images["empty"][2].Y);
        end);
        ZIndex = 3;
        [Fusion.Out "AbsoluteSize"] = RefSize.Piles[i];
        [Fusion.Out "AbsolutePosition"] = RefPosition.Piles[i];
        [Children] = {
            New "UICorner" {CornerRadius = UDim.new(0.05,0)};
            New "UIStroke" {
                Color = Computed(function()
                    if string.sub(KeyboardEditSelection:get(),1,2) == "0" .. i+2 and ActiveInput:get() == "Keyboard" then
                        return Color3.fromRGB(85, 255, 0);
                    end
                    return Color3.fromRGB(0,170,255)
                end);
                Thickness = 2;
                Enabled = Computed(function()
                    if string.sub(KeyboardSelection:get(),1,2) == "0" .. tostring(i+2) and ActiveInput:get() == "Keyboard" then
                        return true
                    end
                    return false
                end);
            };
        };
        [Event "InputBegan"] = function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and ActiveInput:get() == "Drag" and #Piles:get()[i] > 0 then
                dragging = true
                moved = false
                dragStart = input.Position
                startPos = Position:get()

                local con
                con = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        con:Disconnect()
                        if moved then
                            local a,b = GetDropZone(input.Position)
                            if a == 1 then
                                local tmpPile = Piles:get()
                                if string.sub(tmpPile[i][1],1,1) == "A" then
                                    if #tmpPile[b] == 0 then
                                        -- Can Move
                                        table.insert(tmpPile[b],1,tmpPile[i][1])
                                        table.remove(tmpPile[i],1)
                                        Piles:set(tmpPile)
                                        Moves:set(Moves:get() + 1)
                                    end
                                end
                            elseif a == 2 then
                                local tmpPile = Piles:get()
                                local tmpCol = Cols:get()
                                if #tmpCol[b][1] == 0 then
                                    if string.sub(tmpPile[i][1],1,1) == "K" and #tmpCol[b][2] == 0 then -- Needs to be King
                                        -- Is Empty
                                        table.insert(tmpCol[b][1],1,tmpPile[i][1])
                                        table.remove(tmpPile[i],1)
                                        Cols:set(tmpCol)
                                        Piles:set(tmpPile)
                                        Moves:set(Moves:get() + 1)
                                    end
                                elseif string.sub(tmpPile[i][1],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpCol[b][1][1],1,1)) - 1) and Mappings:IsOpposite(tmpPile[i][1],tmpCol[b][1][1]) then -- -1 number and Opposite Color
                                    table.insert(tmpCol[b][1],1,tmpPile[i][1])
                                    table.remove(tmpPile[i],1)
                                    Cols:set(tmpCol)
                                    Piles:set(tmpPile)
                                    Moves:set(Moves:get() + 1)
                                end
                            end
                        else
                            -- Clicked
                            local tmpPile = Piles:get()
                            local found = false
                            -- Move Ace to other pile
                            if string.sub(tmpPile[i][1],1,1) == "A" then
                                for f = 1,4,1 do
                                    if #tmpPile[f] == 0 then
                                        -- Can Move
                                        table.insert(tmpPile[f],1,tmpPile[i][1])
                                        table.remove(tmpPile[i],1)
                                        Piles:set(tmpPile)
                                        found = true
                                        Moves:set(Moves:get() + 1)
                                        break
                                    end
                                end
                            end
                            -- Move card to Table
                            local tmpCol = Cols:get()
                            if not found then
                                for c = 1,7,1 do
                                    if #tmpCol[c][1] == 0 then
                                        if string.sub(tmpPile[i][1],1,1) == "K" and #tmpCol[c][2] == 0 then -- Needs to be King
                                            -- Is Empty
                                            table.insert(tmpCol[c][1],1,tmpPile[i][1])
                                            table.remove(tmpPile[i],1)
                                            Cols:set(tmpCol)
                                            Piles:set(tmpPile)
                                            Moves:set(Moves:get() + 1)
                                            break
                                        end
                                    elseif string.sub(tmpPile[i][1],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpCol[c][1][1],1,1)) - 1) and Mappings:IsOpposite(tmpPile[i][1],tmpCol[c][1][1]) then -- -1 number and Opposite Color
                                        table.insert(tmpCol[c][1],1,tmpPile[i][1])
                                        table.remove(tmpPile[i],1)
                                        Cols:set(tmpCol)
                                        Piles:set(tmpPile)
                                        Moves:set(Moves:get() + 1)
                                        break
                                    end
                                end
                            end
                        end
                        EndOfTurn()
                        Position:set(startPos)
                    end
                end)
            end
        end;
        [Event "InputChanged"] = function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end;
        [Fusion.Cleanup] = toClean;
    };
end

function ColUi(c)
    local Moving = Value(0);
    local Position = Value(UDim2.new(0,0,0,0));
    return New "Frame" {
        Size = UDim2.new(0.12,0,0.76,0);
        Position = UDim2.new(0.02 * c + (0.12 * (c-1)),0,0.22,0);
        BackgroundTransparency = 0.9;
        ZIndex = 3;
        [Fusion.Out "AbsoluteSize"] = RefSize.Cols[c];
        [Fusion.Out "AbsolutePosition"] = RefPosition.Cols[c];

        [Children] = {
            New "ImageLabel" {
                Size = UDim2.new(1,0,0.223,0);
                Position = UDim2.new(0,0,0,0);
                BackgroundTransparency = 1;
                Image = Images["empty"][1];
                ImageRectSize = Vector2.new(200, 280);
                ImageRectOffset = Vector2.new(200*Images["empty"][2].X,280*Images["empty"][2].Y);
                ZIndex = 3;
                [Children] = {
                    New "UICorner" {CornerRadius = UDim.new(0.05,0)};
                    New "UIStroke" {
                        Color = Color3.fromRGB(0,170,255);
                        Thickness = 2;
                        Enabled = Computed(function()
                            local tmp = Cols:get()[c]
                            if #tmp[1] == 0 and #tmp[2] == 0 and string.sub(KeyboardSelection:get(),1,2) == "1" .. tostring(c-1) and ActiveInput:get() == "Keyboard" then
                                return true
                            end
                            return false
                        end);
                    };
                }
            };
            -- Coverd
            Fusion.ForPairs(Computed(function()
                return Cols:get()[c][2]
            end),function(i,_)
                return i, New "ImageButton" {
                    Size = UDim2.new(1,0,0.223,0);
                    Position = UDim2.new(0,0,0.05 * (i-1),0);
                    BackgroundTransparency = 1;
                    Image = Images["B1"][1];
                    ImageRectSize = Vector2.new(200, 280);
                    ImageRectOffset = Vector2.new(200*Images["B1"][2].X,280*Images["B1"][2].Y);
                    ZIndex = 3+i;
                }
            end,Fusion.cleanup);
            -- Shown
            Fusion.ForPairs(Computed(function()
                return Cols:get()[c][1]
            end),function(i,o)
                local tmpCols1 = Cols:get()

                local dragging
                local dragInput
                local dragStart

                local moved = false

                local function update(input)
                    moved = true
                    local delta = input.Position - dragStart
                    Position:set(UDim2.new(0, delta.X, 0, delta.Y))
                end

                local toClean = UserInputService.InputChanged:Connect(function(input)
                    if input == dragInput and dragging then
                        update(input)
                    end
                end)
                return i, New "ImageButton" {
                    Size = UDim2.new(1,0,0.223,0);
                    Position = Computed(function()
                        if Moving:get() >= i then
                            return UDim2.new(0,0,0.05 * (#tmpCols1[c][2]+(#tmpCols1[c][1] - i)),0) + Position:get()
                        end
                        return UDim2.new(0,0,0.05 * (#tmpCols1[c][2]+(#tmpCols1[c][1] - i)),0)
                    end);
                    BackgroundTransparency = 1;
                    Image = Images[o][Mappings:GetImage(o)];
                    ImageRectSize = Vector2.new(200, 280);
                    ImageRectOffset = Vector2.new(200*Images[o][2].X,280*Images[o][2].Y);
                    ZIndex = 3+#tmpCols1[c][2]+(#tmpCols1[c][1]+1 - i);
                    [Children] = {
                        New "UICorner" {CornerRadius = UDim.new(0.05,0)};
                        New "UIStroke" {
                            Color = Computed(function()
                                if string.sub(KeyboardEditSelection:get(),1,2) == "1" .. tostring(c-1) and ActiveInput:get() == "Keyboard" then
                                    return Color3.fromRGB(85, 255, 0);
                                end
                                return Color3.fromRGB(0,170,255)
                            end);
                            Thickness = 2;
                            Enabled = Computed(function()
                                local KeyS = KeyboardSelection:get()
                                local KES = KeyboardEditSelection:get()
                                if ActiveInput:get() == "Keyboard" and ((string.sub(KeyS,1,2) == "1" .. tostring(c-1) and tonumber(string.sub(KeyS,3)) >= i) or (string.sub(KES,1,2) == "1" .. tostring(c-1) and tonumber(string.sub(KES,3)) >= i)) then
                                    return true
                                end
                                return false
                            end);
                        };
                    };
                    [Event "InputBegan"] = function(input)
                        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and ActiveInput:get() == "Drag"  then
                            dragging = true
                            moved = false
                            dragStart = input.Position
                            Moving:set(i)


                            local con
                            con = input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    dragging = false
                                    con:Disconnect()
                                    if moved then
                                        local a,b = GetDropZone(input.Position)
                                        if a == 1 then
                                            if i == 1 then
                                                local tmpPile = Piles:get()
                                                local tmpCols2 = Cols:get()
                                                if string.sub(tmpCols2[c][1][i],1,1) == "A" then
                                                    if #tmpPile[b] == 0 then
                                                        -- Can Move
                                                        table.insert(tmpPile[b],1,tmpCols2[c][1][1])
                                                        table.remove(tmpCols2[c][1],1)
                                                        if #tmpCols2[c][1] == 0 and #tmpCols2[c][2] > 0 then
                                                            table.insert(tmpCols2[c][1],1,tmpCols2[c][2][1])
                                                            table.remove(tmpCols2[c][2],1)
                                                        end
                                                        Piles:set(tmpPile)
                                                        Cols:set(tmpCols2)
                                                        Moves:set(Moves:get() + 1)
                                                    end
                                                elseif #tmpPile[b] > 0 then
                                                    -- Not Ace
                                                    if string.sub(tmpCols2[c][1][1],2,2) == string.sub(tmpPile[b][1],2,2) and string.sub(tmpCols2[c][1][1],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpPile[b][1],1,1)) + 1) then
                                                        -- Same Suit and Next Card
                                                        table.insert(tmpPile[b],1,tmpCols2[c][1][1])
                                                        table.remove(tmpCols2[c][1],1)
                                                        if #tmpCols2[c][1] == 0 and #tmpCols2[c][2] > 0 then
                                                            table.insert(tmpCols2[c][1],1,tmpCols2[c][2][1])
                                                            table.remove(tmpCols2[c][2],1)
                                                        end
                                                        Piles:set(tmpPile)
                                                        Cols:set(tmpCols2)
                                                        Moves:set(Moves:get() + 1)
                                                    end
                                                end
                                            end
                                        elseif a == 2 then
                                            local tmpCols2 = Cols:get()
                                            if #tmpCols2[b][1] == 0 then
                                                if string.sub(tmpCols2[c][1][i],1,1) == "K" and #tmpCols2[b][2] == 0 then
                                                    -- Can Move
                                                    for toMove = i,1,-1 do
                                                        table.insert(tmpCols2[b][1],1,tmpCols2[c][1][toMove])
                                                        table.remove(tmpCols2[c][1],toMove)
                                                    end
                                                    if #tmpCols2[c][1] == 0 and #tmpCols2[c][2] > 0 then
                                                        table.insert(tmpCols2[c][1],1,tmpCols2[c][2][1])
                                                        table.remove(tmpCols2[c][2],1)
                                                    end
                                                    Cols:set(tmpCols2)
                                                    Moves:set(Moves:get() + 1)
                                                end
                                            elseif string.sub(tmpCols2[c][1][i],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpCols2[b][1][1],1,1)) - 1) and Mappings:IsOpposite(tmpCols2[c][1][i],tmpCols2[b][1][1]) then -- -1 number and Opposite Color
                                                for toMove = i,1,-1 do
                                                    table.insert(tmpCols2[b][1],1,tmpCols2[c][1][toMove])
                                                    table.remove(tmpCols2[c][1],toMove)
                                                end
                                                if #tmpCols2[c][1] == 0 and #tmpCols2[c][2] > 0 then
                                                    table.insert(tmpCols2[c][1],1,tmpCols2[c][2][1])
                                                    table.remove(tmpCols2[c][2],1)
                                                end
                                                Cols:set(tmpCols2)
                                                Moves:set(Moves:get() + 1)
                                            end
                                        end
                                    else
                                        -- Clicked
                                        local tmpCols2 = Cols:get()
                                        local found = false
                                        if i == 1 then
                                            -- Can be moved to pile/foundation
                                            local tmpPile = Piles:get()
                                            for f = 1,4,1 do
                                                if string.sub(tmpCols2[c][1][i],1,1) == "A" then
                                                    if #tmpPile[f] == 0 then
                                                        -- Can Move
                                                        table.insert(tmpPile[f],1,tmpCols2[c][1][1])
                                                        table.remove(tmpCols2[c][1],1)
                                                        if #tmpCols2[c][1] == 0 and #tmpCols2[c][2] > 0 then
                                                            table.insert(tmpCols2[c][1],1,tmpCols2[c][2][1])
                                                            table.remove(tmpCols2[c][2],1)
                                                        end
                                                        Piles:set(tmpPile)
                                                        Cols:set(tmpCols2)
                                                        found = true
                                                        Moves:set(Moves:get() + 1)
                                                        break
                                                    end
                                                elseif #tmpPile[f] > 0 then
                                                    -- Not Ace
                                                    if string.sub(tmpCols2[c][1][1],2,2) == string.sub(tmpPile[f][1],2,2) and string.sub(tmpCols2[c][1][1],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpPile[f][1],1,1)) + 1) then
                                                        -- Same Suit and Next Card
                                                        table.insert(tmpPile[f],1,tmpCols2[c][1][1])
                                                        table.remove(tmpCols2[c][1],1)
                                                        if #tmpCols2[c][1] == 0 and #tmpCols2[c][2] > 0 then
                                                            table.insert(tmpCols2[c][1],1,tmpCols2[c][2][1])
                                                            table.remove(tmpCols2[c][2],1)
                                                        end
                                                        Piles:set(tmpPile)
                                                        Cols:set(tmpCols2)
                                                        found = true
                                                        Moves:set(Moves:get() + 1)
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                        -- Move to Table/Cols
                                        if not found then
                                            for f = 1,7,1 do
                                                if #tmpCols2[f][1] == 0 then
                                                    if string.sub(tmpCols2[c][1][i],1,1) == "K" and #tmpCols2[f][2] == 0 then
                                                        -- Can Move
                                                        for toMove = i,1,-1 do
                                                            table.insert(tmpCols2[f][1],1,tmpCols2[c][1][toMove])
                                                            table.remove(tmpCols2[c][1],toMove)
                                                        end
                                                        if #tmpCols2[c][1] == 0 and #tmpCols2[c][2] > 0 then
                                                            table.insert(tmpCols2[c][1],1,tmpCols2[c][2][1])
                                                            table.remove(tmpCols2[c][2],1)
                                                        end
                                                        Cols:set(tmpCols2)
                                                        Moves:set(Moves:get() + 1)
                                                        break
                                                    end
                                                elseif string.sub(tmpCols2[c][1][i],1,1) == Mappings:ToLetter(Mappings:ToNumber(string.sub(tmpCols2[f][1][1],1,1)) - 1) and Mappings:IsOpposite(tmpCols2[c][1][i],tmpCols2[f][1][1]) then -- -1 number and Opposite Color
                                                    for toMove = i,1,-1 do
                                                        table.insert(tmpCols2[f][1],1,tmpCols2[c][1][toMove])
                                                        table.remove(tmpCols2[c][1],toMove)
                                                    end
                                                    if #tmpCols2[c][1] == 0 and #tmpCols2[c][2] > 0 then
                                                        table.insert(tmpCols2[c][1],1,tmpCols2[c][2][1])
                                                        table.remove(tmpCols2[c][2],1)
                                                    end
                                                    Cols:set(tmpCols2)
                                                    Moves:set(Moves:get() + 1)
                                                    break
                                                end
    
                                            end
                                        end
                                    end
                                    EndOfTurn()
                                    Position:set(UDim2.new(0,0,0,0))
                                end
                            end)
                        end
                    end;
                    [Event "InputChanged"] = function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            dragInput = input
                        end
                    end;
                    [Fusion.Cleanup] = toClean;
                }
            end,Fusion.cleanup)
        }
    };
end

local FullScreen = false
local LastPos = UDim2.new(0,0,0,0)
local LastSize = UDim2.new(0,0,0,0)
local ScreenGuiSize = Value()
local ScreenGuiPos = Value()

local Window
function SetFullScreen()
    if FullScreen == false then
        FullScreen = true
        LastPos = ScreenGuiPos:get()
        LastSize = ScreenGuiSize:get()
        local Inset = GuiService.TopbarInset
        local ViewportSize = game.Workspace.CurrentCamera.ViewportSize
        Window.SetPosition(UDim2.new(0,1,0,1 - Inset.Max.Y))
        Window.SetSize(Vector2.new(ViewportSize.X-2,ViewportSize.Y-23))
    else
        FullScreen = false
        Window.SetPosition(UDim2.new(0,LastPos.X,0,LastPos.Y-21))
        Window.SetSize(Vector2.new(LastSize.X,LastSize.Y))
    end
end
Window = Api:CreateWindow({
    Size = Vector2.new(250,250);
    Title = "Solitaire";
    Position = UDim2.new(0.5,-250/2,0.5,-250/2);
    Resizeable = true;
    ResizeableMinimum = Vector2.new(100,100);
    Buttons = {
        [1] = {
            Text = "?";
            Callback = function()
                HowTo:ShowGui("Solitaire")
            end
        };
        [2] = {
            Text = "rbxassetid://11295287825";
            Callback = function()
                SetFullScreen();
            end;
            Padding = 2;
            Type = "Image";
        };
        [3] = {
            Text = "rbxassetid://11293978505";
            Callback = function()
                Restart();
            end;
            Padding = 2;
            Type = "Image";
        };
    };
},New "Frame" {
    Size = UDim2.new(1,0,1,0);
    BackgroundTransparency = 0;
    BackgroundColor3 = Color3.fromRGB(36, 77, 36);
    [Fusion.Out "AbsoluteSize"] = ScreenGuiSize;
    [Fusion.Out "AbsolutePosition"] = ScreenGuiPos;
    [Children] = {
        -- Board Frame
        New "Frame" {
            Size = UDim2.new(1,0,1,0);
            BackgroundTransparency = 1;
            ZIndex = 2;
            AnchorPoint = Vector2.new(0.5,0.5);
            Position = UDim2.new(0.5,0,0.5,0);
            ClipsDescendants = true;
            [Children] = {
                New "UIAspectRatioConstraint" {};

                -- Deck
                New "ImageButton" {
                    Size = UDim2.new(0.12,0,0.17,0);
                    Position = UDim2.new(0.02,0,0.015,0);
                    BackgroundTransparency = 1;
                    Image = Computed(function()
                        if #Deck:get() > 0 then
                            return Images.B1[1]
                        end
                        return Images["empty"][1];
                    end);
                    ImageRectSize = Vector2.new(200, 280);
                    ImageRectOffset = Computed(function()
                        if #Deck:get() > 0 then
                            return Vector2.new(200*Images.B1[2].X,280*Images.B1[2].Y)
                        end
                        return Vector2.new(200*Images["empty"][2].X,280*Images["empty"][2].Y);
                    end);
                    ZIndex = 3;
                    [Event "MouseButton1Up"] = function()
                        local tmpDeck = table.clone(Deck:get())
                        local tmpDis = table.clone(Discard:get())
                        if #tmpDeck > 0 then
                            table.insert(tmpDis,1,tmpDeck[1]);
                            table.remove(tmpDeck,1);
                        elseif #tmpDeck == 0 and #tmpDis ~= 0 then
                            -- Flip
                            for _ = 1,#tmpDis,1 do
                                table.insert(tmpDeck,1,tmpDis[1]);
                                table.remove(tmpDis,1);
                            end
                        end
                        Deck:set(tmpDeck)
                        Discard:set(tmpDis)
                    end;

                    [Children] = {
                        New "UICorner" {CornerRadius = UDim.new(0.05,0)};
                        New "UIStroke" {
                            Color = Color3.fromRGB(0,170,255);
                            Thickness = 2;
                            Enabled = Computed(function()
                                if string.sub(KeyboardSelection:get(),1,2) == "00" and ActiveInput:get() == "Keyboard" then
                                    return true
                                end
                                return false
                            end);
                        };
                    }
                };
                -- Discard (Single-Draw)
                DiscardUi();

                -- Empty Space
                New "Frame" {
                    Size = UDim2.new(0.12,0,0.17,0);
                    Position = UDim2.new(0.02*3 + 0.12*2,0,0.015,0);
                    BackgroundTransparency = 1;
                    ZIndex = 3;
                    [Children] = {
                        New "UICorner" {CornerRadius = UDim.new(0.05,0)};
                        New "UIStroke" {
                            Color = Color3.fromRGB(0,170,255);
                            Thickness = 2;
                            Enabled = Computed(function()
                                if string.sub(KeyboardSelection:get(),1,2) == "02" and ActiveInput:get() == "Keyboard" then
                                    return true
                                end
                                return false
                            end);
                        };
                        New "TextLabel" {
                            Size = UDim2.new(1,0,0.15,0);
                            BackgroundTransparency = 1;
                            Font = Enum.Font.SourceSans;
                            Text = TimerText;
                            TextScaled = true;
                            TextColor3 = Color3.new(.9,.9,.9);
                        };
                        New "TextLabel" {
                            Size = UDim2.new(1,0,0.15,0);
                            Position = UDim2.new(0,0,0.15,0);
                            BackgroundTransparency = 1;
                            Font = Enum.Font.SourceSans;
                            Text = Computed(function()
                                return Moves:get() .. " moves"
                            end);
                            TextScaled = true;
                            TextColor3 = Color3.new(.9,.9,.9);
                        };
                    }
                };

                -- Cols
                ColUi(1);
                ColUi(2);
                ColUi(3);
                ColUi(4);
                ColUi(5);
                ColUi(6);
                ColUi(7);

                -- Pile
                PileUi(1);
                PileUi(2);
                PileUi(3);
                PileUi(4);

                -- Winning Ui
                New "Frame" {
                    AnchorPoint = Vector2.new(0.5,0.5);
                    BackgroundColor3 = Color3.new(0,0,0);
                    BackgroundTransparency = 0.4;
                    Position = Tween(Computed(function()
                        if Status:get() == 2 then
                            return UDim2.new(0.5,0,0.5,0);
                        end
                        return UDim2.new(0.5,0,-0.2,0);
                    end),TweenInfo.new(0.25));
                    Size = UDim2.new(0.45,0,0.25,0);
                    ZIndex = 5;
                    [Children] = {
                        New "UICorner" {
                            CornerRadius = UDim.new(0.05,0);
                        };
                        -- Title
                        New "TextLabel" {
                            BackgroundTransparency = 1;
                            Font = Enum.Font.SourceSansBold;
                            Size = UDim2.new(1,0,0.5,0);
                            Text = "You Win!";
                            TextColor3 = Color3.new(1,1,1);
                            TextScaled = true;
                        };
                        -- Timer
                        New "TextLabel" {
                            BackgroundTransparency = 1;
                            Font = Enum.Font.SourceSansBold;
                            Position = UDim2.new(0,0,0.475,0);
                            Size = UDim2.new(1,0,0.2,0);
                            Text = Computed(function()
                                if Status:get() == 2 then
                                    return tbl:FormatTime(EndTime - StartTime)
                                end
                                return "00:00"
                            end);
                            TextColor3 = Color3.new(1,1,1);
                            TextScaled = true;
                        };
                        -- Play Again
                        New "TextButton" {
                            BackgroundColor3 = Color3.fromRGB(70,70,70);
                            BackgroundTransparency = 0.3;
                            Font = Enum.Font.SourceSansBold;
                            Position = UDim2.new(0.04,0,0.7,0);
                            Size = UDim2.new(0.44,0,0.25,0);
                            Text = "Play Again";
                            TextColor3 = Color3.new(1,1,1);
                            TextScaled = true;
                            [Event "MouseButton1Up"] = function()
                                Restart()
                            end;
                            [Children] = {
                                New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                                New "UIPadding" {
                                    PaddingBottom = UDim.new(0,3);
                                    PaddingLeft = UDim.new(0,3);
                                    PaddingRight = UDim.new(0,3);
                                };
                                New "UIStroke" {
                                    Color = Color3.fromRGB(0,170,255);
                                    Thickness = 2;
                                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                    Enabled = Computed(function()
                                        if string.sub(KeyboardSelection:get(),1,2) == "1" and ActiveInput:get() == "KeyboardWin" then
                                            return true
                                        end
                                        return false
                                    end);
                                };
                            }
                        };
                        -- Exit
                        New "TextButton" {
                            BackgroundColor3 = Color3.fromRGB(70,70,70);
                            BackgroundTransparency = 0.3;
                            Font = Enum.Font.SourceSansBold;
                            Position = UDim2.new(0.52,0,0.7,0);
                            Size = UDim2.new(0.44,0,0.25,0);
                            Text = "Exit";
                            TextColor3 = Color3.new(1,1,1);
                            TextScaled = true;
                            [Event "MouseButton1Up"] = function()
                                ContextActionService:UnbindAction(ActionName)
                                Window.unmount()
                                script:Destroy()
                            end;
                            [Children] = {
                                New "UICorner" {CornerRadius = UDim.new(0.15,0)};
                                New "UIPadding" {
                                    PaddingBottom = UDim.new(0,3);
                                    PaddingLeft = UDim.new(0,3);
                                    PaddingRight = UDim.new(0,3);
                                };
                                New "UIStroke" {
                                    Color = Color3.fromRGB(0,170,255);
                                    Thickness = 2;
                                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                                    Enabled = Computed(function()
                                        if string.sub(KeyboardSelection:get(),1,2) == "2" and ActiveInput:get() == "KeyboardWin" then
                                            return true
                                        end
                                        return false
                                    end);
                                };
                            }
                        };
                    }
                };

                -- Settings Ui
                Settings.Ui(SettingsVis);
                New "ImageButton" {
                    AnchorPoint = Vector2.new(1,0);
                    Size = UDim2.new(0,20,0,20);
                    Position = UDim2.new(1,0,0,2);
                    BackgroundColor3 = Color3.new(0,0,0);
                    BackgroundTransparency = 0.5;
                    Image = "rbxassetid://11293977610";
                    [Event "MouseButton1Up"] = function()
                        SettingsVis:set(not SettingsVis:get());
                    end;
                    ZIndex = 15;
                }
            }
        }
    }
})

Window.OnClose:Connect(function()
    ContextActionService:UnbindAction(ActionName)
    Window.unmount()
    script:Destroy()
end)

ContextActionService:BindActionAtPriority(ActionName,function(_,state,input)
    -- Enable Keyboard Mode: If Window is focused
    local FocusedWindow = Api:GetFocusedWindow()
    if FocusedWindow == Window.id then
        if input.KeyCode ~= Enum.KeyCode.Space then
            if ActiveInput:get() == "Drag" then
                ActiveInput:set("Keyboard")
            end
        end
    end
    -- Keyboard Mode
    if state == Enum.UserInputState.Begin and ActiveInput:get() == "Keyboard" and FocusedWindow == Window.id then
        local Selection = KeyboardSelection:get()
        if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.DPadUp then
            KeyboardSelection:set("0" .. string.sub(Selection,2,2) .. "1");
        elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.DPadDown then
            KeyboardSelection:set("1" .. string.sub(Selection,2,2) .. "1");
        elseif input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.DPadLeft then
            local num = tonumber(string.sub(Selection,2,2)) - 1
            if num < 0 then
                num = 0
            end
            KeyboardSelection:set(string.sub(Selection,1,1) .. num .. "1");
        elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.DPadRight then
            local num = tonumber(string.sub(Selection,2,2)) + 1
            if num > 6 then
                num = 6
            end
            KeyboardSelection:set(string.sub(Selection,1,1) .. num .. "1");

        elseif input.KeyCode == Enum.KeyCode.M or input.KeyCode == Enum.KeyCode.ButtonR1 then
            -- Up
            local KeyS = KeyboardSelection:get()
            if string.sub(KeyS,1,1) == "1" and KeyboardEditMode:get() == 1 then
                local Sel = tonumber(string.sub(KeyS,3))
                local Col = Cols:get()[tonumber(string.sub(KeyS,2,2)) + 1][1]

                Sel += 1;
                if Sel > #Col or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                    Sel = #Col
                end
                KeyboardSelection:set(string.sub(KeyS,1,2) .. Sel)
                KeyboardEditSelection:set(string.sub(KeyS,1,2) .. Sel)
            end

        elseif input.KeyCode == Enum.KeyCode.N or input.KeyCode == Enum.KeyCode.ButtonL1 then
            -- Down
            local KeyS = KeyboardSelection:get()
            if string.sub(KeyS,1,1) == "1" and KeyboardEditMode:get() == 1 then
                local Sel = tonumber(string.sub(KeyS,3))

                Sel -= 1;
                if Sel < 1 or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                    Sel = 1
                end
                KeyboardSelection:set(string.sub(KeyS,1,2) .. Sel)
                KeyboardEditSelection:set(string.sub(KeyS,1,2) .. Sel)
            end

        elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.Return then
            -- Edit Mode
            if KeyboardEditMode:get() == 0 then
                local KeyS = KeyboardSelection:get();
                local HasCard = false
                if string.sub(KeyS,1,2) == "00" then
                    -- Flip Card
                    local tmpDeck = table.clone(Deck:get())
                    local tmpDis = table.clone(Discard:get())
                    if #tmpDeck > 0 then
                        table.insert(tmpDis,1,tmpDeck[1]);
                        table.remove(tmpDeck,1);
                    elseif #tmpDeck == 0 and #tmpDis ~= 0 then
                        -- Flip
                        for _ = 1,#tmpDis,1 do
                            table.insert(tmpDeck,1,tmpDis[1]);
                            table.remove(tmpDis,1);
                        end
                    end
                    Deck:set(tmpDeck)
                    Discard:set(tmpDis)
                elseif string.sub(KeyS,1,2) == "01" then
                    if #Discard:get() > 0 then
                        HasCard = true;
                    end
                elseif string.sub(KeyS,1,2) == "02" then
                elseif string.sub(KeyS,1,1) == "0" then
                    if #Piles:get()[ tonumber(string.sub(KeyS,2,2)) -2 ] > 0 then
                        HasCard = true;
                    end
                elseif string.sub(KeyS,1,1) == "1" then
                    if #Cols:get()[ tonumber(string.sub(KeyS,2,2)) +1 ][1] > 0 then
                        HasCard = true;
                    end
                end
                if HasCard == true then
                    KeyboardEditMode:set(1);
                    KeyboardEditSelection:set(KeyS);
                end
            elseif KeyboardEditMode:get() == 1 then
                -- Cancel
                KeyboardEditMode:set(0);
                KeyboardEditSelection:set("");
                KeyboardSelection:set(string.sub(KeyboardSelection:get(),1,2) .. "1")
            elseif KeyboardEditMode:get() == 2 then
                -- Save
                local KeyS = KeyboardSelection:get()
                local KES = KeyboardEditSelection:get()
                if string.sub(KeyS,1,2) == "00" or string.sub(KeyS,1,2) == "01" or string.sub(KeyS,1,2) == "02" or KES == "" then
                    -- Do Nothing
                else
                    -- Save
                    if string.sub(KeyS,1,1) == "0" and tonumber(string.sub(KES,3)) == 1 then
                        -- Top
                        local PilesTab = Piles:get()
                        local Pile = PilesTab[tonumber(string.sub(KeyS,2,2)) - 2]
                        if #Pile == 0 then
                            -- Must be Ace
                            if string.sub(KES,1,2) == "01" then
                                -- Discard
                                local tmp = Discard:get()
                                if string.sub(tmp[1],1,1) == "A" then
                                    -- Good
                                    table.insert(Pile,1,tmp[1])
                                    table.remove(tmp,1);
                                    Discard:set(tmp);
                                    PilesTab[tonumber(string.sub(KeyS,2,2)) - 2] = Pile
                                    Piles:set(PilesTab)
                                    Moves:set(Moves:get() + 1)
                                end
                            elseif string.sub(KES,1,1) == "0" then
                                if string.sub(PilesTab[tonumber(string.sub(KES,2,2)) - 2][1],1,1) == "A" then
                                    -- Good
                                    table.insert(Pile,1,PilesTab[tonumber(string.sub(KES,2,2)) - 2][1])
                                    table.remove(PilesTab[tonumber(string.sub(KES,2,2)) - 2],1);
                                    PilesTab[tonumber(string.sub(KeyS,2,2)) - 2] = Pile
                                    Piles:set(PilesTab)
                                    Moves:set(Moves:get() + 1)
                                end
                            else
                                -- Bottom
                                local tmp = Cols:get()
                                if string.sub(tmp[tonumber(string.sub(KES,2,2)) + 1][1][1],1,1) == "A" then
                                    table.insert(Pile,1,tmp[tonumber(string.sub(KES,2,2)) + 1][1][1])
                                    table.remove(tmp[tonumber(string.sub(KES,2,2)) + 1][1],1)

                                    if #tmp[tonumber(string.sub(KES,2,2)) + 1][1] == 0 and #tmp[tonumber(string.sub(KES,2,2)) + 1][2] > 0 then
                                        table.insert(tmp[tonumber(string.sub(KES,2,2)) + 1][1],1,tmp[tonumber(string.sub(KES,2,2)) + 1][2][1])
                                        table.remove(tmp[tonumber(string.sub(KES,2,2)) + 1][2],1)
                                    end

                                    Cols:set(tmp)
                                    PilesTab[tonumber(string.sub(KeyS,2,2)) - 2] = Pile
                                    Piles:set(PilesTab)
                                    Moves:set(Moves:get() + 1)
                                end
                            end
                        else
                            -- Must be same Suit
                            if string.sub(KES,1,2) == "01" then
                                -- Discard
                                local tmp = Discard:get()
                                if string.sub(tmp[1],2,2) == string.sub(Pile[1],2,2) and Mappings:ToLetter(Mappings:ToNumber(string.sub(Pile[1],1,1)) + 1) == string.sub(tmp[1],1,1) then
                                    -- Good
                                    table.insert(Pile,1,tmp[1])
                                    table.remove(tmp,1);
                                    Discard:set(tmp);
                                    PilesTab[tonumber(string.sub(KeyS,2,2)) - 2] = Pile
                                    Piles:set(PilesTab)
                                    Moves:set(Moves:get() + 1)
                                end
                            elseif string.sub(KES,1,1) == "0" then -- Isnt possible with a 52card deck
                                if string.sub(PilesTab[tonumber(string.sub(KES,2,2)) - 2][1],2,2) == string.sub(Pile[1],2,2) and Mappings:ToLetter(Mappings:ToNumber(string.sub(Pile[1],1,1)) + 1) == string.sub(PilesTab[tonumber(string.sub(KES,2,2)) - 2][1][1],1,1) then
                                    -- Good
                                    table.insert(Pile,1,PilesTab[tonumber(string.sub(KES,2,2)) - 2][1])
                                    table.remove(PilesTab[tonumber(string.sub(KES,2,2)) - 2],1);
                                    PilesTab[tonumber(string.sub(KeyS,2,2)) - 2] = Pile
                                    Piles:set(PilesTab)
                                    Moves:set(Moves:get() + 1)
                                end
                            else
                                -- Bottom
                                local tmp = Cols:get()
                                if string.sub(tmp[tonumber(string.sub(KES,2,2)) + 1][1][1],2,2) == string.sub(Pile[1],2,2) and Mappings:ToLetter(Mappings:ToNumber(string.sub(Pile[1],1,1)) + 1) == string.sub(tmp[tonumber(string.sub(KES,2,2)) + 1][1][1],1,1) then
                                    table.insert(Pile,1,tmp[tonumber(string.sub(KES,2,2)) + 1][1][1])
                                    table.remove(tmp[tonumber(string.sub(KES,2,2)) + 1][1],1)

                                    if #tmp[tonumber(string.sub(KES,2,2)) + 1][1] == 0 and #tmp[tonumber(string.sub(KES,2,2)) + 1][2] > 0 then
                                        table.insert(tmp[tonumber(string.sub(KES,2,2)) + 1][1],1,tmp[tonumber(string.sub(KES,2,2)) + 1][2][1])
                                        table.remove(tmp[tonumber(string.sub(KES,2,2)) + 1][2],1)
                                    end

                                    Cols:set(tmp)
                                    PilesTab[tonumber(string.sub(KeyS,2,2)) - 2] = Pile
                                    Piles:set(PilesTab)
                                    Moves:set(Moves:get() + 1)
                                end
                            end
                        end
                    else
                        -- Moving to Bottom
                        local tmpCols = Cols:get()
                        local currentCol = tmpCols[tonumber(string.sub(KeyS,2,2)) +1][1]
                        if #currentCol == 0 then
                            -- Must be King
                            if string.sub(KES,1,2) == "01" then
                                -- Discard
                                local tmp = Discard:get()
                                if string.sub(tmp[1],1,1) == "K" then
                                    -- Good
                                    table.insert(currentCol,1,tmp[1])
                                    table.remove(tmp,1);
                                    Discard:set(tmp);
                                    tmpCols[tonumber(string.sub(KeyS,2,2)) +1][1] = currentCol
                                    Cols:set(tmpCols)
                                    Moves:set(Moves:get() + 1)
                                end
                            elseif string.sub(KES,1,1) == "0" then
                                local tmp = Piles:get()
                                if string.sub(tmp[tonumber(string.sub(KES,2,2)) - 2][1],1,1) == "K" then
                                    -- Good
                                    table.insert(currentCol,1,tmp[tonumber(string.sub(KES,2,2)) - 2][1])
                                    table.remove(tmp[tonumber(string.sub(KES,2,2)) - 2],1);
                                    tmpCols[tonumber(string.sub(KeyS,2,2)) +1][1] = currentCol
                                    Cols:set(tmpCols)
                                    Piles:set(tmp);
                                    Moves:set(Moves:get() + 1)
                                end
                            else
                                -- from another col
                                if string.sub(tmpCols[tonumber(string.sub(KES,2,2)) +1][1][tonumber(string.sub(KES,3))],1,1) == "K" then
                                    -- Good
                                    for i = tonumber(string.sub(KES,3)),1,-1 do
                                        table.insert(currentCol,1,tmpCols[tonumber(string.sub(KES,2,2)) +1][1][i])
                                        table.remove(tmpCols[tonumber(string.sub(KES,2,2)) +1][1],i);
                                    end
                                    if #tmpCols[tonumber(string.sub(KES,2,2)) + 1][1] == 0 and #tmpCols[tonumber(string.sub(KES,2,2)) + 1][2] > 0 then
                                        table.insert(tmpCols[tonumber(string.sub(KES,2,2)) + 1][1],1,tmpCols[tonumber(string.sub(KES,2,2)) + 1][2][1])
                                        table.remove(tmpCols[tonumber(string.sub(KES,2,2)) + 1][2],1)
                                    end
                                    tmpCols[tonumber(string.sub(KeyS,2,2)) +1][1] = currentCol
                                    Cols:set(tmpCols)
                                    Moves:set(Moves:get() + 1)
                                end
                            end
                        else
                            -- Must be alternate color
                            if string.sub(KES,1,2) == "01" then
                                -- Discard
                                local tmp = Discard:get()
                                if string.sub(tmp[1],1,1) == Mappings:ToLetter( Mappings:ToNumber(string.sub(currentCol[1],1,1)) -1) and Mappings:IsOpposite(tmp[1],currentCol[1]) then
                                    -- Good
                                    table.insert(currentCol,1,tmp[1])
                                    table.remove(tmp,1);
                                    Discard:set(tmp);
                                    tmpCols[tonumber(string.sub(KeyS,2,2)) +1][1] = currentCol
                                    Cols:set(tmpCols)
                                    Moves:set(Moves:get() + 1)
                                end
                            elseif string.sub(KES,1,1) == "0" then
                                local tmp = Piles:get()
                                if string.sub(tmp[tonumber(string.sub(KES,2,2)) - 2][1],1,1) == Mappings:ToLetter( Mappings:ToNumber(string.sub(currentCol[1],1,1)) -1) and Mappings:IsOpposite(tmp[tonumber(string.sub(KES,2,2)) - 2][1],currentCol[1]) then
                                    -- Good
                                    table.insert(currentCol,1,tmp[tonumber(string.sub(KES,2,2)) - 2][1])
                                    table.remove(tmp[tonumber(string.sub(KES,2,2)) - 2],1);
                                    tmpCols[tonumber(string.sub(KeyS,2,2)) +1][1] = currentCol
                                    Cols:set(tmpCols)
                                    Piles:set(tmp);
                                    Moves:set(Moves:get() + 1)
                                end
                            else
                                -- from another col
                                if string.sub(tmpCols[tonumber(string.sub(KES,2,2)) +1][1][tonumber(string.sub(KES,3))],1,1) == Mappings:ToLetter( Mappings:ToNumber(string.sub(currentCol[1],1,1)) -1) and Mappings:IsOpposite(tmpCols[tonumber(string.sub(KES,2,2)) +1][1][tonumber(string.sub(KES,3))],currentCol[1]) then
                                    -- Good
                                    for i = tonumber(string.sub(KES,3)),1,-1 do
                                        table.insert(currentCol,1,tmpCols[tonumber(string.sub(KES,2,2)) +1][1][i])
                                        table.remove(tmpCols[tonumber(string.sub(KES,2,2)) +1][1],i);
                                    end
                                    if #tmpCols[tonumber(string.sub(KES,2,2)) + 1][1] == 0 and #tmpCols[tonumber(string.sub(KES,2,2)) + 1][2] > 0 then
                                        table.insert(tmpCols[tonumber(string.sub(KES,2,2)) + 1][1],1,tmpCols[tonumber(string.sub(KES,2,2)) + 1][2][1])
                                        table.remove(tmpCols[tonumber(string.sub(KES,2,2)) + 1][2],1)
                                    end
                                    tmpCols[tonumber(string.sub(KeyS,2,2)) +1][1] = currentCol
                                    Cols:set(tmpCols)
                                    Moves:set(Moves:get() + 1)
                                end
                            end
                        end

                    end
                end
                KeyboardEditMode:set(0);
                KeyboardEditSelection:set("");
            end
        end

        if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.DPadUp or input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.DPadDown or input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.DPadLeft or input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.DPadRight then
            local KES = KeyboardEditSelection:get()
            if KES ~= "" and KeyboardEditMode:get() ~= 0 then
                if string.sub(KES,1,2) == string.sub(KeyboardSelection:get(),1,2) then
                    KeyboardEditMode:set(1);
                    KeyboardSelection:set(KeyboardEditSelection:get())
                else
                    KeyboardEditMode:set(2);
                end
            end
        end
        EndOfTurn()
        return Enum.ContextActionResult.Sink;
    elseif state == Enum.UserInputState.Begin and ActiveInput:get() == "KeyboardWin" and FocusedWindow == Window.id then
        if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.DPadLeft then
            KeyboardSelection:set("1")
        elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.DPadRight then
            KeyboardSelection:set("2")
        elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.Return then
            if KeyboardSelection:get() == "1" then
                -- Play Again
                Restart()
            else
                -- Exit
                ContextActionService:UnbindAction(ActionName)
                Window.unmount()
                script:Destroy()
            end
        end
        return Enum.ContextActionResult.Sink;
    elseif state == Enum.UserInputState.Begin and ActiveInput:get() == "Drag" and FocusedWindow == Window.id then
        if input.KeyCode == Enum.KeyCode.Space then
            -- Flip Card
            local tmpDeck = table.clone(Deck:get())
            local tmpDis = table.clone(Discard:get())
            if #tmpDeck > 0 then
                table.insert(tmpDis,1,tmpDeck[1]);
                table.remove(tmpDeck,1);
            elseif #tmpDeck == 0 and #tmpDis ~= 0 then
                -- Flip
                for _ = 1,#tmpDis,1 do
                    table.insert(tmpDeck,1,tmpDis[1]);
                    table.remove(tmpDis,1);
                end
            end
            Deck:set(tmpDeck)
            Discard:set(tmpDis)
            Moves:set(Moves:get() + 1)
            return Enum.ContextActionResult.Sink;
        end
    end
    return Enum.ContextActionResult.Pass;
end,false,3000,Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.DPadDown, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight, Enum.KeyCode.DPadUp,Enum.KeyCode.Space,Enum.KeyCode.ButtonA,Enum.KeyCode.N,Enum.KeyCode.M,Enum.KeyCode.ButtonL1,Enum.KeyCode.ButtonR1,Enum.KeyCode.Return);

local MouseInputs = {
    Enum.UserInputType.MouseButton1;
    Enum.UserInputType.MouseButton2;
    Enum.UserInputType.MouseButton3;
    Enum.UserInputType.MouseMovement;
    Enum.UserInputType.MouseWheel;
    Enum.UserInputType.Touch;
}

-- If Mouse input, then set to drag mode.
UserInputService.LastInputTypeChanged:Connect(function(lastInputType)
    if ActiveInput:get() == "Keyboard" and table.find(MouseInputs,lastInputType) ~= nil then
        ActiveInput:set("Drag")
    end
end)

RunService.RenderStepped:Connect(function()
    if EndTime == 0 then
        TimerText:set(tbl:FormatTime(os.time() - StartTime))
    end
end)
