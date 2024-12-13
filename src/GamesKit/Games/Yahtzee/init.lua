-- Stonetr03

local Api = require(script.Parent.Parent.Parent.Parent:WaitForChild("Api"))

local ActiveGames = {}

local Module = {
    Name = "Yahtzee";
    Image = "rbxassetid://15203011711";
    HowToPlay = [=[Yahtzee...]=];
    PlayersAmt = 50;

    StartGame = function(hash: string,plrs: table)
        ActiveGames[hash] = {
            
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
            
            ActiveGames[hash] = nil;
        end
    end;
    StopGame = nil;
}

return Module
