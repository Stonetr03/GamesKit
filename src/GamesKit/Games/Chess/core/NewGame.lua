-- Stonetr03 - Makes new games

local Clocks = require(script.Parent:WaitForChild("Clock"))

local Module = {}

local InvertTab = {
    [1] = 8;
    [2] = 7;
    [3] = 6;
    [4] = 5;
    [5] = 4;
    [6] = 3;
    [7] = 2;
    [8] = 1;
}

local Pieces = {"r","n","b","q","k","p","R","N","B","Q","K","P"}

function Module:New(Hash,FEN,p1,p2,Seconds: number, BonusTime: number) -- Time in Seconds
    if FEN == nil then
        FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1" -- Board turn Castle enPassantTarget(or -) 
    end
    local FENSplit = string.split(FEN," ")
    -- Render Board
    local Board = {
        [8] = "";
        [7] = "";
        [6] = "";
        [5] = "";
        [4] = "";
        [3] = "";
        [2] = "";
        [1] = "";
    }
    local BoardSplit = string.split(FENSplit[1],"/")
    for i = 1,8,1 do
        local FenCode = BoardSplit[ InvertTab[i] ]
        local Str = ''
        for v = 1,string.len(FenCode),1 do
            local Letter = string.sub(FenCode,v,v)
            if tonumber(Letter) ~= nil then
                -- Empty Space
                for _ = 1,tonumber(Letter),1 do
                    Str = Str .. " "
                end
            else
                if table.find(Pieces,Letter) ~= "nil" then
                    -- Valid Piece
                    Str = Str .. Letter
                else
                    Str = Str .. " "
                end
            end
        end
        -- Check Length
        if string.len(Str) ~= 8 then
            for _ = 1, 8 - string.len(Str),1 do
                Str = Str .. " "
            end
        end

        Board[i] = Str
    end
    -- Move
    local Move = "w"
    if FENSplit[2] == "b" then
        Move = "b"
    end
    -- Castleing
    local Castle = ""
    local ValidCastle = {"K","Q","k","q"}
    for i = 1,string.len(FENSplit[3]),1 do
        if table.find(ValidCastle,string.sub(FENSplit[3],i,i)) ~= nil then
            Castle = Castle .. string.sub(FENSplit[3],i,i)
            table.remove(ValidCastle,table.find(ValidCastle,string.sub(FENSplit[3],i,i)))
        end
    end
    -- EnPassant
    local LastMove = ""
    if FENSplit[4] ~= "-" then
        LastMove = FENSplit[4]
    end
    -- Players
    if p1 == nil then
        p1 = "White"
    end
    if p2 == nil then
        p2 = "Black"
    end
    -- PGN
    local PGN = ""
    if Move == "b" then
        PGN = (tonumber(FENSplit[6]) or tostring(1)) .. ". ..."
    end
    -- Clocks
    if typeof(Seconds) ~= "number" or Seconds < 0 then
        Seconds = 120*60
    end
    if typeof(BonusTime) ~= "number" then
        BonusTime = 0;
    end
    Clocks:RunClock(Hash)
    return {
        Board = Board;
        Turn = Move;
        Castle = Castle;
        Last = LastMove;
        White = p1;
        Black = p2;
        Hash = Hash;
        Status = "";
        MoveCount = tonumber(FENSplit[6]) or 1;
        PGN = PGN;
        Threefold = {};
        Draw = {false,false};
        Move50 = 0;
        Clocks = {
            w = {
                bonus = 5;
                clock = Seconds
            };
            b = {
                bonus = 5;
                clock = Seconds
            };
            bonus = BonusTime
        }
    }
end

return Module
