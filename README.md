# Sokoban Showdown (Roblox)
This package contains the full Lua source + placement map for Roblox Studio.

## Where to paste in Roblox Studio
- **ReplicatedStorage**: `Constants.module.lua`, `LevelStore.module.lua`, `Remotes.lua`, `Tests/Pushing.spec.lua`
- **ServerScriptService**: `SokobanServer.server.lua`, `Leaderboard.server.lua`, `AntiCheat.server.lua`
- **Workspace**: `Setup.server.lua`
- **StarterPlayer/StarterPlayerScripts**: `ClientController.client.lua`
- **StarterGui**: `HUD.gui.lua`, `SocialShare.gui.lua`

## Quick test
Command Bar:
```lua
require(game.ReplicatedStorage.Tests["Pushing.spec"]).run()
```

## Push to GitHub (SSH)
```bash
# 1) unzip
unzip SokobanShowdown.zip -d SokobanShowdown && cd SokobanShowdown

# 2) init repo
git init
git branch -M main
git add .
git commit -m "Initial commit: Sokoban Showdown"

# 3) set remote (replace <USER> and <REPO>)
git remote add origin git@github.com:<USER>/<REPO>.git

# 4) push
git push -u origin main
```

## Push to GitHub (HTTPS)
```bash
git remote add origin https://github.com/<USER>/<REPO>.git
git push -u origin main
```

