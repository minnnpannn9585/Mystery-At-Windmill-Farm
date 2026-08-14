# -*- coding: utf-8 -*-
import re
from pathlib import Path

STRUCT_MARKERS = ('【回访】', '【菜单】', '【轮播】', '【条件】')


def is_structural_branch(line: str) -> bool:
    s = line.strip()
    if not (s.startswith('├─') or s.startswith('└─')):
        return False
    content = s[2:].strip()
    return any(content.startswith(m) for m in STRUCT_MARKERS)


def is_dialogue_branch(line: str) -> bool:
    s = line.strip()
    return s.startswith('├─') or s.startswith('└─')


def strip_branch(line: str) -> str:
    return re.sub(r'^[├└]─\s*', '', line)


def fix_text_block(block_lines: list[str]) -> list[str]:
    out: list[str] = []
    i = 0
    while i < len(block_lines):
        line = block_lines[i]
        stripped = line.strip()

        if stripped.startswith('→') or stripped.startswith('【变量】') or stripped.startswith('· '):
            out.extend(block_lines[i:])
            break

        if not is_dialogue_branch(line):
            out.append(line)
            i += 1
            continue

        if is_structural_branch(line):
            out.append(line)
            i += 1
            while i < len(block_lines):
                l = block_lines[i]
                st = l.strip()
                if st.startswith('→') or st.startswith('【变量】') or st.startswith('· '):
                    break
                if is_dialogue_branch(l) and is_structural_branch(l):
                    break
                if is_dialogue_branch(l) and not is_structural_branch(l):
                    # top-level linear run after structural section ended
                    break
                out.append(l)
                i += 1
            continue

        # linear dialogue run
        collected = []
        while i < len(block_lines):
            l = block_lines[i]
            st = l.strip()
            if st.startswith('→') or st.startswith('【变量】') or st.startswith('· '):
                break
            if is_dialogue_branch(l):
                if is_structural_branch(l):
                    break
                collected.append(strip_branch(l))
                i += 1
            else:
                break

        if collected:
            out.append('└─ ' + collected[0])
            for extra in collected[1:]:
                out.append('   ' + extra)
        else:
            out.append(line)
            i += 1

    return out


def process_file(path: Path) -> bool:
    text = path.read_text(encoding='utf-8')
    parts = text.split('```text')
    if len(parts) == 1:
        return False
    new_parts = [parts[0]]
    changed = False
    for part in parts[1:]:
        if '```' not in part:
            new_parts.append('```text' + part)
            continue
        block, rest = part.split('```', 1)
        block_lines = block.split('\n')
        if block_lines and block_lines[0] == '':
            block_lines = block_lines[1:]
        fixed = fix_text_block(block_lines)
        if fixed != block_lines:
            changed = True
        new_parts.append('```text\n' + '\n'.join(fixed) + '```' + rest)
    if changed:
        path.write_text(''.join(new_parts), encoding='utf-8')
    return changed


if __name__ == '__main__':
    root = Path(__file__).resolve().parents[1]
    files = [
        'docs/characters/乌鸦-对话脚本-树状.md',
        'docs/characters/淑芬-对话脚本-树状.md',
        'docs/characters/小鸡侦探团-对话脚本-树状.md',
        'docs/characters/悲伤蛙-对话脚本-树状.md',
        'docs/characters/老鼠兄弟-对话脚本-树状.md',
    ]
    for f in files:
        p = root / f
        print(f, process_file(p))
