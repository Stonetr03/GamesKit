-- Stonetr03 - GamesKit - How to play Ui

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))
local Api = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Api"))
local Markdown = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("GamesKit"):WaitForChild("Markdown"))

local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children

local Module = {}

function Module:ShowGui(name: string)
    local text = Api:Invoke("GamesKit-getHowTo", name)

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
        Title = "How to Play";
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

    local gui, element = Markdown({
        text = text,
        gui = Doc,
        relayoutOnResize = true,
    })

    Window.OnClose:Connect(function()
        gui:Destroy()
        Window.unmount()
    end)

    resize = function()
        CanvasSize:set(UDim2.new(0, 0, 0, element.size.y + 15))
    end
    CanvasSize:set(UDim2.new(0, 0, 0, element.size.y + 15))

end

return Module
