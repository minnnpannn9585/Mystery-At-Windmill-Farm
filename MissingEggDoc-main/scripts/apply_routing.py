#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Patch routing (entry / Next / hub gates) onto content-only *_FROM_DOC.lua files."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


def parse_doc_map(text: str) -> dict[str, int]:
    mapping: dict[str, int] = {}
    for line in text.splitlines():
        match = re.match(r"--\s+(\S+)\s+->\s+DialogueConfig\[(\d+)\]", line.strip())
        if match:
            mapping[match.group(1)] = int(match.group(2))
    return mapping


def max_node_id(text: str) -> int:
    ids = [int(m.group(1)) for m in re.finditer(r"DialogueConfig\[(\d+)\]", text)]
    return max(ids) if ids else 0


def find_last_node(text: str, doc_prefix: str) -> int | None:
    best: tuple[int, int] | None = None
    current_id: int | None = None
    for line in text.splitlines():
        m = re.match(r"DialogueConfig\[(\d+)\]", line.strip())
        if m:
            current_id = int(m.group(1))
            continue
        if current_id is not None and "DocTag" in line:
            tag = re.search(r'DocTag = "([^"]+)"', line)
            if tag and tag.group(1).startswith(doc_prefix):
                seq = 0
                if "#" in tag.group(1):
                    try:
                        seq = int(tag.group(1).split("#", 1)[1])
                    except ValueError:
                        seq = 0
                if best is None or seq >= best[0]:
                    best = (seq, current_id)
    return best[1] if best else None


def patch_next(text: str, node_id: int, next_id: int) -> str:
    lines = text.splitlines()
    in_node = False
    for i, line in enumerate(lines):
        if line.startswith(f"DialogueConfig[{node_id}]"):
            in_node = True
            continue
        if in_node and re.search(r"\bNext = -?\d+", line):
            lines[i] = re.sub(r"Next = -?\d+", f"Next = {next_id}", line)
            break
        if in_node and line.strip() == "}":
            break
    return "\n".join(lines)


def append_setvar(text: str, node_id: int, var_name: str, *, value: bool | int) -> str:
    lines = text.splitlines()
    in_node = False
    insert_at: int | None = None
    has_set = False
    for i, line in enumerate(lines):
        if line.startswith(f"DialogueConfig[{node_id}]"):
            in_node = True
            continue
        if in_node and "SetVariables" in line:
            has_set = True
        if in_node and line.strip() == "}":
            insert_at = i
            break
    if insert_at is None:
        return text
    if has_set:
        for i in range(insert_at - 1, -1, -1):
            if "SetVariables" in lines[i]:
                break
            if lines[i].strip() == "},":
                lines.insert(i, f'        {{ VarName = "{var_name}", VarType = "bool", Value = {"true" if value else "false"} }},')
                return "\n".join(lines)
    vtype = "bool" if isinstance(value, bool) else "int"
    block = [
        "    SetVariables = {",
        f'        {{ VarName = "{var_name}", VarType = "{vtype}", Value = {"true" if value is True else "false" if value is False else value} }}',
        "    },",
    ]
    lines[insert_at:insert_at] = block
    return "\n".join(lines)


def render_gate_node(
    node_id: int,
    doc_tag: str,
    *,
    branches: list[dict],
    fallback_next: int,
    pos_x: int,
    pos_y: int,
) -> str:
    branch_lines: list[str] = []
    for b in branches:
        if b.get("VarType") == "int":
            branch_lines.append(
                f'        {{ VarName = "{b["VarName"]}", VarType = "int", Op = "{b["Op"]}", '
                f'Value = {b["Value"]}, Next = {b["Next"]} }}'
            )
        else:
            branch_lines.append(
                f'        {{ VarName = "{b["VarName"]}", VarType = "bool", '
                f'TrueNext = {b["TrueNext"]}, FalseNext = {b["FalseNext"]} }}'
            )
    branches_str = ",\n".join(branch_lines)
    return f"""
-- 普通对话类型  -- doc:{doc_tag}
-- Position: {{ {pos_x}, {pos_y} }}
DialogueConfig[{node_id}] = {{
    Type = "Normal",
    DocTag = "{doc_tag}",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {{
{branches_str}
    }},
    Next = {fallback_next}  -- 下一段对话ID
}}
"""


def update_doc_map_header(text: str, extra: dict[str, int]) -> str:
    lines = text.splitlines()
    insert_idx = None
    for i, line in enumerate(lines):
        if line.strip() == "DialogueConfig = {}":
            insert_idx = i
            break
    if insert_idx is None:
        return text
    # Remove stale routing map lines already inserted
    header_end = insert_idx
    while header_end > 0 and lines[header_end - 1].startswith("--"):
        header_end -= 1
    existing_keys = set(re.findall(r"--\s+(\S+)\s+->", "\n".join(lines[:insert_idx])))
    map_lines = []
    if "__entry__" not in existing_keys and 0 in extra.values():
        map_lines.append("--   __entry__ -> DialogueConfig[0]")
    for doc_id, node_id in sorted(extra.items(), key=lambda x: x[1]):
        if doc_id in existing_keys:
            continue
        map_lines.append(f"--   {doc_id} -> DialogueConfig[{node_id}]")
    lines[header_end:header_end] = map_lines
    return "\n".join(lines)


def apply_shufang(text: str) -> str:
    doc_map = parse_doc_map(text)
    intro = doc_map["1-hub-intro"]
    hub = doc_map["1-hub"]
    ngplus = doc_map.get("NGPlus") or doc_map["NGPlus-revisit"]
    one_a = doc_map["1-A"]

    last_1a = find_last_node(text, "1-A#") or one_a
    text = patch_next(text, last_1a, intro)
    text = patch_next(text, intro, hub)

    for prefix in ("1-B#", "1-C#", "1-D#", "1-E#", "1-F#", "1-G#", "2-A#", "3-A#"):
        last = find_last_node(text, prefix)
        if last:
            text = patch_next(text, last, hub)

    next_id = max_node_id(text) + 1
    entry_comm = next_id
    entry_new = next_id + 1
    entry0 = 0

    extra = {
        "__entry__": entry0,
        "entry#comm": entry_comm,
        "entry#new": entry_new,
    }
    text = update_doc_map_header(text, extra)

    gates = render_gate_node(
        entry_comm,
        "entry#comm",
        branches=[{
            "VarName": "Shufen_CommissionDone",
            "VarType": "bool",
            "TrueNext": intro,
            "FalseNext": -1,
        }],
        fallback_next=-1,
        pos_x=750,
        pos_y=150,
    ) + render_gate_node(
        entry_new,
        "entry#new",
        branches=[{
            "VarName": "Shufen_CommissionDone",
            "VarType": "bool",
            "TrueNext": entry_comm,
            "FalseNext": one_a,
        }],
        fallback_next=entry_comm,
        pos_x=400,
        pos_y=150,
    ) + f"""
-- 普通对话类型  -- doc:entry#0
-- Position: {{ 50, 150 }}
DialogueConfig[{entry0}] = {{
    Type = "Normal",
    DocTag = "entry#0",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {{
        {{ VarName = "NGPlus", VarType = "bool", TrueNext = {ngplus}, FalseNext = {entry_new} }}
    }},
    Next = {entry_new}  -- 下一段对话ID
}}
"""
    return text.rstrip() + "\n" + gates


def clone_hub_options_block(text: str, source_hub_id: int) -> str:
    match = re.search(
        rf"DialogueConfig\[{source_hub_id}\] = \{{(.*?)\n\}}",
        text,
        re.DOTALL,
    )
    if not match:
        return "    Options = {}"
    block = match.group(1)
    opt = re.search(r"(\s+Options = \{.*?\n\s+\})", block, re.DOTALL)
    return opt.group(1) if opt else "    Options = {}"


def render_question_node(
    node_id: int,
    doc_tag: str,
    speaker: str,
    dialogue: str,
    options_block: str,
    *,
    setvars: list[tuple[str, bool]] | None = None,
    pos_x: int,
    pos_y: int,
) -> str:
    setvar_block = ""
    if setvars:
        entries = ",\n".join(
            f'        {{ VarName = "{n}", VarType = "bool", Value = {"true" if v else "false"} }}'
            for n, v in setvars
        )
        setvar_block = f"    SetVariables = {{\n{entries}\n    }},\n"
    return f"""
-- 提问类型（玩家需要选择回答）  -- doc:{doc_tag}
-- Position: {{ {pos_x}, {pos_y} }}
DialogueConfig[{node_id}] = {{
    Type = "Question",
    DocTag = "{doc_tag}",
    NpcName = "{speaker}",
    NpcSprite = "",
    Dialogue = "{dialogue}",
{setvar_block}{options_block}
}}
"""


def apply_xiaoji_e03(text: str) -> str:
    doc_map = parse_doc_map(text)
    last = find_last_node(text, "1-A#")
    if last:
        text = patch_next(text, last, -1)
    if "E03_Overheard" not in text and last:
        text = append_setvar(text, last, "E03_Overheard", value=True)
    return text


def apply_xiaoji_01(text: str) -> str:
    doc_map = parse_doc_map(text)
    hub_content_id = doc_map["2-hub"]
    two_a = doc_map["2-A"]
    three_a = doc_map["3-A"]
    ngplus = doc_map["NGPlus"]
    ngplus_revisit = doc_map.get("NGPlus-revisit", doc_map.get("NGPlus-revisit", ngplus))
    if "NGPlus-revisit" in doc_map:
        ngplus_revisit = doc_map["NGPlus-revisit"]

    options_block = clone_hub_options_block(text, hub_content_id)

    last_2a = find_last_node(text, "2-A#") or two_a
    sub_prefixes = ("2-B#", "2-C#", "2-D#", "2-E#", "2-F#")
    last_3a = find_last_node(text, "3-A#") or three_a

    nid = max_node_id(text) + 1
    hub_s1 = nid
    hub_s2 = nid + 1
    hub_s3 = nid + 2
    return_pre = nid + 3
    hub_return = nid + 4
    gate_sub = nid + 5
    gate_s3 = nid + 6
    gate_s2 = nid + 7
    gate_s1 = nid + 8
    hub_gate = nid + 9
    entry_hub = nid + 10
    entry_3a1 = nid + 11
    entry_3a2 = nid + 12
    entry_3a0 = nid + 13
    entry_2a = nid + 14
    entry_ng1 = nid + 15
    entry_ng2 = nid + 16

    return_chain = f"""
-- 普通对话类型  -- doc:2-hub#return@pre#1
-- Position: {{ 11250, 50 }}
DialogueConfig[{return_pre}] = {{
    Type = "Normal",
    DocTag = "2-hub#return@pre#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（四只小鸡又挤到一起）",
    Next = {hub_return}  -- 下一段对话ID
}}
"""

    hubs = (
        render_question_node(
            hub_s1, "2-hub#s1#menu", "阿满", "……在查。别碰我们的现场。", options_block, pos_x=12300, pos_y=50
        )
        + render_question_node(
            hub_s2, "2-hub#s2#menu", "阿满", "池塘那边……去了吗？", options_block, pos_x=12300, pos_y=330
        )
        + render_question_node(
            hub_s3, "2-hub#s3#menu", "阿满", "……外勤停了。有事快说。", options_block, pos_x=11950, pos_y=50
        )
        + return_chain
        + render_question_node(
            hub_return,
            "2-hub#return#menu",
            "阿满",
            "……还说？",
            options_block,
            setvars=[("Chick_HubFromSubItem", False)],
            pos_x=11600,
            pos_y=50,
        )
    )

    gates = (
        render_gate_node(
            gate_s3,
            "2-hub#g3",
            branches=[{"VarName": "ChickStatus", "VarType": "int", "Op": "==", "Value": 3, "Next": hub_s3}],
            fallback_next=gate_s2,
            pos_x=11600,
            pos_y=330,
        )
        + render_gate_node(
            gate_s2,
            "2-hub#g2",
            branches=[{"VarName": "ChickStatus", "VarType": "int", "Op": "==", "Value": 2, "Next": hub_s2}],
            fallback_next=gate_s1,
            pos_x=11950,
            pos_y=330,
        )
        + render_gate_node(
            gate_s1,
            "2-hub#g1",
            branches=[{"VarName": "ChickStatus", "VarType": "int", "Op": "==", "Value": 1, "Next": hub_s1}],
            fallback_next=hub_s1,
            pos_x=12200,
            pos_y=330,
        )
        + render_gate_node(
            hub_gate,
            "2-hub#gate",
            branches=[{
                "VarName": "Chick_HubFromSubItem",
                "VarType": "bool",
                "TrueNext": hub_return,
                "FalseNext": gate_s3,
            }],
            fallback_next=gate_s3,
            pos_x=11250,
            pos_y=330,
        )
    )

    entry = (
        render_gate_node(
            entry_hub,
            "entry#hub",
            branches=[{"VarName": "ChickStatus", "VarType": "int", "Op": ">=", "Value": 1, "Next": hub_gate}],
            fallback_next=-1,
            pos_x=1800,
            pos_y=150,
        )
        + render_gate_node(
            entry_3a1,
            "entry#3a1",
            branches=[{
                "VarName": "Chick_Chapter2GuiltShown",
                "VarType": "bool",
                "TrueNext": entry_hub,
                "FalseNext": three_a,
            }],
            fallback_next=entry_hub,
            pos_x=1450,
            pos_y=150,
        )
        + render_gate_node(
            entry_3a2,
            "entry#3a2",
            branches=[{"VarName": "ChickStatus", "VarType": "int", "Op": "==", "Value": 3, "Next": entry_3a1}],
            fallback_next=entry_hub,
            pos_x=1100,
            pos_y=50,
        )
        + render_gate_node(
            entry_3a0,
            "entry#3a0",
            branches=[{"VarName": "DogStatus", "VarType": "int", "Op": "==", "Value": 4, "Next": entry_3a2}],
            fallback_next=entry_hub,
            pos_x=750,
            pos_y=50,
        )
        + render_gate_node(
            entry_2a,
            "entry#2a",
            branches=[{"VarName": "ChickStatus", "VarType": "int", "Op": "==", "Value": 0, "Next": two_a}],
            fallback_next=entry_3a0,
            pos_x=1100,
            pos_y=330,
        )
        + render_gate_node(
            entry_ng1,
            "entry#ng1",
            branches=[{
                "VarName": "Chick_NGPlusShown",
                "VarType": "bool",
                "TrueNext": entry_2a,
                "FalseNext": ngplus,
            }],
            fallback_next=entry_2a,
            pos_x=750,
            pos_y=330,
        )
        + render_gate_node(
            entry_ng2,
            "entry#ng2",
            branches=[{
                "VarName": "Chick_NGPlusShown",
                "VarType": "bool",
                "TrueNext": ngplus_revisit,
                "FalseNext": entry_ng1,
            }],
            fallback_next=entry_ng1,
            pos_x=400,
            pos_y=150,
        )
        + f"""
-- 普通对话类型  -- doc:entry#0
-- Position: {{ 50, 150 }}
DialogueConfig[0] = {{
    Type = "Normal",
    DocTag = "entry#0",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {{
        {{ VarName = "NGPlus", VarType = "bool", TrueNext = {entry_ng2}, FalseNext = {entry_2a} }}
    }},
    Next = {entry_2a}  -- 下一段对话ID
}}
"""
    )

    extra = {
        "__entry__": 0,
        "2-hub#s1#menu": hub_s1,
        "2-hub#s2#menu": hub_s2,
        "2-hub#s3#menu": hub_s3,
        "2-hub#return#menu": hub_return,
        "2-hub": hub_gate,
        "NGPlus-revisit": ngplus_revisit,
        "entry#ng2": entry_ng2,
        "entry#ng1": entry_ng1,
        "entry#2a": entry_2a,
        "entry#3a0": entry_3a0,
        "entry#3a2": entry_3a2,
        "entry#3a1": entry_3a1,
        "entry#hub": entry_hub,
    }
    text = update_doc_map_header(text, extra)

    text = patch_next(text, last_2a, hub_gate)
    for prefix in sub_prefixes:
        last = find_last_node(text, prefix)
        if last:
            text = patch_next(text, last, hub_gate)
            text = append_setvar(text, last, "Chick_HubFromSubItem", value=True)

    # Remove content-only 2-hub question node body from map usage (leave node in file unused)
    return text.rstrip() + "\n" + hubs + gates + entry


PROFILES = {
    "shufang": apply_shufang,
    "xiaoji_01": apply_xiaoji_01,
    "xiaoji_e03": apply_xiaoji_e03,
}


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply NPC routing rules to content-only lua.")
    parser.add_argument("--profile", choices=sorted(PROFILES), required=True)
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=None)
    args = parser.parse_args()

    text = args.input.read_text(encoding="utf-8")
    patched = PROFILES[args.profile](text)
    out = args.output or args.input
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(patched, encoding="utf-8")
    print(f"Applied routing profile={args.profile} -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
