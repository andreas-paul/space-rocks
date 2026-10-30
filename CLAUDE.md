# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

A 2D Asteroids-style game (exported as "SpaceRocks") in Godot 4.7 with GDScript, at a 1920x1080 base viewport. Desktop uses Forward+; web uses Compatibility, where `Utils` replaces HDR glow with additive blending (test with `--rendering-method gl_compatibility`). The entry scene is `scenes/ui_elements/main_menu.tscn`.

## Commands

The project has no test suite, linter, or build scripts, so changes are checked by running the game. `godot` is not on PATH on this machine, so use the full path to the editor binary in place of `godot` below (`D:/SteamLibrary/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe`).

```sh
godot --path .                                  # run the game
godot --path . scenes/levels/game_scene.tscn    # run one scene directly
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

`test_scenes/` is also gitignored, so git can't restore it.

## Architecture

### Autoloads

Global state and cross-scene coordination live in autoloads registered in `project.godot`. `Events` must stay ahead of the autoloads that connect to it in `_ready`.

- `Events` is the global signal bus for game flow and score (`new_game`, `restart`, `open_main_menu`, `quit`, `won`, `lost`, `score`, `score_updated`, ...).
- `GameManager` listens to `Events` and does all scene changes with a fade, plus hit stop (`Events.hit_stop`). Emit a signal rather than calling `change_scene_to_packed` directly.
- `ScoreManager` accumulates `Events.score` and re-emits the total as `score_updated`, which `scenes/ui_elements/user_interface.gd` displays.
- `AudioManager` is a scene (`scenes/managers/audio_manager.tscn`), not a script. Its `Sounds` and `Music` children define their own signals, so audio is triggered with `AudioManager.get_node("Sounds").play_cannon_sound.emit()`. A new sound needs an exported player, a signal, and a handler in `scenes/managers/sounds.gd`.
- `InGameMenu` is an always-loaded `CanvasLayer` overlay that toggles on `ui_cancel` and handles `get_tree().paused`.

### Gameplay

`scenes/levels/game_scene.tscn` places the player, the initial asteroids, the mothership, and the HUD by hand. Spawned objects are added to the scene root: `get_parent().add_child` for effects and `owner.add_child` for bullets.

- **Mouse aiming:** `player_ship.gd` turns towards the pointer. `game_scene.gd` confines and hides the pointer during play, shows `scenes/ui_elements/crosshair.tscn` in its place, and releases it while `InGameMenu` is open, on `won`/`lost`, and on exit.
- **Waves and winning:** `game_scene.gd` checks every frame for direct children of type `Asteroid`, `SmallAsteroid`, or `TinyAsteroid`. When there are none it starts the next wave, or emits `won` after the last one (`total_waves`). Wave 1 is the asteroids placed in the scene; later waves spawn outside the screen and only start wrapping once they have flown in (`Asteroid.has_entered_screen`). A new asteroid type must be added to this check, and asteroids must stay direct children of the scene root.
- **End of game:** `won` and `lost` show `scenes/ui_elements/game_over_screen.tscn`, which asks for a 3 character name if the score makes the top 10. `SaveManager` keeps that list in `user://highscore.json` and connects first because it's an autoload, so the screen can read the updated `is_new_highscore`. `scenes/ui_elements/high_score_list.tscn` shows the list from the main menu.
- **Asteroid split chain:** `Asteroid` → 3 `SmallAsteroid` → 2 `TinyAsteroid`, using `PackedScene` exports set in the `.tscn` files. The three classes share no base class and duplicate their logic, so a behavior change usually has to be made in all three.
- **Asteroid cleanup:** all three classes call `queue_free()` when destroyed, and `hit()` returns early if already queued, so two bullets landing in the same physics tick can't split or score twice.
- **Ship and asteroid collisions:** both sides call `PlayerShip.collide_with_asteroid`, which shares a bounce by each object's `mass` and applies damage. New asteroid types need a `mass`.
- **Screen shake:** `Events.screen_shake` drives a `Camera2D` that `game_scene.gd` creates in code. Keep `max_shake_offset` below 14, or tiny asteroids near the edge can trigger their `screen_exited` cleanup and vanish.
- **Each wave after the first** calls `mother_ship.gd` `start_pass()`, one crossing per wave until it is destroyed.
- **Power-ups** only drop from destroyed large asteroids (`Asteroid.power_up_chance`).
- **Intro:** `player_ship.gd` `play_intro()` flies the ship in from below the screen at the start of each game, with controls and collisions off. The rocket cooldown starts when it ends.
- **Weapons:** holding left click fires bullets, Space (the `fire` action, also used by the main menu) fires `scenes/rocket/rocket.tscn`, whose blast damages everything in range. `scenes/rocket/rocket_icon.tscn` shows the rocket cooldown.
- **Damage:** `scenes/bullet/bullet.gd` calls `hit()` on any body in the `Asteroids`, `Player`, or `Mothership` groups. Anything damageable needs both the group and a `hit()` method. The player and the mothership share one bullet scene, and each narrows the bullet's mask at spawn: player bullets ignore the player layer, mothership bullets only hit the player.

### Collision layers

Layers are unnamed in `project.godot`; values are set per scene:

| Object | Layer value |
| --- | --- |
| Player | 1 (default) |
| `Asteroid` | 2 |
| `SmallAsteroid` | 4 |
| `TinyAsteroid` | 8 |
| Bullet | 16 |
| Mothership | bit 32 |

## Unfinished code

These look wired up but aren't, so check them before building on them:

- `components/shoot_component.gd` is unused and its `can_shoot` is never set; shooting is actually implemented in `player_ship.gd` and `mother_ship.gd`.

## Custom art and sound

Code-drawn placeholders are used until art is set on these exports: `texture` on the `Crosshair` node in `scenes/ui_elements/crosshair.tscn`, `texture` on `scenes/rocket/rocket.tscn`, `icon` on `scenes/rocket/rocket_icon.tscn` (light art, it gets tinted). The power-up sprite is in `scenes/power_up/power_up.tscn`; its shader recolors the shape unless `keep_art_colors` is on. Everything else is a normal `Sprite2D` texture or particle texture in its scene. Each sound has its own player under `Sounds` in `scenes/managers/audio_manager.tscn`, so a new file only needs setting as that node's `Stream`.
