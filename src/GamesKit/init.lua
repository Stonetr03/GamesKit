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
    StopGame: (hash: string) -> (); -- NOTE: This function is added by THIS script, not by the game's script.
    AddPlayer: (hash: string, p: Player) -> ();
    CanInvite: (hash: string, p: Player) -> ()?;
    SetPublic: (hash: string, public: boolean) -> (); -- NOTE: This function is added by THIS script, not by the game's script.
    SetPending: (hash: string, pending: boolean) -> (); -- NOTE: This function is added by THIS script, not by the game's script.
    RemovePlayer: (hash: string, p: Player) -> (); -- NOTE: This function is added by THIS script, not by the game's script.
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
    info.SetPublic = function(hash: hash, public: boolean)
        if ActiveGames[hash] then
            ActiveGames[hash].Public = public;
        end
    end
    info.SetPending = function(hash: hash, pending: boolean)
        if ActiveGames[hash] then
            ActiveGames[hash].Pending = pending;
        end
    end
    info.RemovePlayer = function(hash: hash, p: Player)
        if ActiveGames[hash] then
            if table.find(ActiveGames[hash].Players,p) then
                table.remove(ActiveGames[hash].Players,table.find(ActiveGames[hash].Players,p));                
            end
            if #ActiveGames[hash].Players <= 0 then
                -- Quit Game
                GameInfo[ ActiveGames[hash].Type ].EndGame(hash)
                GameInfo[ ActiveGames[hash].Type ].StopGame(hash)
            end
        end
    end
end

Create("StringValue",RS,{Value = HttpService:JSONEncode(GamesList),Name = "GamesList"})

local ReqCooldown = {}
Api:RegisterCommand("games","Shows the list of games.",function(p)
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

function isInGame(p: Player): hash | false
    for h: hash,g in pairs(ActiveGames) do
        if table.find(g.Players,p) then
            return h;
        end
    end
    return false;
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
        Public = false;
        Pending = true;
    }
    if GameInfo[gameName].PlayersAmt ~= 1 then
        ActiveGames[hash] = tab;
    end
    GameInfo[gameName].StartGame(hash,plrs)
    return hash;
end

invites.gameInfo = GameInfo;
invites.isInGame = isInGame;
invites.joinGame = function(hash: string, p: Player): boolean
    if isInGame(p) then
        Api:Notification(p,false,"Cannot join game, already in a game.")
        return false;
    end
    if ActiveGames[hash] and ActiveGames[hash].Pending and #ActiveGames[hash].Players < GameInfo[ ActiveGames[hash].Type ].PlayersAmt then
        if not table.find(ActiveGames[hash].Players,p) then
            table.insert(ActiveGames[hash].Players,p);
            if typeof(GameInfo[ ActiveGames[hash].Type ].AddPlayer) == "function" then
                GameInfo[ ActiveGames[hash].Type ].AddPlayer(hash, p);
                invites:cleanupPlayer(p);
                Api:Notification(p,GameInfo[ ActiveGames[hash].Type ].Image,"Joining game " .. ActiveGames[hash].Type .. ".")
            else
                warn("NO ADD PLAYER FUNCTION FOR " .. ActiveGames[hash].Type);
            end
        end
    else
        warn("NO ACTIVE GAME FOR HASH " .. hash);
    end
    return false
end
invites.startDuel = StartGame;

-- Challenges
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
            -- Check if player is in game
            if isInGame(p) then
                Api:Notification(p,false,"Cannot send new invite while already in a game.")
                return false
            end
            invites:SendInvite(found,p,plrs[1]);
        elseif GameInfo[found].PlayersAmt >= 2 and not GameInfo[found].PlayersRequired then
            -- Check if player is in game
            local h = isInGame(p)
            if h then
                -- Send new invite
                if ActiveGames[h].Pending then
                    -- Could send game
                    if typeof(GameInfo[ ActiveGames[h].Type ].CanInvite) == "function" and GameInfo[ ActiveGames[h].Type ].CanInvite(p) then
                        -- Can Send Invite
                        for _,plr in pairs(plrs) do
                            invites:SendInvite(found,p,plr,h);
                        end
                    else
                        Api:Notification(p,false,"Unable to send invite.")
                    end
                else
                    Api:Notification(p,false,"Unable to send invite, game is in progress.")
                end
            else
                -- Start new game
                local hash = StartGame({p},found)
                for _,plr in pairs(plrs) do
                    if plr ~= p then
                        invites:SendInvite(found,p,plr,hash);
                    end
                end
            end

        else
            Api:Notification(p,false,"Invalid game param, please try sending invite again.")
        end

    else
        Api:Notification(p,false,"Game not found")
    end
end,"1;*[string];*[string];",{"play"})
Api:RegisterCommand("join","Joins a player's public game.",function(p: Player, Args: {string})
    print("JOIN GAME")
    if isInGame(p) then
        Api:Notification(p,false,"Cannot join game whilest in game.")
        return false;
    end

    local plrList = Api:GetPlayer(Args[1],p)
    if #plrList >= 1 then
        local pToJoin = plrList[1];
        if pToJoin ~= p then
            for hash,g in pairs(ActiveGames) do
                if table.find(g.Players,pToJoin) then
                    print("found plr/g,me")
                    -- Found game
                    if g.Pending and g.Public and #g.Players < GameInfo[g.Type].PlayersAmt then
                        print("able")
                        -- Join Game
                        if typeof(GameInfo[ g.Type ].AddPlayer) == "function" then
                            print("join")
                            GameInfo[ g.Type ].AddPlayer(hash, p);
                            invites:cleanupPlayer(p);
                            Api:Notification(p,GameInfo[ ActiveGames[hash].Type ].Image,"Joining game " .. ActiveGames[hash].Type .. ".")
                            print("done")
                        end
                    else
                        Api:Notification(p,false,"Unable to join " .. pToJoin.Name .. "'s game.")
                    end
                    break
                end
            end
        end
    else
        Api:Notification(p,false,"Player not found")
    end
end,"1;*[string]")
Api:RegisterCommand("invite","Invites a player to a game.",function(p: Player, Args: {string})
    local hash = isInGame(p);
    local plrs = Api:GetPlayer(Args[1],p)
    if hash then

        if ActiveGames[hash].Pending then
            -- Could send game
            if typeof(GameInfo[ ActiveGames[hash].Type ].CanInvite) == "function" and GameInfo[ ActiveGames[hash].Type ].CanInvite(hash,p) then
                -- Can Send Invite
                for _,plr in pairs(plrs) do
                    if plr ~= p then
                        invites:SendInvite(ActiveGames[hash].Type,p,plr,hash);
                    end
                end
            else
                Api:Notification(p,false,"Unable to send invite.")
            end
        else
            Api:Notification(p,false,"Unable to send invite, game is in progress.")
        end

    else
        Api:Notification(p,false,"Unable to send invite, Not in game.")
    end
end)

game.Players.PlayerRemoving:Connect(function(p)
    for h,g in pairs(ActiveGames) do
        for _,plr in pairs(g.Players) do
            if plr == p then
                -- End Game
                if GameInfo[g.Type].EndGame(h,p) then
                    ActiveGames[h] = nil;
                end
            end
        end
    end
    invites:cleanupPlayer(p);
end)

Api:OnInvoke("GamesKit-getHowTo",function(p,name)
    if GameInfo[name] and GameInfo[name].HowToPlay then
        return GameInfo[name].HowToPlay
    end
    return "*requested game HowToPlay unavaliable*"
end)

Api:RegisterCommand("activegames","Lists all active games.",function(p: Player)
    if Api:GetRank(p) >= 2 then
        script.activeList:Clone().Parent = p:WaitForChild("PlayerGui");
    else
        -- Invalid Rank Notification
        Api:InvalidPermissionsNotification(p)
    end
end)
Api:OnInvoke("GamesKit-activeGames",function(p)
    if Api:GetRank(p) >= 2 then
        return ActiveGames,GameInfo
    else
        -- Invalid Rank Notification
        Api:InvalidPermissionsNotification(p)
    end
end)

return true