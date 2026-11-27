# Farmstead

A top-down sandbox survival prototype built with Godot.

## Current prototype

- Main menu and world scene.
- Top-down movement with a camera that follows the player.
- A small hand-designed resource layout over a seeded, tile-like grass field.
- Harvestable trees, rocks, and berry bushes.
- A basic inventory for wood, stone, and berries.
- Hunger drains over time; eating berries restores hunger.
- Health decreases when hunger reaches zero.
- Craft a campfire from wood and stone; resting nearby restores health.
- A repeating day cycle with a subtle world tint.
- On-screen controls on mobile builds.

## Controls

| Action | Keyboard |
| --- | --- |
| Move | WASD |
| Gather nearby resource | E |
| Eat one berry | F |
| Craft a campfire (3 wood + 2 stone) | C |

On mobile, use the on-screen directional pad and E/F/C buttons.

## Run

Open the project in Godot 4.7 and run the project. The main menu is configured as the startup scene.

## Current boundaries

This is the first playable foundation, not the complete game. Art is currently made from simple shapes. The campfire is the only craftable structure so far; there is no save system, full building system, combat, procedural chunk streaming, or multiplayer yet. The next development steps should be chosen after testing this version in the Godot editor.
