-- Stonetr03 - GamesKit

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local Create = require(script.Parent.Parent:WaitForChild("CreateModule"))
local HttpService = game:GetService("HttpService")
local invites = require(script:WaitForChild("invites"));

export type hash = string;
export type ActiveGame = {
    Type: string;
    Players: {Players};
    Public: boolean; -- Weather the game can be joined using !join
    Pending: boolean; -- Allows players to join game.
}

export type GameInfo = {
    Name: string;
    Alias: {string};
    Image: string;
    HowToPlay: string;

    PlayersAmt: number;
    PlayersRequired: boolean?; -- Indicates if a game is a duel, only works for 2 player games.

    StartGame: (hash: string, plrs: {Player}) -> ();
    EndGame: (hash: string, p: Player?) -> ();
    StopGame: (hash: string) -> (); -- NOTE: This function is added by this script, not by the game's script.
    AddPlayer: (hash: string, p: Player) -> ();
}

local GamesList = {} :: {[string]: GameInfo}

local GameInfo = {}

local ActiveGames = {} :: {[hash]: ActiveGame}

local RS = Api:CreateRSFolder("GamesKit")
script:WaitForChild("Markdown").Parent = RS
script:WaitForChild("HowTo").Parent = RS

for _,o in pairs(script:WaitForChild("Games"):GetChildren()) do
    local info = require(o)
    GameInfo[info.Name] = info
    table.insert(GamesList,info.Name)
    info.StopGame = function(hash)
        if ActiveGames[hash] then
            ActiveGames[hash] = nil;
        end
    end
end

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
end,"1;[player];",{"games-list"})

Api:OnInvoke("GamesKit-GetInfo",function(p,Args)
    if GameInfo[Args] then
        return GameInfo[Args]
    end
    return {}
end)

function ShuffleTable(t)
    local shuffled = table.clone(t)

    for i = #shuffled, 2, -1 do
        local randomGenerator = Random.new()
        local randomIndex = math.random(randomGenerator:NextInteger(1, i))
        shuffled[i], shuffled[randomIndex] = shuffled[randomIndex], shuffled[i]
    end

    return shuffled
end

function StartGame(plrs: {Players}, gameName: string): hash
    plrs = ShuffleTable(plrs)
    for _,p in pairs(plrs) do
        Api:Notification(p,GameInfo[gameName].Image,"Starting game " .. gameName .. ".")
    end
    -- Start Game
    local hash = HttpService:GenerateGUID(true);
    local tab = {
        Type = gameName;
        Players = plrs;
    }
    ActiveGames[hash] = tab;
    GameInfo[gameName].StartGame(hash,plrs)
    return hash;
end

invites.gameInfo = GameInfo;
invites.isInGame = function(p: Player): boolean
    for _,o in pairs(ActiveGames) do
        for _,plr in pairs(o.Players) do
            if plr == p then
                return true;
            end
        end
    end
    return false;
end
invites.joinGame = function(hash: string, p: Player)
    if ActiveGames[hash] then
        if not table.find(ActiveGames[hash].Players,p) then
            table.insert(ActiveGames[hash].Players,p);
            if typeof(GameInfo[ ActiveGames[hash].Type ].AddPlayer) == "function" then
                GameInfo[ ActiveGames[hash].Type ].AddPlayer(hash, p);
            else
                warn("NO ADD PLAYER FUNCTION FOR " .. ActiveGames[hash].Type);
            end
        end
    else
        warn("NO ACTIVE GAME FOR HASH " .. hash);
    end
end
invites.startDuel = StartGame;

-- Challenges
--NOTE: THIS WILL NOT WORK WITH >2 PLAYER GAMES
Api:RegisterCommand("challenge","Challenge a player to a game.",function(p,Args)
    -- find game
    local found = false;
    for _,g in pairs(GamesList) do
        if string.lower(g) == Args[1] then
            found = g;
        end
    end
    if found == false then
        for n,g in pairs(GameInfo) do
            if typeof(g.Alias) == "table" then
                for _,o in pairs(g.Alias) do
                    if string.lower(o) == Args[1] then
                        found = n;
                    end
                end
            end
        end
    end
    if found ~= false then
        local plrs = Api:GetPlayer(Args[2],p)

        if GameInfo[found].PlayersAmt == 1 then
            -- Start Game
            StartGame({p},found)
        elseif GameInfo[found].PlayersAmt == 2 and GameInfo[found].PlayersRequired and #plrs >= 1 then
            invites:SendInvite(found,p,plrs[1]);
        elseif GameInfo[found].PlayersAmt >= 2 and not GameInfo[found].PlayersRequired then
            local hash = StartGame({p},found)
            for _,plr in pairs(plrs) do
                invites:SendInvite(found,p,plr,hash);
            end
        else
            Api:Notification(p,false,"Invalid game param, please try sending invite again.")
        end

    else
        Api:Notification(p,false,"Game not found")
    end
end,"1;*[string];*[string];",{"play"})

game.Players.PlayerRemoving:Connect(function(p)
    for h,g in pairs(ActiveGames) do
        for _,plr in pairs(g.Players) do
            if plr == p then
                -- End Game
                GameInfo[g.Type].EndGame(h,p)
                ActiveGames[h] = nil;
            end
        end
    end
    --[[for _,c in pairs(OpenChallenges) do
        if table.find(c.Players,p) then
            -- Remove Challenge
            if table.find(OpenChallenges,c) then
                table.remove(OpenChallenges,table.find(OpenChallenges,c))
            end
        end
    end]]
end)

Api:OnInvoke("GamesKit-getHowTo",function(p,name)
    if GameInfo[name] and GameInfo[name].HowToPlay then
        return GameInfo[name].HowToPlay
    end
    return "*requested game HowToPlay unavaliable*"
end)

return true