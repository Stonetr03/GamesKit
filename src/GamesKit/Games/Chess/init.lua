-- Stonetr03

script.Parent.Parent.Parent.Parent.Parent = game.ServerScriptService
local Api = require(script.Parent.Parent.Parent.Parent:WaitForChild("Api"))
local core = require(script:WaitForChild("core"))

local GameListeners = {}

script:WaitForChild("clientcore").Parent = script:WaitForChild("ui")
local picker = script:WaitForChild("Picker")
picker.Name = "Chess_Picker"
picker.Parent = game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("GamesKit")

local Module = {
    Name = "Chess";
    Image = "rbxassetid://14388088851";
    HowToPlay = [==[# How to Play Chess

---

## Objective
The objective of chess is to checkmate your opponent's king. 

## Setup

- Each player starts with 16 pieces: 
    - 1 king 
    - 1 queen 
    - 2 rooks 
    - 2 knights 
    - 2 bishops 
    - 8 pawns
- The board consists of 64 squares in an 8x8 grid.

## Movement

- **King**: Moves one square in any direction.
- **Queen**: Moves diagonally, horizontally, or vertically any number of squares.
- **Rook**: Moves horizontally or vertically any number of squares.
- **Bishop**: Moves diagonally any number of squares.
- **Knight**: Moves in an L-shape (2 squares in one direction and 1 square perpendicular).
- **Pawn**: Moves forward but captures diagonally. On its first move, a pawn can move two squares forward.

## Special Moves

- **Castling**: Move the king two squares towards a rook, and the rook moves to the square next to the king.
- **En Passant**: Capturing a pawn that has moved two squares forward from its starting position.
- **Promoting**: When a pawn reaches the end of the board, it promotes to any other piece except for a king.

## Check and Checkmate

- **Check**: When the king is under threat of capture by the opponent's move.
- **Checkmate**: When a player's king is in check and there is no legal move to escape the threat.

## Game End

- The game ends when a player achieves checkmate, resignation, stalemate, or a draw by insufficient material or the fifty-move rule.

## Conclusion
Chess is a game of strategy and patience. Enjoy the game!
]==];
    PlayersAmt = 2;
    PlayersRequired = true;

    StartGame = function(hash: string,plrs: table)
        local p1 = plrs[1]
        local p2 = plrs[2]

        -- Load Ui
        for _,p in pairs(plrs) do
            local ui = script.ui:Clone()
            ui.hash.Value = hash;
            ui.Name = "ChessUi"
            ui.Parent = p:WaitForChild("PlayerGui"):WaitForChild("__AdminCube_Main")
        end
        task.wait()

        -- Start Game
        core:NewGame(hash,p1,p2)

        GameListeners[hash] = plrs

        core.Signals[hash]:Connect(function(Moves,Newboard)
            for _,p in pairs(GameListeners[hash]) do
                Api:Fire(p,"GamesKit-Chess-UpdateGame",hash,Moves,Newboard)
            end
        end)
    end;
    EndGame = function(hash: string,p: Player|nil)
        if GameListeners[hash] then
            if core.Games[hash] and core.Games[hash].Status == "" then
                if p == core.Games[hash].White or p == core.Games[hash].Black then
                    core:Resign(hash,p)
                end
            end
            core:Cleanup(hash)
        end
    end;
    StopGame = nil;
}

core.OtherSignal:Connect(function(t,hash,v1)
    if t == "Draw" then
        Api:Fire(v1,"GamesKit-Chess-DrawUpdate",hash)
    elseif t == "Cleanup" then
        -- Cleanup
        if GameListeners[hash] then
            GameListeners[hash] = nil;
        end
        Module.StopGame(hash)
    end
end)

Api:OnInvoke("GamesKit-Chess:GetBoardFomHash",function(p,Hash)
    if core.Games[Hash] then
        return core.Games[Hash]
    end
    return nil
end)

Api:OnInvoke("GamesKit-Chess:ListenHash",function(p,Hash,Value)
    if core.Games[Hash] and GameListeners[Hash] then
        if Value == true then
            if table.find(GameListeners[Hash],p) == nil then
                table.insert(GameListeners[Hash],p)
            end
            return true
        elseif Value == false then
            if table.find(GameListeners[Hash],p) then
                table.remove(GameListeners[Hash],table.find(GameListeners[Hash],p))
            end
            return true
        end
    end
    return false
end)

-- Make Move
Api:OnInvoke("GamesKit-Chess:MakeMove",function(p,Hash,Sqr,Move,Promote)
    if core.Games[Hash] then
        if core.Games[Hash].Turn == "w" and core.Games[Hash].White == p then
        elseif core.Games[Hash].Turn == "b" and core.Games[Hash].Black == p then
        else
            return
        end
        return core:Playmove(Hash,p,Sqr,Move,Promote)
    end
    return false
end)

-- Resign
Api:OnInvoke("GamesKit-Chess:Resign",function(p,Hash)
    if core.Games[Hash] then
        core:Resign(Hash,p)
    end
end)
Api:OnInvoke("GamesKit-Chess:Draw",function(p,Hash,Value)
    if core.Games[Hash] then
        core:Draw(Hash,p,Value)
    end
end)

return Module
