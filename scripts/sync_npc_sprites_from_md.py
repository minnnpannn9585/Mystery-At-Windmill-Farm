#!/usr/bin/env python3
"""Patch NpcSprite (and NpcName) in existing FROM_DOC lua from annotated tree md."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "MissingEggDoc-main/scripts"))

from doc_to_lua import (  # noqa: E402
    normalize_doc_id,
    normalize_tree_line,
    parse_sections,
    parse_speaker_line,
    parse_section_tree,
    is_tree_noise,
)

MD_TO_LUA = {
    "大黄-对话脚本-树状样章.md": "dahuang_01_FROM_DOC.lua",
    "淑芬-对话脚本-树状.md": "shufang_01_FROM_DOC.lua",
    "黑猫-对话脚本-树状.md": "heimao_03_FROM_DOC.lua",
    "小鸡侦探团-对话脚本-树状.md": "xiaojiZTT_01_FROM_DOC.lua",
    "悲伤蛙-对话脚本-树状.md": "qingwa_01_FROM_DOC.lua",
    "乌鸦-对话脚本-树状.md": "wuya_01_FROM_DOC.lua",
    "闪电蜗牛-Flash-对话脚本-树状.md": "wuniu_01_FROM_DOC.lua",
}

HEIMAO_TREE_SECTIONS = {"1-A", "1-B"}


def collect_lines_from_section(doc_id: str, section_lines: list[str]) -> list[tuple[str, str, str, str]]:
    """Return list of (doc_tag, speaker, sprite, dialogue)."""
    parsed = parse_section_tree(type("S", (), {"doc_id": doc_id, "lines": section_lines})())
    entries: list[tuple[str, str, str, str]] = []
    idx = 0

    def add_line(raw: str, tag_prefix: str) -> None:
        nonlocal idx
        content = normalize_tree_line(raw)
        if not content or is_tree_noise(content):
            return
        pl = parse_speaker_line(content)
        if not pl:
            return
        idx += 1
        sp, spr, txt = pl
        entries.append((f"{tag_prefix}#{idx}", sp, spr, txt))

    for line in parsed.dialogue_lines:
        add_line(line, doc_id)

    if parsed.revisit_text:
        pl = parse_speaker_line(
            f"{parsed.revisit_speaker}·{parsed.revisit_sprite}：{parsed.revisit_text}"
            if parsed.revisit_sprite
            else f"{parsed.revisit_speaker}：{parsed.revisit_text}"
        )
        if pl:
            sp, spr, txt = pl
            tag = doc_id if doc_id.endswith("'") or doc_id.endswith("-hub") else f"{doc_id}#revisit"
            entries.append((tag, sp, spr, txt))

    for block in parsed.conditional_blocks:
        sub_id = f"{doc_id}@cond"
        sub_idx = 0
        for line in block.lines:
            content = normalize_tree_line(line)
            pl = parse_speaker_line(content)
            if pl:
                sub_idx += 1
                sp, spr, txt = pl
                entries.append((f"{sub_id}#{sub_idx}", sp, spr, txt))

    if parsed.is_carousel_only and parsed.carousel_variants:
        for vi, variant in enumerate(parsed.carousel_variants, 1):
            vidx = 0
            for line in variant:
                content = normalize_tree_line(line)
                pl = parse_speaker_line(content)
                if pl:
                    vidx += 1
                    sp, spr, txt = pl
                    entries.append((f"{doc_id}@v{vi}#{vidx}", sp, spr, txt))

    return entries


def build_sprite_map(md_path: Path, *, section_filter: set[str] | None = None) -> dict[str, tuple[str, str]]:
    """doc_tag -> (npc_name, npc_sprite)."""
    text = md_path.read_text(encoding="utf-8")
    sections = parse_sections(text, None)
    result: dict[str, tuple[str, str]] = {}
    for sec in sections:
        if section_filter and sec.doc_id not in section_filter:
            continue
        for tag, sp, spr, _ in collect_lines_from_section(sec.doc_id, sec.lines):
            result[tag] = (sp, spr)
    return result


def patch_lua(lua_path: Path, sprite_map: dict[str, tuple[str, str]]) -> int:
    content = lua_path.read_text(encoding="utf-8")
    changed = 0

    def repl_block(m: re.Match) -> str:
        nonlocal changed
        block = m.group(0)
        tag_m = re.search(r'DocTag\s*=\s*"([^"]+)"', block)
        if not tag_m:
            return block
        tag = tag_m.group(1)
        # try exact tag, then without suffix variants
        lookup = sprite_map.get(tag)
        if not lookup and "#" in tag:
            base = tag.rsplit("#", 1)[0]
            # hub revisit: DocTag may be 1-hub without number
            for k, v in sprite_map.items():
                if k.startswith(base):
                    pass
        if not lookup:
            return block
        sp, spr = lookup
        new_block = block
        if re.search(r'NpcName\s*=\s*"[^"]*"', new_block):
            new_name = re.sub(r'NpcName\s*=\s*"[^"]*"', f'NpcName = "{sp}"', new_block, count=1)
            if new_name != new_block:
                new_block = new_name
        new_sprite = re.sub(r'NpcSprite\s*=\s*"[^"]*"', f'NpcSprite = "{spr}"', new_block, count=1)
        if new_sprite != block:
            changed += 1
            return new_sprite
        return block

    # Patch by DocTag blocks
    pattern = re.compile(
        r"DialogueConfig\[\d+\]\s*=\s*\{[^}]*?DocTag\s*=\s*\"[^\"]+\"[^}]*?\}",
        re.DOTALL,
    )
    new_content = pattern.sub(repl_block, content)

    # Fallback: sequential match by DocTag order within file
    tags_in_lua = re.findall(r'DocTag\s*=\s*"([^"]+)"', content)
    for tag in tags_in_lua:
        if tag not in sprite_map:
            continue
        sp, spr = sprite_map[tag]
        # NpcSprite for this DocTag
        tag_pat = re.escape(tag)
        block_pat = re.compile(
            rf"(DialogueConfig\[\d+\]\s*=\s*\{{[^}}]*?DocTag\s*=\s*\"{tag_pat}\"[^}}]*?)(NpcSprite\s*=\s*\")([^\"]*)(\"[^}}]*?\}})",
            re.DOTALL,
        )

        def sub_sprite(m: re.Match, _sp=sp, _spr=spr) -> str:
            nonlocal changed
            if m.group(3) == _spr and re.search(rf'NpcName\s*=\s*"{re.escape(_sp)}"', m.group(0)):
                return m.group(0)
            changed += 1
            mid = m.group(1)
            mid = re.sub(r'NpcName\s*=\s*"[^"]*"', f'NpcName = "{_sp}"', mid, count=1)
            return f'{mid}{m.group(2)}{_spr}{m.group(4)}'

        new_content = block_pat.sub(sub_sprite, new_content)

    lua_path.write_text(new_content, encoding="utf-8")
    return changed


def sync_file(md_name: str, lua_name: str, *, section_filter: set[str] | None = None) -> None:
    md_path = ROOT / "MissingEggDoc-main/docs/characters" / md_name
    for sub in ("Editor", "Data"):
        lua_path = ROOT / f"Assets/{sub}/DialogueData/FROM_DOC" / lua_name
        if not lua_path.exists():
            continue
        smap = build_sprite_map(md_path, section_filter=section_filter)
        n = patch_lua(lua_path, smap)
        print(f"  {lua_path.relative_to(ROOT)}: {n} nodes patched ({len(smap)} md lines)")


def main() -> int:
    for md, lua in MD_TO_LUA.items():
        print(md)
        sync_file(md, lua)
    print("heimao_tree (1-A, 1-B)")
    sync_file("黑猫-对话脚本-树状.md", "heimao_tree_01_FROM_DOC.lua", section_filter=HEIMAO_TREE_SECTIONS)
    return 0


if __name__ == "__main__":
    sys.exit(main())
