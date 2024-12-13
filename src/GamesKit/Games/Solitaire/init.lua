-- Stonetr03

local Api = require(script.Parent.Parent.Parent.Parent:WaitForChild("Api"))

local Module = {
    Name = "Solitaire";
    Image = "rbxassetid://15659831696";
    HowToPlay = [=[# How to Play Solitaire

---

## **Objective:**

- Move all cards to the foundation piles, building them up in ascending order by suit, starting with the Ace and ending with the King.
 
## **Rules:**

- Place cards on the table in descending order and alternating colors.
- Utilize the foundation piles to build up each suit from the Ace to the King.
- Move cards between columns to reveal face-down cards.
- An empty column can only be filled with a King or a valid sequence starting with a King.
- Use the stock pile to deal additional cards onto the table.
 
## **Winning:**

- Successfully move all cards to the foundation piles according to their suits and in ascending order from Ace to King.

## **Keybinds:**

Cards can be moved by either Dragging them, clicking on them, or using a keyboard or gamepad.

> The arrow keys or DPad buttons are used to move your selection around.
> Pressing space or ButtonA will pick up / set down cards,  and the N/M keys and L1 and R1 buttons can be used to increase/decrease the cards picked up.]=];
    PlayersAmt = 1;

    StartGame = nil;
    EndGame = function(hash: string,p: Player|nil)
    end;
    StopGame = nil;
}
Module.StartGame = function(hash: string,plrs: table)
    -- Ui
    for _,p in pairs(plrs) do
        local ui = script.Ui:Clone()
        ui.Parent = p:WaitForChild("PlayerGui")
    end
end;

return Module
