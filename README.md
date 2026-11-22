# 4 Nano Metre

A retro cyberpunk cleanroom game where you play as CEO GPU, the last operator left on night shift at a semiconductor plant. A bomb has been planted right under the wafer line. Get through 14 factory bays, breach the central airlock, and hack the host terminal before the timer runs out.

[Play online on itch.io](https://tanmaylarper.itch.io/4-nanometre)

---

## The mission

The game is split into two phases:

### Phase 1: core run (platformer)
Make your way across 14 cleanroom bays to reach the reactor core before the clock hits zero.
- Green resistors (+5s): adds extra time to your fuse.
- Red hazards and hot plates (-penalty): cuts your timer and sends you back to the last bay checkpoint.
- Wet bench pneumatic lift: step onto the green lift over the chemical trench and keep holding right to clear the broken bridge.
- Etch and scrubber ladders: jump onto ladders and hold Right or Up to climb past machinery.

### Phase 2: host breach (terminal hack)
Once you reach Bay 14, the core console is locked down. You have to override the mainframe using an IP decryption terminal:
- An 8 x 10 live number matrix continuously shifts with 2-digit hex octets.
- Find the target 4-part IP address (like `51.88.66.00`) horizontally in the grid.
- Watch out for decoys that share the first 1 or 2 octets.
- Match 3 target IPs before running out of lives or time to trigger the override.

---

## Factory shifts

Pick your shift from the home screen:

| Shift | Location | Fuse time | Hit penalty | Terminal lives | Stability |
| :--- | :--- | :---: | :---: | :---: | :---: |
| Shift 01 | Silicon Valley (standard) | `04:45` | -6 seconds | 3 lives | 70% |
| Shift 02 | Shenzhen (hard) | `03:45` | -8 seconds | 2 lives | 60% |

Your best remaining time on cleared runs is saved locally for each factory.

---

## Controls

### Level 1: core run
| Action | Keyboard | Gamepad | Touch |
| :--- | :--- | :--- | :--- |
| Move | `A` / `D` or Arrow keys | Left stick / D-pad | On-screen D-pad |
| Jump | `Space` or `Up` | Bottom face button (`A` / `X`) | On-screen jump button |
| Climb | Hold `W` or `Right` at ladder | Push Up / Right | On-screen Up / Right |
| Pause | `P` or `Esc` | Menu / Start | On-screen pause |

### Level 2: host breach
| Action | Input |
| :--- | :--- |
| Navigate grid | `W` `A` `S` `D` / Arrow keys / Mouse hover |
| Select / inject | `Space` / `Enter` / Left click |

You can rebind your jump key anytime from the in-game pause menu.

---

## Running the project

### Playing the web build locally
The repo includes a local server script with the `COOP`/`COEP` headers needed for WebAssembly and Web Audio:
```bash
python serve_web.py
