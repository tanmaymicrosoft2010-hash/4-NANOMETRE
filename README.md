# 4 Nano Metre

A bomb is ticking under the wafer line at 4 Nano Metre. You’re CEO GPU, the last operator on shift, and the core is fourteen bays away. Hop over hot plates, climb ladders and bounce across broken bridges. Green coins buy you five seconds. Red ones cost you five. Your first step starts the fuse. Can you reach the core before time runs out?

Open `project.godot` in Godot 4.6 and press **F5** to play.

## Current playtest: the factory floor

Choose **Play** to go straight to Core Run, **How to Play** for the field manual, or **Story** for the radio call and factory choice. The fuse holds at 5:00 until you move.

The run crosses 14 bays. Climb the Etch ladder and take the Wet bench lift to reach Wafer transfer, the halfway mark. Beyond the bake ovens, climb to the air scrubber and ride the cooling-loop lift toward the core in Bay 14. Green dots add 5 seconds. Red dots and hot plates take 5 seconds away.

- **Keyboard:** A/D or arrows to move; Space or Up to jump. Hold Right (or W) at the ladder to climb. **Gamepad:** left stick or D-pad, bottom face button to jump. Touch controls support moving and jumping with different fingers.
- **Pause:** P, the controller Menu button, or the on-screen button. You can rebind the keyboard jump key here.
- **A clean run:** reach the core before the fuse burns out. Falling or touching a hot plate costs 5 seconds and returns you to the last bay.
- **After Level 1:** the report shows your time left and dot count. Level 2 is marked **UNDER PROGRESS**.

Open `scenes/level_select.tscn` and press **F6** to playtest the console jobs.

| Job | Controls | To clear it |
| --- | --- | --- |
| Core run | A/D or arrows to move; Space or Up to jump; hold Right or W at the ladder. Touch controls appear on touchscreens. | Reach the core before 5:00 runs out. Green dots add 5 seconds; red dots, hot plates and falls cost 5 seconds. |
| Wafer sort | Click a pad, press 1–4, or use the numpad. | Score 150 points. |
| Final test | Same console, larger batches. | Score 200 points. |

On the console, a correct answer gives 10 points and restores 10 stability. A mistake costs 25 stability. At 30 or less, the clock runs at 1.5× speed until you get three right **in a row**. That Bounce Back restores stability to 80 and adds ten seconds.

The best time left on each cleared job is saved locally, separately for each factory.

## Editor notes

- `scenes/character_select.tscn` is the title screen. The operator is always CEO GPU. `scenes/how_to_play.tscn` holds the About and Controls sections.
- Change type, colors and focus styles in `ui/shift_theme.tres`. The floor uses `ui/floor_strip.tscn`; the console jobs use `ui/line_hud.tscn`.
- Arrange the track in `scenes/level1_runner.tscn`. Deck widths and station names are editable in the Inspector. The reusable player, time dots, ladder, lift and hot plate are in `scenes/runner/`.
- The runner frames are from the supplied `yo/templerun` folder. The `yo/factory` deck stripe matches the Kenney industrial pack already in `assets/`. Display fonts are by Kenney.

## itch.io

With matching Godot export templates installed, use **Project → Export → Web (itch.io)**. Export to an empty folder as `index.html`, zip the contents with `index.html` at the root, and upload the zip as an HTML game. The preset is single-threaded and packages the playable scenes and their dependencies. The suggested embed size is **960 × 540**.

An ESP32 is optional. On the web, the game calls `window.connectArduino()` and `window.sendToArduino(code)` if the page provides them. The codes are `G` (correct/save), `R` (danger), `B` (boost/recovery) and `X` (failure).
