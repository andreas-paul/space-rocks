# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A 2D Asteroids-style game (exported as "SpaceRocks") in Godot 4.7 with GDScript, using the `gl_compatibility` renderer at a 1920x1080 base viewport. The entry scene is `scenes/main_menu.tscn`.

## Commands

The project has no test suite, linter, or build scripts, so changes are checked by running the game. `godot` is not on PATH on this machine, so use the full path to the editor binary in place of `godot` below.

```sh
godot --path .                                  # run the game
godot --path . scenes/game_scene.tscn           # run one scene directly
godot --path . --editor                         # open the editor
godot --headless --path . --import              # reimport assets, surfaces script/resource load errors
godot --headless --path . --export-release "Windows Desktop"   # presets: "Web", "Windows Desktop"
```

Export paths in `export_presets.cfg` are absolute paths on the user's Desktop.

### Assets are stored in DVC

`.gitignore` excludes everything under `assets/` except `*.dvc` pointer files. The DVC remote is a local folder (`D:/development/dvc_storage`).

```sh
dvc pull                 # fetch assets
dvc add assets/art/x.png # after adding or changing an asset, then git add the .dvc file
dvc push
```

`addons/` and `test_scenes/` are also gitignored, even though `project.godot` enables the addons and autoloads `SignalLens` from `addons/signal_lens/`. A fresh clone won't have them, so don't assume git can restore them.

## Architecture

### Autoloads

Global state and cross-scene coordination live in autoloads registered in `project.godot`. `Events` must stay ahead of the autoloads that connect to it in `_ready`.

- `Events` is the global signal bus for game flow and score (`new_game`, `restart`, `open_main_menu`, `quit`, `won`, `lost`, `score`, `score_updated`, ...).
- `GameManager` listens to `Events` and does all scene changes. Emit a signal rather than calling `change_scene_to_packed` directly.
- `ScoreManager` accumulates `Events.score` and re-emits the total as `score_updated`, which `scenes/user_interface.gd` displays.
- `AudioManager` is a scene (`scenes/audio_manager.tscn`), not a script. Its `Sounds` and `Music` children define their own signals, so audio is triggered with `AudioManager.get_node("Sounds").play_cannon_sound.emit()`. A new sound needs an exported player, a signal, and a handler in `scenes/sounds.gd`.
- `InGameMenu` is an always-loaded overlay that toggles on `ui_cancel` and handles `get_tree().paused`.

### Gameplay

`scenes/game_scene.tscn` places the player, the initial asteroids, the mothership, and the HUD by hand. Spawned objects are added to the scene root: `get_parent().add_child` for effects and `owner.add_child` for bullets.

- **Win condition:** `game_scene.gd` checks every frame for direct children of type `Asteroid`, `SmallAsteroid`, or `TinyAsteroid`, and emits `won` when there are none. A new asteroid type must be added to this check, and asteroids must stay direct children of the scene root.
- **Asteroid split chain:** `Asteroid` → 3 `SmallAsteroid` → 2 `TinyAsteroid`, using `PackedScene` exports set in the `.tscn` files. The three classes share no base class and duplicate their logic, so a behavior change usually has to be made in all three.
- **Asteroid cleanup:** `Asteroid` and `SmallAsteroid` call `hide()` when destroyed rather than `queue_free()`. They are freed by the `VisibleOnScreenNotifier2D` `screen_exited` handler, which the win condition depends on.
- **Damage:** `scenes/bullet.gd` calls `hit()` on any body in the `Asteroids`, `Player`, or `Mothership` groups. Anything damageable needs both the group and a `hit()` method. Bullets from the player and the mothership are the same scene, so they differ only by spawn point.

### Collision layers

Layers are unnamed in `project.godot`; values are set per scene:

| Object | Layer value |
| --- | --- |
| Player | 1 (default) |
| `Asteroid` | 2 |
| `SmallAsteroid` | 4 |
| `TinyAsteroid` | 8 |
| Bullet | 16 + bit 32 |
| Mothership | bit 32 |

## Unfinished code

These look wired up but aren't, so check them before building on them:

- `SaveManager.on_lost_won` is empty and `handle_highscore` is never called, so high scores are never saved.
- Nothing outside `SaveManager` connects to `Events.won` or `Events.lost`, so there is no win or lose screen; the tree just pauses.
- `ScoreManager.score` is never reset, so it carries over through restarts.
- `user_interface.gd` subtracts a hardcoded 10 from the health bar instead of reading `PlayerShip.hitpoints`, and `PlayerShip.heal()` doesn't update the bar.
- `power_up.gd` is an empty script at the repo root, and nothing calls `PlayerShip.heal()`.
- `components/shoot_component.gd` references an undeclared `can_shoot`; shooting is actually implemented in `player_ship.gd` and `mother_ship.gd`.
