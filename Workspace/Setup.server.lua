-- Builds the map from the current Level using LevelStore. Listens to BuildLevel event.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage:WaitForChild("Constants"))
local LevelStore = require(ReplicatedStorage:WaitForChild("LevelStore"))
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))

local MapFolder = Instance.new("Folder")
MapFolder.Name = "Map"
MapFolder.Parent = workspace

local function cellToWorld(cell: Vector2): Vector3
	local cs = Constants.CELL_SIZE
	return Vector3.new(cell.X * cs, 1, cell.Y * cs)
end

local function clearMap()
	for _, child in ipairs(MapFolder:GetChildren()) do
		child:Destroy()
	end
end

local function makePart(name, size, color)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Size = size
	p.Color = color
	p.Name = name
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	return p
end

local function buildLevel(levelId)
	clearMap()
	local lvl = LevelStore.GetLevel(levelId)

	-- Floor
	local floorSize = Vector3.new(lvl.width * Constants.CELL_SIZE, 1, lvl.height * Constants.CELL_SIZE)
	local floor = makePart("Floor", floorSize, Constants.COLORS.Floor)
	floor.CFrame =
		CFrame.new(((lvl.width - 1) * Constants.CELL_SIZE) / 2, 0.5, ((lvl.height - 1) * Constants.CELL_SIZE) / 2)
	floor.Parent = MapFolder

	-- Walls
	for _, w in ipairs(lvl.walls) do
		local wall = makePart("Wall", Vector3.new(Constants.CELL_SIZE, 3, Constants.CELL_SIZE), Constants.COLORS.Wall)
		wall.CFrame = CFrame.new(cellToWorld(w))
		wall.Parent = MapFolder
		CollectionService:AddTag(wall, "Wall")
	end

	-- Goals
	for _, g in ipairs(lvl.goals) do
		local goal = makePart("Goal", Vector3.new(Constants.CELL_SIZE, 0.2, Constants.CELL_SIZE), Constants.COLORS.Goal)
		goal.CFrame = CFrame.new(cellToWorld(g))
		goal.Parent = MapFolder
		CollectionService:AddTag(goal, "Goal")
	end

	-- Boxes
	for i, b in ipairs(lvl.boxes) do
		local box = makePart(
			("Box_%d"):format(i),
			Vector3.new(Constants.CELL_SIZE * 0.9, Constants.CELL_SIZE * 0.9, Constants.CELL_SIZE * 0.9),
			Constants.COLORS.Box
		)
		box.CFrame = CFrame.new(cellToWorld(b))
		box.Parent = MapFolder
		CollectionService:AddTag(box, "Box")
	end
end

-- Listen for build requests
Remotes.BuildLevel.Event:Connect(function(levelId)
	buildLevel(levelId)
end)
