-- Stonetr03

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local Markdown = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("GamesKit"):WaitForChild("Markdown"))
local GamesList = game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("GamesKit"):WaitForChild("GamesList")
local HttpService = game:GetService("HttpService")

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children

local links = {}
local text = [=[# **Games - List**
---
]=]

for _,o in pairs(HttpService:JSONDecode(GamesList.Value)) do
    text = text .. "\n[" .. o .. "](" .. o .. ")\n";
    links[o] = function()
        local info = Api:Invoke("GamesKit-GetInfo",o)
        if info.PlayersAmt then
            local plrlist = {}
            for _,p in pairs(game.Players:GetPlayers()) do
                table.insert(plrlist,p.Name)
            end
            table.remove(plrlist,table.find(plrlist,game.Players.LocalPlayer.Name));
            local promptInfo = {}
            for i = 1,info.PlayersAmt-1,1 do
                table.insert(promptInfo,{
                    Title = "*Player" .. i;
                    Type = "Dropdown";
                    Value = plrlist;
                })
            end
            Api:Prompt({
                Title = info.Name .. " Challenge";
                Prompt = promptInfo;
            },function(res)
                if res[1] == true then
                    local plrs = {}
                    local valid = true
                    for i,p in pairs(res[2]) do
                        if game.Players:FindFirstChild(p) then
                            plrs[i] = game.Players:FindFirstChild(p)
                        else
                            valid = false
                        end
                    end
                    if valid == true then
                        -- Send Challenge
                        local plrStr = "";
                        for _,plr in pairs(plrs) do
                            if plr ~= game.Players.LocalPlayer.Name then
                                if plrStr ~= "" then
                                    plrStr = plrStr .. ","
                                end
                                plrStr = plrStr .. plr.Name
                            end
                        end
                        Api:Fire("CmdBar","!challenge " .. info.Name .. " " .. plrStr)
                    end
                end
            end)
        end
    end
end
text = text .. "\n---\n###### *GamesKit made by Stonetr03*"

local CanvasSize = Value(UDim2.new(0,0,0,0))
local resize

local LastSize = Vector2.new(0,0)
local Doc = New "Frame" {
    BackgroundTransparency = 1;
    Size = UDim2.new(1,0,1,-2);

    [Fusion.OnChange "AbsoluteSize"] = function(NewSize)
        if typeof(resize) == "function" and (LastSize.X ~= math.round(NewSize.X) or LastSize.Y ~= math.round(NewSize.Y)) then
            resize()
            LastSize = Vector2.new(math.round(NewSize.X),math.round(NewSize.Y))
        end
    end
}


local Window = Api:CreateWindow({
    Size = Vector2.new(200,300);
    Title = "Games";
    Position = UDim2.new(0.5,-50,0,0);
    Resizeable = true;
    ResizeableMinimum = Vector2.new(100,50)
},New "ScrollingFrame" {
    BackgroundTransparency = 1;
    Size = UDim2.new(1,0,1,0);
    CanvasSize = CanvasSize;
    ScrollBarThickness = 5;
    TopImage = "";
    BottomImage = "";
    ScrollBarImageColor3 = Color3.new(1,1,1);
    ScrollingDirection = Enum.ScrollingDirection.Y;
    VerticalScrollBarInset = Enum.ScrollBarInset.None;

    [Children] = Doc;
})

Window.OnClose:Connect(function()
    Window.unmount()
    script:Destroy()
end)

local gui, element = Markdown({
    text = text,
    gui = Doc,
    relayoutOnResize = true,
    links = links,
})

resize = function()
    CanvasSize:set(UDim2.new(0, 0, 0, element.size.y + 15))
end
CanvasSize:set(UDim2.new(0, 0, 0, element.size.y + 15))
