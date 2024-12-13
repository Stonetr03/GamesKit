-- GamesKit - Stonetr03 - Invite Manager

local Api = require(script.Parent.Parent.Parent:WaitForChild("Api"))

export type invite = {
    gameId: string; -- name of game
    sender: Player;
    receiving: Player;
    expires: number;
    hash: string?;
}

local Invites = {} :: {invite};

local Module = {
    isInGame = nil :: (Player) -> (boolean);
    startDuel = nil :: (plrs: {Player},gameId: string) -> (); -- used for 2 player only games
    joinGame = nil :: (hash: string, p: Player) -> ();
    gameInfo = nil;
};

--[=[
    Opens a new player invite.

    @param gameId string - Name of game.
    @param sendingPlr Player - Player sending invite.
    @param ReceivingPlr Player - Player receiving invite.
    @param hash string? - Represents if a game is already in progress. The lack of a hash value means the game is a duel.
]=]
function Module:SendInvite(gameId: string, sendingPlr: Player, receivingPlr: Player, hash: string?)
    if Module.isInGame(receivingPlr) then
        Api:Notification(sendingPlr,false,"Unable to send game invite to " .. receivingPlr.Name);
        return false
    end
    if Module.isInGame(sendingPlr) and typeof(hash) ~= "string" then
        Api:Notification(sendingPlr,false,"Unable to send game invite while in game.\nLeave game to send a new invite.");
        return false
    end
    -- Check if invite already sent;
    for _,i in pairs(Invites) do
        if i.sender == receivingPlr and i.receiving == sendingPlr and i.gameId == gameId then
            -- Accept Invite
            Module:AcceptInvite(i);
            return;
        elseif i.sender == sendingPlr and i.receiving == receivingPlr and i.gameId == gameId then
            -- already sent
            return;
        end
    end

    local inv: invite = {
        gameId = gameId;
        sender = sendingPlr;
        receiving = receivingPlr;
        expires = os.time() + 61; -- expires in 61 seconds from time sent;
        hash = hash;
    }
    table.insert(Invites,inv);
    Api:Notification(sendingPlr,Module.GameInfo[gameId].Image,"Challenge to " .. receivingPlr.Name .. " has been sent.");
    Api:Notification(receivingPlr,Module.GameInfo[gameId].Image, sendingPlr.Name .. " has challenged you to a game of " .. gameId, "Accept Challenge",function()
        -- Accept Invite
        if inv.expires >= os.time() then
            Module:AcceptInvite(inv);
        end
    end,60)

    -- Expire Invite
    task.spawn(function()
        task.wait(62);
        if table.find(Invites,inv) then
            table.remove(Invites,table.find(Invites,inv));
        end
    end);
end

function Module:AcceptInvite(inv: invite)
    if typeof(inv.hash) == "string" then
        -- group game
        Module.joinGame(inv.hash,inv.receiving);
    else
        -- duel
        Module.startDuel({inv.sender,inv.receiving},inv.gameId);
    end
    Module:cleanupPlayer(inv.receiving);
end

--[=[
    Cancels a invite for the given sender and receiver.
]=]
function Module:CancelInvite(sender: Player, receiver: Player)
    for _,i in pairs(Invites) do
        if i.receiving == receiver and i.sender == sender then
            table.remove(Invites,table.find(Invites,i))
        end
    end
end

--[=[
    Cancels all invites for the given player. (Used on player leave)
]=]
function Module:cleanupPlayer(p: Player)
    for _,i in pairs(Invites) do
        if i.receiving == p or i.sender == p then
            table.remove(Invites,table.find(Invites,i));
        end
    end
end

return Module;
