#!/usr/bin/env python3
"""Rebuild ~/.local/share/icons/bloom and bloom-dark with Win11 overlays."""
from __future__ import annotations

import os
import shutil
import sys
from pathlib import Path

HOME = Path.home()
ICONS = HOME / ".local/share/icons"
USR_BLOOM = Path("/usr/share/icons")
APP_SIZES = ("16", "24", "32", "48", "64", "96", "128", "256", "512")
PLACE_SIZES = ("16", "22", "24", "32", "48", "64", "96", "128", "256", "512")


def link_tree(src: Path, dst: Path) -> None:
    if not src.is_dir():
        return
    dst.mkdir(parents=True, exist_ok=True)
    for item in src.iterdir():
        target = dst / item.name
        if item.is_dir() and not item.is_symlink():
            link_tree(item, target)
            continue
        if target.exists() or target.is_symlink():
            target.unlink()
        os.symlink(item, target)


def seed_from_system(theme: str) -> None:
    dst = ICONS / theme
    src = USR_BLOOM / theme
    if not src.is_dir():
        return
    for size in APP_SIZES:
        link_tree(src / "apps" / size, dst / "apps" / size)
    for size in PLACE_SIZES:
        link_tree(src / "places" / size, dst / "places" / size)


def apply_tsv(tsv: Path, custom: Path) -> None:
    for line in tsv.read_text().splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        theme, rel, crel = line.split("\t")
        dest = ICONS / theme / rel
        src = custom / crel
        if not src.exists():
            print(f"aviso: falta {src}", file=sys.stderr)
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        if dest.exists() or dest.is_symlink():
            dest.unlink()
        os.symlink(src, dest)


def main() -> int:
    if len(sys.argv) != 4:
        print("uso: apply-icon-overlay.py INDEX_DIR CUSTOM_DIR OVERLAY.tsv", file=sys.stderr)
        return 2
    index_dir = Path(sys.argv[1])
    custom = Path(sys.argv[2])
    tsv = Path(sys.argv[3])

    for theme, index_name in (("bloom", "bloom.index.theme"), ("bloom-dark", "bloom-dark.index.theme")):
        dest = ICONS / theme
        dest.mkdir(parents=True, exist_ok=True)
        shutil.copy2(index_dir / index_name, dest / "index.theme")
        seed_from_system(theme)

    apply_tsv(tsv, custom)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
