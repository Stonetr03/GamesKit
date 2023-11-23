-- Stonetr03
-- Modified from Stonetr03/Chess
-- - removed Challenge Stuff
-- - no printing
-- + NewGame accepts hash arg

local NewGame = require(script:WaitForChild("NewGame"))
--local PrintBoard = require(script:WaitForChild("PrintBoard"))
local Moves = require(script:WaitForChild("Moves"))
local PlayMove = require(script:WaitForChild("PlayMove"))
local Signal = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Signal"))
local Clocks = require(script:WaitForChild("Clock"))

local legalPromote = {"r","n","b","q","","nil"}

local Module = {
    Games = {};
    Signals = {};
    OtherSignal = Signal.new();
}

function Module:NewGame(Hash: string,p1: Player,p2: Player)
    Module.Games[Hash] = NewGame:New(Hash,nil,p1,p2,10 * 60,0)
    --PrintBoard(Module.Games[Hash])
    local GameSignal = Signal.new()
    Module.Signals[Hash] = GameSignal;
    return Hash,GameSignal
end

function Module:GetLegalMoves(Hash: string,Square: string)
    local Board = Module.Games[Hash]
    if Board then
        return Moves:GetLegalMoves(Board,Square)
    end
end

function Module:Playmove(Hash: string,Player: Player,Square: string,Move: string,Promote: string)
    if not table.find(legalPromote,string.lower(tostring(Promote))) then return end
    local Board = Module.Games[Hash]
    if Board then
        local Moved,New,UpdateMoves = PlayMove:Move(Board,Player,Square,Move,Promote)
        if Moved == true then
            Module.Games[Hash] = New
            Module.Signals[Hash]:Fire(UpdateMoves,New)
            --PrintBoard(Module.Games[Hash])
            --print(UpdateMoves)
            if New.Status ~= "" then
                Module:Cleanup(Hash)
            end
            return true
        end
    end
    return false
end

function Module:Draw(Hash: string,Player: Player,v: boolean)
    local Board = Module.Games[Hash]
    if Board and typeof(v) == "boolean" and Board.Status == "" then
        if Board.White == Player then
            if Board.Draw[1] == v then
                return
            end
            Board.Draw[1] = v
        elseif Board.Black == Player then
            if Board.Draw[2] == v then
                return
            end
            Board.Draw[2] = v
        else
            return
        end
    end
    if v == false then
        Board.Draw = {false,false}
    end
    if Board.Draw[1] == true and Board.Draw[2] == true then
        Board.Turn = ""
        Board.Status = "draw;agreement"
        Board.PGN = Board.PGN .. " 1/2-1/2"
        Module.Signals[Hash]:Fire({},Board)
        Module:Cleanup(Hash)
    elseif Board.Draw[1] == true and Board.Draw[2] == false then
        Module.OtherSignal:Fire("Draw",Hash,Board.Black)
    elseif Board.Draw[1] == false and Board.Draw[2] == true then
        Module.OtherSignal:Fire("Draw",Hash,Board.White)
    end
end

function Module:Resign(Hash: string,Player: Player)
    local Board = Module.Games[Hash]
    if Board and Board.Status == "" then
        if Board.White == Player then
            Board.Turn = ""
            Board.Status = "resign;b"
            Board.PGN = Board.PGN .. " 0-1"
            Module.Signals[Hash]:Fire({},Board)
            Module:Cleanup(Hash)
        elseif Board.Black == Player then
            Board.Turn = ""
            Board.Status = "resign;w"
            Board.PGN = Board.PGN .. " 1-0"
            Module.Signals[Hash]:Fire({},Board)
            Module:Cleanup(Hash)
        end
    end
end

function Module:Cleanup(Hash: string) -- This needs to be integrated with all game ending functions
    if Module.Games[Hash] then
        if Module.Games[Hash].Status == "" then
            local Board = Module.Games[Hash]
            Board.Turn = ""
            Board.Status = "draw;agreement"
            Board.PGN = Board.PGN .. " 1/2-1/2"
            Module.Signals[Hash]:Fire({},Board)
        end
        Module.Games[Hash] = nil;
    end
    if Module.Signals[Hash] then
        Module.Signals[Hash]:Destroy();
    end
    Clocks:StopClock(Hash)
    Module.OtherSignal:Fire("Cleanup",Hash)
end

game.Players.PlayerRemoving:Connect(function(p)
    -- Remove Boards
    for _,g in pairs(Module.Games) do
        if g.White == p or g.Black == p then
            Module:Resign(g.Hash,p)
        end
    end
end)

-- Clocks
Clocks.Games = Module.Games
Clocks.GameOver = function(Hash,Color)
    local Board = Module.Games[Hash]
    if Color == "w" then
        local Pieces = Moves:GetPieces(Board,"b")
        if #Pieces == 1 then
            -- Draw
            Board.Turn = ""
            Board.Status = "draw;timeout"
            Board.PGN = Board.PGN .. " 1/2-1/2"
            Module.Signals[Hash]:Fire({},Board)
            Module:Cleanup(Hash)
        else
            -- Loose
            Board.Turn = ""
            Board.Status = "timeout;b"
            Board.PGN = Board.PGN .. " 0-1"
            Module.Signals[Hash]:Fire({},Board)
            Module:Cleanup(Hash)
        end

    else
        local Pieces = Moves:GetPieces(Board,"w")
        if #Pieces == 1 then
            -- Draw
            Board.Turn = ""
            Board.Status = "draw;timeout"
            Board.PGN = Board.PGN .. " 1/2-1/2"
            Module.Signals[Hash]:Fire({},Board)
            Module:Cleanup(Hash)
        else
            -- Loose
            Board.Turn = ""
            Board.Status = "timeout;w"
            Board.PGN = Board.PGN .. " 1-0"
            Module.Signals[Hash]:Fire({},Board)
            Module:Cleanup(Hash)
        end
    end
end;

return Module
