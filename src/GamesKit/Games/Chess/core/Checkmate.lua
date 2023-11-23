-- Stonetr03

local Moves = require(script.Parent:WaitForChild("Moves"))

local Module = {}

local ColorPieces = {
    ["w"] = "K";
    ["b"] = "k";
}

local Files = {
    ["a"] = 1;
    ["b"] = 2;
    ["c"] = 3;
    ["d"] = 4;
    ["e"] = 5;
    ["f"] = 6;
    ["g"] = 7;
    ["h"] = 8;
}

function Module:SetTmpSquare(Board,Square,Piece)
    if typeof(Square) == "table" then
        if Square[2] ~= "Promote" and Square[2] ~= "castle" then
            Square = Square[1]
        else
            return Board
        end
    end
    local File = Files[string.lower(string.sub(Square,1,1))]
    local Rank = tonumber(string.sub(Square,2,2));
    Board.Board[Rank] = string.sub(Board.Board[Rank],0,File-1) .. Piece .. string.sub(Board.Board[Rank],File+1,9)
    return Board
end

function Module:CheckForCheckmate(Board,Color)
    local King = Moves:GetSquareFromPiece(Board,ColorPieces[Color])
    if Moves:CheckifCheck(Board, King, Color) == false then
        return false
    end

    local Pieces = Moves:GetPieces(Board,Color)
    for _,p in pairs(Pieces) do
        local PieceMoves = Moves:GetLegalMoves(Board,p)
        for _,m in pairs(PieceMoves) do
            local NewBoard = {Board = table.clone(Board.Board), Castle = "",Last = Board.Last}
            -- Play Move
            local Rank = tonumber(string.sub(p,2,2));
            local File = Files[string.lower(string.sub(p,1,1))]
            NewBoard = Module:SetTmpSquare(NewBoard,m,string.sub(NewBoard.Board[Rank],File,File))
            NewBoard = Module:SetTmpSquare(NewBoard,p," ")
            local skip = false
            if typeof(m) == "table" then
                if m[2] == "castle" then
                    -- Skip
                    skip = true
                elseif m[2] == "Promote" then
                    NewBoard = Module:SetTmpSquare(NewBoard,m[1],m[3])
                else
                    -- EnPassant
                    NewBoard = Module:SetTmpSquare(NewBoard,m[2]," ")
                end
            end
            if skip == false then
                local NewKing = Moves:GetSquareFromPiece(NewBoard,ColorPieces[Color])
                if Moves:CheckifCheck(NewBoard,NewKing,Color) == false then
                    return false
                end
            end
        end
    end
    return true
end

function Module:CheckForStalemate(Board,Color)
    local King = Moves:GetSquareFromPiece(Board,ColorPieces[Color])
    if Moves:CheckifCheck(Board, King, Color) == true then
        return false
    end

    local Pieces = Moves:GetPieces(Board,Color)
    for _,p in pairs(Pieces) do
        local PieceMoves = Moves:GetLegalMoves(Board,p)
        for _,m in pairs(PieceMoves) do
            local NewBoard = {Board = table.clone(Board.Board), Castle = "",Last = Board.Last}
            -- Play Move
            local Rank = tonumber(string.sub(p,2,2));
            local File = Files[string.lower(string.sub(p,1,1))]
            if typeof(m) == "table" then
                NewBoard = Module:SetTmpSquare(NewBoard,m[1],string.sub(NewBoard.Board[Rank],File,File))
            else
                NewBoard = Module:SetTmpSquare(NewBoard,m,string.sub(NewBoard.Board[Rank],File,File))
            end
            NewBoard = Module:SetTmpSquare(NewBoard,p," ")
            if typeof(m) == "table" then
                if m[2] == "castle" then
                elseif m[2] == "Promote" then
                    NewBoard = Module:SetTmpSquare(NewBoard,m[1],m[3])
                else
                    -- EnPassant
                    NewBoard = Module:SetTmpSquare(NewBoard,m[2]," ")
                end
            end
            local NewKing = Moves:GetSquareFromPiece(NewBoard,ColorPieces[Color])
            if Moves:CheckifCheck(NewBoard,NewKing,Color) == false then
                return false
            end
        end
    end
    return true
end

function Module:CheckForInsufficientMaterial(Board)
    local WSquares = Moves:GetPieces(Board,"w")
    local WPieces = {}
    for _,o in pairs(WSquares) do
        local Piece = string.sub(Board.Board[tonumber(string.sub(o,2,2))],Files[string.sub(o,1,1)],Files[string.sub(o,1,1)])
        table.insert(WPieces,Piece)
    end
    -- Check Pieces
    local WLone = false
    local WtwoN = false
    if #WPieces == 1 and WPieces[1] == "K" then
        WLone = true
    elseif #WPieces == 2 and table.find(WPieces,"K") and table.find(WPieces,"B") then
    elseif #WPieces == 2 and table.find(WPieces,"K") and table.find(WPieces,"N") then
    elseif #WPieces == 3 then
        -- Two Knights
        local NCount = 0
        for _,n in pairs(WPieces) do
            if n == "N" then
                NCount += 1
            end
        end
        if NCount == 2 then
            WtwoN = true
        else
            return false
        end
    else return false
    end
    -- Black
    local BSquares = Moves:GetPieces(Board,"b")
    local BPieces = {}
    for _,o in pairs(BSquares) do
        local Piece = string.sub(Board.Board[tonumber(string.sub(o,2,2))],Files[string.sub(o,1,1)],Files[string.sub(o,1,1)])
        table.insert(BPieces,Piece)
    end
    -- Check Pieces
    if #BPieces == 1 and BPieces[1] == "k" then
        return true
    elseif #BPieces == 2 and table.find(BPieces,"k") and table.find(BPieces,"b") then
        if WtwoN == false then return true end
    elseif #BPieces == 2 and table.find(BPieces,"k") and table.find(BPieces,"n") then
        if WtwoN == false then return true end
    elseif #BPieces == 3 then
        -- Two Knights
        local NCount = 0
        for _,n in pairs(BPieces) do
            if n == "n" then
                NCount += 1
            end
        end
        if NCount == 2 then
            if WLone == true then
                return true
            end
        else
            return false
        end
    else return false
    end
    return false
end

return Module
