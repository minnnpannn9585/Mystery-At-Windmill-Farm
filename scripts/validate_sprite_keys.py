#!/usr/bin/env python3
"""Verify every NpcSprite key in FROM_DOC lua exists as TouXiang_LiHui PNG filename."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PORTRAIT_ROOT = ROOT / "Assets/Res/Model/TouXiang_LiHui"
LUA_DIR = ROOT / "Assets/Editor/DialogueData/FROM_DOC"


def portrait_keys() -> set[str]:
    return {p.stem for p in PORTRAIT_ROOT.rglob("*.png")}


def lua_sprite_keys() -> set[str]:
    keys: set[str] = set()
    for lua in LUA_DIR.glob("*_FROM_DOC.lua"):
        for m in re.finditer(r'NpcSprite\s*=\s*"([^"]+)"', lua.read_text(encoding="utf-8")):
            k = m.group(1)
            if k:
                keys.add(k)
    return keys


def main() -> int:
    assets = portrait_keys()
    used = lua_sprite_keys()
    missing = sorted(used - assets)
    unused = sorted(assets - used)
    print(f"Portrait PNGs: {len(assets)}")
    print(f"NpcSprite keys used: {len(used)}")
    if missing:
        print("MISSING assets for keys:", missing)
        return 1
    if unused:
        print("Unused PNGs (ok):", unused)
    print("OK: all NpcSprite keys have matching PNG files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
