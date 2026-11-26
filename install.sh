#!/usr/bin/env bash
# Aplica o visual Win11-like no Linux Mint Cinnamon (tema, ícones, painel, Nemo, wallpaper).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
DOUGLAS_PINS=0
INSTALL_GREETER=0

usage() {
  cat <<'EOF'
Uso: ./install.sh [--douglas-pins] [--greeter]

  --douglas-pins  Fixa na barra os mesmos apps da máquina original
                  (Chrome, Steam, Cursor, etc.). Sem esta flag, usa
                  Nemo / Firefox / Chrome / Terminal / Configurações.

  --greeter       Também aplica o tema da tela de login (pede sudo).
EOF
}

for arg in "$@"; do
  case "$arg" in
    --douglas-pins) DOUGLAS_PINS=1 ;;
    --greeter) INSTALL_GREETER=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "opção desconhecida: $arg" >&2; usage; exit 1 ;;
  esac
done

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "precisa do comando: $1" >&2
    exit 1
  }
}

need_cmd gsettings
need_cmd python3
need_cmd rsync

backup_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a "$f" "$f.bak-mint-win11"
  fi
}

echo "==> tema GTK/Cinnamon"
mkdir -p "$HOME_DIR/.themes"
rsync -a "$ROOT/assets/themes/Win11-round-Dark/" "$HOME_DIR/.themes/Win11-round-Dark/"

echo "==> ícones (pastas Win11 + overlay bloom)"
mkdir -p "$HOME_DIR/.local/share/icons/custom"
rsync -a "$ROOT/assets/icons/custom/" "$HOME_DIR/.local/share/icons/custom/"
python3 "$ROOT/scripts/apply-icon-overlay.py" \
  "$ROOT/assets/icons" \
  "$HOME_DIR/.local/share/icons/custom" \
  "$ROOT/assets/icons/overlay.tsv"
if [[ ! -d /usr/share/icons/bloom ]]; then
  echo "    aviso: /usr/share/icons/bloom não está neste PC."
  echo "    o fallback Papirus entra no lugar; Chrome/Steam Deepin só aparecem se o bloom do sistema existir."
fi
gtk-update-icon-cache -f "$HOME_DIR/.local/share/icons/bloom" 2>/dev/null || true
gtk-update-icon-cache -f "$HOME_DIR/.local/share/icons/bloom-dark" 2>/dev/null || true

echo "==> CSS GTK (Nemo sidebar + botões min/max/fechar)"
mkdir -p "$HOME_DIR/.config/gtk-3.0" "$HOME_DIR/.config/gtk-4.0"
backup_file "$HOME_DIR/.config/gtk-3.0/gtk.css"
backup_file "$HOME_DIR/.config/gtk-3.0/settings.ini"
backup_file "$HOME_DIR/.config/gtk-4.0/gtk.css"
backup_file "$HOME_DIR/.config/gtk-4.0/settings.ini"
cp -a "$ROOT/assets/gtk/gtk-3.0/gtk.css" "$HOME_DIR/.config/gtk-3.0/gtk.css"
cp -a "$ROOT/assets/gtk/gtk-3.0/settings.ini" "$HOME_DIR/.config/gtk-3.0/settings.ini"
cp -a "$ROOT/assets/gtk/gtk-4.0/gtk.css" "$HOME_DIR/.config/gtk-4.0/gtk.css"
cp -a "$ROOT/assets/gtk/gtk-4.0/settings.ini" "$HOME_DIR/.config/gtk-4.0/settings.ini"

echo "==> wallpaper"
PICTURES="$(xdg-user-dir PICTURES 2>/dev/null || true)"
[[ -n "$PICTURES" ]] || PICTURES="$HOME_DIR/Imagens"
WALL_DIR="$PICTURES/wallpapper"
mkdir -p "$WALL_DIR"
cp -a "$ROOT/assets/wallpaper/windows-11-dark-mode-blue.jpg" \
  "$WALL_DIR/windows-11-dark-mode-blue.jpg"
WALL_URI="file://$WALL_DIR/windows-11-dark-mode-blue.jpg"

echo "==> gsettings (tema, painel 60px, ícones 38px, Nemo)"
while IFS='|' read -r schema key value; do
  [[ -z "${schema:-}" || "$schema" =~ ^# ]] && continue
  gsettings set "$schema" "$key" "$value"
done < "$ROOT/config/gsettings.conf"
gsettings set org.cinnamon.desktop.background picture-uri "$WALL_URI" || true
gsettings set org.cinnamon.desktop.background picture-uri-dark "$WALL_URI" 2>/dev/null || true

echo "==> menu e lista de janelas do Cinnamon"
SPICE_DST="$HOME_DIR/.config/cinnamon/spices"
mkdir -p "$SPICE_DST/menu@cinnamon.org" "$SPICE_DST/grouped-window-list@cinnamon.org"
cp -a "$ROOT/assets/cinnamon/spices/menu@cinnamon.org/0.json" \
  "$SPICE_DST/menu@cinnamon.org/0.json"
cp -a "$ROOT/assets/cinnamon/spices/grouped-window-list@cinnamon.org/2.json" \
  "$SPICE_DST/grouped-window-list@cinnamon.org/2.json"

if [[ "$DOUGLAS_PINS" -eq 1 ]]; then
  python3 - <<PY
import json
from pathlib import Path
pins = [l.strip() for l in Path("$ROOT/extras/douglas-pinned-apps.txt").read_text().splitlines()
        if l.strip() and not l.startswith("#")]
p = Path("$SPICE_DST/grouped-window-list@cinnamon.org/2.json")
data = json.loads(p.read_text())
data["pinned-apps"]["value"] = pins
p.write_text(json.dumps(data, indent=4, ensure_ascii=False) + "\n")
print("    pins da máquina original aplicados:", len(pins))
PY
fi

if [[ "$INSTALL_GREETER" -eq 1 ]]; then
  echo "==> tela de login (sudo)"
  sudo mkdir -p /usr/share/themes /usr/share/backgrounds
  sudo rsync -a "$ROOT/assets/themes/Win11-Greeter/" /usr/share/themes/Win11-Greeter/
  sudo cp -a "$ROOT/assets/greeter/win11-login.jpg" /usr/share/backgrounds/win11-login.jpg
  if [[ -f /etc/lightdm/slick-greeter.conf ]]; then
    sudo cp -a /etc/lightdm/slick-greeter.conf /etc/lightdm/slick-greeter.conf.bak-mint-win11
  fi
  sudo tee /etc/lightdm/slick-greeter.conf >/dev/null <<'EOF'
[Greeter]
background=/usr/share/backgrounds/win11-login.jpg
background-color=#000000
draw-user-backgrounds=false
theme-name=Win11-Greeter
icon-theme-name=Papirus-Dark
cursor-theme-name=Bibata-Modern-Classic
cursor-theme-size=24
EOF
fi

update-desktop-database "$HOME_DIR/.local/share/applications" 2>/dev/null || true

cat <<'EOF'

Pronto. Para o Cinnamon recarregar o painel/ícones:

  1. Alt+F2, digite r, Enter
     ou saia da sessão e entre de novo.

Papirus precisa estar instalado (sudo apt install papirus-icon-theme).
Cursor Yaru vem do pacote yaru-theme-icon.

EOF
