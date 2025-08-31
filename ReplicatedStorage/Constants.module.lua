local Constants = {
	CELL_SIZE = 4, -- studs per tile
	TWEEN_TIME = 0.15, -- seconds for client-side ghost tween
	ROUND_DURATION = 180, -- seconds
	NEXT_ROUND_DELAY = 6, -- seconds after win/timeout
	GAME_NAME = "Sokoban Showdown",
	DATASTORE_NAME = "SokobanShowdown_BestTimes_v1",
	ORDERED_NAME_PREFIX = "SokobanShowdown_Top_Level_",
	COLORS = {
		Floor = Color3.fromRGB(235, 235, 235),
		Wall  = Color3.fromRGB(60,  60,  60),
		Goal  = Color3.fromRGB(255, 210, 66),
		Box   = Color3.fromRGB(181, 101, 29),
	},
	ADMIN_USERIDS = { -- add your userId if you want live reset
		-- [12345678] = true,
	},
}
return Constants
