# Inside Life

A Godot 4.7 cell biology game. Grow one persistent cell by importing nutrients, making ATP, transcribing genes, building proteins, placing organelles and transporters, and responding to membrane damage and other stresses.

## Run

Open `project.godot` in Godot 4.7 and run the main scene. The game starts with an action-based tutorial, then moves into continuous play.

## Tests

The `tests/` directory contains headless Godot regression checks. Run one with:

```sh
godot --headless --path . --script res://tests/playthrough.gd
```

The `textures/` directory contains the artwork used by the game.
