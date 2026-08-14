#!/usr/bin/env python3
"""Wire all TouXiang_LiHui sprites into Mechanics_Code DialogueManager.Sprites (scene YAML)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "Assets/Scenes/Mechanics_Code.unity"
PORTRAIT_ROOT = ROOT / "Assets/Res/Model/TouXiang_LiHui"

SPRITE_LINE = "        - {{fileID: 21300000, guid: {guid}, type: 3}}"


def collect_guids() -> list[tuple[str, str]]:
    items: list[tuple[str, str]] = []
    for meta in sorted(PORTRAIT_ROOT.rglob("*.png.meta")):
        text = meta.read_text(encoding="utf-8")
        m = re.search(r"^guid:\s*(\S+)", text, re.MULTILINE)
        if not m:
            continue
        name = meta.name.replace(".png.meta", "")
        items.append((name, m.group(1)))
    return items


def patch_yaml_file(path: Path, guids: list[tuple[str, str]]) -> bool:
    content = path.read_text(encoding="utf-8")
    lines_block = "\n".join(SPRITE_LINE.format(guid=g) for _, g in guids)
    pattern = re.compile(
        r"(        varName: Sprites\n        Data:\n)"
        r"(?:        - \{fileID: 21300000, guid: [0-9a-f]+, type: 3\}\n)+"
        r"(        varType: UnityEngine\.Sprite\[\])",
        re.MULTILINE,
    )
    replacement = r"\1" + lines_block + "\n" + r"\2"
    new_content, n = pattern.subn(replacement, content, count=1)
    if n != 1:
        print(f"ERROR: Sprites block not found or ambiguous in {path}")
        return False
    path.write_text(new_content, encoding="utf-8")
    print(f"Patched {path.name}: {len(guids)} sprites")
    for name, guid in guids:
        print(f"  {name} -> {guid}")
    return True


def main() -> int:
    guids = collect_guids()
    if len(guids) != 21:
        print(f"WARN: expected 21 portraits, found {len(guids)}")
    prefab = ROOT / "Assets/Prefabs/DialogueManager.prefab"
    ok = patch_yaml_file(prefab, guids)
    if SCENE.exists():
        ok = patch_yaml_file(SCENE, guids) and ok
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
