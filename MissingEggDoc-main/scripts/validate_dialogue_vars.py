# -*- coding: utf-8 -*-
"""Validate dialogue tree scripts against docs/17-全局游戏状态变量.md.

Usage:
  powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate_dialogue_vars.ps1
  python scripts/validate_dialogue_vars.py  (if Python available)

Exit code: 1 if any ERROR, else 0.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VAR_DOC = ROOT / "docs" / "17-全局游戏状态变量.md"
TREE_GLOB = "docs/characters/*-树状*.md"

SHORTHAND: dict[str, str] = {
    "E07": "E07_ViewNapSpot",
    "E08": "E08_ViewBurnMark",
    "E10": "E10_ViewWhiteStone",
    "E13": "E13_ViewDoorBlocked",
    "E17": "E17_ViewEmptyBucket",
    "E18": "E18_ViewBootprints",
    "Started": "BlackCat_CaseLineStarted",
    "Done": "BlackCat_CaseLineDone",
    "StoneRevealShown": "BlackCat_StoneRevealShown",
    "CaseLineDone": "BlackCat_CaseLineDone",
    "MintFishLineDone": "BlackCat_MintFishLineDone",
    "MintFishPending": "BlackCat_MintFishPending",
}

E_POINT_REFS = frozenset(
    f"E{i:02d}" for i in (4, 6, 20, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39)
)

HUB_SUBTREE_DECLARED = re.compile(r"hub\s*子树", re.I)
MENU_COND = re.compile(r"（([^）]+)）\s*→")
RETURN_COND = re.compile(r"→.+（([^）]+)）\s*$")

ALWAYS_OK = frozenset({
    "NGPlus", "Comic_Revealed", "CheeseCount", "ChickTraceCount",
    "TreeClueCount", "DogStatus", "ChickStatus",
})

VAR_PREFIXES = (
    "E", "Dog_", "BlackCat_", "Chick_", "Shufen_", "Crow_",
    "Frog_", "Mouse_", "RedRoof_", "MintFish_", "Flash_", "Comic_",
)


def load_registered_vars(doc_path: Path) -> set[str]:
    text = doc_path.read_text(encoding="utf-8")
    registered = set(ALWAYS_OK)
    for m in re.finditer(r"`([A-Za-z][A-Za-z0-9_]*)`", text):
        name = m.group(1)
        if name.startswith(VAR_PREFIXES) or name in ALWAYS_OK:
            registered.add(name)
    return registered


def resolve_token(raw: str) -> str | None:
    tok = raw.strip()
    if not tok or tok.isdigit() or tok == "E":
        return None
    if tok in E_POINT_REFS:
        return None
    tok = SHORTHAND.get(tok, tok)
    if tok in ALWAYS_OK:
        return tok
    if re.match(r"E\d{2}$", tok) and tok in SHORTHAND:
        return SHORTHAND[tok]
    if tok.startswith(VAR_PREFIXES):
        return tok
    return None


def tokens_in_condition(cond: str) -> set[str]:
    found: set[str] = set()
    for m in re.finditer(r"`([A-Za-z][A-Za-z0-9_]*)`", cond):
        v = resolve_token(m.group(1))
        if v:
            found.add(v)
    for m in re.finditer(r"\b(E\d{2}_[A-Za-z0-9_]+)\b", cond):
        v = resolve_token(m.group(1))
        if v:
            found.add(v)
    for m in re.finditer(r"!?([A-Za-z][A-Za-z0-9_]*)", cond):
        v = resolve_token(m.group(1))
        if v:
            found.add(v)
    return found


def conditions_from_line(line: str) -> list[str]:
    conds: list[str] = []
    for m in MENU_COND.finditer(line):
        c = m.group(1).strip()
        if "**" not in c:
            conds.append(c)
    m = RETURN_COND.search(line)
    if m:
        c = m.group(1).strip()
        if "**" not in c:
            conds.append(c)
    return conds


def scan_tree_file(path: Path, registered: set[str]) -> tuple[list, list]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    has_hub_rule = bool(HUB_SUBTREE_DECLARED.search(text))
    errors: list[tuple[int, str]] = []
    warnings: list[tuple[int, str]] = []

    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        for cond in conditions_from_line(stripped):
            for var in tokens_in_condition(cond):
                if var not in registered:
                    errors.append((i, f"未登记变量 `{var}` in （{cond}）"))

        if has_hub_rule and stripped.startswith("→") and re.search(r"hub", stripped, re.I):
            if re.search(r"BlackCat_Entered|!BlackCat_Entered", stripped):
                warnings.append((i, "返链含 BlackCat_Entered（hub 子树铁则建议省略）"))
            if (
                re.search(r"DogStatus\s*==\s*4", stripped)
                and re.search(r"Dog_BlackCatSummoned|BlackCat_Entered|RedRoof_", stripped)
            ):
                warnings.append((i, "返链含 DogStatus==4 复合条件（hub 子树铁则建议省略）"))

    return errors, warnings


def main() -> int:
    if not VAR_DOC.exists():
        print(f"ERROR: missing {VAR_DOC}", file=sys.stderr)
        return 1

    registered = load_registered_vars(VAR_DOC)
    print(f"Registered variables: {len(registered)}")

    all_errors: list[tuple[str, int, str]] = []
    all_warnings: list[tuple[str, int, str]] = []

    for path in sorted(ROOT.glob(TREE_GLOB)):
        errs, warns = scan_tree_file(path, registered)
        rel = path.relative_to(ROOT).as_posix()
        for line, msg in errs:
            all_errors.append((rel, line, msg))
        for line, msg in warns:
            all_warnings.append((rel, line, msg))

    if all_warnings:
        print("\n--- WARNINGS ---")
        for rel, line, msg in all_warnings:
            print(f"  {rel}:{line}: {msg}")

    if all_errors:
        print("\n--- ERRORS ---")
        for rel, line, msg in all_errors:
            print(f"  {rel}:{line}: {msg}")
        print(f"\n{len(all_errors)} error(s)")
        return 1

    print("\nOK: no unregistered variable errors.")
    if all_warnings:
        print(f"{len(all_warnings)} warning(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
