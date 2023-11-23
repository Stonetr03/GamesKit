-- Stonetr03 - Prints the board

function PrintBoard(board)
    local Txt = " \n========\n"
    Txt = Txt .. "B:" .. tostring(board.Black) .. "\n--------\n"
    -- Board
    for i = 8,1,-1 do
        Txt = Txt .. board.Board[i] .. "\n"
    end
    Txt = Txt .. "--------\nW:" .. tostring(board.White) .. "\n--------\n" .. "T:" .. board.Turn .. ", C:" .. board.Castle .. ", L:" .. board.Last .. ", s:" .. board.Status .. "\n========\n" .. board.PGN .. "\n========\n"
    print(Txt)
    return
end

return PrintBoard
