# Sokoban Showdown (Roblox)

This repository contains the full Luau source code for the Sokoban Showdown game.

## How to Open the Project

1.  **Install Roblox Studio:** If you don't have it already, download and install [Roblox Studio](https://www.roblox.com/create).
2.  **Open the Place File:**
    *   Open Roblox Studio.
    *   Go to **File > Open from File...**.
    *   Navigate to the `build` directory in this repository.
    *   Select the `socoblox.rbxlx` file and click **Open**.

The project should now be open in Roblox Studio, and you should be able to run and edit the game.

## Development

This project uses `rojo` to manage the codebase. The Luau source code is organized into directories that map to Roblox services.

### Original README Content

The following is the original content of the README file, which contains information about the project's structure and how to set it up manually.

---

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
