# mint-win11-cinnamon

Visual **Windows 11** no **Linux Mint Cinnamon** (X11): tema escuro arredondado, pastas amarelas Fluent, menu estilo Iniciar, Nemo com sidebar escura e wallpaper stock do Win11.

Extraído da máquina do Douglas (Mint 22.3 / Cinnamon). Colegas: clonem e rodem o instalador.

## O que entra

- Tema GTK/Cinnamon/Metacity `Win11-round-Dark` (botões min/max/fechar no canto direito, fechar vermelho no hover)
- Ícones `bloom` com overlay:
  - pastas amarelas Win11 (incluindo Home e Área de trabalho)
  - lixeira Win11
  - Explorer na barra
  - calculadora / terminal / configurações no estilo mac (os que estavam no desktop original)
  - sidebar do Nemo mais viva (não-simbólica)
- Painel inferior **60px**, ícones centrais **38px**, tray menor à direita
- Menu Iniciar com ícone Windows (`mintstick-logo-windows`), **38px**, sem sidebar/avatar/favoritos
- CSS do Nemo (`#202020` + seleção `#0078D4`)
- Wallpaper Windows 11 dark 3840×2160
- Tela de login opcional (`--greeter`)

Não copia apps pessoais, senhas nem configs do Cursor/Steam.

## Requisitos

Linux Mint **Cinnamon** (testado no 22.x).

```bash
sudo apt install papirus-icon-theme yaru-theme-icon
```

Se o PC tiver `/usr/share/icons/bloom` (ícones Deepin), o Chrome/Steam ficam iguais ao original. Sem bloom, o Papirus cobre o resto.

## Instalação

```bash
git clone https://github.com/neves-douglas/mint-win11-cinnamon.git
cd mint-win11-cinnamon
chmod +x install.sh
./install.sh
```

Depois **Alt+F2** → `r` → Enter (ou logout).

Opções:

```bash
./install.sh --douglas-pins   # mesma lista de apps fixos da barra original
./install.sh --greeter        # tema da tela de login (sudo)
```

Arquivos GTK antigos viram `*.bak-mint-win11`.

## Tamanhos (os que o pessoal comentou)

| Peça | Valor |
| --- | --- |
| Altura do painel | 60 px |
| Ícones da lista de janelas (centro) | 38 px |
| Ícones da bandeja (direita) | 22 px |
| Ícone do menu Iniciar | 38 px |
| Fonte da interface | Ubuntu 10 |
| Sidebar do Nemo | 220 px |

## Depois de instalar, no Cinnamon

1. **Temas** → Aplicativos / Desktop / Janelas = `Win11-round-Dark`
2. **Ícones** = `bloom`
3. **Cursor** = `Yaru` (já aplicado pelo script)

Se o painel ainda mostrar ícone velho, tira o app da barra e pinna de novo.

## Créditos

Ver [ATTRIBUTIONS.md](ATTRIBUTIONS.md). Tema GTK: vinceliuice. Pastas: yeyushengfan258. O wallpaper stock é da Microsoft — podem trocar em `~/Imagens/wallpapper/` (ou `~/Pictures/wallpapper/`).
