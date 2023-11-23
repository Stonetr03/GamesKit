-- Stonetr03

-- Pieces
local Pawn = require(script.Parent:WaitForChild("Pieces"):WaitForChild("Pawn"))
local Rook = require(script.Parent:WaitForChild("Pieces"):WaitForChild("Rook"))
local Bishop = require(script.Parent:WaitForChild("Pieces"):WaitForChild("Bishop"))
local Queen = require(script.Parent:WaitForChild("Pieces"):WaitForChild("Queen"))
local Knight = require(script.Parent:WaitForChild("Pieces"):WaitForChild("Knight"))
local King = require(script.Parent:WaitForChild("Pieces"):WaitForChild("King"))

local Module = {}

local WhitePieces = {"R","N","B","Q","K","P"}
local BlackPieces = {"r","n","b","q","k","p"}

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

function Module:GetLegalMoves(Board: table, Square: string)
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
    -- Check if king is in check
    local LegalMoves = CheckFuncs[string.lower(Piece)]:GetMoves(Board,File,Rank,Color)
    -- Check if king is Still in check
    return LegalMoves
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

function Module:GetSquareFromPiece(Board,Piece)
    for Rank = 1,8,1 do
        for File = 1,8,1 do
            if string.sub(Board.Board[Rank],File,File) == Piece then
                return FileNums[File] .. tostring(Rank)
            end
        end
    end
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
        local Moves = Module:GetLegalMoves(Board,Piece)
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

return Module
