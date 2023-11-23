-- Stonetr03 - Pieces

local Fusion = require(game:GetService("ReplicatedStorage"):WaitForChild("AdminCube"):WaitForChild("Packages"):WaitForChild("Fusion"))

local Value = Fusion.Value

return {
    ImageId = Value("rbxassetid://6556269075");
    BoardWColor = Value(Color3.fromRGB(240, 217, 181));
    BoardBColor = Value(Color3.fromRGB(181, 136, 99));

    K = Vector2.new(0,0); -- White King
    Q = Vector2.new(170,0); -- White Queen
    B = Vector2.new(340,0); -- White Bishop
    N = Vector2.new(510,0); -- White Knight
    R = Vector2.new(680,0); -- White Rook
    P = Vector2.new(850,0); -- White Pawn

    k = Vector2.new(0,170); -- Black King
    q = Vector2.new(170,170); -- Black Queen
    b = Vector2.new(340,170); -- Black Bishop
    n = Vector2.new(510,170); -- Black Knight
    r = Vector2.new(680,170); -- Black Rook
    p = Vector2.new(850,170); -- Black Pawn
}
