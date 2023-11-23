-- Stonetr03

local Moves = require(script.Parent:WaitForChild("Moves"))
local Checkmate = require(script.Parent:WaitForChild("Checkmate"))

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

local NumFiles = {
    [1] = "a";
    [2] = "b";
    [3] = "c";
    [4] = "d";
    [5] = "e";
    [6] = "f";
    [7] = "g";
    [8] = "h";
}


local ColorPieces = {
    ["w"] = "K";
    ["b"] = "k";
}

function Module:SetSquare(Board,Square,Piece)
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

function Module:Move(Board,Player,Square,Move,Promote) -- Square:OldSquare, Move:NewSquare
    -- Check Player
    local ReturnMoves = {}
    local KingPiece = "K"
    if Board.Turn == "w" then
        if Board.White ~= Player then
            return
        end
    elseif Board.Turn == "b" then
        KingPiece = "k"
        if Board.Black ~= Player then
            return
        end
    else
        return
    end
    -- Check if square is piece
    local File = Files[string.lower(string.sub(Square,1,1))]
    local Rank = tonumber(string.sub(Square,2,2));
    local NewFile = Files[string.lower(string.sub(Move,1,1))]
    local NewRank = tonumber(string.sub(Move,2,2));
    if Board.Turn == "w" then
        if table.find(WhitePieces,string.sub(Board.Board[Rank],File,File)) then else
            return
        end
    elseif Board.Turn == "b" then
        if table.find(BlackPieces,string.sub(Board.Board[Rank],File,File)) then else
            return
        end
    end

    -- Check if Check
    local inCheck = Moves:CheckifCheck(Board,Moves:GetSquareFromPiece(Board,KingPiece),Board.Turn)
    -- Check if LegalMove
    local LegalMoves = Moves:GetLegalMoves(Board,Square)
    local Legal = false
    local CheckMove
    for i,o in pairs(LegalMoves) do
        if typeof(o) == "table" and o[1] == Move then
            CheckMove = i
            Legal = true
            break
        elseif o == Move then
            CheckMove = i
            Legal = true
            break
        end
    end
    if not Legal then
        return
    end

    -- Check Check
    local tmpCheckBoard = {Board = table.clone(Board.Board), Castle = "",Last = Board.Last}
    tmpCheckBoard = Checkmate:SetTmpSquare(tmpCheckBoard,Move,string.sub(tmpCheckBoard.Board[Rank],File,File))
    tmpCheckBoard = Checkmate:SetTmpSquare(tmpCheckBoard,Square," ")
    local promotePiece = ""
    if typeof(LegalMoves[CheckMove]) == "table" then
        if LegalMoves[CheckMove][2] == "castle" then
        elseif LegalMoves[CheckMove][2] == "Promote" then
            if table.find(WhitePieces,string.upper(Promote)) < 5 then
                -- allowed
                if Board.Turn == "w" then
                    promotePiece = string.upper(Promote)
                else
                    promotePiece = string.lower(Promote)
                end
            else -- illegal
                return
            end
            tmpCheckBoard = Checkmate:SetTmpSquare(tmpCheckBoard,Move,promotePiece)
        else
            -- EnPassant
            tmpCheckBoard = Checkmate:SetTmpSquare(tmpCheckBoard,LegalMoves[CheckMove][2]," ")
        end
    end
    local inCheck2 = Moves:CheckifCheck(tmpCheckBoard,Moves:GetSquareFromPiece(tmpCheckBoard,KingPiece),Board.Turn)
    if inCheck == false and inCheck2 == true then
        -- illegal
        return
    elseif inCheck == true and inCheck2 == true then
        -- illegal
        return
    end

    -- Check Castle
    if inCheck == true and typeof(LegalMoves[CheckMove]) == "table" then
        if LegalMoves[CheckMove][2] == "castle" then
            return
        end
    end

    -- Taking
    local isTaking = false
    if string.sub(Board.Board[NewRank],NewFile,NewFile) ~= " " then
        isTaking = true
        table.insert(ReturnMoves,Move .. "-x")
    end

    -- Castles
    local ValidCastle = {}
    for i = 1,string.len(Board.Castle),1 do
        table.insert(ValidCastle,string.sub(Board.Castle,i,i))
    end
    if Board.Turn == "w" then
        if string.sub(Board.Board[Rank],File,File) == "K" then
            -- Remove Castles
            if table.find(ValidCastle,"K") then
                table.remove(ValidCastle,table.find(ValidCastle,"K"))
            end
            if table.find(ValidCastle,"Q") then
                table.remove(ValidCastle,table.find(ValidCastle,"Q"))
            end
        elseif string.sub(Board.Board[Rank],File,File) == "R" then
            if Rank == 1 then
                if File == 1 then
                    -- Remove Queen
                    if table.find(ValidCastle,"Q") then
                        table.remove(ValidCastle,table.find(ValidCastle,"Q"))
                    end
                elseif File == 8 then
                    -- Remove King
                    if table.find(ValidCastle,"K") then
                        table.remove(ValidCastle,table.find(ValidCastle,"K"))
                    end
                end
            end
        end
    elseif Board.Turn == "b" then
        if string.sub(Board.Board[Rank],File,File) == "k" then
            -- Remove Castles
            if table.find(ValidCastle,"k") then
                table.remove(ValidCastle,table.find(ValidCastle,"k"))
            end
            if table.find(ValidCastle,"q") then
                table.remove(ValidCastle,table.find(ValidCastle,"q"))
            end
        elseif string.sub(Board.Board[Rank],File,File) == "r" then
            if Rank == 1 then
                if File == 1 then
                    -- Remove Queen
                    if table.find(ValidCastle,"q") then
                        table.remove(ValidCastle,table.find(ValidCastle,"q"))
                    end
                elseif File == 8 then
                    -- Remove King
                    if table.find(ValidCastle,"k") then
                        table.remove(ValidCastle,table.find(ValidCastle,"k"))
                    end
                end
            end
        end
    end
    local NewCastle = ""
    for _,o in pairs(ValidCastle) do
        NewCastle = NewCastle .. o
    end
    Board.Castle = NewCastle

    -- Make Move
    local isCastle = ""
    Board = Module:SetSquare(Board,Move,string.sub(Board.Board[Rank],File,File))
    Board = Module:SetSquare(Board,Square," ")
    table.insert(ReturnMoves,Square .. "-" .. Move)
    if typeof(LegalMoves[CheckMove]) == "table" then
        if LegalMoves[CheckMove][2] == "castle" then
            -- Move Rook
            local Rooks = string.split(LegalMoves[CheckMove][3],"-")
            Board = Module:SetSquare(Board,Rooks[1]," ")
            if Board.Turn == "w" then
                Board = Module:SetSquare(Board,Rooks[2],"R")
            else
                Board = Module:SetSquare(Board,Rooks[2],"r")
            end
            table.insert(ReturnMoves,Rooks[1] .. "-" .. Rooks[2] .. "-castle")

            -- PGN
            if string.sub(Rooks[1],1,1) == "a" then
                isCastle = "O-O-O"
            elseif string.sub(Rooks[1],1,1) == "h" then
                isCastle = "O-O"
            end
        elseif LegalMoves[CheckMove][2] == "Promote" then
            -- Pawn Promotion
            Board = Module:SetSquare(Board,Move,promotePiece)
        else
            -- EnPassant
            Board = Module:SetSquare(Board,LegalMoves[CheckMove][2]," ")
            table.insert(ReturnMoves,LegalMoves[CheckMove][2] .. "-x")
            Board.Move50 = -1
            isCastle = string.sub(Square,1,1) .. "x" .. Move
        end
    end

    -- PGN
    local NewPgn = ""
    if isCastle ~= "" then
        NewPgn = isCastle
    else
        local Piece = string.upper(string.sub(Board.Board[NewRank],NewFile,NewFile))
        if Piece == "P" then
            Board.Move50 = -1
            if isTaking == true then
                NewPgn = string.sub(Square,1,1) .. "x" .. Move
            else
                NewPgn = Move
            end
        else
            if isTaking == true then
                NewPgn = Piece .. "x" .. Move
                Board.Move50 = -1
            else
                NewPgn = Piece .. Move
            end
        end
    end
    if promotePiece ~= "" then
        if isTaking == true then
            NewPgn = string.sub(Square,1,1) .. "x" .. Move
        else
            NewPgn = Move
        end
        NewPgn = NewPgn .. "=" .. string.upper(promotePiece)
    end

    -- Switch Turns
    if Board.Turn == "w" then
        Board.Turn = "b"
        Board.Clocks.w.bonus = 0;
        if Board.Clocks.bonus ~= 0 then
            Board.Clocks.w.clock += Board.Clocks.bonus
        end
    else
        Board.Turn = "w"
        Board.Clocks.b.bonus = 0;
        if Board.Clocks.bonus ~= 0 then
            Board.Clocks.b.clock += Board.Clocks.bonus
        end
    end
    Board.Last = Move;

    -- Threefold Repetition
    if isTaking == true then
        Board.Threefold = {}
    end

    local BoardString = "";
    for i = 1,8,1 do
        BoardString = BoardString .. Board.Board[i] .. "/"
    end
    BoardString = BoardString .. Board.Castle
    -- Find Table
    local DrawThreeFold = false
    local ThreeFoldFound = false
    for _,o in pairs(Board.Threefold) do
        if o[1] == BoardString then
            o[2] += 1;
            ThreeFoldFound = true
            if o[2] == 3 then
                DrawThreeFold = true
            end
            break
        end
    end
    if ThreeFoldFound == false then
        table.insert(Board.Threefold,{BoardString,1})
    end

    -- Check for Checkmate
    local LastTurn = ""
    if Checkmate:CheckForCheckmate(Board,Board.Turn) == true then
        LastTurn = Board.Turn
        Board.Turn = ""
        NewPgn = NewPgn .. "#"
        local Winner
        if LastTurn == "w" then
            Winner = "b";
            NewPgn = NewPgn .. " 0-1"
        else
            Winner = "w";
            NewPgn = NewPgn .. " 1-0"
        end
        Board.Status = "checkmate;" .. Winner
    elseif Checkmate:CheckForStalemate(Board,Board.Turn) == true then
        -- Check for Stalemate
        LastTurn = Board.Turn
        Board.Turn = ""
        Board.Status = "draw;stalemate"
        NewPgn = NewPgn .. " 1/2-1/2"
    elseif Checkmate:CheckForInsufficientMaterial(Board) == true then
        -- Check for Insuffient Material
        LastTurn = Board.Turn
        Board.Turn = ""
        Board.Status = "draw;insufficient material"
        NewPgn = NewPgn .. " 1/2-1/2"
    elseif DrawThreeFold == true then
        LastTurn = Board.Turn
        Board.Turn = ""
        Board.Status = "draw;threefold repetition"
        NewPgn = NewPgn .. " 1/2-1/2"
    elseif Board.Move50 >= 50 then
        LastTurn = Board.Turn
        Board.Turn = ""
        Board.Status = "draw;50 move rule"
        NewPgn = NewPgn .. " 1/2-1/2"
    else
        -- Check for Check
        local King = Moves:GetSquareFromPiece(Board,ColorPieces[Board.Turn])
        if Moves:CheckifCheck(Board, King, Board.Turn) == true then
            NewPgn = NewPgn .. "+"
        end
    end
    Board.Move50 += 1

    -- Edit Board.PGN
    if Board.Turn == "w" or LastTurn == "w" then
        -- Was B now W
        Board.MoveCount += 1
        Board.PGN = Board.PGN .. " " .. NewPgn .. " "
    else
        -- Was W not B
        Board.PGN = Board.PGN .. tonumber(Board.MoveCount) .. ". " .. NewPgn
    end

    return true, Board, ReturnMoves
end

return Module
