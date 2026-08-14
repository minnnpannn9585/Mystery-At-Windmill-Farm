#!/usr/bin/env python3
"""Patch NpcSprite in lua by matching Dialogue text from annotated tree md."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "MissingEggDoc-main/scripts"))

from doc_to_lua import normalize_tree_line, parse_sections, parse_speaker_line, is_tree_noise  # noqa: E402

MD_LUA = [
    ("小鸡侦探团-对话脚本-树状.md", "xiaojiZTT_e03_FROM_DOC.lua"),
    ("黑猫-对话脚本-树状.md", "heimao_03_FROM_DOC.lua"),
    ("小鸡侦探团-对话脚本-树状.md", "xiaojiZTT_01_FROM_DOC.lua"),
]


def dialogue_sprite_map(md_path: Path) -> dict[str, tuple[str, str]]:
    text = md_path.read_text(encoding="utf-8")
    sections = parse_sections(text, None)
    result: dict[str, tuple[str, str]] = {}
    for sec in sections:
        for raw in sec.lines:
            content = normalize_tree_line(raw)
            if not content or is_tree_noise(content):
                continue
            pl = parse_speaker_line(content)
            if not pl:
                continue
            sp, spr, dlg = pl
            if spr:
                result[dlg] = (sp, spr)
    return result


def patch_by_dialogue(lua_path: Path, dmap: dict[str, tuple[str, str]]) -> int:
    content = lua_path.read_text(encoding="utf-8")
    changed = 0
    skip = {"玩家", "描述", "大树"}

    def repl(m: re.Match) -> str:
        nonlocal changed
        block = m.group(0)
        nm = re.search(r'NpcName\s*=\s*"([^"]*)"', block)
        dlg_m = re.search(r'Dialogue\s*=\s*"((?:[^"\\]|\\.)*)"', block)
        sp_m = re.search(r'NpcSprite\s*=\s*"([^"]*)"', block)
        if not nm or not dlg_m or not sp_m:
            return block
        name, dlg, cur = nm.group(1), dlg_m.group(1), sp_m.group(1)
        if name in skip or cur:
            return block
        hit = dmap.get(dlg)
        if not hit:
            return block
        exp_name, exp_sprite = hit
        new = block
        if name != exp_name:
            new = re.sub(r'NpcName\s*=\s*"[^"]*"', f'NpcName = "{exp_name}"', new, count=1)
        new = re.sub(r'NpcSprite\s*=\s*"[^"]*"', f'NpcSprite = "{exp_sprite}"', new, count=1)
        if new != block:
            changed += 1
        return new

    pat = re.compile(r"DialogueConfig\[\d+\]\s*=\s*\{.*?\n\}", re.DOTALL)
    new_content = pat.sub(repl, content)
    lua_path.write_text(new_content, encoding="utf-8")
    return changed


def main() -> int:
    seen = set()
    for md_name, lua_name in MD_LUA:
        key = (md_name, lua_name)
        if key in seen:
            continue
        seen.add(key)
        dmap = dialogue_sprite_map(ROOT / "MissingEggDoc-main/docs/characters" / md_name)
        for sub in ("Editor", "Data"):
            lp = ROOT / f"Assets/{sub}/DialogueData/FROM_DOC" / lua_name
            if lp.exists():
                n = patch_by_dialogue(lp, dmap)
                print(f"{lp.relative_to(ROOT)}: {n}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
