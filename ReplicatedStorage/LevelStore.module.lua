local LevelStore = {}

local function V(x,y) return Vector2.new(x,y) end

local Levels = {
	{
		id = "Level1",
		width = 9, height = 7,
		playerSpawn = V(1, 5),
		walls = {
			V(0,0),V(1,0),V(2,0),V(3,0),V(4,0),V(5,0),V(6,0),V(7,0),V(8,0),
			V(0,1),                                                  V(8,1),
			V(0,2),                        V(4,2),                  V(8,2),
			V(0,3),                        V(4,3),                  V(8,3),
			V(0,4),                        V(4,4),                  V(8,4),
			V(0,5),                                                  V(8,5),
			V(0,6),V(1,6),V(2,6),V(3,6),V(4,6),V(5,6),V(6,6),V(7,6),V(8,6),
		},
		goals = { V(6,2), V(6,4) },
		boxes = { V(5,2), V(5,4) },
	},
	{
		id = "Level2",
		width = 10, height = 8,
		playerSpawn = V(2,6),
		walls = (function()
			local t = {}
			for x=0,9 do table.insert(t, V(x,0)); table.insert(t, V(x,7)) end
			for y=1,6 do table.insert(t, V(0,y)); table.insert(t, V(9,y)) end
			for x=3,6 do table.insert(t, V(x,3)) end
			return t
		end)(),
		goals = { V(7,2), V(7,5), V(2,2) },
		boxes = { V(6,2), V(6,5), V(3,2) },
	},
	{
		id = "Level3",
		width = 8, height = 8,
		playerSpawn = V(1,6),
		walls = (function()
			local t = {}
			for x=0,7 do table.insert(t, V(x,0)); table.insert(t, V(x,7)) end
			for y=1,6 do table.insert(t, V(0,y)); table.insert(t, V(7,y)) end
			table.insert(t, V(4,2)); table.insert(t, V(4,3)); table.insert(t, V(4,4))
			return t
		end)(),
		goals = { V(6,1), V(6,6) },
		boxes = { V(5,1), V(5,6) },
	},
}

local currentLevelIndex = 1

local function deepCopyVecList(src)
	local out = {}
	for i,v in ipairs(src) do out[i] = Vector2.new(v.X, v.Y) end
	return out
end

local function makeLevelCopy(lv)
	return {
		id = lv.id,
		width = lv.width,
		height = lv.height,
		playerSpawn = Vector2.new(lv.playerSpawn.X, lv.playerSpawn.Y),
		walls = deepCopyVecList(lv.walls),
		goals = deepCopyVecList(lv.goals),
		boxes = deepCopyVecList(lv.boxes),
	}
end

function LevelStore.GetLevel(idOrIndex)
	if typeof(idOrIndex) == "string" then
		for i,lv in ipairs(Levels) do if lv.id == idOrIndex then return makeLevelCopy(lv), i end end
	elseif typeof(idOrIndex) == "number" then
		local lv = Levels[idOrIndex]
		if lv then return makeLevelCopy(lv), idOrIndex end
	end
	return makeLevelCopy(Levels[1]), 1
end

function LevelStore.ListLevels()
	local list = {}
	for i,lv in ipairs(Levels) do list[i] = lv.id end
	return list
end

function LevelStore.LoadLevel(idOrIndex)
	local _, idx = LevelStore.GetLevel(idOrIndex)
	currentLevelIndex = idx
	return Levels[idx].id
end

function LevelStore.GetCurrentLevelId()
	return Levels[currentLevelIndex].id
end

function LevelStore.NextLevelId()
	local nextIdx = currentLevelIndex + 1
	if nextIdx > #Levels then nextIdx = 1 end
	return Levels[nextIdx].id
end

return LevelStore
