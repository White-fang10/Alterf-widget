# Alterf Widget

**A glass-tile desktop dashboard for Conky on Linux.**

Alterf Widget transforms your desktop into a clean, modern dashboard with rounded glass-style tiles, system monitoring rings, live weather information, network statistics, and music playback details.

Built on [Conky](https://github.com/brndnmtthws/conky) and inspired by the original Alterf theme, this version reimagines the layout with a custom Cairo/Lua-drawn interface.

> Designed for Linux users who want a desktop that looks as good as it performs.

## Features

- **Personalized greeting** — A welcoming desktop header with a customizable avatar.
- **Date and time** — Keep essential date information within easy reach.
- **Live weather** — Display weather information for your configured location.
- **Wi-Fi status** — Monitor your wireless connection.
- **CPU and RAM monitoring** — Visualize system resource usage with circular indicators.
- **Storage information** — Keep track of available disk space.
- **Network speed** — View network activity at a glance.
- **Now playing** — Display currently playing music using Playerctl.
- **Glass-style interface** — Rounded tiles, adjustable transparency, and a cohesive dashboard layout.
- **Customizable appearance** — Personalize positioning, colors, opacity, fonts, and avatar assets.

## Preview

Add a screenshot of your configured desktop here to showcase the widget.

```markdown
![Alterf Widget Preview](res/preview.png)
```

Place your screenshot at `res/preview.png`, or replace the path with the location of your own screenshot.

## Requirements

Alterf Widget is designed for Linux distributions that support Conky, including Linux Mint and Ubuntu.

### Dependencies

- Conky with Lua and Cairo support
- `jq` — JSON processing
- `curl` — Weather and web requests
- `playerctl` — Media playback information
- `git` — Repository management

Install the required packages:

```bash
sudo apt update
sudo apt install conky-all jq curl playerctl git
```

**Important:** Use `conky-all` rather than the minimal `conky` package. The widget relies on graphical drawing capabilities provided by a suitably built Conky installation.

## Installation

### 1. Clone the repository

```bash
mkdir -p ~/.config/conky

git clone https://github.com/White-fang10/Alterf-widget.git \
  ~/.config/conky/Alterf
```

### 2. Install the bundled fonts

```bash
mkdir -p ~/.local/share/fonts/Alterf

cp -r ~/.config/conky/Alterf/fonts/* \
  ~/.local/share/fonts/Alterf/

fc-cache -f
```

### 3. Launch the widget

```bash
conky -c ~/.config/conky/Alterf/Alterf.conf
```

To restart Conky cleanly:

```bash
killall conky 2>/dev/null
conky -c ~/.config/conky/Alterf/Alterf.conf
```

**Tip:** Run Conky from a terminal while troubleshooting so you can see error messages.

## Customization

Make Alterf Widget your own by adjusting the assets and configuration files.

| Element | File or setting | What to change |
|---|---|---|
| Avatar | `res/ava.png` | Replace with your own square PNG image. |
| Weather location | `scripts/weather-v2.0.sh` | Configure your city and any required API credentials. |
| Widget position | `Alterf.conf` | Adjust `gap_x` and `gap_y` near the top of the configuration. |
| Tile colors | `scripts/card.lua` | Modify the color palette to match your desktop theme. |
| Tile transparency | `scripts/card.lua` | Adjust `TILE_ALPHA` to control opacity. |
| Fonts | `fonts/` | Customize the bundled font files, where supported. |

After making changes, restart the widget to apply them:

```bash
killall conky 2>/dev/null
conky -c ~/.config/conky/Alterf/Alterf.conf
```

## Start Automatically at Login

To launch Alterf Widget whenever you log in, create a desktop autostart entry:

```bash
mkdir -p ~/.config/autostart

cat > ~/.config/autostart/conky-alterf.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Alterf Widget
Comment=Launch the Alterf desktop dashboard
Exec=sh -c "sleep 10 && conky -c $HOME/.config/conky/Alterf/Alterf.conf"
X-GNOME-Autostart-enabled=true
EOF
```

The short delay allows your desktop session to initialize before Conky starts.

If you use Conky Manager or another startup utility, disable its separate launcher for this widget to prevent duplicate instances.

## Updating

If you installed Alterf Widget by cloning the Git repository, update it with:

```bash
cd ~/.config/conky/Alterf

git pull
```

If you have local modifications that conflict with upstream changes, back them up before updating. For example:

```bash
git status
git diff
```

Commit or back up important changes before pulling new versions.

## Troubleshooting

| Problem | Possible solution |
|---|---|
| Tiles do not appear | Run Conky from a terminal and inspect the errors. Verify that your installation supports the required Lua and Cairo features. |
| Only text appears | Check the Conky build and the configuration's drawing dependencies. |
| Weather is missing or incorrect | Check the location and API configuration in `scripts/weather-v2.0.sh`. Confirm that `curl` and `jq` are installed. |
| Music information is missing | Install `playerctl` and check whether your media player exposes playback information. |
| The widget does not start at login | Verify the autostart file and the path to `Alterf.conf`. |
| Multiple widgets appear | Check for duplicate Conky processes and disable competing startup entries. |
| Changes do not appear | Restart Conky after editing configuration files. |

To inspect running Conky processes:

```bash
ps aux | grep '[c]onky'
```

To restart the widget:

```bash
killall conky 2>/dev/null
conky -c ~/.config/conky/Alterf/Alterf.conf
```

## Project Structure

The repository includes the main Conky configuration, Lua-based drawing logic, supporting scripts, and visual assets.

```text
Alterf/
├── Alterf.conf
├── fonts/
├── res/
│   └── ava.png
└── scripts/
    ├── card.lua
    └── weather-v2.0.sh
```

*This is a simplified overview. Additional files may be present in the repository.*

## Contributing

Ideas, bug reports, and improvements are welcome.

1. Fork the repository.
2. Create a branch for your changes.
3. Make and test your improvements.
4. Submit a pull request with a clear description of the changes.

When reporting an issue, include your Linux distribution, Conky version, relevant terminal output, and a screenshot when applicable.

## License

See the [`LICENSE`](LICENSE) file for the applicable license and attribution requirements of the original theme and this project.

## Acknowledgements

- [Conky](https://github.com/brndnmtthws/conky) — The lightweight system monitor powering the widget.
- The original **Alterf Conky theme** — The inspiration for this customized desktop dashboard.

---

**Alterf Widget** — System information, beautifully arranged.
