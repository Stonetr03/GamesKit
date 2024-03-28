-- Stonetr03 - GamesKit

local Api = require(script.Parent.Parent:WaitForChild("Api"))
local Create = require(script.Parent.Parent:WaitForChild("CreateModule"))
local HttpService = game:GetService("HttpService")

local GamesList = {}

local GameInfo = {}
local OpenChallenges = {}
--    [1] = {
--        Type = "Chess";
--        Sender = p1;
--        Players = {p1,p2};
--        Expires = 1;
--    }
local ActiveGames = {}
--    [UUID HASH] = {
--        Type = "Chess";
--        Players = {p1,p2};
--    }

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

function StartGame(plrs,gameName)
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
end

-- Challenges
--NOTE: THIS WILL NOT WORK WITH >2 PLAYER GAMES
Api:RegisterCommand("challenge","Challenge a player to a game.",function(p,Args)
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
        if #plrs == GameInfo[found].PlayersAmt - 1 and #plrs ~= 0 then
            -- Check if players is not self
            for _,plr in pairs(plrs) do
                if plr == p then
                    Api:Notification(p,false,"Cannot challenge yourself.")
                    return
                end
                -- Check to make sure player is not in a game
                for _,o in pairs(ActiveGames) do
                    for _,a in pairs(o.Players) do
                        if a == p or a == plr then
                            Api:Notification(p,false,"Player is in a game.")
                            return
                        end
                    end
                end
                for _,o in pairs(OpenChallenges) do
                    for _,a in pairs(o.Players) do
                        if a == plr and o.Sender == p and o.Expires > os.time() then
                            Api:Notification(p,false,"Already sent challenge to player.")
                            return
                        end
                    end
                end
            end
            -- Check for duplicates
            local checkplrs = {}
            for _,plr in pairs(plrs) do
                if table.find(checkplrs,plr) then
                    Api:Notification(p,false,"Duplicated Player.")
                    return
                else
                    table.insert(checkplrs,plr)
                end
            end

            -- Send Challenge
            local challenge = {
                Type = found;
                Sender = p;
                Players = plrs;
                Expires = os.time() + 61;
            }
            Api:Notification(p,GameInfo[found].Image,"Challenge sent.")
            for _,plr in pairs(plrs) do
                Api:Notification(plr,GameInfo[found].Image,p.Name .. " has challenged you to a game of " .. found,"Accept Challenge",function()
                    -- Accept Challenge
                    if table.find(OpenChallenges,challenge) then
                        if table.find(OpenChallenges,challenge) then
                            table.remove(OpenChallenges,table.find(OpenChallenges,challenge))
                        end
                        StartGame(plrs,found)
                    end
                end,60)
            end
            table.insert(plrs,p)
            table.insert(OpenChallenges,challenge)
            task.wait(62)
            -- Expire
            if table.find(OpenChallenges,challenge) then
                table.remove(OpenChallenges,table.find(OpenChallenges,challenge))
            end
        elseif GameInfo[found].PlayersAmt == 1 then
            StartGame({p},found)
        else
            Api:Notification(p,false,"Invalid amount of players for " .. found .. ", Amount:" .. GameInfo[found].PlayersAmt)
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
    for _,c in pairs(OpenChallenges) do
        if table.find(c.Players,p) then
            -- Remove Challenge
            if table.find(OpenChallenges,c) then
                table.remove(OpenChallenges,table.find(OpenChallenges,c))
            end
        end
    end
end)

Api:OnInvoke("GamesKit-getHowTo",function(p,name)
    if GameInfo[name] and GameInfo[name].HowToPlay then
        return GameInfo[name].HowToPlay
    end
    return "*requested game HowToPlay unavaliable*"
end)

return true