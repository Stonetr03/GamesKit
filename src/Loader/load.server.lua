-- Admin Cube
-- Stonetr03 Studios

local InsertService = game:GetService("InsertService")
local s, m = pcall(InsertService.LoadAsset, InsertService, 15440554589)
if s and m and m:FindFirstChild("GamesKit") then
    m.GamesKit.Parent = script:WaitForChild("Commands")
end

_G.AdminCubeCustomSettings = require(script.Settings)

require(6490802893)(script.Commands)
