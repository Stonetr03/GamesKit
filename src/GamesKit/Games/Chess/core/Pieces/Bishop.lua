-- Stonetr03

local Module = {}

local WhitePieces = {"R","N","B","Q","K","P"}
local BlackPieces = {"r","n","b","q","k","p"}

local Files = {
    [1] = "a";
    [2] = "b";
    [3] = "c";
    [4] = "d";
    [5] = "e";
    [6] = "f";
    [7] = "g";
    [8] = "h";
}

function Module:GetMoves(Board,File,Rank,Color)
    local Moves = {}
    if Color == "w" then
        -- Check White Piece
        -- Check NE
        for i = 1,7,1 do
            local Sqr = {File+i,Rank+i}
            if Sqr[1] > 8 or Sqr[2] > 8 then
                break
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(BlackPieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                    break
                else
                    -- White Piece
                    break
                end
            end
        end
        -- Check NW
        for i = 1,7,1 do
            local Sqr = {File-i,Rank+i}
            if Sqr[1] < 1 or Sqr[2] > 8 then
                break
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(BlackPieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                    break
                else
                    -- White Piece
                    break
                end
            end
        end
        -- Check SE
        for i = 1,7,1 do
            local Sqr = {File+i,Rank-i}
            if Sqr[1] > 8 or Sqr[2] < 1 then
                break
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(BlackPieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                    break
                else
                    -- White Piece
                    break
                end
            end
        end
        -- Check SW
        for i = 1,7,1 do
            local Sqr = {File-i,Rank-i}
            if Sqr[1] < 1 or Sqr[2] < 1 then
                break
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(BlackPieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                    break
                else
                    -- White Piece
                    break
                end
            end
        end
    elseif Color == "b" then
        -- Check Black Piece
        -- Check NE
        for i = 1,7,1 do
            local Sqr = {File+i,Rank+i}
            if Sqr[1] > 8 or Sqr[2] > 8 then
                break
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(WhitePieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                    break
                else
                    -- White Piece
                    break
                end
            end
        end
        -- Check NW
        for i = 1,7,1 do
            local Sqr = {File-i,Rank+i}
            if Sqr[1] < 1 or Sqr[2] > 8 then
                break
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(WhitePieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                    break
                else
                    -- White Piece
                    break
                end
            end
        end
        -- Check SE
        for i = 1,7,1 do
            local Sqr = {File+i,Rank-i}
            if Sqr[1] > 8 or Sqr[2] < 1 then
                break
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(WhitePieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                    break
                else
                    -- White Piece
                    break
                end
            end
        end
        -- Check SW
        for i = 1,7,1 do
            local Sqr = {File-i,Rank-i}
            if Sqr[1] < 1 or Sqr[2] < 1 then
                break
            else
                local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
                if Piece == " " then
                    -- Blank Space
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                elseif table.find(WhitePieces,Piece) then
                    -- Black Piece
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                    break
                else
                    -- White Piece
                    break
                end
            end
        end
    end
    return Moves
end

return Module
