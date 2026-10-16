# Alterf Widget

A tile-style [Conky](https://github.com/brndnmtthws/conky) desktop widget for Linux Mint / Ubuntu. Each element sits in its own rounded glass tile: greeting, date, weather, Wi-Fi, RAM and CPU rings, storage, network speed and now-playing.

Based on the Alterf conky theme, reworked with a cairo/Lua-drawn tile layout.

## Install

```bash
sudo apt update
sudo apt install conky-all jq curl playerctl git

mkdir -p ~/.config/conky
git clone https://github.com/White-fang10/Alterf-widget.git ~/.config/conky/Alterf

# fonts
mkdir -p ~/.fonts
cp -r ~/.config/conky/Alterf/fonts/* ~/.fonts/
fc-cache -f

# run
killall conky
conky -c ~/.config/conky/Alterf/Alterf.conf
```

> Use `conky-all`, not `conky`. The plain package often lacks Lua and cairo support.

## Customize

- **Avatar:** replace `res/ava.png` with your own square PNG.
- **Weather city:** edit `scripts/weather-v2.0.sh` and set your city (add your own API key if the script asks for one).
- **Position:** change `gap_x` and `gap_y` at the top of `Alterf.conf`.
- **Colors / opacity:** edit the palette and `TILE_ALPHA` at the top of `scripts/card.lua`.

## Autostart at login

```bash
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/conky-alterf.desktop << 'EOT'
[Desktop Entry]
Type=Application
Name=Conky Alterf
Exec=sh -c "sleep 10 && conky -c $HOME/.config/conky/Alterf/Alterf.conf"
X-GNOME-Autostart-enabled=true
EOT
```

If you use Conky Manager, disable its own startup so two launchers don't conflict.

## Update

```bash
cd ~/.config/conky/Alterf && git stash && git pull && git stash pop
```

## Troubleshooting

| Problem | Fix |
| --- | --- |
| No tiles, plain text only | Run conky in a terminal and read the error. Usually `conky-all` is missing. |
| No weather / wrong city | Edit `scripts/weather-v2.0.sh`; make sure `jq` and `curl` are installed. |
| No song shown | Install `playerctl`; not every player reports its title. |
| Old widget keeps coming back | Another launcher (e.g. Conky Manager) starts an old copy. Check with `ps aux \| grep [c]onky`. |

See `LICENSE` for the original theme's license.
