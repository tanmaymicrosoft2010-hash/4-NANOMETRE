# 4 Nano Metre

A sabotage bomb is ticking right under the wafer line at 4 Nano Metre. You play as CEO GPU, the last operator left on shift, with the reactor core 14 bays away. Jump over hot plates, climb ladders, ride lifts, and stabilize the factory before the fuse runs out.

---

## Play on itch.io

 itch.io- https://tanmaylarper.itch.io/4-nanometre

Playable directly in the browser (recommended at 960 x 540) with full keyboard, gamepad, and mobile touch support.

---

## Two factories, two shifts

Choose between Silicon Valley and Shenzhen right from the home screen. Each site has its own fuse limit, hit penalties, and factory hazards:

| Factory | Core run fuse | Hit penalty | Console stability | Site hazard |
| :--- | :--- | :--- | :--- | :--- |
| Silicon Valley | 4:45 | -6 sec | Starts at 70 (-25 per mistake) | Investor emails every 12s |
| Shenzhen | 3:45 | -8 sec | Starts at 60 (-30 per mistake) | Power dims every 10s |

---

## Gameplay

### Core run (level 1)
Race across 14 bays to reach the core—climb the Etch ladder, take the Wet Bench lift to Wafer Transfer, push past the bake ovens, and ride the cooling-loop lift into Bay 14.
* First step starts the fuse.
* Green coins add +5 seconds to the timer.
* Red coins, hot plates, and falls trigger the site's hit penalty and send you back to the last bay.

### Fab console jobs (wafer sort & final test)
Level 2 is currently marked under progress after level 1, and can be playtested directly in Godot via `scenes/level_select.tscn` -> `F6`.
* Clear rapid-fire console checks to hit 150 points (Wafer Sort) or 200 points (Final Test).
* Each correct answer gives +10 points and restores +10 stability.
* Bounce Back recovery: if stability drops to 30 or below, the bomb clock speeds up to 1.5x. Land 3 correct answers in a row in the danger zone to trigger a Bounce Back—restoring stability (80 in Silicon Valley, 70 in Shenzhen) and adding +10 seconds back to the clock.

Best clear times and sound settings are saved locally for each factory.

---

## Controls

* Move: `A` / `D`, arrow keys, left stick, or D-pad
* Jump: `Space`, `Up`, or bottom face button (rebindable from the pause menu)
* Climb ladders: hold `Right` or `W`
* Console pads: mouse click, `1–4`, or numpad
* Pause: `P`, `Esc`, controller menu button, or on-screen pause button (auto-pauses on tab switch in web builds)
* Touch: multi-touch supported (move and jump independently)

---

## Hardware support (ESP32)

The web build includes optional WebSerial support for an external ESP32 LED indicator. When `window.connectArduino()` and `window.sendToArduino(code)` are available on the host page, the game streams live factory states:
* `G` — correct / saved
* `R` — danger zone
* `B` — bounce back / boost
* `X` — failure

The game runs normally without any hardware connected.

---

## Running locally

1. Clone or download this repository.
2. Open `project.godot` in Godot 4.6 (Compatibility renderer).
3. Press `F5` to launch from the home screen (or open `scenes/level_select.tscn` and press `F6` to test the console jobs directly).

---

## Team

* Tanmay Kumar
* Samarth Aggrawal
* Kavya

---

## Credits & assets

* 2D art, industrial tiles, ladders & fonts: [Kenney.nl](https://kenney.nl/)
* Music & sound effects: [MyInstants.com](https://www.myinstants.com/)
* Dispatch controls: [factory_ v1.0](https://kevins-moms-house.itch.io/factory) by analogStudios / Kevin's Mom's House (CC0)
