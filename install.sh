#!/usr/bin/env bash
# Instala o visual Win11 completo no Linux Mint Cinnamon.
# Bloom, Papirus, cursor, tema, pastas, painel, wallpaper e (por padrão) tela de login.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
DOUGLAS_PINS=0
INSTALL_GREETER=1

usage() {
  cat <<'EOF'
Uso: ./install.sh [--douglas-pins] [--no-greeter]

  --douglas-pins  Fixa na barra os mesmos apps da máquina original
                  (Chrome, Steam, Cursor, etc.). Sem esta flag, usa
                  Nemo / Firefox / Chrome / Terminal / Configurações.

  --no-greeter    Não mexe na tela de login.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --douglas-pins) DOUGLAS_PINS=1 ;;
    --no-greeter) INSTALL_GREETER=0 ;;
    --greeter) INSTALL_GREETER=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "opção desconhecida: $arg" >&2; usage; exit 1 ;;
  esac
done

copy_tree() {
  local src="$1" dst="$2"
  mkdir -p "$dst"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a "$src" "$dst"
  else
    cp -a "$src"/. "$dst"
  fi
}

backup_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a "$f" "$f.bak-mint-win11"
  fi
}

need_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    return 0
  fi
  if ! command -v sudo >/dev/null 2>&1; then
    echo "Este instalador precisa de sudo (senha do computador)." >&2
    exit 1
  fi
  echo
  echo "Vai pedir a senha do Linux uma vez."
  echo "É a mesma senha que você usa para instalar programa no Mint."
  echo
  sudo -v
}

apt_install() {
  local pkgs=("$@")
  local missing=()
  local p
  for p in "${pkgs[@]}"; do
    if ! dpkg -s "$p" >/dev/null 2>&1; then
      missing+=("$p")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    echo "    pacotes já instalados: ${pkgs[*]}"
    return 0
  fi
  echo "    instalando: ${missing[*]}"
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
}

install_bloom_from_deb() {
  echo "    tentando baixar o pacote bloom (deepin-icon-theme) direto..."
  local tmp
  tmp="$(mktemp -d)"
  local deb="deepin-icon-theme_2023.11.28-1_all.deb"
  local url1="http://archive.ubuntu.com/ubuntu/pool/universe/d/deepin-icon-theme/${deb}"
  local url2="http://ubuntu-archive.locaweb.com.br/ubuntu/pool/universe/d/deepin-icon-theme/${deb}"
  if command -v wget >/dev/null 2>&1; then
    wget -O "$tmp/$deb" "$url1" || wget -O "$tmp/$deb" "$url2"
  else
    curl -L -o "$tmp/$deb" "$url1" || curl -L -o "$tmp/$deb" "$url2"
  fi
  sudo dpkg -i "$tmp/$deb" || sudo apt-get install -f -y
  rm -rf "$tmp"
}

cat <<'EOF'

========================================
  Visual Windows 11 — Linux Mint
========================================

Isto instala TUDO que o visual precisa:
  • ícones bloom (Deepin) + Papirus
  • cursor Yaru
  • tema das janelas Win11-round-Dark
  • pastas amarelas, lixeira, Explorer
  • painel 60px / ícones 38px
  • menu Iniciar estilo Windows
  • wallpaper
  • tela de login (pode desligar com --no-greeter)

EOF

DESKTOP="${XDG_CURRENT_DESKTOP:-}"
if [[ "$DESKTOP" != *[Cc]innamon* && "$DESKTOP" != *X-Cinnamon* ]]; then
  echo "Aviso: este PC não parece estar no Cinnamon (detectado: '${DESKTOP:-vazio}')."
  echo "O visual foi feito para Linux Mint Cinnamon. Continuando mesmo assim..."
  echo
fi

need_sudo

PKGS=(
  papirus-icon-theme
  yaru-theme-icon
  deepin-icon-theme
  fonts-ubuntu
  rsync
  wget
)
if [[ "$INSTALL_GREETER" -eq 1 ]]; then
  PKGS+=(bibata-cursor-theme)
fi

echo "==> 1/7  programas de ícone (bloom, Papirus, cursor)"
if ! apt_install "${PKGS[@]}"; then
  echo "    apt falhou; tentando o bloom pelo arquivo .deb"
  install_bloom_from_deb
fi

if [[ ! -d /usr/share/icons/bloom ]]; then
  echo "    bloom ainda não apareceu; baixando o .deb"
  install_bloom_from_deb
fi

if [[ ! -d /usr/share/icons/bloom ]]; then
  echo "ERRO: não consegui instalar os ícones bloom." >&2
  echo "Sem internet o instalador não baixa o pacote deepin-icon-theme (~31 MB)." >&2
  echo "Conecte a rede e rode de novo:  ./install.sh" >&2
  exit 1
fi
echo "    bloom OK em /usr/share/icons/bloom"

echo "==> 2/7  tema das janelas"
mkdir -p "$HOME_DIR/.themes"
copy_tree "$ROOT/assets/themes/Win11-round-Dark/" "$HOME_DIR/.themes/Win11-round-Dark/"

echo "==> 3/7  ícones (bloom + pastas Win11 + Explorer)"
mkdir -p "$HOME_DIR/.local/share/icons/custom"
copy_tree "$ROOT/assets/icons/custom/" "$HOME_DIR/.local/share/icons/custom/"
python3 "$ROOT/scripts/apply-icon-overlay.py" \
  "$ROOT/assets/icons" \
  "$HOME_DIR/.local/share/icons/custom" \
  "$ROOT/assets/icons/overlay.tsv"

# ícone do menu Iniciar (Windows) mesmo se o pacote mintstick não existir
mkdir -p "$HOME_DIR/.local/share/icons/hicolor/scalable/apps"
mkdir -p "$HOME_DIR/.local/share/icons/hicolor/scalable/status"
cp -a "$ROOT/assets/icons/menu/mintstick-logo-windows.svg" \
  "$HOME_DIR/.local/share/icons/hicolor/scalable/apps/mintstick-logo-windows.svg"
cp -a "$ROOT/assets/icons/menu/mintstick-logo-windows.svg" \
  "$HOME_DIR/.local/share/icons/hicolor/scalable/status/mintstick-logo-windows.svg"

gtk-update-icon-cache -f "$HOME_DIR/.local/share/icons/bloom" 2>/dev/null || true
gtk-update-icon-cache -f "$HOME_DIR/.local/share/icons/bloom-dark" 2>/dev/null || true
gtk-update-icon-cache -f "$HOME_DIR/.local/share/icons/hicolor" 2>/dev/null || true

echo "==> 4/7  visual do Nemo e botões min/max/fechar"
mkdir -p "$HOME_DIR/.config/gtk-3.0" "$HOME_DIR/.config/gtk-4.0"
backup_file "$HOME_DIR/.config/gtk-3.0/gtk.css"
backup_file "$HOME_DIR/.config/gtk-3.0/settings.ini"
backup_file "$HOME_DIR/.config/gtk-4.0/gtk.css"
backup_file "$HOME_DIR/.config/gtk-4.0/settings.ini"
cp -a "$ROOT/assets/gtk/gtk-3.0/gtk.css" "$HOME_DIR/.config/gtk-3.0/gtk.css"
cp -a "$ROOT/assets/gtk/gtk-3.0/settings.ini" "$HOME_DIR/.config/gtk-3.0/settings.ini"
cp -a "$ROOT/assets/gtk/gtk-4.0/gtk.css" "$HOME_DIR/.config/gtk-4.0/gtk.css"
cp -a "$ROOT/assets/gtk/gtk-4.0/settings.ini" "$HOME_DIR/.config/gtk-4.0/settings.ini"

echo "==> 5/7  wallpaper"
PICTURES="$(xdg-user-dir PICTURES 2>/dev/null || true)"
[[ -n "$PICTURES" ]] || PICTURES="$HOME_DIR/Imagens"
WALL_DIR="$PICTURES/wallpapper"
mkdir -p "$WALL_DIR"
cp -a "$ROOT/assets/wallpaper/windows-11-dark-mode-blue.jpg" \
  "$WALL_DIR/windows-11-dark-mode-blue.jpg"
WALL_URI="file://$WALL_DIR/windows-11-dark-mode-blue.jpg"

echo "==> 6/7  barra, menu, Nemo e Win+L (travar tela)"
while IFS='|' read -r schema key value; do
  [[ -z "${schema:-}" || "$schema" =~ ^# ]] && continue
  gsettings set "$schema" "$key" "$value"
done < "$ROOT/config/gsettings.conf"
gsettings set org.cinnamon.desktop.background picture-uri "$WALL_URI" || true
gsettings set org.cinnamon.desktop.background picture-uri-dark "$WALL_URI" 2>/dev/null || true

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
print("    apps da barra original:", len(pins))
PY
fi

echo "==> 7/7  tela de login"
if [[ "$INSTALL_GREETER" -eq 1 ]]; then
  sudo mkdir -p /usr/share/themes /usr/share/backgrounds
  copy_tree_sudo() {
    sudo mkdir -p "$2"
    if command -v rsync >/dev/null 2>&1; then
      sudo rsync -a "$1" "$2"
    else
      sudo cp -a "$1"/. "$2"
    fi
  }
  copy_tree_sudo "$ROOT/assets/themes/Win11-Greeter/" /usr/share/themes/Win11-Greeter/
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
cursor-theme-name=Yaru
cursor-theme-size=24
EOF
  if [[ -d /usr/share/icons/Bibata-Modern-Classic ]]; then
    sudo sed -i 's/cursor-theme-name=.*/cursor-theme-name=Bibata-Modern-Classic/' /etc/lightdm/slick-greeter.conf
  fi
  echo "    tela de login aplicada"
else
  echo "    pulada (--no-greeter)"
fi

update-desktop-database "$HOME_DIR/.local/share/applications" 2>/dev/null || true

echo
echo "==> recarregando o Cinnamon (equivale a Alt+F2, r, Enter)"
if dbus-send --session --type=method_call --dest=org.Cinnamon /org/Cinnamon \
    org.Cinnamon.Eval string:'global.reexec_self()' >/dev/null 2>&1; then
  echo "    Cinnamon recarregado."
else
  echo "    não deu para recarregar sozinho — use o atalho abaixo."
fi

cat <<'EOF'

========================================
  PRONTO
========================================

O visual já foi aplicado. Se a tela não mudou:

  1. Aperte  Alt + F2
  2. Digite  r
  3. Aperte  Enter

Isso só atualiza o painel. Não apaga arquivo nenhum.

Se um ícone da barra ficar antigo, tire o app da barra e pinne de novo.

Win+L trava a tela (como no Windows).

EOF

if [[ -t 0 ]]; then
  read -r -p "Aperte Enter para fechar... "
fi
