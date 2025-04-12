local PathfindingHandler = require(game:GetService("ReplicatedStorage"):WaitForChild("PathfindingHandler"))

local GRID_SIZE = Vector3.new(30,1,30)
local OBSTACLE_PERCENT = 0.2
local PADDING = Vector3.new(3, 3, 3)
local PART_SIZE = Vector3.new(3, 3, 3)
local VISUALIZE = true
local DELAY = 0.1

local partsFolder = workspace:FindFirstChild("Parts")
if not partsFolder then
	partsFolder = Instance.new("Folder", workspace)
	partsFolder.Name = "Parts"
end

local grid = PathfindingHandler.new(GRID_SIZE)

math.randomseed(tick())
for x = 1, GRID_SIZE.X do
	for y = 1, GRID_SIZE.Y do
		for z = 1, GRID_SIZE.Z do
			if math.random() < OBSTACLE_PERCENT then
				local pos = Vector3.new(x, y, z)
				grid:block(pos)
			end
		end
	end
end

local function getRandomUnblockedPosition()
	while true do
		local pos = Vector3.new(
			math.random(1, GRID_SIZE.X),
			math.random(1, GRID_SIZE.Y),
			math.random(1, GRID_SIZE.Z)
		)
		if not grid[pos.X][pos.Y][pos.Z].Blocked then
			return pos
		end
	end
end

local startPos = getRandomUnblockedPosition()
local endPos = getRandomUnblockedPosition()

grid[startPos.X][startPos.Y][startPos.Z]._Color = Color3.fromRGB(0, 255, 0)
grid[endPos.X][endPos.Y][endPos.Z]._Color = Color3.fromRGB(255, 255, 0)

grid:visualize(PADDING, PART_SIZE)

grid:pathfind(startPos, endPos, VISUALIZE, DELAY, PADDING, PART_SIZE)

local current = endPos
local path = {}
while current ~= startPos do
	table.insert(path, 1, current)
	current = grid[current.X][current.Y][current.Z].Origin
end
table.insert(path, 1, startPos)
