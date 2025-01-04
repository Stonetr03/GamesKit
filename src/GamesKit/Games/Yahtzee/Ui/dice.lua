-- Stonetr03 - GamesKit - Yahtzee Dice Ui

local Fusion = require(game.ReplicatedStorage:WaitForChild("AdminCube"):WaitForChild("Fusion"))

local New = Fusion.New
local Value = Fusion.Value
local Event = Fusion.OnEvent
local Spring = Fusion.Spring
local Children = Fusion.Children
local Computed = Fusion.Computed

local Module = {
    dice = {
        [1] = {
            position = Value(UDim2.new(0,0,0,0));
            frozen = Value(false); -- frozen dice / blue dice
            rotation = Value(0); -- (deg)
            number = Value(math.random(1,6));
        };
        [2] = {
            position = Value(UDim2.new(0,0,0,0));
            frozen = Value(false); -- frozen dice / blue dice
            rotation = Value(0); -- (deg)
            number = Value(math.random(1,6));
        };
        [3] = {
            position = Value(UDim2.new(0,0,0,0));
            frozen = Value(false); -- frozen dice / blue dice
            rotation = Value(0); -- (deg)
            number = Value(math.random(1,6));
        };
        [4] = {
            position = Value(UDim2.new(0,0,0,0));
            frozen = Value(false); -- frozen dice / blue dice
            rotation = Value(0); -- (deg)
            number = Value(math.random(1,6));
        };
        [5] = {
            position = Value(UDim2.new(0,0,0,0));
            frozen = Value(false); -- frozen dice / blue dice
            rotation = Value(0); -- (deg)
            number = Value(math.random(1,6));
        };
    };
    size = Value(UDim2.new(0.26,0,0.26,0));
    locked = Value(0); -- 0: none, 1: bottom, 2: top;

    topLock = {
        [1] = Value(Vector2.zero);
        [2] = Value(Vector2.zero);
        [3] = Value(Vector2.zero);
        [4] = Value(Vector2.zero);
        [5] = Value(Vector2.zero);
    };
    bottomLock = {
        [1] = Value(Vector2.zero);
        [2] = Value(Vector2.zero);
        [3] = Value(Vector2.zero);
        [4] = Value(Vector2.zero);
        [5] = Value(Vector2.zero);
    };
    lockSize = Value(Vector2.zero);
    relPos = Value(Vector2.zero);
    relSize = Value(Vector2.zero);
}

function RestArea(links: table, ac: Vector2, pos: UDim2): GuiObject
    return New "Frame" {
        AnchorPoint = ac;
        Position = pos;
        Size = UDim2.new(1,0,0.12,0);
        Visible = false;
        [Children] = {
            New "UIAspectRatioConstraint" {AspectRatio = 6};
            New "UISizeConstraint" {MaxSize = Vector2.new(math.huge,55)};
            New "UIListLayout" {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                Padding = UDim.new(0,3);
                SortOrder = Enum.SortOrder.LayoutOrder;
                VerticalAlignment = Enum.VerticalAlignment.Center;
            };
            Fusion.ForPairs(links,function(i,o)
                return i, New "Frame" {
                    Size = UDim2.new(1,0,1,0);
                    SizeConstraint = Enum.SizeConstraint.RelativeYY;
                    LayoutOrder = i;
                    [Fusion.Out "AbsolutePosition"] = o;
                    [Fusion.Out "AbsoluteSize"] = (links == Module.bottomLock and i == 1) and Module.lockSize or nil;
                }
            end,Fusion.cleanup);
        }
    }
end

function dot(Pos: UDim2,v: boolean): GuiObject
    return New "Frame" {
        AnchorPoint = Vector2.new(0.5,0.5);
        BackgroundColor3 = Color3.fromRGB(51,51,51);
        Position = Pos;
        Size = UDim2.new(0.2,0,0.2,0);
        Visible = v;
        [Children] = New "UICorner" {CornerRadius = UDim.new(1,0)};
    }
end

function die(n: number): GuiObject
    local s = Value(Vector2.one);
    return New "TextButton" {
        AnchorPoint = Vector2.new(0.5,0.5);
        BackgroundTransparency = 1;
        Position = Spring(Module.dice[n].position,12,1);
        Rotation = Spring(Module.dice[n].rotation,14,1);
        Size = Module.size;
        Name = Module.dice[n].number;
        Text = "";
        [Event "MouseButton1Up"] = function()
            if Module.locked:get() == 0 then
                Module.dice[n].frozen:set(not Module.dice[n].frozen:get())
            end
        end;
        [Children] = {
            New "UIAspectRatioConstraint" {};
            New "UISizeConstraint" {MaxSize = Vector2.new(55,55)};
            -- Visible Die
            New "Frame" {
                AnchorPoint = Vector2.new(0.5,0.5);
                BackgroundColor3 = Color3.new(1,1,1);
                Position = UDim2.new(0.5,0,0.5,0);
                Size = UDim2.new(1/1.16,0,1/1.16,0);
                [Fusion.Out "AbsoluteSize"] = s;
                [Fusion.Cleanup] = s;
                [Children] = {
                    New "UICorner" {};
                    New "UIGradient" {
                        Color = Computed(function()
                            return Module.dice[n].frozen:get() and ColorSequence.new(Color3.fromRGB(149,175,245),Color3.fromRGB(93,154,245)) or ColorSequence.new(Color3.fromRGB(245,245,245),Color3.fromRGB(188,188,188));
                        end);
                    };
                    New "UIStroke" {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        Color = Computed(function()
                            return Module.dice[n].frozen:get() and Color3.fromRGB(90,114,204) or Color3.fromRGB(204,204,204);
                        end);
                        Thickness = Computed(function()
                            local size = s:get();
                            if typeof(size) ~= "Vector2" then size = Vector2.zero; end
                            return size.X * 0.08;
                        end);
                    };
                    -- Dots
                    dot(UDim2.new(0.23,0,0.23,0),Computed(function()
                        local num = Module.dice[n].number:get()
                        if typeof(num) ~= "number" then num = 0 end;
                        return num > 1
                    end));
                    dot(UDim2.new(0.77,0,0.23,0),Computed(function()
                        local num = Module.dice[n].number:get()
                        if typeof(num) ~= "number" then num = 0 end;
                        return num > 3
                    end));
                    dot(UDim2.new(0.23,0,0.5,0),Computed(function()
                        local num = Module.dice[n].number:get()
                        if typeof(num) ~= "number" then num = 0 end;
                        return num == 6
                    end));
                    dot(UDim2.new(0.77,0,0.5,0),Computed(function()
                        local num = Module.dice[n].number:get()
                        if typeof(num) ~= "number" then num = 0 end;
                        return num == 6
                    end));
                    dot(UDim2.new(0.23,0,0.77,0),Computed(function()
                        local num = Module.dice[n].number:get()
                        if typeof(num) ~= "number" then num = 0 end;
                        return num > 3
                    end));
                    dot(UDim2.new(0.77,0,0.77,0),Computed(function()
                        local num = Module.dice[n].number:get()
                        if typeof(num) ~= "number" then num = 0 end;
                        return num > 1
                    end));
                    dot(UDim2.new(0.5,0,0.5,0),Computed(function()
                        local num = Module.dice[n].number:get()
                        if typeof(num) ~= "number" then num = 0 end;
                        return num % 2 == 1
                    end));
                }
            }
        };
    }
end

function refreshLocks()
    local locked = Module.locked:get();
    if locked == 1 then
        local rel = Module.relPos:get();
        local size = Module.lockSize:get();
        if typeof(size) ~= "Vector2" then size = Vector2.one end;
        if typeof(rel) ~= "Vector2" then rel = Vector2.one end;
        Module.size:set(UDim2.new(0,size.X,0,size.Y));
        for i = 1,5,1 do
            local lp = Module.bottomLock[i]:get();
            if typeof(lp) ~= "Vector2" then lp = Vector2.one end;
            local p = lp - rel;
            Module.dice[i].position:set(UDim2.new(0,p.X + size.X/2 + 1,0,p.Y + size.Y/2 + 1));
            Module.dice[i].rotation:set(0);
        end
    elseif locked == 2 then
        local rel = Module.relPos:get();
        local size = Module.lockSize:get();
        if typeof(size) ~= "Vector2" then size = Vector2.one end;
        if typeof(rel) ~= "Vector2" then rel = Vector2.one end;
        Module.size:set(UDim2.new(0,size.X,0,size.Y));
        for i = 1,5,1 do
            local lp = Module.topLock[i]:get();
            if typeof(lp) ~= "Vector2" then lp = Vector2.one end;
            local p = lp - rel;
            Module.dice[i].position:set(UDim2.new(0,p.X + size.X/2 + 1,0,p.Y + size.Y/2 + 1));
            Module.dice[i].rotation:set(0);
        end
    end
end
local d1 = Fusion.Observer(Module.relPos):onChange(refreshLocks)
local d2 = Fusion.Observer(Module.relSize):onChange(refreshLocks)
local d3

function Module.Ui(data: table): {GuiObject}
    d3 = Fusion.Observer(data.spectate):onChange(function()
        task.wait(0.25)
        refreshLocks();
    end)
    return {
        -- Rest Areas
        RestArea(Module.bottomLock,Vector2.new(0.5,1),UDim2.new(0.5,0,1,0));
        RestArea(Module.topLock,Vector2.new(0.5,0),UDim2.new(0.5,0,0,0));
        -- Dice
        die(1);
        die(2);
        die(3);
        die(4);
        die(5);
    };
end

function Module.LockTop()
    for i = 1,5,1 do
        Module.dice[i].frozen:set(false);
    end
    Module.locked:set(2);
    refreshLocks();
end

function Module.LockBottom()
    for i = 1,5,1 do
        Module.dice[i].frozen:set(false);
    end
    Module.locked:set(1);
    refreshLocks();
end

function Module.Unlock()
    Module.locked:set(0);
    Module.size:set(UDim2.new(0.26,0,0.26,0))
end

function Module.cleanup()
    if typeof(d1) == "function" then
        d1();
    end
    if typeof(d2) == "function" then
        d2();
    end
    if typeof(d3) == "function" then
        d3();
    end
end

function biasedRandom(min, max, samples)
	samples = samples or 2
	local sum = 0
	for _ = 1, samples do
		sum = sum + math.random()
	end
	local average = sum / samples
	return min + (max - min) * average
end

function rand(Positions: table, d: number, area: Vector2): (boolean, table)
    local c = 0;
    for i = 1,5,1 do
        if not Module.dice[i].frozen:get() then
            -- random pos
            local rPos
            local valid = false
            while not valid do
                --rPos = Vector2.new(math.random(d/2,area.X - d/2),math.random(d/2, area.Y - d/2));
                rPos = Vector2.new(biasedRandom(d/2,area.X - d/2,2),biasedRandom(d/2,area.Y - d/2));
                -- Check if valid
                local v = true
                for j = 1,5,1 do
                    if j == i then
                        continue
                    end
                    local dist = math.sqrt( math.pow(rPos.X - Positions[j].X,2) + math.pow(rPos.Y - Positions[j].Y,2) )
                    if dist < d then
                        -- invalid
                        c += 1;
                        v = false;
                        break
                    end
                end
                if c > 1500 then
                    return false, {}
                end
                valid = v;
            end
            -- Valid Pos;
            Positions[i] = rPos;
        end
    end
    return true, Positions
end

function Module.RandomizePositions()
    if Module.locked:get() ~= 0 then
        Module.Unlock();
    end
    local Positions = table.create(5,Vector2.new(-200,-200));
    local area = Module.relSize:get();
    if typeof(area) ~= "Vector2" then area = Vector2.one end;
    local diceSize = math.min(area.X * 0.26,55);
    local d = math.sqrt(2) * diceSize;
    -- Convert frozen positions to px
    for i = 1,5,1 do
        if Module.dice[i].frozen:get() then
            local pos = Module.dice[i].position:get() :: UDim2;
            if typeof(pos) == "UDim2" then
                Positions[i] = Vector2.new(area.X * pos.X.Scale,area.Y * pos.Y.Scale);
            end
        end
    end
    -- Generate Random Positions
    local valid = false;
    while not valid do
        local nv, np = rand(table.clone(Positions),d,area);
        if nv then
            Positions = np;
            valid = true;
        else
            task.wait();
        end
    end
    -- Generate Random Rotations / Save Pos
    for i = 1,5,1 do
        if not Module.dice[i].frozen:get() then
            Module.dice[i].rotation:set(math.random(0,360));
            Module.dice[i].position:set(UDim2.new(Positions[i].X / area.X,0, Positions[i].Y / area.Y,0));
        end
    end
end

function Module.Refresh()
    refreshLocks();
end

return Module;
