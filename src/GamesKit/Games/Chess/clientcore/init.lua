-- Stonetr03

-- Pieces
local Pawn = require(script:WaitForChild("Pieces"):WaitForChild("Pawn"))
local Rook = require(script:WaitForChild("Pieces"):WaitForChild("Rook"))
local Bishop = require(script:WaitForChild("Pieces"):WaitForChild("Bishop"))
local Queen = require(script:WaitForChild("Pieces"):WaitForChild("Queen"))
local Knight = require(script:WaitForChild("Pieces"):WaitForChild("Knight"))
local King = require(script:WaitForChild("Pieces"):WaitForChild("King"))

local Module = {}

local WhitePieces = {"R","N","B","Q","K","P"}
local BlackPieces = {"r","n","b","q","k","p"}

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

local FileNums = {
    [1] = "a";
    [2] = "b";
    [3] = "c";
    [4] = "d";
    [5] = "e";
    [6] = "f";
    [7] = "g";
    [8] = "h";
}

local CheckFuncs = {
    ["p"] = Pawn;
    ["r"] = Rook;
    ["b"] = Bishop;
    ["q"] = Queen;
    ["n"] = Knight;
    ["k"] = King;
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

function Module:GetPieces(Board,Color)
    local Pieces = {}
    for Rank = 1,8,1 do
        for File = 1,8,1 do
            if Color == "w" and table.find(WhitePieces,string.sub(Board.Board[Rank],File,File)) then
                table.insert(Pieces,FileNums[File] .. tostring(Rank))
            elseif Color == "b" and table.find(BlackPieces,string.sub(Board.Board[Rank],File,File)) then
                table.insert(Pieces,FileNums[File] .. tostring(Rank))
            end
        end
    end
    return Pieces
end

function Module:CheckifCheck(Board,Square,Color)
    local Check = false
    local Pieces
    if Color == "w" then
        Pieces = Module:GetPieces(Board,"b")
    elseif Color == "b" then
        Pieces = Module:GetPieces(Board,"w")
    end
    for _,Piece in pairs(Pieces) do
        local Moves = Module:GetLegalMoves(Board,Piece,false)
        for _,o in pairs(Moves) do
            if typeof(o) == "table" then
            elseif o == Square then
                Check = true
                break
            end
        end
    end
    return Check
end

function Module:GetSquareFromPiece(Board,Piece)
    for Rank = 1,8,1 do
        for File = 1,8,1 do
            if string.sub(Board.Board[Rank],File,File) == Piece then
                return FileNums[File] .. tostring(Rank)
            end
        end
    end
end

function Module:GetLegalMoves(Board: table,Square: string,CheckCheck: boolean)
    -- Get Squares
    if string.len(Square) ~= 2 then return {} end

    local File = Files[string.lower(string.sub(Square,1,1))]
    if not File then return {} end
    local Rank = tonumber(string.sub(Square,2,2));
    if not Rank then return {} end
    if Rank < 1 or Rank > 8 then return {} end

    -- Get Piece
    local Piece = string.sub(Board.Board[Rank],File,File)
    if Piece == " " then return {} end

    -- Get Legal Moves
    local Color = "w"
    if table.find(BlackPieces,Piece) then
        Color = "b"
    end
    local king = ColorPieces[Color]
    -- Check if king is in check
    local PreCheck = false
    if CheckCheck == true then
        PreCheck = Module:CheckifCheck(Board,Module:GetSquareFromPiece(Board,king),Color)
    end
    local LegalMoves = CheckFuncs[string.lower(Piece)]:GetMoves(Board,File,Rank,Color)
    if CheckCheck == true then
        local PostCheckMoves = {}
        -- Check if king is Still in check
        for _,m in pairs(LegalMoves) do
            local TmpBoard = {Board = table.clone(Board.Board), Castle = Board.Castle,Last = Board.Last}
            -- Play Move
            local TmpRank = tonumber(string.sub(Square,2,2));
            local TmpFile = Files[string.lower(string.sub(Square,1,1))]
            TmpBoard = Module:SetTmpSquare(TmpBoard,m,string.sub(TmpBoard.Board[TmpRank],TmpFile,TmpFile))
            TmpBoard = Module:SetTmpSquare(TmpBoard,Square," ")
            local castle = false
            if typeof(m) == "table" then
                if m[2] == "castle" then
                    if PreCheck == false then
                        table.insert(PostCheckMoves,m)
                    end
                    castle = true
                elseif m[2] == "Promote" then
                    TmpBoard = Module:SetTmpSquare(TmpBoard,m[1],m[3])
                else
                    -- EnPassant
                    TmpBoard = Module:SetTmpSquare(TmpBoard,m[2]," ")
                end
            end
            if castle == false then
                local NewKing = Module:GetSquareFromPiece(TmpBoard,ColorPieces[Color])
                local PostCheck = Module:CheckifCheck(TmpBoard,NewKing,Color)

                if PreCheck == true and PostCheck == false then
                    table.insert(PostCheckMoves,m);
                elseif PreCheck == false and PostCheck == false then
                    table.insert(PostCheckMoves,m);
                end

            end
        end

        return PostCheckMoves
    else
        return LegalMoves
    end
end

function Module:CheckMove(Board: table,OldSqr: string,NewSqr: string)
    local LegalMoves = Module:GetLegalMoves(Board,OldSqr,true)
    for _,m in pairs(LegalMoves) do
        if typeof(m) == "table" and m[1] == NewSqr then
            return true
        elseif m == NewSqr then
            return true
        end
    end
    return false
end

local PieceValue = {
    p = 1;
    r = 5;
    n = 3;
    b = 3;
    q = 9;
    k = 0;
}

function Module:GetPieceDifference(Board)
    local WhiteCount = {
        p = 0;
        r = 0;
        n = 0;
        b = 0;
        q = 0;
        k = 0;
    }
    local BlackCount = {
        p = 0;
        r = 0;
        n = 0;
        b = 0;
        q = 0;
        k = 0;
    }
    for rank = 1,8,1 do
        for file = 1,8,1 do
            local piece = string.sub(Board.Board[rank],file,file)
            if piece ~= " " then
                if table.find(WhitePieces,piece) then
                    -- White Piece
                    WhiteCount[string.lower(piece)] += 1
                elseif table.find(BlackPieces,piece) then
                    -- Black Piece
                    BlackCount[string.lower(piece)] += 1
                end
            end
        end
    end
    local WhiteMissing = {
        p = 8;
        r = 2;
        n = 2;
        b = 2;
        q = 1;
        k = 1;
    }
    local BlackMissing = {
        p = 8;
        r = 2;
        n = 2;
        b = 2;
        q = 1;
        k = 1;
    }
    local WhiteValue = 0;
    for i,v in pairs(WhiteCount) do
        WhiteValue += v * PieceValue[i]

        WhiteMissing[i] -= v
        if WhiteMissing[i] < 0 then
            WhiteMissing[i] = 0
        end
    end
    local BlackValue = 0;
    for i,v in pairs(BlackCount) do
        BlackValue += v * PieceValue[i]

        BlackMissing[i] -= v
        if BlackMissing[i] < 0 then
            BlackMissing[i] = 0
        end
    end

    return {
        w = {
            diff = WhiteValue - BlackValue;
            missing = WhiteMissing
        };
        b = {
            diff = BlackValue - WhiteValue;
            missing = BlackMissing
        };
    }
end

return Module
