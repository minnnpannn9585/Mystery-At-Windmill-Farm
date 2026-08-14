#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Convert Egg Rescue Lua data tables to JSON for the C# PC runtime.

Usage:
  python MissingEggDoc-main/scripts/lua_to_json.py
  # or: dotnet run --project MissingEggDoc-main/scripts/LuaToJson/LuaToJson.csproj

Writes TextAssets under Assets/Resources/GameData/ (*.txt) for the C# runtime."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "Assets" / "Data"
OUT = ROOT / "Assets" / "Resources" / "GameData"

STRING_RE = re.compile(r'"(?:\\.|[^"\\])*"')


class LuaParseError(RuntimeError):
    pass


class Lexer:
    def __init__(self, text: str) -> None:
        self.src = self._strip_comments(text)
        self.n = len(self.src)
        self.i = 0

    @staticmethod
    def _strip_comments(text: str) -> str:
        out = []
        i = 0
        n = len(text)
        while i < n:
            ch = text[i]
            if ch == "-" and i + 1 < n and text[i + 1] == "-":
                if i + 3 < n and text[i + 2] == "[" and text[i + 3] == "[":
                    end = text.find("]]", i + 4)
                    i = n if end < 0 else end + 2
                    continue
                while i < n and text[i] not in "\n\r":
                    i += 1
                continue
            if ch == '"':
                j = i + 1
                while j < n:
                    if text[j] == "\\" and j + 1 < n:
                        j += 2
                        continue
                    if text[j] == '"':
                        j += 1
                        break
                    j += 1
                out.append(text[i:j])
                i = j
                continue
            out.append(ch)
            i += 1
        return "".join(out)

    def peek(self) -> str:
        while self.i < self.n and self.src[self.i].isspace():
            self.i += 1
        return self.src[self.i] if self.i < self.n else ""

    def take(self, n: int = 1) -> str:
        self.peek()
        s = self.src[self.i : self.i + n]
        self.i += n
        return s

    def ident(self) -> str:
        self.peek()
        start = self.i
        if self.i < self.n and (self.src[self.i].isalpha() or self.src[self.i] == "_"):
            self.i += 1
            while self.i < self.n and (self.src[self.i].isalnum() or self.src[self.i] == "_"):
                self.i += 1
        return self.src[start : self.i]

    def number(self) -> float | int:
        self.peek()
        start = self.i
        if self.i < self.n and self.src[self.i] in "+-":
            self.i += 1
        while self.i < self.n and (self.src[self.i].isdigit() or self.src[self.i] in ".eE"):
            self.i += 1
        raw = self.src[start : self.i]
        if "." in raw or "e" in raw.lower():
            return float(raw)
        return int(raw)

    def string(self) -> str:
        self.peek()
        if self.take() != '"':
            raise LuaParseError("expected string")
        buf = []
        while self.i < self.n:
            ch = self.src[self.i]
            self.i += 1
            if ch == '"':
                break
            if ch == "\\" and self.i < self.n:
                nxt = self.src[self.i]
                self.i += 1
                escapes = {"n": "\n", "r": "\r", "t": "\t", '"': '"', "\\": "\\"}
                buf.append(escapes.get(nxt, nxt))
            else:
                buf.append(ch)
        return "".join(buf)


def parse_value(lex: Lexer):
    ch = lex.peek()
    if ch == "{":
        return parse_table(lex)
    if ch == '"':
        return lex.string()
    if ch in "+-" or ch.isdigit():
        return lex.number()
    ident = lex.ident()
    if ident == "true":
        return True
    if ident == "false":
        return False
    if ident == "nil":
        return None
    raise LuaParseError(f"unexpected ident {ident!r} at {lex.i}")


def parse_table(lex: Lexer):
    if lex.take() != "{":
        raise LuaParseError("expected {")
    obj: dict = {}
    arr: list = []
    is_array = True
    next_index = 1
    while True:
        ch = lex.peek()
        if ch == "}":
            lex.take()
            break
        if ch == "":
            raise LuaParseError("unterminated table")

        # [key] = value  or  ident = value  or  value
        key = None
        if ch == "[":
            lex.take()
            key = parse_value(lex)
            if lex.peek() != "]":
                raise LuaParseError("expected ]")
            lex.take()
            if lex.peek() != "=":
                raise LuaParseError("expected = after [] key")
            lex.take()
            val = parse_value(lex)
        else:
            # lookahead: ident =
            save = lex.i
            ident = lex.ident()
            if ident and lex.peek() == "=":
                lex.take()
                key = ident
                val = parse_value(lex)
            else:
                lex.i = save
                val = parse_value(lex)
                key = next_index
                next_index += 1

        if isinstance(key, int) and key == len(arr) + 1 and is_array:
            arr.append(val)
        else:
            is_array = False
            obj[str(key)] = val
            if isinstance(key, int) and key >= next_index:
                next_index = key + 1

        ch = lex.peek()
        if ch == ",":
            lex.take()
            continue
        if ch == "}":
            lex.take()
            break
        raise LuaParseError(f"expected , or }} at {lex.i}, got {ch!r}")

    if obj and arr:
        for i, v in enumerate(arr, start=1):
            obj.setdefault(str(i), v)
        return obj
    if obj:
        return obj
    return arr


def extract_indexed_table(text: str, name: str) -> dict:
    stripped = Lexer._strip_comments(text)
    marker = name + "["
    obj = {}
    idx = 0
    while True:
        found = stripped.find(marker, idx)
        if found < 0:
            break
        lex = Lexer.__new__(Lexer)
        lex.src = stripped[found + len(marker) :]
        lex.n = len(lex.src)
        lex.i = 0
        try:
            key = parse_value(lex)
            if lex.peek() != "]":
                idx = found + len(marker)
                continue
            lex.take()
            if lex.peek() != "=":
                idx = found + len(marker)
                continue
            lex.take()
            val = parse_value(lex)
            obj[str(key)] = val
            idx = found + len(marker) + lex.i
        except LuaParseError:
            idx = found + len(marker)
    return obj


def extract_assignment(text: str, name: str):
    m = re.search(rf"{re.escape(name)}\s*=", text)
    if not m:
        raise LuaParseError(f"{name} assignment not found")
    lex = Lexer(text[m.end() :])
    return parse_value(lex)


def dialogue_config_to_nodes(table) -> list[dict]:
    nodes = []
    if isinstance(table, list):
        for i, node in enumerate(table, start=1):
            if isinstance(node, dict):
                item = dict(node)
                item["id"] = i
                nodes.append(item)
        return nodes
    if not isinstance(table, dict):
        return nodes
    for key, node in table.items():
        if not isinstance(node, dict):
            continue
        try:
            nid = int(key)
        except (TypeError, ValueError):
            continue
        item = dict(node)
        item["id"] = nid
        nodes.append(item)
    nodes.sort(key=lambda n: n["id"])
    return nodes


def convert_global_variables() -> None:
    src = DATA / "GlobalData" / "GlobalVariables.lua"
    table = extract_assignment(src.read_text(encoding="utf-8"), "GlobalVariables")
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "global_variables.txt").write_text(
        json.dumps(table, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"wrote global_variables.txt ({len(table)} vars)")


def convert_npc_data() -> None:
    src = DATA / "GlobalData" / "NPCData_Config.lua"
    table = extract_assignment(src.read_text(encoding="utf-8"), "NPCData")
    (OUT / "npc_data.txt").write_text(
        json.dumps(table, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    n = len(table.get("npcList", [])) if isinstance(table, dict) else 0
    print(f"wrote npc_data.txt ({n} npcs)")


def convert_dialogue_file(path: Path, out_name: str) -> None:
    text = path.read_text(encoding="utf-8")
    table = extract_indexed_table(text, "DialogueConfig")
    nodes = dialogue_config_to_nodes(table)
    dest_dir = OUT / "Dialogue"
    dest_dir.mkdir(parents=True, exist_ok=True)
    (dest_dir / f"{out_name}.txt").write_text(
        json.dumps({"module": out_name, "nodes": nodes}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"wrote Dialogue/{out_name}.txt ({len(nodes)} nodes)")


def main() -> int:
    convert_global_variables()
    convert_npc_data()
    convert_dialogue_file(DATA / "DialogueData" / "miaosu.lua", "miaosu")
    from_doc = DATA / "DialogueData" / "FROM_DOC"
    for path in sorted(from_doc.glob("*_FROM_DOC.lua")):
        convert_dialogue_file(path, path.stem)
    return 0


if __name__ == "__main__":
    sys.exit(main())
