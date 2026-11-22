# 4 Nano Metre

You’re CEO GPU, the last operator on shift in a sabotaged chip factory. A bomb is ticking under the wafer line. First, cross fourteen bays to reach the core. Then trade the jump button for a four-cell cursor: somewhere on a flickering terminal is the address you need.

**[Download the current two-level build (repository ZIP)](https://github.com/tanmaymicrosoft2010-hash/4-NANOMETRE/archive/refs/heads/main.zip)** · [Play the earlier browser preview on itch.io](https://tanmaylarper.itch.io/4-nanometre)

## Play the judging build

The ZIP includes the exported game. You’ll need **Python 3 and a desktop browser with WebGL 2**.

1. Extract the ZIP and open a terminal in the folder containing [`serve_web.py`](serve_web.py).
2. Run `python3 serve_web.py` (Windows: `python serve_web.py`). Open the address printed after `SERVING_ON:`, usually `http://127.0.0.1:8080/`.
3. Choose **Silicon Valley** for a first run. Your first move starts the fuse. When you reach the core, select **Start Level 2: Host Breach** on the results screen.

**Judging with Godot?** Open [`project.godot`](project.godot) in Godot 4.6 and press `F5` for the full game. To try the puzzle immediately, open [`scenes/gameplay.tscn`](scenes/gameplay.tscn) and press `F6`.

## What to look for

**Level 1 · Core Run.** A green resistor above a hot plate can buy back five seconds. Miss the landing in Shenzhen and you lose eight. That makes each pickup a decision. Falls and hot plates return you to your last bay; red pickups cost time. At the broken bridge by the Wet Bench, step onto the green lift and **keep holding right** to reach the far side.

**Level 2 · Host Breach.** Read the address above the 8×10 grid. If it says `07.42.18.63`, look for `07 42 18 63` side by side in one row. A decoy can start with the same two numbers. Check all four before you commit: a wrong match costs a life and sends the clock into a faster red zone. Match three addresses to win.

| Factory | Starting fuse | Time lost per hit | Host Breach lives |
| --- | ---: | ---: | ---: |
| Silicon Valley · Standard | 4:45 | 6 seconds | 3 |
| Shenzhen · Hard | 3:45 | 8 seconds | 2 |

Each level starts with its factory’s fuse. Your best **time remaining** is saved locally for each factory and level.

## Controls

- **Core Run:** `A` / `D` or `←` / `→` to move; `Space` or `↑` to jump. Hold `→` or `W` at a ladder to climb. The floor also supports a gamepad and on-screen touch controls.
- **Host Breach:** Move the selector with `WASD`, the arrow keys, or the mouse. Submit with `Space`, `Enter`, or a left click.
- **Pause:** `P`, `Esc`, or the on-screen pause button. You can rebind the keyboard jump from the pause menu.

<details>
<summary><strong>Technical notes for reviewers</strong></summary>

- The [movement controller](scripts/runner_motor.gd) remembers a jump pressed up to 120 ms before landing and allows a jump up to 100 ms after stepping off a ledge.
- The [puzzle generator](scripts/gameplay.gd) places a complete target in every grid before adding decoys. Background cells can change while you search; the target stays readable.
- The [web export check](tests/web_export_smoke.gd) exercises both factory routes from the packaged game. The [puzzle tests](tests/gta_hacking_test.gd) check target placement, selector bounds, and the results of correct and incorrect choices.
- A compatible web host can connect an optional ESP32 status light to [game events](scripts/game_state.gd).

</details>

## Team and credits

**Tanmay Kumar · Samarth Aggrawal · Kavya**

Built with Godot 4.6 and GDScript. Project code: [MIT License](LICENSE). As disclosed on itch.io, AI assistance was used for code.

Industrial tiles and fonts: [Kenney](https://kenney.nl/) · Dispatch controls: [factory_](https://kevins-moms-house.itch.io/factory) by analogStudios / Kevin’s Mom’s House (CC0) · Music and sound clips sourced via [Myinstants](https://www.myinstants.com/).
