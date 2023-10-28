-- Stonetr03

local Api = require(script.Parent.Parent.Parent.Parent:WaitForChild("Api"))

local Module = {
    Name = "Chess";
    Image = "rbxassetid://14388088851";
    HowToPlay = [=[# How to Play Chess]=];
    PlayersAmt = 2;

    StartGame = function(hash: string,plrs: table)
        
    end;
    EndGame = function(hash: string,p: Player|nil)
        
    end;
    StopGame = nil;
}

return Module
