# mint-win11-cinnamon

Visual **Windows 11** no **Linux Mint Cinnamon**. O instalador coloca **tudo**: ícones bloom, Papirus, cursor, tema, pastas, tamanhos do painel, menu, wallpaper e tela de login.

Feito para quem não manja de Linux — pede a senha uma vez e resolve o resto.

## Instalar

### Pelo GitHub (mais fácil)

1. Abra https://github.com/neves-douglas/mint-win11-cinnamon
2. Botão verde **Code** → **Download ZIP**
3. Extraia o ZIP
4. Abra a pasta e dê dois cliques em **Instalar.desktop**
5. Escolha **Executar no terminal**
6. Digite a senha do computador (não mostra asterisco, é normal)
7. Ao terminar: **Alt+F2**, digite `r`, Enter

### Pelo terminal

```bash
git clone https://github.com/neves-douglas/mint-win11-cinnamon.git
cd mint-win11-cinnamon
chmod +x install.sh
./install.sh
```

Na primeira vez precisa de **internet**. O script instala sozinho o pacote `deepin-icon-theme` (ícones **bloom**, ~31 MB) mais Papirus, cursor Yaru e fontes Ubuntu.

## O que o `./install.sh` instala

| Item | Como entra |
| --- | --- |
| Ícones **bloom** (Chrome, Steam, apps Deepin) | `sudo apt install deepin-icon-theme` (se o apt falhar, baixa o .deb) |
| Papirus (base dos ícones) | `papirus-icon-theme` |
| Cursor | `yaru-theme-icon` |
| Fonte Ubuntu 10 | `fonts-ubuntu` (já vem no Mint) |
| Tema das janelas `Win11-round-Dark` | copiado para `~/.themes` |
| Pastas amarelas Win11, lixeira, Explorer | overlay em `~/.local/share/icons` |
| Painel (barra) 60px, ícones 38px, applets iguais | gsettings + config do Cinnamon |
| Menu Iniciar (ícone Windows 38px) | config do Cinnamon + SVG incluso |
| **Win+L** trava a tela (e Ctrl+Alt+L) | atalho do Cinnamon |
| Sidebar do Nemo escura | `~/.config/gtk-3.0/gtk.css` |
| Wallpaper Win11 dark | `~/Imagens/wallpapper/` |
| Tela de login | slick-greeter (use `--no-greeter` se não quiser) |

A **barra** (tamanho, posição, menu, relógio, som, rede) vai igual. **Não** copia a lista de programas fixos (Chrome, Steam, Cursor…). A barra deles nasce com Nemo, Firefox, Chrome, Terminal e Configurações — cada um pinna o que usar.

```bash
./install.sh --douglas-pins   # mesma barra de apps da máquina original
./install.sh --no-greeter     # não mexe na tela de login
```

## Tamanhos

| Peça | Valor |
| --- | --- |
| Altura do painel | 60 px |
| Ícones da lista de janelas (centro) | 38 px |
| Ícones da bandeja (direita) | 22 px |
| Ícone do menu Iniciar | 38 px |
| Fonte | Ubuntu 10 |
| Sidebar do Nemo | 220 px |

## Se algo não mudou

1. Alt+F2 → `r` → Enter (ou saia da sessão)
2. Temas: Aplicativos / Desktop / Janelas = `Win11-round-Dark`, ícones = `bloom`, cursor = `Yaru`
3. Ícone velho na barra: tira o app e pinna de novo

Arquivos GTK antigos ficam como `*.bak-mint-win11`.

## Créditos

[ATTRIBUTIONS.md](ATTRIBUTIONS.md) — vinceliuice (GTK), yeyushengfan258 (pastas), Deepin bloom, Papirus. Wallpaper stock da Microsoft; podem trocar a imagem depois.
