# Chase a Cyclist

Repo-first Roblox project for agentic Luau development.

## Workflow

This project treats the Git repo as the source of truth for code. Roblox Studio is still used for playtesting, visual editing, debugging, assets, animation, terrain, and publishing checks.

Daily loop:

1. Edit Luau files in `src/` with VS Code or an agent.
2. Run formatting and linting.
3. Sync into Roblox Studio with Rojo.
4. Playtest in Studio.
5. Commit reviewed changes with Git.

## Setup

Install Roblox Studio, VS Code, and Git.

Install Rokit, then from this folder run:

```powershell
rokit install
rojo plugin install
```

Open Roblox Studio, open or create a place, then connect the Rojo plugin while this runs:

```powershell
rojo serve default.project.json
```

## Checks

```powershell
stylua src
selene src
```

If you are working from WSL, run Git and toolchain commands from a WSL terminal in `/home/tobias/projects/chase-a-cyclist`. Roblox Studio still runs on Windows; Rojo serves the project to the Studio plugin.

## Project Layout

```text
src/
  shared/   Code available to server and client through ReplicatedStorage.Shared
  server/   Server-only code through ServerScriptService.Server
  client/   Client-only code through StarterPlayerScripts.Client
```

Keep gameplay rules, economy numbers, and system logic in modules where possible. The more logic is represented as normal files, the more reliably an agent can modify and review it.

## BLE Bridge Integration

The first playable slice polls `GameConfig.BleBridge.Endpoint` for cyclist power.

Expected response formats:

```json
{ "powerWatts": 185 }
```

Also accepted: `{ "power": 185 }`, `{ "watts": 185 }`, `{ "instantaneousPower": 185 }`, or a raw numeric response like `185`.

Roblox requires HTTP requests to be enabled in Studio under **Home > Game Settings > Security > Allow HTTP Requests**. For unpublished local testing, the Command Bar can also set:

```lua
game:GetService("HttpService").HttpEnabled = true
```

The default endpoint is `https://blebridge.com/v1/demo/power`. The current demo shape is:

```json
{
  "code": "DEMO-POWER",
  "schemaVersion": 2,
  "connected": true,
  "stale": false,
  "ageMs": 0,
  "expiresAt": 1783159560371,
  "lastBridgeSeenAt": 1783152360371,
  "power": 151
}
```

If `connected` is `false` or `stale` is `true`, the game uses fallback power and shows the bridge status in the HUD.
