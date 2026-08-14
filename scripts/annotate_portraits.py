#!/usr/bin/env python3
"""Annotate tree dialogue md with 角色·立绘名：台词 per plan §11.4.3."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHAR_DIR = ROOT / "MissingEggDoc-main/docs/characters"

SPEAKER_RE = re.compile(
    r"^(\s*(?:[│├└─]+\s*)?)"
    r"(?P<speaker>玩家|描述|大黄|淑芬|黑猫|悲伤蛙|乌鸦|阿满|米粒|瓜子|豆豆|大树|"
    r"闪电蜗牛|小鸡侦探团|鼠哥|鼠弟|Flash)"
    r"(?:·[^：:]+)?"
    r"[:：](?P<text>.+)$"
)
SECTION_HDR = re.compile(r"^###\s+(?P<id>[^\s·]+)")
NODE_ROOT = re.compile(r"^(\s*(?:[│├└─]+\s*)?)(?P<id>F-\d+|NGPlus[^\s]*|\d+-[A-Za-z0-9'-]+|0-A)\s*$")

CHICKEN = frozenset({"阿满", "米粒", "瓜子", "豆豆", "小鸡侦探团"})
MOUSE = frozenset({"鼠哥", "鼠弟"})

DEFAULT_SPRITE = {
    "大黄": "醉倒",
    "淑芬": "守望",
    "黑猫": "高傲",
    "悲伤蛙": "丧",
    "乌鸦": "得意",
    "Flash": "待机",
    "闪电蜗牛": "待机",
    "鼠哥": "兜售",
    "鼠弟": "兜售",
    **{n: "装酷" for n in CHICKEN},
}


def sprite_for(node_id: str, speaker: str, section_title: str = "") -> str | None:
    """Return sprite key or None if no portrait (玩家/描述/大树)."""
    if speaker in ("玩家", "描述", "大树"):
        return None
    if speaker == "Flash":
        speaker = "闪电蜗牛"

    nid = node_id.replace("′", "'").strip()
    title = section_title

    # --- 大黄 ---
    if speaker == "大黄":
        if nid in ("1-G", "2-B") or "1-G" in title or "2-B ·" in title:
            return "振奋"
        if nid in ("1-A", "1-A'", "1-C") or re.search(r"1-A|1-C", title):
            if nid not in ("1-B", "1-D", "1-E", "1-F", "2-A", "2-hub", "2-A'", "2-C", "2-E") and "1-B" not in title:
                if nid in ("1-A", "1-A'", "1-C") or "宿醉" in title or "叫不醒" in title:
                    return "醉倒"
        if nid in ("1-B", "1-D", "1-E", "1-F", "2-A", "2-hub", "2-A'", "2-C", "2-E", "NGPlus") or re.search(
            r"1-B|1-D|1-E|1-F|2-hub|2-A'|2-C|2-E|NGPlus|红顶", title
        ):
            if nid not in ("1-G", "2-B") and "1-G" not in title and "2-B ·" not in title:
                return "执勤"
        return "醉倒"

    # --- 淑芬 ---
    if speaker == "淑芬":
        if nid in ("1-hub-intro", "2-A") or "intro" in title.lower() or "白石头" in title or "盼讯" in title:
            return "护雏"
        return "守望"

    # --- 黑猫 ---
    if speaker == "黑猫":
        if re.match(r"2-B", nid) or "案情" in title or "2-B-" in nid:
            return "审视"
        if nid in ("2-A", "2-E") or "落地" in title or "激将" in title:
            return "炸毛"
        return "高傲"

    # --- 悲伤蛙 ---
    if speaker == "悲伤蛙":
        if nid in ("2-D", "3-C", "3-D") or "水怪" in title or "交垫" in title or "排第七" in title:
            return "介入"
        return "丧"

    # --- 乌鸦 ---
    if speaker == "乌鸦":
        if re.match(r"1-[BC]", nid) or "攀爬" in title or "喊话" in title:
            return "叫嚣"
        if re.match(r"2-[BC]", nid) or "护石" in title or "玻璃珠" in title:
            return "吝啬"
        return "得意"

    # --- 小鸡 ---
    if speaker in CHICKEN:
        if nid in ("1-A", "2-B", "2-F") or "偷听" in title or "水怪" in title or "拦顶" in title:
            return "心虚"
        if nid in ("2-E", "3-A") or "招供" in title:
            return "愧疚"
        return "装酷"

    # --- 老鼠 ---
    if speaker in MOUSE:
        if re.match(r"1-[BC]", nid) or "情报" in title or "便宜" in title or "贵情报" in title:
            return "八卦"
        if nid in ("1-D", "1-E-C") or "黑猫" in title or "对峙" in title:
            return "发怵"
        return "兜售"

    # --- 闪电蜗牛 ---
    if speaker == "闪电蜗牛":
        if nid in ("F-3", "F-4", "F-5", "F-6"):
            return "闪电蜗牛"
        return "待机"

    return DEFAULT_SPRITE.get(speaker, "")


def annotate_line(line: str, node_id: str, section_title: str) -> str:
    m = SPEAKER_RE.match(line.rstrip())
    if not m:
        return line
    speaker = m.group("speaker")
    if "·" in line.split("：")[0].split(":")[0]:
        return line  # already annotated
    sprite = sprite_for(node_id, speaker, section_title)
    if sprite is None:
        return line
    prefix, text = m.group(1), m.group("text")
    display_speaker = speaker
    if speaker == "Flash":
        display_speaker = "闪电蜗牛"
    return f"{prefix}{display_speaker}·{sprite}：{text}"


def process_file(path: Path) -> int:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    out: list[str] = []
    in_text = False
    node_id = ""
    section_title = ""
    changed = 0

    for line in lines:
        hdr = SECTION_HDR.match(line.strip())
        if hdr:
            section_title = line.strip()
            node_id = hdr.group("id").replace("′", "'")

        if line.strip().startswith("```text"):
            in_text = True
            out.append(line)
            continue
        if in_text and line.strip().startswith("```"):
            in_text = False
            out.append(line)
            continue

        if in_text:
            root = NODE_ROOT.match(line.rstrip())
            if root:
                node_id = root.group("id").replace("′", "'")
            new_line = annotate_line(line, node_id, section_title)
            if new_line != line:
                changed += 1
            out.append(new_line)
            continue

        out.append(line)

    path.write_text("\n".join(out) + ("\n" if text.endswith("\n") else ""), encoding="utf-8")
    return changed


def main() -> int:
    files = sorted(CHAR_DIR.glob("*树状*.md"))
    total = 0
    for f in files:
        n = process_file(f)
        print(f"{f.name}: {n} lines annotated")
        total += n
    print(f"Total: {total}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
