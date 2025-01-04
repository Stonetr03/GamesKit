-- Stonetr03 - GamesKit - Yahtzee server

local Api = require(script.Parent.Parent.Parent.Parent:WaitForChild("Api"))

local Styles = {
    flow = require(script:WaitForChild("Styles"):WaitForChild("flow"));
    sync = require(script:WaitForChild("Styles"):WaitForChild("sync"));
    turn = require(script:WaitForChild("Styles"):WaitForChild("turn"));
}

local ActiveGames = {}

function ActiveStyle(hash: string): table
    if ActiveGames[hash] then
        return Styles[ ActiveGames[hash].Style ]
    end
end

local Module = {
    Name = "Yahtzee";
    Image = "rbxassetid://105437499828203";
    HowToPlay = [=[# How to play Yahtzee

---

## Objective

The goal of Yahtzee is to score the most points in 13 turns by rolling dice.

## How to Play

1. **Roll the dice**
	- At the start of your turn, roll all 5 dice.
	- You get an additional 2 re-rolls per turn, you can roll all, some, or none of the dice.
2. **Score**
	- After rolling the dice, choose a category to score points in.
	- Each category can only be scored once per game, so choose carefully!
3. **Categories**
    - **Upper Section:** Score based on individual numbers.
        - Example: If you roll three 4s, you can score 12 in the "Fours" category.
    - **Lower Section:** Score based on specific dice combinations:
        - **Three of a Kind:** Total of all dice with at least 3 dice showing the same number.
        - **Four of a Kind:** Total of all dice with at least 4 dice showing the same number.
        - **Full House:** 3 of one number + 2 of another (e.g., 3-3-3-2-2).
        - **Small Straight:** 4 consecutive numbers (e.g., 1-2-3-4).
        - **Large Straight:** 5 consecutive numbers (e.g., 2-3-4-5-6).
        - **Yahtzee:** All 5 dice showing the same number (50 points!).
        - **Chance:** The total of all dice, no specific combination required.

## Double Yahtzee
If an additional Yahtzee is rolled, you have an option to score a *Double Yahtzee*, which scores an additional 100 points and another box.

1. If the upper section box for the number rolled is available, that box will be automatically scored.
2. If that is not available, you may choose a lower section box to score.
3. If no boxes are available in the lower section, you may choose an upper section box to score. 

## Upper Section Bonus
An additional 35 points is awarded if the total score of the upper section is 63 or greater.

## Multiplayer Round Styles
Different round styles may be chosen for GamesKit Yahtzee, The host of the game may choose a style in between rounds.

- **Turn Style**
	- Each player takes turns rolling dice and scoring boxes.
- **Sync Style**
	- Each player rolls at the same time, but must stay on the current round until all players have completed the round.
- **Flow Style**
	- Each player rolls at the same time, completing all 13 rounds.

]=];
    PlayersAmt = 50;

    StartGame = function(hash: string,plrs: table)
        ActiveGames[hash] = {
            host = plrs[1];
            players = plrs;
            pending = true;

            Public = false;
            Style = "turn";

            data = {};
        };

        -- Ui
        for _,p in pairs(plrs) do
            local ui = script.Ui:Clone()
            script.score:Clone().Parent = ui;
            ui.hash.Value = hash
            ui.Parent = p:WaitForChild("PlayerGui")
        end
    end;
    EndGame = function(hash: string,p: Player|nil): boolean
        if ActiveGames[hash] then

            if p then

                if ActiveGames[hash].host == p then
                    for _,plr in pairs(ActiveGames[hash].players) do
                        Api:Fire(plr,"GamesKit-Yahtzee-Quit",hash,ActiveGames[hash])
                    end
                    if ActiveGames[hash].pending == false then
                        ActiveStyle(hash).cleanup(ActiveGames[hash]);
                    end
                    ActiveGames[hash] = nil;
                else
                    -- Only remove from game
                    table.remove(ActiveGames[hash].players,table.find(ActiveGames[hash].players,p));
                    ActiveStyle(hash).HandlePlayerLeave(ActiveGames[hash],p);

                    for _,plr in pairs(ActiveGames[hash].players) do
                        Api:Fire(plr,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
                    end
                    return false
                end

            else
                for _,plr in pairs(ActiveGames[hash].players) do
                    Api:Fire(plr,"GamesKit-Yahtzee-Quit",hash,ActiveGames[hash],hash)
                end
                if ActiveGames[hash].pending == false then
                    ActiveStyle(hash).cleanup(ActiveGames[hash]);
                end
                ActiveGames[hash] = nil;
            end
        end
        return true;
    end;
    StopGame = nil :: (string) -> ();
    RemovePlayer = nil :: (string,Player) -> ();
    SetPublic = nil :: (string,boolean) -> ();
    SetPending = nil :: (string,boolean) -> ();
    CanInvite = function(hash: string, p: Player): boolean
        if ActiveGames[hash] and ActiveGames[hash].host == p then
            return true
        end
        return false
    end;
    AddPlayer = function(hash: string, p: Player)
        if ActiveGames[hash] then
            if not table.find(ActiveGames[hash].players,p) then
                table.insert(ActiveGames[hash].players,p);
            end

            local ui = script.Ui:Clone()
            script.score:Clone().Parent = ui;
            ui.hash.Value = hash
            ui.Parent = p:WaitForChild("PlayerGui");

            for _,plr in pairs(ActiveGames[hash].players) do
                Api:Fire(plr,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
            end
        end
    end;
}

Api:OnInvoke("GamesKit-Get-Yahtzee",function(p: Player,hash: string)
    if typeof(hash) ~= "string" then
        return {};
    end
    if ActiveGames[hash] then
        return ActiveGames[hash]
    end
    return {};
end)

Api:OnEvent("GamesKit-Quit-Yahtzee",function(p: Player,hash: string)
    if typeof(hash) ~= "string" then
        return false
    end
    if ActiveGames[hash] then
        if ActiveGames[hash].host == p then
            -- Quit Game
            Module.EndGame(hash,p)
            Module.StopGame(hash)
        elseif table.find(ActiveGames[hash].players,p) then
            table.remove(ActiveGames[hash].players,table.find(ActiveGames[hash].players,p));
            for _,plr in pairs(ActiveGames[hash].players) do
                Api:Fire(plr,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
            end
            -- TODO: If is turn, next player;
        end
    end
end)

-- Waiting --
Api:OnInvoke("GamesKit-Yahtzee-SetStyle",function(p: Player,hash: string, style: string)
    if typeof(hash) ~= "string" or typeof(style) ~= "string" then
        return false
    end
    if ActiveGames[hash] and ActiveGames[hash].host == p and ActiveGames[hash].pending == true then
        if style == "turn" or style == "sync" or style == "flow" then
            ActiveGames[hash].Style = style;
            for _,plr in pairs(ActiveGames[hash].players) do
                Api:Fire(plr,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
            end
            return true;
        end
    end
    return false
end);
Api:OnInvoke("GamesKit-Yahtzee-SetPub",function(p: Player,hash: string, pub: boolean)
    if typeof(hash) ~= "string" or typeof(pub) ~= "boolean" then
        return false
    end
    if ActiveGames[hash] and ActiveGames[hash].host == p and ActiveGames[hash].pending == true then
        ActiveGames[hash].Public = pub;
        Module.SetPublic(hash,pub);
        for _,plr in pairs(ActiveGames[hash].players) do
            Api:Fire(plr,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
        end
        return true;
    end
    return false
end);
Api:OnInvoke("GamesKit-Yahtzee-Kickplr",function(p: Player,hash: string, plr: Player)
    if typeof(hash) ~= "string" or typeof(plr) ~= "Instance" or plr:IsA("Player") == false then
        return false
    end
    if ActiveGames[hash] and ActiveGames[hash].host == p and ActiveGames[hash].pending == true and p ~= plr then
        Api:Fire(plr,"GamesKit-Yahtzee-Quit",hash,ActiveGames[hash])
        Module.RemovePlayer(hash,plr);

        for _,plr2 in pairs(ActiveGames[hash].players) do
            Api:Fire(plr2,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
        end
    end
end)
Api:OnInvoke("GamesKit-Yahtzee-Start",function(p: Player,hash: string)
    if typeof(hash) ~= "string" then
        return false
    end
    if ActiveGames[hash] and ActiveGames[hash].host == p and ActiveGames[hash].pending == true then
        -- Start Game;
        ActiveGames[hash].pending = false;
        Module.SetPending(hash,false);
        ActiveStyle(hash).CreateInitData( ActiveGames[hash] );
        for _,plr in pairs(ActiveGames[hash].players) do
            Api:Fire(plr,"GamesKit-Yahtzee-GameStart",hash)
            Api:Fire(plr,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
        end
    end
end)

-- Playing --
Api:OnEvent("GamesKit-Yahtzee-Roll",function(p: Player, hash: string, f1: boolean, f2: boolean, f3: boolean, f4: boolean, f5: boolean)
    if typeof(hash) ~= "string" or typeof(f1) ~= "boolean" or typeof(f2) ~= "boolean" or typeof(f3) ~= "boolean" or typeof(f4) ~= "boolean" or typeof(f5) ~= "boolean" then
        return
    end
    if f1 and f2 and f3 and f4 and f5 then
        return -- at least one dice has to not be frozen
    end
    if ActiveGames[hash] and ActiveGames[hash].pending == false then
        if ActiveStyle(hash).Roll( ActiveGames[hash], p, f1,f2,f3,f4,f5 ) then
            for _,plr in pairs(ActiveGames[hash].players) do
                Api:Fire(plr,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
            end
        end
    end
end)
Api:OnEvent("GamesKit-Yahtzee-Score",function(p: Player, hash: string, i: number, j: number?)
    if typeof(j) ~= "number" then j = 0 end;
    if typeof(hash) ~= "string" or typeof(i) ~= "number" then
        return
    end
    if ActiveGames[hash] and ActiveGames[hash].pending == false then
        if ActiveStyle(hash).Score( ActiveGames[hash], p, i, j ) then
            for _,plr in pairs(ActiveGames[hash].players) do
                Api:Fire(plr,"GamesKit-Yahtzee-Refresh",hash,ActiveGames[hash])
            end
        end
    end
end)
-- Finish --
function finish(g: table, score: table)
    local h
    for hash,tbl in pairs(ActiveGames) do
        if tbl == g then
            -- found game
            h = hash;
            break;
        end
    end
    if h then
        -- game found
        ActiveGames[h].pending = true;
        Module.SetPending(h,true);
        for _,plr in pairs(ActiveGames[h].players) do
            Api:Fire(plr,"GamesKit-Yahtzee-GameFinish",h,score)
            Api:Fire(plr,"GamesKit-Yahtzee-Refresh",h,ActiveGames[h])
        end
    end
end
Styles.flow.Finish = finish;
Styles.sync.Finish = finish;
Styles.turn.Finish = finish;
-- Timeouts --
function timeout(g: table, p: Player)
    local h
    for hash,tbl in pairs(ActiveGames) do
        if tbl == g then
            -- found game
            h = hash;
            break;
        end
    end
    if h then
        for _,plr in pairs(ActiveGames[h].players) do
            Api:Fire(plr,"GamesKit-Yahtzee-Refresh",h,ActiveGames[h])
        end
        Api:Fire(p,"GamesKit-Yahtzee-Timeout",h);
    end
end
Styles.flow.Timeout = timeout;
Styles.sync.Timeout = timeout;
Styles.turn.Timeout = timeout;

return Module
