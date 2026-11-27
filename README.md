# Farmstead — Player Foundation

This branch contains the first playable movement prototype.

## Run

Open the project in Godot 4.7 and run the project. The main scene is
`scenes/world/test_world.tscn`.

## Controls

- WASD or arrow keys: move
- Diagonal movement is normalized so it is not faster than straight movement.

## Current slice

- CharacterBody2D player with a small ground-level collision shape.
- Separate player visual component and SpriteFrames resource.
- Four-direction movement with diagonal input.
- Camera follow and parent Y-sorting based on the player's ground position.
- Small bounded test field with solid stone obstacles.

The supplied character pack does not include a down-facing run animation or
side-facing idle animations yet. Those states temporarily fall back to the
front idle animation. The jump animation is imported but not wired to gameplay.

The ground and obstacles are prototype placeholders, not the final world system.
No inventory, interaction, gathering, combat, survival stats, or world persistence
is included in this milestone.
