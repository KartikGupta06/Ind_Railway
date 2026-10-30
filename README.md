# Idle Railway Empire — Prototype v0.1

A small Godot 4.7.2-compatible prototype scaffold for the railway network-building game.

## What works in this prototype scaffold

- A large colourful, Indian-inspired 2D map drawn with placeholder shapes.
- Two available station locations: Asha Nagar and Nadi Gaon.
- Camera pan and zoom.
- Build Mode: add track waypoints, preview a smoothed route, and connect the two stations.
- Construction cost is deducted from starting coins.
- A simple train moves back and forth along the built route.
- Minimal HUD with status messages and build/cancel/reset controls.

## Controls (desktop prototype)

- Drag with the left mouse button to pan the map.
- Mouse wheel to zoom in/out.
- Click **Build Track**, then click the map to place intermediate bends.
- Click **Finish Route** to connect to Nadi Gaon and construct the route.
- Click **Cancel** to leave build mode.
- Click **Reset View** to return the camera to its starting position.

## Open the project

1. Install the **standard** (not .NET) build of Godot 4.7.2 stable.
2. Extract this ZIP into a normal project folder (for example `Documents/IdleRailwayEmpire_Prototype`).
3. Open Godot Project Manager and select **Import**.
4. Choose the extracted folder, select `project.godot`, and import it.
5. Open the project and press **F6** to run the current scene or **F5** to run the main project.
6. Open the project folder in Antigravity as a workspace when you want the AI assistant to help edit the GDScript files.

## Important

This is an early playable scaffold, not the finished game. The graphics are drawn from simple shapes so we can validate map movement, route planning, track placement and train movement before producing final art assets. Android export, save/load, actual railway signalling, bridges/tunnels, coach management, stations and mission/economy systems are not implemented yet.
