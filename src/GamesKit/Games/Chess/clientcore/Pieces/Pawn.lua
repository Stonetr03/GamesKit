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
        -- Get Piece Above
        if Rank+1 <= 8 then
            local AboveSqr = {File,Rank+1}
            local AbovePiece = string.sub(Board.Board[AboveSqr[2]],AboveSqr[1],AboveSqr[1])
            if AbovePiece == " " and Rank+1 ~= 8 then
                table.insert(Moves,Files[File] .. tostring(AboveSqr[2]))

                -- Check if First Move
                if Rank == 2 then
                    local AboveSqr2 = {File,Rank+2}
                    local AbovePiece2 = string.sub(Board.Board[AboveSqr2[2]],AboveSqr2[1],AboveSqr2[1])
                    if AbovePiece2 == " " then
                        table.insert(Moves,Files[File] .. tostring(AboveSqr2[2]))
                    end
                end
            elseif AbovePiece == " " and Rank+1 == 8 then
                -- Promotion
                for i = 1,4,1 do
                    table.insert(Moves,{Files[File] .. tostring(AboveSqr[2]),"Promote",WhitePieces[i]})
                end
            end
        end
        -- Check Takes
        if File < 8 then
            local Sqr = {File+1,Rank+1}
            local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
            if table.find(BlackPieces,Piece) then
                -- Can Take
                if Sqr[2] == 8 then
                    for i = 1,4,1 do
                        table.insert(Moves,{Files[Sqr[1]] .. tostring(Sqr[2]),"Promote",WhitePieces[i]})
                    end
                else
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                end
            end
        end
        if File > 1 then
            local Sqr = {File-1,Rank+1}
            local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
            if table.find(BlackPieces,Piece) then
                -- Can Take
                if Sqr[2] == 8 then
                    for i = 1,4,1 do
                        table.insert(Moves,{Files[Sqr[1]] .. tostring(Sqr[2]),"Promote",WhitePieces[i]})
                    end
                else
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                end
            end
        end
        -- EnPassant
        if File > 1 then
            local Sqr = {File+1,Rank}
            local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
            if Piece == "p" and Board.Last == Files[Sqr[1]] .. tostring(Sqr[2]) then
                -- Can Take
                table.insert(Moves,{Files[Sqr[1]] .. tostring(Sqr[2] + 1),Files[Sqr[1]] .. tostring(Sqr[2])})
            end
        end
        if File < 8 then
            local Sqr = {File-1,Rank}
            local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
            if Piece == "p" and Board.Last == Files[Sqr[1]] .. tostring(Sqr[2]) then
                -- Can Take
                table.insert(Moves,{Files[Sqr[1]] .. tostring(Sqr[2] + 1),Files[Sqr[1]] .. tostring(Sqr[2])})
            end
        end

    elseif Color == "b" then
        -- Check Black Piece
        -- Get Piece Above
        if Rank-1 >= 1 then
            local AboveSqr = {File,Rank-1}
            local AbovePiece = string.sub(Board.Board[AboveSqr[2]],AboveSqr[1],AboveSqr[1])
            if AbovePiece == " " and Rank-1 ~= 1 then
                table.insert(Moves,Files[File] .. tostring(AboveSqr[2]))

                -- Check if First Move
                if Rank == 7 then
                    local AboveSqr2 = {File,Rank-2}
                    local AbovePiece2 = string.sub(Board.Board[AboveSqr2[2]],AboveSqr2[1],AboveSqr2[1])
                    if AbovePiece2 == " " then
                        table.insert(Moves,Files[File] .. tostring(AboveSqr2[2]))
                    end
                end
            elseif AbovePiece == " " and Rank-1 == 1 then
                -- Promotion
                for i = 1,4,1 do
                    table.insert(Moves,{Files[File] .. tostring(AboveSqr[2]),"Promote",BlackPieces[i]})
                end
            end
        end
        -- Check Takes
        if File < 8 then
            local Sqr = {File+1,Rank-1}
            local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
            if table.find(WhitePieces,Piece) then
                -- Can Take
                if Sqr[2] == 1 then
                    for i = 1,4,1 do
                        table.insert(Moves,{Files[Sqr[1]] .. tostring(Sqr[2]),"Promote",BlackPieces[i]})
                    end
                else
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                end
            end
        end
        if File > 1 then
            local Sqr = {File-1,Rank-1}
            local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
            if table.find(WhitePieces,Piece) then
                -- Can Take
                if Sqr[2] == 1 then
                    for i = 1,4,1 do
                        table.insert(Moves,{Files[Sqr[1]] .. tostring(Sqr[2]),"Promote",BlackPieces[i]})
                    end
                else
                    table.insert(Moves,Files[Sqr[1]] .. tostring(Sqr[2]))
                end
            end
        end
        -- EnPassant
        if File > 1 then
            local Sqr = {File+1,Rank}
            local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
            if Piece == "P" and Board.Last == Files[Sqr[1]] .. tostring(Sqr[2]) then
                -- Can Take
                table.insert(Moves,{Files[Sqr[1]] .. tostring(Sqr[2] - 1),Files[Sqr[1]] .. tostring(Sqr[2])})
            end
        end
        if File < 8 then
            local Sqr = {File-1,Rank}
            local Piece = string.sub(Board.Board[Sqr[2]],Sqr[1],Sqr[1])
            if Piece == "P" and Board.Last == Files[Sqr[1]] .. tostring(Sqr[2]) then
                -- Can Take
                table.insert(Moves,{Files[Sqr[1]] .. tostring(Sqr[2] - 1),Files[Sqr[1]] .. tostring(Sqr[2])})
            end
        end

    end
    return Moves
end

return Module
