# Agent Instructions

This is a repo-first Roblox project. The source of truth for game code is this Git repository, not a binary `.rbxl` place file.

## Architecture

- `src/shared` maps to `ReplicatedStorage.Shared`.
- `src/server` maps to `ServerScriptService.Server`.
- `src/client` maps to `StarterPlayer.StarterPlayerScripts.Client`.
- Put reusable gameplay rules, configuration, and pure logic in ModuleScripts.
- Keep server authority on the server. Clients should request actions; servers should validate them.

## Workflow

- Prefer editing files under `src/`.
- Use Rojo to sync source into Roblox Studio for playtesting.
- Use Roblox Studio for visual editing, terrain, assets, animation, debugging, and final playtest validation.
- Do not rely on generated `.rbxl`, `.rbxlx`, `.rbxm`, `.rbxmx`, `Packages/`, or `sourcemap.json` as source files unless the user explicitly asks.

## Checks

Run these when the tools are installed:

```powershell
stylua src
selene src
```

If a task changes Rojo mapping, validate `default.project.json` and explain how to test the sync in Studio.
