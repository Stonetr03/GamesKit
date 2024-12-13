-- Stonetr03

local Api = require(script.Parent.Parent.Parent.Parent:WaitForChild("Api"))

local ActiveGames = {}

local Module = {
    Name = "Tic-Tac-Toe";
    Alias = {"TicTacToe"};
    Image = "rbxassetid://15203011711";
    HowToPlay = [=[# How to Play Tic-Tac-Toe

Tic-Tac-Toe is a simple two-player game. The objective is to be the first to get three of your marks (X or O) in a row, either horizontally, vertically, or diagonally.

## Rules:

1. Player 1 is X, and Player 2 is O.
2. Players take turns to place their symbol on an empty cell on the grid.
3. The game continues until one player gets three of their symbols in a row or the grid is full, resulting in a draw.

## Winning:

To win, you must create a row, column, or diagonal of three of your marks before your opponent does. The first player to do so is the winner.]=];
    PlayersAmt = 2;
    PlayersRequired = true;

    StartGame = function(hash: string,plrs: table)
        ActiveGames[hash] = {
            p1 = plrs[1];
            p2 = plrs[2];
            turn = "X";
            board = {
                [1] = 0; [2] = 0; [3] = 0;
                [4] = 0; [5] = 0; [6] = 0;
                [7] = 0; [8] = 0; [9] = 0;
            };
            status = "";
        };

        -- Ui
        for _,p in pairs(plrs) do
            local ui = script.Ui:Clone()
            ui.hash.Value = hash
            ui.Parent = p:WaitForChild("PlayerGui")
        end
    end;
    EndGame = function(hash: string,p: Player|nil)
        if ActiveGames[hash] then
            if p == ActiveGames[hash].p1 then
                ActiveGames[hash].turn = "O"
                ActiveGames[hash].status = "O10"
            elseif p == ActiveGames[hash].p2 then
                ActiveGames[hash].turn = "X"
                ActiveGames[hash].status = "X10"
            else
                ActiveGames[hash].turn = ""
                ActiveGames[hash].status = "T10"
            end
            Api:Fire(ActiveGames[hash].p1,"GamesKit-Tic-Tac-Toe",hash,ActiveGames[hash])
            Api:Fire(ActiveGames[hash].p2,"GamesKit-Tic-Tac-Toe",hash,ActiveGames[hash])
            ActiveGames[hash] = nil;
        end
    end;
    StopGame = nil;
}

function CheckEnding(board)
    if board[1] ~= 0 and board[1] == board[2] and board[2] == board[3] then
        return board[1],1
    elseif board[4] ~= 0 and board[4] == board[5] and board[5] == board[6] then
        return board[4],2
    elseif board[7] ~= 0 and board[7] == board[8] and board[8] == board[9] then
        return board[7],3
    elseif board[1] ~= 0 and board[1] == board[4] and board[4] == board[7] then
        return board[1],4
    elseif board[2] ~= 0 and board[2] == board[5] and board[5] == board[8] then
        return board[2],5
    elseif board[3] ~= 0 and board[3] == board[6] and board[6] == board[9] then
        return board[3],6
    elseif board[1] ~= 0 and board[1] == board[5] and board[5] == board[9] then
        return board[1],7
    elseif board[3] ~= 0 and board[3] == board[5] and board[5] == board[7] then
        return board[3],8
    elseif board[1] ~= 0 and board[2] ~= 0 and board[3] ~= 0 and board[4] ~= 0 and board[5] ~= 0 and board[6] ~= 0 and board[7] ~= 0 and board[8] ~= 0 and board[9] ~= 0 then
        return 3,9
    end
    return 0
end

Api:OnEvent("GamesKit-Tic-Tac-Toe",function(p: Player,hash: string,move: number)
    if typeof(move) ~= "number" or move < 0 or move > 9 then
        return
    end
    if ActiveGames[hash] then
        if ActiveGames[hash].board[move] == 0 then
            -- legal
            if ActiveGames[hash].turn == "X" and ActiveGames[hash].p1 == p then
                -- Make Move
                ActiveGames[hash].board[move] = 1
            elseif ActiveGames[hash].turn == "O" and ActiveGames[hash].p2 == p then
                -- Make Move
                ActiveGames[hash].board[move] = 2
            else
                return
            end

            -- Check for Ending
            local ending,endType = CheckEnding(ActiveGames[hash].board)
            if ending == 1 then
                ActiveGames[hash].status = "X" .. endType;
            elseif ending == 2 then
                ActiveGames[hash].status = "O" .. endType;
            elseif ending == 3 then
                ActiveGames[hash].status = "T" .. endType;
                ActiveGames[hash].turn = ""
            else
                -- Switch Turns
                if ActiveGames[hash].turn == "X" then
                    ActiveGames[hash].turn = "O"
                else
                    ActiveGames[hash].turn = "X"
                end
            end

            -- Update Board
            Api:Fire(ActiveGames[hash].p1,"GamesKit-Tic-Tac-Toe",hash,ActiveGames[hash])
            Api:Fire(ActiveGames[hash].p2,"GamesKit-Tic-Tac-Toe",hash,ActiveGames[hash])

            -- End Game
            if ending ~= 0 then
                ActiveGames[hash] = nil
                Module.StopGame(hash)
            end
        end
    end
end)

Api:OnInvoke("GamesKit-Get-Tic-Tac-Toe",function(p: Player,hash: string)
    if ActiveGames[hash] then
        return ActiveGames[hash]
    end
    return {};
end)

Api:OnEvent("GamesKit-Quit-Tic-Tac-Toe",function(p: Player,hash: string)
    if ActiveGames[hash] then
        if ActiveGames[hash].p1 == p or ActiveGames[hash].p2 == p then
            Module.EndGame(hash,p)
            Module.StopGame(hash)
        end
    end
end)

return Module
