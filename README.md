# Idle Railway Empire (Ind_Railway) — Prototype v0.2

A Godot 4.7.2 railway network-building simulation prototype scaffold.

## What works in this prototype

- A large colourful, Indian-inspired 2D map drawn with placeholder shapes.
- Two available station locations: Asha Nagar and Nadi Gaon.
- Decoupled Camera2D with cursor-anchored zoom, map boundary clamping, and smooth damping.
- Decoupled HUD scene (`scenes/hud.tscn`) with responsive controls and status messages.
- Centralized game configuration (`scripts/game_config.gd`).
- Build Mode: click to add track waypoints with real-time Catmull-Rom spline preview matching the final route.
- Construction cost deducted from starting coins.
- Bidirectional train movement along the built route with proper travel heading orientation.
- Minimal HUD with status messages and build/cancel/reset controls.

## Controls (desktop prototype)

- Drag with the left mouse button to pan the map.
- Mouse wheel to zoom in/out (anchored to cursor position).
- Click **+ Build Track**, then click the map to place intermediate bends.
- Click **Finish Route** to connect to Nadi Gaon and construct the route.
- Click **Cancel** to leave build mode.
- Click **Reset View** to return the camera to its starting position.

## Open the project

1. Install the **standard** (not .NET) build of Godot 4.7.2 stable.
2. Open Godot Project Manager and select **Import**.
3. Choose the project folder, select `project.godot`, and import it.
4. Open the project and press **F6** to run the current scene or **F5** to run the main project.
5. Open the project folder in Antigravity as a workspace when you want the AI assistant to help edit the GDScript files.

## Important

This is an early playable scaffold, not the finished game. The graphics are drawn from simple shapes so we can validate map movement, route planning, track placement and train movement before producing final art assets. Android export, save/load, actual railway signalling, bridges/tunnels, coach management, stations and mission/economy systems are not implemented yet.
