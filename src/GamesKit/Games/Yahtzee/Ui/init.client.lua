-- Stonetr03 - GamesKit - Yahtzee Main

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local HowTo = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("GamesKit"):WaitForChild("HowTo"))
local RunService = game:GetService("RunService");

local waitingUi = require(script:WaitForChild("Waiting"));
local playingUi = require(script:WaitForChild("Playing"));
local scoreboardUi = require(script:WaitForChild("scoreboard"));
local diceUi = require(script:WaitForChild("dice"));
local animUi = require(script:WaitForChild("Anim"));
local hash = script:WaitForChild("hash").Value;
local getScore = require(script:WaitForChild("score"));

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Children = Fusion.Children
local Computed = Fusion.Computed

local data = {
    isHost = Value(false);
    players = Value({});
    style = Value("turn");
    vis = Value(false); -- public / private
    isRunning = Value(true);
    data = Value({});
    altText = Value("");

    isTurn = Value(false);
    roll = Value(0); -- Amount of rolls 0: has not rolled yet
    pickDbl = Value(0);
    spectate = Value(); -- Player to spectate
    clock = Value("0:00");
    clockTime = 0;
}

local quitVis = Value(false);
local Window
Window = Api:CreateWindow({
    Size = Vector2.new(300,300);
    Title = "Yahtzee";
    Position = UDim2.new(0.5,-300/2,0.5,-300/2);
    Resizeable = true;
    ResizeableMinimum = Vector2.new(300,300);
    Buttons = {
        [1] = {
            Text = "?";
            Callback = function()
                HowTo:ShowGui("Yahtzee")
            end
        };
    };
},New "Frame" {
    Size = UDim2.new(1,0,1,0);
    BackgroundColor3 = Color3.fromRGB(0,85,0);
    ClipsDescendants = true;
    [Children] = {
        waitingUi.Ui(data);
        playingUi.Ui(data);
        scoreboardUi.Ui();
        animUi.Ui();

        New "Frame" {
            AnchorPoint = Vector2.new(0.5,1);
            AutomaticSize = Enum.AutomaticSize.XY;
            BackgroundColor3 = Color3.fromRGB(253,251,172);
            Position = UDim2.new(0.5,0,1,-10);
            Size = UDim2.new(0,0,0,30);
            ZIndex = 2;
            Visible = Computed(function()
                return not data.isRunning:get() or data.altText:get() ~= "";
            end);
            [Children] = {
                New "ImageLabel" {
                    AnchorPoint = Vector2.new(0,0.5);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://11419713314";
                    ImageColor3 = Color3.new(0,0,0);
                    Position = UDim2.new(0,3,0.5,0);
                    Size = UDim2.new(0,30,0,30);
                };
                New "TextLabel" {
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxassetid://12187370747");
                    Position = UDim2.new(0,36,0,0);
                    Size = UDim2.new(0,0,1,0);
                    Text = Computed(function()
                        if not data.isRunning:get() then
                            return "Game has been cancelled."
                        end
                        return data.altText:get();
                    end);
                    TextColor3 = Color3.new(0,0,0);
                    TextSize = 18;
                    RichText = true;
                };
            }
        };

        New "TextButton" {
            AutoButtonColor = false;
            BackgroundColor3 = Color3.new(0,0,0);
            BackgroundTransparency = 0.5;
            Size = UDim2.new(1,0,1,0);
            Selectable = false;
            Text = "";
            ZIndex = 100;
            Visible = quitVis;
            [Children] = {
                New "TextLabel" {
                    BackgroundTransparency = 1;
                    FontFace = Font.new("rbxassetid://12187370747");
                    Size = UDim2.new(1,0,0.5,0);
                    Text = "Are you sure you want to quit the game?";
                    TextColor3 = Color3.new(1,1,1);
                    TextSize = 22;
                    TextWrapped = true;
                };
                New "TextButton" {
                    BackgroundColor3 = Color3.fromRGB(170,0,0);
                    BackgroundTransparency = 0.3;
                    FontFace = Font.new("rbxassetid://12187370747");
                    Position = UDim2.new(0.067,0,0.5,0);
                    Size = UDim2.new(0.4,0,0.2,0);
                    Text = "Yes";
                    TextColor3 = Color3.new(1,1,1);
                    TextSize = 22;
                    TextWrapped = true;
                    [Children] = New "UICorner" {CornerRadius = UDim.new(0,12)};
                    [Event "MouseButton1Up"] = function()
                        Api:Fire("GamesKit-Quit-Yahtzee",hash)
                        Window.unmount()
                        script:Destroy()
                    end
                };
                New "TextButton" {
                    BackgroundColor3 = Color3.fromRGB(0,85,0);
                    BackgroundTransparency = 0.3;
                    FontFace = Font.new("rbxassetid://12187370747");
                    Position = UDim2.new(0.533,0,0.5,0);
                    Size = UDim2.new(0.4,0,0.2,0);
                    Text = "No";
                    TextColor3 = Color3.new(1,1,1);
                    TextSize = 22;
                    TextWrapped = true;
                    [Children] = New "UICorner" {CornerRadius = UDim.new(0,12)};
                    [Event "MouseButton1Up"] = function()
                        quitVis:set(false);
                    end
                };

            }
        }
    }
})

Window.OnClose:Connect(function()
    task.wait();
    Window.SetVis(true);
    quitVis:set(true);
end)

-- Settings
waitingUi.setStyle = function(style: string)
    if data.isHost:get() then
        Api:Invoke("GamesKit-Yahtzee-SetStyle",hash,style);
    end
end
waitingUi.setVis = function(pub: boolean)
    if data.isHost:get() then
        Api:Invoke("GamesKit-Yahtzee-SetPub",hash,pub);
    end
end
waitingUi.sentInv = function(p: Player)
    if data.isHost:get() then
        Api:Fire("CmdBar","!invite " .. p.Name);
    end
end
waitingUi.kickPlr = function(p: Player)
    if data.isHost:get() then
        Api:Invoke("GamesKit-Yahtzee-Kickplr",hash,p);
    end
end
waitingUi.start = function()
    if data.isHost:get() then
        Api:Invoke("GamesKit-Yahtzee-Start",hash);
    end
end

playingUi.Roll = function()
    if data.isTurn:get() then
        data.pickDbl:set(0);
        data.altText:set("");
        Api:Fire("GamesKit-Yahtzee-Roll",hash,diceUi.dice[1].frozen:get(),diceUi.dice[2].frozen:get(),diceUi.dice[3].frozen:get(),diceUi.dice[4].frozen:get(),diceUi.dice[5].frozen:get())
    end
end
local scoreDebounce = false
playingUi.Score = function(i: number)
    if scoreDebounce then return end;
    scoreDebounce = true;
    if data.isTurn:get() then
        if data.pickDbl:get() == 0 then
            local d = data.data:get();
            if i == 12 and d.players[game.Players.LocalPlayer.UserId].score[12] > 0 then
                -- dbl
                if getScore(12,{diceUi.dice[1].number:get(),diceUi.dice[2].number:get(),diceUi.dice[3].number:get(),diceUi.dice[4].number:get(),diceUi.dice[5].number:get()},d.players[game.Players.LocalPlayer.UserId].score[12]) ~= d.players[game.Players.LocalPlayer.UserId].score[12] then
                    -- has dbl
                    if d.players[game.Players.LocalPlayer.UserId].score[diceUi.dice[1].number:get()] == -1 then
                        Api:Fire("GamesKit-Yahtzee-Score",hash,i,0)
                    else
                        local top, bot = false, false
                        for j = 1,13,1 do
                            if j > 6 and not bot then
                                -- bot
                                bot = d.players[game.Players.LocalPlayer.UserId].score[j] == -1;
                            elseif j <= 6 and not top then
                                top = d.players[game.Players.LocalPlayer.UserId].score[j] == -1;
                            end
                        end
                        if bot then
                            -- score bottom
                            data.pickDbl:set(2);
                            data.altText:set("Double Yahtzee! Pick a score in the lower section to continue.");
                        elseif top then
                            data.pickDbl:set(1);
                            data.altText:set("Double Yahtzee! Pick a score in the upper section to continue.");
                        end
                    end
                end
            else
                Api:Fire("GamesKit-Yahtzee-Score",hash,i,0)
            end
        else
            data.altText:set("");
            Api:Fire("GamesKit-Yahtzee-Score",hash,12,i)
            data.pickDbl:set(0);
        end
    end
    task.wait(0.5);
    scoreDebounce = false;
end

scoreboardUi.Close = function()
    task.wait(animUi.Play() / 2);
    waitingUi.Visible:set(true);
    playingUi.Visible:set(false);
    scoreboardUi.Visible:set(false);
end

function update(newData: table)
    data.isHost:set(newData.host == game.Players.LocalPlayer);
    data.players:set(newData.players);
    data.style:set(newData.Style);
    data.vis:set(newData.Public);
    if not newData.pending then
        -- Fix Data (due to limitation in remote event)
        for i,o in pairs(newData.data.players) do
            if typeof(i) ~= "number" and tonumber(i) then
                newData.data.players[tonumber(i)] = o
                newData.data.players[i] = nil;
            end
        end
        data.data:set(newData.data);
        -- Check Turn;
        if newData.data.style == "flow" then
            if newData.data.players[game.Players.LocalPlayer.UserId] then
                local todo = false
                for _,o in pairs(newData.data.players[game.Players.LocalPlayer.UserId].score) do
                    if o == -1 then
                        todo = true;
                        break
                    end
                end
                data.isTurn:set(todo);
                if todo then
                    local isLocked = false
                    for i,o in pairs(newData.data.players[game.Players.LocalPlayer.UserId].dice) do
                        if o == 0 then
                            diceUi.LockBottom();
                            isLocked = true;
                            break
                        end
                        diceUi.dice[i].number:set(o);
                        diceUi.dice[i].frozen:set(newData.data.players[game.Players.LocalPlayer.UserId].frozen[i])
                    end
                    if data.roll:get() ~= newData.data.players[game.Players.LocalPlayer.UserId].roll and not isLocked then
                        diceUi.RandomizePositions();
                    end
                    data.roll:set(newData.data.players[game.Players.LocalPlayer.UserId].roll)
                    data.altText:set("")
                    data.spectate:set(nil);
                    data.clockTime = newData.data.players[game.Players.LocalPlayer.UserId].timeout
                else
                    -- Spectate
                    local sp = data.spectate:get();
                    if sp ~= nil then
                        if typeof(sp) == "Instance" and sp:IsA("Player") then
                            if newData.data.players[sp.UserId] then
                                local f = true
                                for _,o in pairs(newData.data.players[sp.UserId].score) do
                                    if o == -1 then
                                        f = false;
                                    end
                                end
                                if f then -- player has finished, find new player to spectate
                                    sp = nil;
                                end
                            else
                                sp = nil;
                            end
                        else
                            sp = nil;
                        end
                    end
                    if sp == nil then
                        -- Find new player to spectate
                        for pId,o in pairs(newData.data.players) do
                            if sp == nil then
                                for _,s in pairs(o.score) do
                                    if s == -1 then
                                        local plr = game.Players:GetPlayerByUserId(pId)
                                        if plr then
                                            sp = plr;
                                            break;
                                        end
                                    end
                                end
                            end
                        end
                    end
                    -- Spectate new player
                    if sp ~= nil then
                        data.spectate:set(sp);
                        local isLocked = false
                        for i,o in pairs(newData.data.players[sp.UserId].dice) do
                            if o == 0 then
                                diceUi.LockTop();
                                isLocked = true;
                                break
                            end
                            diceUi.dice[i].number:set(o);
                            diceUi.dice[i].frozen:set(newData.data.players[sp.UserId].frozen[i])
                        end
                        if data.roll:get() ~= newData.data.players[sp.UserId].roll and not isLocked then
                            diceUi.RandomizePositions();
                        end
                        data.roll:set(newData.data.players[sp.UserId].roll)
                        data.clockTime = newData.data.players[sp.UserId].timeout
                    end
                    local count = 0;
                    for _,_ in pairs(newData.data.players) do
                        count+=1;
                    end
                    data.altText:set(`Waiting for players. ({newData.data.done}/{count})`)
                    diceUi.Refresh();
                end
            else
                -- Spectate
                local sp = data.spectate:get();
                if sp ~= nil then
                    if typeof(sp) == "Instance" and sp:IsA("Player") then
                        if newData.data.players[sp.UserId] then
                            local f = true
                            for _,o in pairs(newData.data.players[sp.UserId].score) do
                                if o == -1 then
                                    f = false;
                                end
                            end
                            if f then -- player has finished, find new player to spectate
                                sp = nil;
                            end
                        else
                            sp = nil;
                        end
                    else
                        sp = nil;
                    end
                end
                if sp == nil then
                    -- Find new player to spectate
                    for pId,o in pairs(newData.data.players) do
                        if sp == nil then
                            for _,s in pairs(o.score) do
                                if s == -1 then
                                    local plr = game.Players:GetPlayerByUserId(pId)
                                    if plr then
                                        sp = plr;
                                        break;
                                    end
                                end
                            end
                        end
                    end
                end
                -- Spectate new player
                if sp ~= nil then
                    data.spectate:set(sp);
                    local isLocked = false
                    for i,o in pairs(newData.data.players[sp.UserId].dice) do
                        if o == 0 then
                            diceUi.LockTop();
                            isLocked = true;
                            break
                        end
                        diceUi.dice[i].number:set(o);
                        diceUi.dice[i].frozen:set(newData.data.players[sp.UserId].frozen[i])
                    end
                    if data.roll:get() ~= newData.data.players[sp.UserId].roll and not isLocked then
                        diceUi.RandomizePositions();
                    end
                    data.roll:set(newData.data.players[sp.UserId].roll)
                    data.clockTime = newData.data.players[sp.UserId].timeout
                end
                local count = 0;
                for _,_ in pairs(newData.data.players) do
                    count+=1;
                end
                data.altText:set(`Waiting for players. ({newData.data.done}/{count})\n<font size="7">────────────────────</font>\n<font size="16">Spectating</font>`)
                diceUi.Refresh();
            end
        elseif newData.data.style == "sync" then
            if newData.data.players[game.Players.LocalPlayer.UserId] then
                local completed = 0;
                for _,o in pairs(newData.data.players[game.Players.LocalPlayer.UserId].score) do
                    if o ~= -1 then
                        completed+=1;
                    end
                end
                data.isTurn:set(completed < newData.data.round);
                if completed < newData.data.round then
                    local isLocked = false
                    data.spectate:set(nil);
                    for i,o in pairs(newData.data.players[game.Players.LocalPlayer.UserId].dice) do
                        if o == 0 then
                            diceUi.LockBottom();
                            isLocked = true;
                            break
                        end
                        diceUi.dice[i].number:set(o);
                        diceUi.dice[i].frozen:set(newData.data.players[game.Players.LocalPlayer.UserId].frozen[i])
                    end
                    if data.roll:get() ~= newData.data.players[game.Players.LocalPlayer.UserId].roll and not isLocked then
                        diceUi.RandomizePositions();
                    end
                    data.roll:set(newData.data.players[game.Players.LocalPlayer.UserId].roll)
                    data.clockTime = newData.data.players[game.Players.LocalPlayer.UserId].timeout
                    data.altText:set("");
                else
                    -- Spectate
                    local sp = data.spectate:get();
                    if sp ~= nil then
                        if typeof(sp) == "Instance" and sp:IsA("Player") then
                            if newData.data.players[sp.UserId] then
                                local c = 0;
                                for _,o in pairs(newData.data.players[sp.UserId].score) do
                                    if o ~= -1 then
                                        c += 1;
                                    end
                                end
                                if c >= newData.data.round then -- player has finished, find new player to spectate
                                    sp = nil;
                                end
                            else
                                sp = nil;
                            end
                        else
                            sp = nil;
                        end
                    end
                    if sp == nil then
                        -- Find new player to spectate
                        for pId,o in pairs(newData.data.players) do
                            if sp == nil then
                                local c = 0;
                                for _,s in pairs(o.score) do
                                    if s ~= -1 then
                                        c += 1;
                                    end
                                end
                                if c < newData.data.round then
                                    local plr = game.Players:GetPlayerByUserId(pId)
                                    if plr then
                                        sp = plr;
                                        break;
                                    end
                                end
                            end
                        end
                    end
                    -- Spectate new player
                    if sp ~= nil then
                        data.spectate:set(sp);
                        local isLocked = false
                        for i,o in pairs(newData.data.players[sp.UserId].dice) do
                            if o == 0 then
                                diceUi.LockTop();
                                isLocked = true;
                                break
                            end
                            diceUi.dice[i].number:set(o);
                            diceUi.dice[i].frozen:set(newData.data.players[sp.UserId].frozen[i])
                        end
                        if data.roll:get() ~= newData.data.players[sp.UserId].roll and not isLocked then
                            diceUi.RandomizePositions();
                        end
                        data.roll:set(newData.data.players[sp.UserId].roll)
                        data.clockTime = newData.data.players[sp.UserId].timeout
                    end
                    local count = 0;
                    for _,_ in pairs(newData.data.players) do
                        count+=1;
                    end
                    data.altText:set(`Waiting for players. ({newData.data.done}/{count})`)
                    diceUi.Refresh();
                end
            else
                -- Spectate
                local sp = data.spectate:get();
                if sp ~= nil then
                    if typeof(sp) == "Instance" and sp:IsA("Player") then
                        if newData.data.players[sp.UserId] then
                            local c = 0;
                            for _,o in pairs(newData.data.players[sp.UserId].score) do
                                if o ~= -1 then
                                    c += 1;
                                end
                            end
                            if c >= newData.data.round then -- player has finished, find new player to spectate
                                sp = nil;
                            end
                        else
                            sp = nil;
                        end
                    else
                        sp = nil;
                    end
                end
                if sp == nil then
                    -- Find new player to spectate
                    for pId,o in pairs(newData.data.players) do
                        if sp == nil then
                            local c = 0;
                            for _,s in pairs(o.score) do
                                if s ~= -1 then
                                    c += 1;
                                end
                            end
                            if c < newData.data.round then
                                local plr = game.Players:GetPlayerByUserId(pId)
                                if plr then
                                    sp = plr;
                                    break;
                                end
                            end
                        end
                    end
                end
                -- Spectate new player
                if sp ~= nil then
                    data.spectate:set(sp);
                    local isLocked = false
                    for i,o in pairs(newData.data.players[sp.UserId].dice) do
                        if o == 0 then
                            diceUi.LockTop();
                            isLocked = true;
                            break
                        end
                        diceUi.dice[i].number:set(o);
                        diceUi.dice[i].frozen:set(newData.data.players[sp.UserId].frozen[i])
                    end
                    if data.roll:get() ~= newData.data.players[sp.UserId].roll and not isLocked then
                        diceUi.RandomizePositions();
                    end
                    data.roll:set(newData.data.players[sp.UserId].roll)
                    data.clockTime = newData.data.players[sp.UserId].timeout
                end
                local count = 0;
                for _,_ in pairs(newData.data.players) do
                    count+=1;
                end
                data.altText:set(`Waiting for players. ({newData.data.done}/{count})\n<font size="7">────────────────────</font>\n<font size="16">Spectating</font>`)
                diceUi.Refresh();
            end
        elseif newData.data.style == "turn" then
            if newData.data.turn == game.Players.LocalPlayer and newData.data.players[game.Players.LocalPlayer.UserId] then
                data.isTurn:set(true);
                data.spectate:set(nil);
                local isLocked = false
                for i,o in pairs(newData.data.players[game.Players.LocalPlayer.UserId].dice) do
                    if o == 0 then
                        diceUi.LockBottom();
                        isLocked = true;
                        break
                    end
                    diceUi.dice[i].number:set(o);
                    diceUi.dice[i].frozen:set(newData.data.players[game.Players.LocalPlayer.UserId].frozen[i])
                end
                if data.roll:get() ~= newData.data.players[game.Players.LocalPlayer.UserId].roll and not isLocked then
                    diceUi.RandomizePositions();
                end
                data.roll:set(newData.data.players[game.Players.LocalPlayer.UserId].roll)
                data.clockTime = newData.data.players[game.Players.LocalPlayer.UserId].timeout
            else
                -- Spectate
                local sp = nil;
                if newData.data.turn and typeof(newData.data.turn) == "Instance" and newData.data.turn:IsA("Player") then
                    sp = newData.data.turn;
                end
                -- Spectate new player
                if sp ~= nil then
                    data.spectate:set(sp);
                    local isLocked = false
                    for i,o in pairs(newData.data.players[sp.UserId].dice) do
                        if o == 0 then
                            diceUi.LockTop();
                            isLocked = true;
                            break
                        end
                        diceUi.dice[i].number:set(o);
                        diceUi.dice[i].frozen:set(newData.data.players[sp.UserId].frozen[i])
                    end
                    if data.roll:get() ~= newData.data.players[sp.UserId].roll and not isLocked then
                        diceUi.RandomizePositions();
                    end
                    data.roll:set(newData.data.players[sp.UserId].roll)
                    data.clockTime = newData.data.players[sp.UserId].timeout
                end
                local count = 0;
                for _,_ in pairs(newData.data.players) do
                    count+=1;
                end
                diceUi.Refresh();
                data.isTurn:set(false);
            end
        end
    end
end

Api:OnEvent("GamesKit-Yahtzee-Refresh",function(h: string, newData: table)
    if hash == h then
        update(newData)
    end
end)

Api:OnEvent("GamesKit-Yahtzee-Quit",function(h: string, newData: table)
    if hash == h then
        update(newData)
        data.isRunning:set(false)
    end
end)

Api:OnEvent("GamesKit-Yahtzee-GameStart",function(h: string)
    if hash == h then
        task.wait(animUi.Play() / 2);
        waitingUi.Visible:set(false);
        playingUi.Visible:set(true);
        scoreboardUi.Visible:set(false);
    end
end)

Api:OnEvent("GamesKit-Yahtzee-GameFinish",function(h: string,score: {[Player]: number})
    if hash == h then
        data.altText:set("")
        task.wait(animUi.Play() / 2);
        waitingUi.Visible:set(false);
        playingUi.Visible:set(false);
        scoreboardUi.Visible:set(true);
        scoreboardUi.Score:set(score);
    end
end)

Api:OnEvent("GamesKit-Yahtzee-Timeout",function(h: string)
    if hash == h then
        data.altText:set("You have timed out!\nYou can join in on the next round.")
    end
end)

local clockText = "";
RunService.RenderStepped:Connect(function()
    local diff = math.max(data.clockTime - os.time(),0);
    local txt = `{math.floor(diff / 60)}:{(diff % 60 < 10) and "0" or ""}{diff % 60}`
    if clockText ~= txt then
        clockText = txt
        data.clock:set(txt);
    end
end)

update(Api:Invoke("GamesKit-Get-Yahtzee",hash))
