#!/usr/bin/env python3
"""Set TouXiang_LiHui PNGs to Single sprite mode so sprite.name matches filename."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PORTRAIT_ROOT = ROOT / "Assets/Res/Model/TouXiang_LiHui"

SINGLE_SPRITE_SHEET = """  spriteSheet:
    serializedVersion: 2
    sprites: []
    outline: []
    physicsShape: []
    bones: []
    spriteID: 5e97eb03825dee720800000000000000
    internalID: 0
    vertices: []
    indices: 
    edges: []
    weights: []
    secondaryTextures: []
    nameFileIdTable: {}"""


def fix_meta(meta_path: Path) -> bool:
    text = meta_path.read_text(encoding="utf-8")
    if "spriteMode: 1" in text and 'name: "\\u' not in text and "_0" not in text:
        return False
    text = re.sub(r"spriteMode: \d+", "spriteMode: 1", text, count=1)
    text = re.sub(
        r"  spriteSheet:\n    serializedVersion: 2\n.*?(?=  spritePackingTag:)",
        SINGLE_SPRITE_SHEET + "\n",
        text,
        count=1,
        flags=re.DOTALL,
    )
    meta_path.write_text(text, encoding="utf-8")
    return True


def main() -> int:
    changed = 0
    for meta in sorted(PORTRAIT_ROOT.rglob("*.png.meta")):
        if fix_meta(meta):
            changed += 1
            print(f"fixed {meta.relative_to(ROOT)}")
    print(f"Done: {changed} meta files updated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
