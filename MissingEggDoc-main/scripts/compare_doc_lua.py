#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Compare dialogue lines in tree markdown vs generated DialogueConfig lua."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

SPEAKER_LINE = re.compile(
    r"^(?P<speaker>玩家|描述|Flash|大黄|淑芬|黑猫|悲伤蛙|乌鸦|阿满|米粒|瓜子|豆豆|大树|闪电蜗牛|小鸡侦探团)[:：](?P<text>.+)$"
)
DIALOGUE_FIELD = re.compile(r'Dialogue\s*=\s*"(?P<text>(?:\\.|[^"\\])*)"')
VAR_LINE = re.compile(r"^·\s*(?P<name>[A-Za-z0-9_]+)\s*=\s*(?P<value>.+)$")
SET_VAR = re.compile(
    r'VarName\s*=\s*"(?P<name>[^"]+)"[^}]*VarType\s*=\s*"(?P<vtype>[^"]+)"[^}]*Value\s*=\s*(?P<value>\S+)'
)


def normalize_text(text: str) -> str:
    return text.replace('\\"', '"').strip()


def extract_md_dialogues(markdown: str) -> list[str]:
    lines: list[str] = []
    in_text = False
    for raw in markdown.splitlines():
        stripped = raw.strip()
        if stripped.startswith("```text"):
            in_text = True
            continue
        if in_text and stripped.startswith("```"):
            in_text = False
            continue
        if not in_text:
            continue
        content = stripped
        if content.startswith(("├─", "└─", "│")):
            content = re.sub(r"^[├└│─\s]+", "", content)
        if not content or content.startswith(("→", "【", "1-", "2-", "NGPlus")):
            continue
        match = SPEAKER_LINE.match(content)
        if match:
            lines.append(normalize_text(match.group("text")))
    return lines


def extract_md_variables(markdown: str) -> set[str]:
    names: set[str] = set()
    in_text = False
    for raw in markdown.splitlines():
        stripped = raw.strip()
        if stripped.startswith("```text"):
            in_text = True
            continue
        if in_text and stripped.startswith("```"):
            in_text = False
            continue
        if not in_text:
            continue
        content = stripped.lstrip("│ ").strip()
        match = VAR_LINE.match(content)
        if match:
            names.add(match.group("name"))
    return names


def extract_lua_dialogues(lua_text: str) -> list[str]:
    lines: list[str] = []
    for match in DIALOGUE_FIELD.finditer(lua_text):
        text = normalize_text(match.group("text"))
        if text:
            lines.append(text)
    return lines


def extract_lua_variables(lua_text: str) -> set[str]:
    names: set[str] = set()
    for match in SET_VAR.finditer(lua_text):
        names.add(match.group("name"))
    return names


def main() -> int:
    parser = argparse.ArgumentParser(description="Compare md dialogue vs lua output.")
    parser.add_argument("--input", type=Path, required=True, help="Tree markdown file")
    parser.add_argument("--lua", type=Path, required=True, help="Generated lua file")
    args = parser.parse_args()

    md_text = args.input.read_text(encoding="utf-8")
    lua_text = args.lua.read_text(encoding="utf-8")

    md_lines = extract_md_dialogues(md_text)
    lua_lines = extract_lua_dialogues(lua_text)
    lua_set = set(lua_lines)

    missing = [line for line in md_lines if line not in lua_set]
    md_vars = extract_md_variables(md_text)
    lua_vars = extract_lua_variables(lua_text)
    missing_vars = sorted(md_vars - lua_vars)

    print(f"md dialogue lines: {len(md_lines)}")
    print(f"lua dialogue lines (non-empty): {len(lua_lines)}")
    print(f"missing in lua: {len(missing)}")
    if missing:
        print("\n--- Missing dialogue ---")
        for line in missing[:50]:
            print(f"  - {line}")
        if len(missing) > 50:
            print(f"  ... and {len(missing) - 50} more")

    print(f"\nmd variables: {len(md_vars)}, lua SetVariables names: {len(lua_vars)}")
    if missing_vars:
        print("missing variables in lua:")
        for name in missing_vars:
            print(f"  - {name}")

    return 1 if missing or missing_vars else 0


if __name__ == "__main__":
    sys.exit(main())
