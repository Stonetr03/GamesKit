-- Stonetr03 - GamesKit

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local Create = require(script.Parent.Parent:WaitForChild("CreateModule"))
local HttpService = game:GetService("HttpService")

local GamesList = {
    [1] = "Chess";
    [2] = "Tic-Tac-Toe";
}

local RS = Api:CreateRSFolder("GamesKit")
script:WaitForChild("Markdown").Parent = RS
Create("StringValue",RS,{Value = HttpService:JSONEncode(GamesList),Name = "GamesList"})

local ReqCooldown = {}
Api:RegisterCommand("games","Shows the list of games.",function(p,Args)
    if ReqCooldown[p] == nil then
        ReqCooldown[p] = true;
        script.gamesList:Clone().Parent = p:WaitForChild("PlayerGui")
        task.wait(5);
        ReqCooldown[p] = nil;
    else
        Api:InvalidPermissionsNotification(p)
    end
end,"1;[player];")

return true