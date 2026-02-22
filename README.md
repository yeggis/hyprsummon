# hyprsummon

> 🇹🇷 [Türkçe](README.tr.md)

Summon any app as a scratchpad overlay on Hyprland.
One key to show. Same key to hide. No alt-tab, no workspace switching.

<!-- demo gif here -->

## What it does

Hyprland has [special workspaces](https://wiki.hyprland.org/Configuring/Workspace-Rules/#special-workspace) — hidden overlay workspaces that slide in and out.
Chromium can [install any site as an app](https://support.google.com/chrome/answer/9658361) — a standalone window with no browser UI.

**hyprsummon** ties these together. It auto-detects your installed PWAs and gives you one-key toggle access to each:

```
Super+Y    → YouTube slides in
Super+Y    → YouTube disappears
Super+B    → Binance slides in
Super+Esc  → Whatever's open, dismiss it
```

Works with Chromium, Brave, Edge, and any Chromium-based browser. Also works with non-PWA apps — Steam, Spotify, terminals, anything with a window.

## Install

**Arch Linux (AUR):**
```bash
paru -S hyprsummon-git
# or: yay -S hyprsummon-git
```

**Manual:**
```bash
git clone https://github.com/yeggis/hyprsummon.git
cd hyprsummon
sudo make install
```

Or just copy it:
```bash
cp hyprsummon ~/.local/bin/
chmod +x ~/.local/bin/hyprsummon
```

**Dependencies:** Hyprland (≥ 0.40), jq, bash (≥ 4.0)

```bash
# Arch
sudo pacman -S jq

# Fedora
sudo dnf install jq

# Ubuntu/Debian
sudo apt install jq
```

## Two ways to use it

### Wizard mode — `pick`

The easiest way. Open the app you want, then:

```bash
hyprsummon pick
```

It gives you a 3-second countdown to focus the target window, then walks you through naming it, enabling auto-launch, assigning a keybind, and applying — all in one go.

```
$ hyprsummon pick
Focus the window you want to add.
  Capturing in 3... 2... 1...
  Caught: Spotify — Liked Songs

Name [spotify]:
Auto-launch when not running? [y/N]: y
>>> 'spotify' added.
Keybind (e.g. Super, Z): Super, M
>>> spotify → Super, M

Apply now? [Y/n]:
>>> Rules → ~/.config/hypr/hyprsummon/rules.conf
>>> Binds → ~/.config/hypr/hyprsummon/binds.conf
>>> Hyprland reloaded ✓
```

Done. Press `Super+M` — Spotify launches and slides in. Press again — it disappears.

**Smart features:**
- If the window is already registered, it detects the existing entry and suggests the current name
- If you rename an existing entry, the old one is automatically removed (no duplicates)
- Launch command is auto-detected from `.desktop` files — you don't need to know it

### Command mode

For bulk setup or scripting. Good for Chromium PWAs since `scan` finds them all at once:

```bash
hyprsummon scan                        # auto-detects all installed PWAs
hyprsummon bind youtube Super, Y       # assign keybinds
hyprsummon bind chatgpt Super+Shift, 1
hyprsummon apply                       # writes configs, reloads Hyprland
```

`apply` does three things automatically:
1. Writes windowrules to `~/.config/hypr/hyprsummon/rules.conf`
2. Writes keybinds to `~/.config/hypr/hyprsummon/binds.conf`
3. Adds `source` lines to `hyprland.conf` (first run only) and reloads

Works regardless of your Hyprland config file structure.

## Auto-launch

By default, keybinds only toggle the special workspace. If the app isn't running, the workspace opens empty and you launch the app manually from your launcher.

With **auto-launch** enabled, the keybind also starts the app if it's not running — just like a dropdown terminal. A lock mechanism prevents duplicate windows from fast key presses.

**Enable via wizard:**
```bash
hyprsummon pick
# answer 'y' to "Auto-launch when not running?"
```

**Enable via command:**
```bash
hyprsummon add spotify Spotify yes 5
#                      │       │   └── max wait: 5 seconds
#                      │       └────── autolaunch: yes
#                      └────────────── window class
```

## Adding non-PWA apps

Two ways:

**With the wizard** — just open the app and `hyprsummon pick`. It detects the window class and launch command automatically.

**Manually** — you only need the name and window class:

```bash
hyprsummon add zen zen yes 15
hyprsummon add steam steam yes 5
hyprsummon bind zen Super, F
hyprsummon bind steam Super+Shift, G
hyprsummon apply
```

The launch command is auto-detected from `.desktop` files. If you need a custom command (rare), pass it as the last parameter:

```bash
hyprsummon add zen zen yes 15 "zen-browser --private-window"
```

Format: `hyprsummon add <name> <class> [autolaunch] [wait] [launch_cmd]`

> **Finding the window class:** Open the app and run `hyprctl activewindow -j | jq -r '.class'`
> Or just use `hyprsummon pick` — it does this for you.

## Commands

| Command | What it does |
|---|---|
| `hyprsummon <app>` | Toggle an app (show/hide) |
| `hyprsummon dismiss` | Dismiss whatever special workspace is open |
| `hyprsummon pick` | Interactive wizard — focus, name, bind, apply |
| `hyprsummon scan` | Auto-detect all Chromium PWAs |
| `hyprsummon list` | List registered apps, keybinds, and autolaunch status |
| `hyprsummon status` | Show running/stopped state |
| `hyprsummon bind <app> <key>` | Assign a keybind (no quotes needed) |
| `hyprsummon apply` | Write Hyprland configs + reload |
| `hyprsummon add <n> <class> [autolaunch] [wait] [cmd]` | Register an app manually |
| `hyprsummon remove <name>` | Unregister an app |

## The dismiss key

`hyprsummon dismiss` closes whatever special workspace is currently visible. By default, `apply` binds it to `Super+Escape`.

To change it:

```bash
echo 'dismiss_key=Super+Shift, Escape' > ~/.config/hyprsummon/settings.conf
hyprsummon apply
```

## hyprscrolling support

If you use the [hyprscrolling](https://hypr.land/Plugins/hyprscrolling) plugin (`general:layout = scrolling`), hyprsummon detects it automatically and adapts its behavior:

| Scenario | Standard layout | scrolling layout |
|---|---|---|
| App already in special ws | `togglespecialworkspace` | `togglespecialworkspace` |
| **App running on regular ws** | `movetoworkspacesilent` | **`movecoltoworkspace` + `fit active`** |
| App not running | `togglespecialworkspace` | `togglespecialworkspace` |

When `scrolling` is active, "kidnapping" a window into a scratchpad uses `movecoltoworkspace` to preserve column integrity and automatically fits it to screen width. All other scenarios remain identical.

No configuration needed — it works transparently on both `scrolling` and `dwindle`/`master` layouts.

## How it works

When you run `hyprsummon youtube`:

```
┌─────────────────────────────┐
│  Is window in special ws?   │
└──────────┬──────────────────┘
       yes │           no
           │    ┌──────────────────┐
  toggle   │    │  Is it running   │
  (hide/   │    │  somewhere?      │
   show)   │    └──────┬───────────┘
           │       yes │        no
           │           │    ┌──────────────┐
           │   move to │    │ autolaunch?  │
           │   special │    └──┬───────────┘
           │   + show  │   yes │       no
           │           │       │
           │           │  launch +   toggle
           │           │  wait for   empty
           │           │  window     workspace
```

- **Atomic locking** — `mkdir` based lock prevents double-toggle from fast key mashing
- **Single query** — window state checked once via `hyprctl clients -j`, not per-app
- **Launch guard** — separate lock prevents spawning duplicates during slow startup
- **Duplicate protection** — keybind conflicts are auto-resolved, same-class entries are detected

## Config files

**App registry** — `~/.config/hyprsummon/apps.conf`:
```
youtube|chrome-agimnkijcaahngcdmfeangaknmldooml-Default|gtk-launch youtube.desktop|1|Super, Y|yes
steam|steam|steam -silent|5|Super+Shift, G|no
```

Format: `name|class|launch_cmd|wait|keybind|autolaunch`

The class names contain Chromium's internal app-id, unique per browser installation. That's why `scan` exists — it reads your `.desktop` files to find the correct IDs for your system.

**Settings** — `~/.config/hyprsummon/settings.conf` (optional):
```
dismiss_key=Super, Escape
```

**Generated Hyprland configs** — `~/.config/hypr/hyprsummon/`:
```
rules.conf    # windowrules pinning apps to special workspaces
binds.conf    # keybinds calling hyprsummon
```

## FAQ

**Why not browser tabs?**
PWAs have no address bar, no tabs, no browser chrome. Combined with special workspaces they become instant-access overlays — like a dropdown terminal, but for anything.

**Window class changed after reinstalling the browser.**
Run `hyprsummon scan` again. The app-id changes on reinstall.

**Can I customize the slide-in animation?**
Yes, in your Hyprland config:
```ini
animation = specialWorkspace, 1, 3, default, slidevert
```

**Firefox support?**
Firefox doesn't do PWAs natively. Use `hyprsummon pick` or `hyprsummon add` with the correct window class.

**Can I use autolaunch without pick?**
Yes: `hyprsummon add <name> <class> yes`. The launch command is auto-detected.

## License

MIT
