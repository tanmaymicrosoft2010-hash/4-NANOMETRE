# 4 Nano Metre

A bomb is ticking under the wafer line at 4 Nano Metre. You’re CEO GPU, the last operator on shift, and the core is fourteen bays away. Hop over hot plates, climb ladders and bounce across broken bridges. Green coins buy you five seconds. Red ones cost you five. Your first step starts the fuse. Can you reach the core before time runs out?

Open `project.godot` in Godot 4.6 and press **F5** to play.

## Current playtest: the factory floor

Choose **Silicon Valley** or **Shenzhen** on the home screen to start Core Run, **How to Play** for the field manual, or **Story** for the radio call.

The run crosses 14 bays. Climb the Etch ladder and take the Wet bench lift to reach Wafer transfer, the halfway mark. Beyond the bake ovens, climb to the air scrubber and ride the cooling-loop lift toward the core in Bay 14.

Choose **Silicon Valley** or **Shenzhen** directly from the home screen. Both shifts now have a modestly tighter fuse and stronger hit penalties: Silicon Valley gets 4:45 and 6-second penalties; Shenzhen gets 3:45 and 8-second penalties. On the console, Shenzhen starts at 60 stability, costs 30 per mistake, and dims every 10 seconds; Silicon Valley starts at 70, costs 25, and gets investor mail every 12 seconds.

- **Keyboard:** A/D or arrows to move; Space or Up to jump. Hold Right (or W) at the ladder to climb. **Gamepad:** left stick or D-pad, bottom face button to jump. Touch controls support moving and jumping with different fingers.
- **Pause:** P, Esc, the controller Menu button, or the on-screen button. The web build also pauses when it loses focus. Resume, leave the job, or rebind jump from the pause slip. Sound and fullscreen controls are on the home screen; the sound choice is saved locally.
- **A clean run:** reach the core before the fuse burns out. Falling or touching a hot plate costs 5 seconds and returns you to the last bay.
- **After Level 1:** the report shows your time left and dot count. Level 2 is marked **UNDER PROGRESS**.

Open `scenes/level_select.tscn` and press **F6** to playtest the console jobs.

| Job | Controls | To clear it |
| --- | --- | --- |
| Core run | A/D or arrows to move; Space or Up to jump; hold Right or W at the ladder. Touch controls appear on touchscreens. | Reach the core before your site fuse runs out. Green dots add 5 seconds; red dots, hot plates and falls use the site's hit penalty. |
| Wafer sort | Click a pad, press 1–4, or use the numpad. | Score 150 points. |
| Final test | Same console, larger batches. | Score 200 points. |

On the console, a correct answer gives 10 points and restores 10 stability. Silicon Valley loses 25 stability per mistake; Shenzhen loses 30. At 30 or less, the clock runs at 1.5× speed until you get three right **in a row**. That Bounce Back restores stability to 80 in Silicon Valley, 70 in Shenzhen, and adds ten seconds.

The best time left on each cleared job is saved locally, separately for each factory.

## Editor notes

- `scenes/character_select.tscn` is the title screen. Its layout is composed by `scripts/home_layout.gd`; the live lift demonstration is in `ui/line_preview.tscn`. The operator is always CEO GPU. `scenes/how_to_play.tscn` holds the About and Controls sections.
- Place the supplied site-card screenshots at `assets/site_cards/silicon-valley.png` and `assets/site_cards/shenzhen.png` (JPG, JPEG and WebP are also supported). No generated replacement artwork is used.
- Change type, colors and focus styles in `ui/shift_theme.tres`. The floor uses `ui/floor_strip.tscn`; the console jobs use `ui/line_hud.tscn`.
- Arrange the track in `scenes/level1_runner.tscn`. Deck widths and station names are editable in the Inspector. The reusable player, time dots, ladder, lift and hot plate are in `scenes/runner/`.
- The runner frames are from the supplied `yo/templerun` folder. The floor and home-screen lift preview share the original Kenney industrial deck, wall art and green pad. The dispatch controls use **[factory_ v1.0](https://kevins-moms-house.itch.io/factory)** by analogStudios / Kevin's Mom's House ([CC0](https://creativecommons.org/publicdomain/zero/1.0/)); the original sheet and readme are in `assets/factory_/`. The ladder and display fonts are by Kenney.

## itch.io

With matching Godot export templates installed, use **Project → Export → Web (itch.io)**. Export to an empty folder as `index.html`, zip the contents with `index.html` at the root, and upload the zip as an HTML game. The preset is single-threaded and packages the playable scenes and their dependencies. The suggested embed size is **960 × 540**.

To check the shipped build, extract the zip outside the project and run `godot --headless --main-pack index.pck --script /absolute/path/to/tests/web_export_smoke.gd` from that folder. This opens each factory and plays through a Level 2 recovery using only resources from the exported game.

An ESP32 is optional. On the web, the game calls `window.connectArduino()` and `window.sendToArduino(code)` if the page provides them. The codes are `G` (correct/save), `R` (danger), `B` (boost/recovery) and `X` (failure).
