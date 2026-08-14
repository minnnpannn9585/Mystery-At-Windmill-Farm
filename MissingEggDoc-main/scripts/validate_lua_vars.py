#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Validate VarName references in dialogue lua against docs/17-全局游戏状态变量.md.

Usage:
  python MissingEggDoc-main/scripts/validate_lua_vars.py
  python MissingEggDoc-main/scripts/validate_lua_vars.py --lua-dir Assets/Data/DialogueData

Exit code: 1 if any unknown VarName is found, else 0.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
VAR_DOC = ROOT / "docs" / "17-全局游戏状态变量.md"
DEFAULT_LUA_DIR = REPO / "Assets" / "Data" / "DialogueData"
GLOBAL_VARS_LUA = REPO / "Assets" / "Data" / "GlobalData" / "GlobalVariables.lua"

VAR_PREFIXES = (
    "E", "Dog_", "BlackCat_", "Chick_", "Shufen_", "Crow_",
    "Frog_", "Mouse_", "RedRoof_", "MintFish_", "Flash_", "Comic_",
)
ALWAYS_OK = frozenset({
    "NGPlus", "Comic_Revealed", "CheeseCount", "ChickTraceCount",
    "TreeClueCount", "DogStatus", "ChickStatus",
})

VAR_NAME_RE = re.compile(r'VarName\s*=\s*"([A-Za-z][A-Za-z0-9_]*)"')
BRANCH_FLAG_RE = re.compile(r'BranchFlag\s*=\s*"([A-Za-z][A-Za-z0-9_]*)"')
GLOBAL_VAR_NAME_RE = re.compile(r'name\s*=\s*"([A-Za-z][A-Za-z0-9_]*)"')


def load_registered_vars(doc_path: Path, global_vars_path: Path) -> set[str]:
    text = doc_path.read_text(encoding="utf-8")
    registered = set(ALWAYS_OK)
    for match in re.finditer(r"`([A-Za-z][A-Za-z0-9_]*)`", text):
        name = match.group(1)
        if name.startswith(VAR_PREFIXES) or name in ALWAYS_OK:
            registered.add(name)
    if global_vars_path.exists():
        gv_text = global_vars_path.read_text(encoding="utf-8")
        registered.update(GLOBAL_VAR_NAME_RE.findall(gv_text))
    return registered


def collect_var_names(lua_text: str) -> set[str]:
    return set(VAR_NAME_RE.findall(lua_text))


def validate_lua_dir(lua_dir: Path, registered: set[str]) -> list[tuple[str, str]]:
    errors: list[tuple[str, str]] = []
    for lua_file in sorted(lua_dir.glob("*.lua")):
        text = lua_file.read_text(encoding="utf-8")
        for var_name in sorted(collect_var_names(text)):
            if var_name not in registered:
                errors.append((lua_file.name, var_name))
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate dialogue lua VarName references.")
    parser.add_argument(
        "--lua-dir",
        type=Path,
        default=DEFAULT_LUA_DIR,
        help="Directory containing DialogueConfig lua files",
    )
    args = parser.parse_args()

    if not VAR_DOC.exists():
        print(f"ERROR: missing variable doc: {VAR_DOC}", file=sys.stderr)
        return 1
    if not args.lua_dir.exists():
        print(f"ERROR: missing lua dir: {args.lua_dir}", file=sys.stderr)
        return 1

    registered = load_registered_vars(VAR_DOC, GLOBAL_VARS_LUA)
    errors = validate_lua_dir(args.lua_dir, registered)

    if not errors:
        print(f"OK: all VarName references in {args.lua_dir} are registered in doc 17.")
        return 0

    print("ERROR: unknown VarName references:")
    for file_name, var_name in errors:
        print(f"  {file_name}: {var_name}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
