#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generate DialogueConfig lua from tree dialogue markdown (Phase 2).

Usage:
  python MissingEggDoc-main/scripts/doc_to_lua.py \\
    --input MissingEggDoc-main/docs/characters/大黄-对话脚本-树状样章.md \\
    --output Assets/Editor/DialogueData/FROM_DOC/dahuang_01_FROM_DOC.lua \\
    --all
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
CROSS_NPC_MAP = SCRIPT_DIR / "cross_npc_map.json"

DEFAULT_ALL_SECTIONS = (
    "1-A,1-A',1-B,1-C,1-D,1-E,1-F,1-G,"
    "2-A,2-hub,2-A',2-B,2-C,2-E,NGPlus"
)

SPEAKER_NAMES = (
    r"玩家|描述|大黄|淑芬|黑猫|悲伤蛙|乌鸦|阿满|米粒|瓜子|豆豆|大树|闪电蜗牛|小鸡侦探团|"
    r"鼠哥|鼠弟|Flash"
)
SPEAKER_LINE = re.compile(
    rf"^(?P<speaker>{SPEAKER_NAMES})(?:·(?P<sprite>[^：:]+))?[:：](?P<text>.+)$"
)
MENU_LINE = re.compile(
    r"^「(?P<text>[^」]+)」(?:（(?P<cond>[^）]*)）)?→\s*(?P<target>.+)$"
)
VAR_LINE = re.compile(r"^·\s*(?P<name>[A-Za-z0-9_]+)\s*=\s*(?P<value>.+)$")
SECTION_HEADER = re.compile(r"^###\s+(?P<doc_id>[^\s·]+)")
CHAPTER_HEADER = re.compile(r"^##\s+")
COND_HEADER = re.compile(r"^【条件】（(?P<expr>[^）]*)）")
REVISIT_COND = re.compile(r"^【回访】（(?P<expr>[^）]*)）")
MENU_COND = re.compile(r"^【菜单】（(?P<expr>[^）]*)）")


@dataclass
class ExitSpec:
    target: str
    condition: str | None = None


@dataclass
class ConditionalBlock:
    condition: str
    lines: list[str] = field(default_factory=list)
    revisit_lines: list[str] = field(default_factory=list)
    exits: list[ExitSpec] = field(default_factory=list)


@dataclass
class TreeSection:
    doc_id: str
    lines: list[str] = field(default_factory=list)


@dataclass
class ParsedSection:
    doc_id: str
    dialogue_lines: list[str] = field(default_factory=list)
    conditional_blocks: list[ConditionalBlock] = field(default_factory=list)
    revisit_speaker: str = "大黄"
    revisit_sprite: str = ""
    revisit_text: str = ""
    revisit_condition: str = ""
    menu_lines: list[str] = field(default_factory=list)
    menu_condition: str = ""
    carousel_variants: list[list[str]] = field(default_factory=list)
    exits: list[ExitSpec] = field(default_factory=list)
    variables: list[tuple[str, str]] = field(default_factory=list)
    skip: bool = False
    is_carousel_only: bool = False
    is_conditional_hub: bool = False
    early_cond_block: ConditionalBlock | None = None


@dataclass
class LuaNode:
    node_id: int
    doc_id: str
    type: str
    npc_name: str = ""
    npc_sprite: str = ""
    dialogue: str = ""
    next_id: int = -1
    options: list[dict] = field(default_factory=list)
    set_variables: list[dict] = field(default_factory=list)
    condition_branches: list[dict] = field(default_factory=list)
    rotate_pool: list[int] = field(default_factory=list)
    unlock_branches: list[dict] = field(default_factory=list)
    position_x: float = 0.0
    position_y: float = 0.0


MICRO_START_X = 50.0
MICRO_START_Y = 150.0
MICRO_X_SPACING = 350.0
MICRO_Y_SPACING = 280.0
CLUSTER_MARGIN = 50.0
SECTION_MACRO_GAP = 350.0
REGION_GAP = 1200.0
BARN_GRID_COLS = 3
RED_GRID_COLS = 3
BARN_SECTION_ORDER = ["1-A", "1-A'", "1-B", "1-C", "1-D", "1-E", "1-F", "1-G"]
RED_SECTION_ORDER = ["2-A", "2-hub", "2-A'", "2-B", "2-C", "2-E"]


def layout_bucket(doc_id: str) -> str:
    if doc_id.startswith("entry"):
        return "entry"
    if doc_id.startswith("NGPlus"):
        return "ngplus"
    if doc_id.startswith("2-") or doc_id.startswith("2-hub"):
        return "red"
    return "barn"


def section_name(doc_id: str) -> str:
    if doc_id.startswith("entry"):
        return doc_id.split("#")[0] if "#" in doc_id else "entry"
    if doc_id.startswith("NGPlus"):
        return "NGPlus"
    match = re.match(r"((?:1|2)-[^@#]+|2-hub[^@#]*)", doc_id)
    if match:
        name = normalize_doc_id(match.group(1))
        if name.startswith("2-hub"):
            return "2-hub"
        return name
    return doc_id.split("@")[0].split("#")[0]


def _section_neighbor_ids(node: LuaNode, section_ids: set[int]) -> list[int]:
    neighbors: list[int] = []

    def add(nid: int) -> None:
        if nid > 0 and nid in section_ids:
            neighbors.append(nid)

    if node.type == "Normal":
        add(node.next_id)
        for cb in node.condition_branches:
            if cb.get("VarType") == "int":
                add(cb.get("Next", -1))
            else:
                add(cb.get("TrueNext", -1))
                add(cb.get("FalseNext", -1))
    elif node.type == "Question":
        for opt in node.options:
            add(opt.get("Next", -1))
    return neighbors


def layout_section_cluster(nodes: list[LuaNode]) -> tuple[float, float]:
    """BFS 横排排版同一 doc 小节内的节点，返回簇宽高。"""
    from collections import defaultdict, deque

    if not nodes:
        return (0.0, 0.0)

    section_ids = {n.node_id for n in nodes}
    adj: dict[int, list[int]] = {nid: [] for nid in section_ids}
    in_degree: dict[int, int] = {nid: 0 for nid in section_ids}

    for node in nodes:
        for neighbor in _section_neighbor_ids(node, section_ids):
            if neighbor not in adj[node.node_id]:
                adj[node.node_id].append(neighbor)
                in_degree[neighbor] += 1

    roots = [nid for nid, deg in in_degree.items() if deg == 0]
    if not roots and 1 in section_ids:
        roots = [1]
    if not roots:
        roots = [min(section_ids)]

    depths: dict[int, int] = {}
    queue: deque[int] = deque()
    visited: set[int] = set()
    for root in roots:
        depths[root] = 0
        queue.append(root)
        visited.add(root)

    while queue:
        curr = queue.popleft()
        curr_depth = depths[curr]
        for neighbor in adj[curr]:
            if neighbor not in depths:
                depths[neighbor] = curr_depth + 1
            else:
                depths[neighbor] = max(depths[neighbor], curr_depth + 1)
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    max_depth = max(depths.values()) if depths else 0
    for node in nodes:
        if node.node_id not in depths:
            depths[node.node_id] = max_depth + 1

    depth_levels: dict[int, list[LuaNode]] = defaultdict(list)
    for node in nodes:
        depth_levels[depths[node.node_id]].append(node)

    max_x = MICRO_START_X
    max_y = MICRO_START_Y
    for depth, level_nodes in depth_levels.items():
        total_height = (len(level_nodes) - 1) * MICRO_Y_SPACING
        column_start_y = MICRO_START_Y - (total_height / 2.0)
        if column_start_y < 50.0:
            column_start_y = 50.0
        for index, node in enumerate(level_nodes):
            x = MICRO_START_X + depth * MICRO_X_SPACING
            y = column_start_y + index * MICRO_Y_SPACING
            node.position_x = x
            node.position_y = y
            max_x = max(max_x, x)
            max_y = max(max_y, y)

    return (max_x + CLUSTER_MARGIN, max_y + CLUSTER_MARGIN)


def _offset_cluster(nodes: list[LuaNode], offset_x: float, offset_y: float) -> None:
    for node in nodes:
        node.position_x += offset_x
        node.position_y += offset_y


def _place_cluster_grid(
    clusters: list[list[LuaNode]],
    origin_x: float,
    origin_y: float,
    grid_cols: int,
    gap: float,
) -> tuple[float, float]:
    cursor_x = origin_x
    cursor_y = origin_y
    col = 0
    max_row_height = 0.0
    region_right = origin_x
    region_bottom = origin_y

    for group in clusters:
        width, height = layout_section_cluster(group)
        _offset_cluster(group, cursor_x, cursor_y)
        region_right = max(region_right, cursor_x + width)
        region_bottom = max(region_bottom, cursor_y + height)
        max_row_height = max(max_row_height, height)
        col += 1
        if col >= grid_cols:
            col = 0
            cursor_x = origin_x
            cursor_y += max_row_height + gap
            max_row_height = 0.0
        else:
            cursor_x += width + gap

    return region_right, region_bottom


def assign_layout_positions(nodes: list[LuaNode]) -> None:
    from collections import defaultdict

    groups: dict[tuple[str, str], list[LuaNode]] = defaultdict(list)
    for node in nodes:
        groups[(layout_bucket(node.doc_id), section_name(node.doc_id))].append(node)

    bucket_order = {"entry": 0, "barn": 1, "red": 2, "ngplus": 3}

    def section_sort_key(bucket: str, sec: str) -> tuple:
        if bucket == "barn" and sec in BARN_SECTION_ORDER:
            return (0, BARN_SECTION_ORDER.index(sec))
        if bucket == "red" and sec in RED_SECTION_ORDER:
            return (0, RED_SECTION_ORDER.index(sec))
        if bucket == "entry":
            return (0, sec)
        if bucket == "ngplus":
            return (0, 0)
        return (1, sec)

    sorted_groups = sorted(
        groups.items(),
        key=lambda kv: (bucket_order.get(kv[0][0], 9), section_sort_key(kv[0][0], kv[0][1])),
    )

    entry_clusters: list[list[LuaNode]] = []
    barn_clusters: list[list[LuaNode]] = []
    red_clusters: list[list[LuaNode]] = []
    ngplus_clusters: list[list[LuaNode]] = []

    for (bucket, _sec), group in sorted_groups:
        if bucket == "entry":
            entry_clusters.append(group)
        elif bucket == "barn":
            barn_clusters.append(group)
        elif bucket == "red":
            red_clusters.append(group)
        elif bucket == "ngplus":
            ngplus_clusters.append(group)

    entry_right = 0.0
    entry_bottom = 0.0
    if entry_clusters:
        entry_nodes = [node for cluster in entry_clusters for node in cluster]
        entry_right, entry_bottom = layout_section_cluster(entry_nodes)

    barn_origin_y = entry_bottom + REGION_GAP if entry_clusters else 0.0
    barn_right, barn_bottom = _place_cluster_grid(
        barn_clusters, 0.0, barn_origin_y, BARN_GRID_COLS, SECTION_MACRO_GAP
    )

    red_origin_x = max(barn_right, entry_right) + REGION_GAP
    red_right, red_bottom = _place_cluster_grid(
        red_clusters, red_origin_x, 0.0, RED_GRID_COLS, SECTION_MACRO_GAP
    )

    if ngplus_clusters:
        ngplus_nodes = [node for cluster in ngplus_clusters for node in cluster]
        layout_section_cluster(ngplus_nodes)
        _offset_cluster(ngplus_nodes, red_origin_x, red_bottom + REGION_GAP)


class NodeBuilder:
    def __init__(self, start_id: int = 1) -> None:
        self.next_id = start_id
        self.nodes: list[LuaNode] = []
        self.doc_to_lua: dict[str, int] = {}

    def create(
        self,
        doc_id: str,
        node_type: str,
        npc_name: str,
        dialogue: str,
        *,
        npc_sprite: str | None = None,
    ) -> LuaNode:
        node = LuaNode(
            node_id=self.next_id,
            doc_id=doc_id,
            type=node_type,
            npc_name=npc_name,
            npc_sprite=npc_sprite if npc_sprite is not None else infer_sprite(npc_name),
            dialogue=dialogue,
        )
        self.nodes.append(node)
        self.next_id += 1
        return node

    def add_dialogue_chain(
        self,
        lines: list[str],
        doc_prefix: str,
        *,
        link: bool = True,
    ) -> list[LuaNode]:
        created: list[LuaNode] = []
        for index, line in enumerate(lines):
            parsed = parse_speaker_line(line)
            if not parsed:
                continue
            speaker, sprite, text = parsed
            node = self.create(
                f"{doc_prefix}#{index + 1}",
                "Normal",
                speaker,
                text,
                npc_sprite=sprite,
            )
            created.append(node)
        if link:
            for i in range(len(created) - 1):
                created[i].next_id = created[i + 1].node_id
        return created

    def add_hub(
        self,
        doc_id: str,
        revisit_text: str,
        menu_lines: list[str],
        *,
        speaker: str = "大黄",
        revisit_sprite: str | None = None,
    ) -> LuaNode:
        hub = self.create(
            doc_id,
            "Question",
            speaker,
            revisit_text or "……",
            npc_sprite=revisit_sprite if revisit_sprite is not None else infer_sprite(speaker),
        )
        self.doc_to_lua[doc_id] = hub.node_id
        for menu_line in menu_lines:
            for option in _menu_line_to_options(menu_line):
                hub.options.append(option)
        return hub

    def apply_variables(self, node: LuaNode, variables: list[tuple[str, str]]) -> None:
        for name, value in variables:
            if value.lower() in {"true", "false"}:
                node.set_variables.append({
                    "VarName": name,
                    "VarType": "bool",
                    "Value": value.lower() == "true",
                })
            else:
                node.set_variables.append({
                    "VarName": name,
                    "VarType": "int",
                    "Value": int(value),
                })

    def wire_exits(self, node: LuaNode, exits: list[ExitSpec]) -> None:
        if not exits:
            return
        if len(exits) == 1 and not exits[0].condition:
            target = target_to_doc_id(exits[0].target)
            if target == "__END__":
                node.next_id = -1
            elif target.startswith("__CROSS_NPC__"):
                node._cross_npc = target  # type: ignore[attr-defined]
                node.next_id = -1
            else:
                node._exit_doc = target  # type: ignore[attr-defined]
            return

        for spec in exits:
            cond = spec.condition or ""
            target = target_to_doc_id(spec.target)
            next_id = -1
            if target != "__END__" and not target.startswith("__CROSS_NPC__"):
                next_id = -2  # resolved later via _exit_doc
            branch = parse_exit_condition_branch(cond, next_id)
            if branch:
                if target != "__END__":
                    branch["_exit_doc"] = target
                node.condition_branches.append(branch)
            elif target == "__END__":
                node.next_id = -1

    def register_doc_entry(self, doc_id: str, node_id: int) -> None:
        self.doc_to_lua[doc_id] = node_id


def _menu_line_to_options(menu_line: str) -> list[dict]:
    match = MENU_LINE.match(menu_line)
    if not match:
        return []
    target_doc = target_to_doc_id(match.group("target"))
    options: list[dict] = []
    for cond_expr in expand_or_conditions(match.group("cond") or ""):
        option: dict = {
            "Text": match.group("text"),
            "Next": -1,
            "BranchFlag": "",
            "DisplayConditions": parse_condition_expr(cond_expr),
        }
        if target_doc == "__END__":
            option["Next"] = -1
        elif target_doc.startswith("__CROSS_NPC__"):
            option["_cross_npc"] = target_doc
            option["Next"] = -1
        else:
            option["_target_doc"] = target_doc
        options.append(option)
    return options


def normalize_doc_id(doc_id: str) -> str:
    return doc_id.replace("′", "'").strip()


def normalize_tree_line(line: str) -> str:
    stripped = line.strip()
    stripped = re.sub(r"^[│├└─]+\s*", "", stripped)
    return stripped.strip()


def is_tree_noise(content: str) -> bool:
    if not content or content in {"│", "├─", "└─"}:
        return True
    if re.match(r"^[12NG]", content) and "：" not in content and "【" not in content:
        if content.startswith("NGPlus"):
            return False
        return True
    return False


def parse_exit_line(content: str) -> ExitSpec:
    content = content.replace("→", "", 1).strip()
    condition = None
    if "（" in content and content.endswith("）"):
        base, cond_part = content.rsplit("（", 1)
        content = base.strip()
        condition = cond_part[:-1].strip()
    return ExitSpec(target=content, condition=condition)


def _parse_int_compare(token: str, op: str) -> dict | None:
    if op not in token:
        return None
    name, value = [x.strip() for x in token.split(op, 1)]
    if not value.isdigit():
        return None
    return {
        "VarName": name,
        "VarType": "int",
        "Op": op,
        "Value": int(value),
    }


def lua_emit_int_op_value(op: str, value: int) -> tuple[str, int]:
    """DouyinScript ScriptedImporter 不接受 Op '<' 或 'lt'；ChickStatus<3 改写为 <=2。"""
    if op in ("<", "lt"):
        return "<=", max(0, int(value) - 1)
    return op, int(value)


def lua_emit_op(op: str) -> str:
    """Deprecated helper; prefer lua_emit_int_op_value for int compares."""
    emitted, _ = lua_emit_int_op_value(op, 0)
    return emitted


def expand_or_conditions(expr: str) -> list[str]:
    expr = expr.strip()
    if not expr or "||" not in expr:
        return [expr] if expr else [""]
    match = re.match(r"^\(([^)]+)\)(.*)$", expr)
    if match and "||" in match.group(1):
        rest = match.group(2).strip()
        if rest.startswith("&&"):
            rest = rest[3:].strip()
        parts = [p.strip() for p in re.split(r"\s*\|\|\s*", match.group(1))]
        return [f"{part} && {rest}" if rest else part for part in parts]
    return [expr]


def parse_condition_expr(expr: str) -> list[dict]:
    expr = expr.strip()
    if not expr:
        return []
    parts = re.split(r"\s*&&\s*", expr)
    conditions: list[dict] = []
    for part in parts:
        part = part.strip()
        if not part:
            continue
        negate = part.startswith("!")
        token = part[1:] if negate else part
        parsed: dict | None = None
        for op in (">=", "<=", "==", "<", ">"):
            parsed = _parse_int_compare(token, op)
            if parsed:
                break
        if parsed:
            conditions.append(parsed)
        elif token.endswith("Count") or token.endswith("Status"):
            conditions.append({
                "VarName": token,
                "VarType": "int",
                "Op": lua_emit_op(">=" if not negate else "<"),
                "Value": 1,
            })
        else:
            conditions.append({
                "VarName": token,
                "VarType": "bool",
                "Value": not negate,
            })
    return conditions


def parse_single_bool(expr: str) -> tuple[str, bool] | None:
    expr = expr.strip()
    if not expr:
        return None
    negate = expr.startswith("!")
    token = expr[1:] if negate else expr
    if "&&" in token or "==" in token:
        return None
    return token, not negate


def parse_exit_condition_branch(cond: str, placeholder_next: int) -> dict | None:
    if not cond:
        return None
    if "DogStatus" in cond and "==" in cond:
        value = int(cond.split("==", 1)[1].strip())
        return {
            "VarName": "DogStatus",
            "VarType": "int",
            "Op": "==",
            "Value": value,
            "Next": placeholder_next,
        }
    single = parse_single_bool(cond)
    if single:
        name, want_true = single
        return {
            "VarName": name,
            "VarType": "bool",
            "Value": want_true,
            "Next": placeholder_next,
            "_bool_int_style": True,
        }
    return None


def target_to_doc_id(target: str) -> str:
    target = target.strip()
    cross = re.search(r"([^\s]+)\s+\*\*([0-9A-Za-z'-]+)\*\*", target)
    if cross and "黑猫" in cross.group(1):
        return f"__CROSS_NPC__黑猫|{normalize_doc_id(cross.group(2))}"
    target = re.split(r"【", target)[0].strip()
    if "（" in target:
        target = target.split("（", 1)[0].strip()
    if target == "对话结束":
        return "__END__"
    match = re.match(r"([12NG][^【\s]+|NGPlus)", target.replace("回访", "").strip())
    if match:
        tid = normalize_doc_id(match.group(1))
        if tid.startswith("NGPlus"):
            return "NGPlus"
        return tid
    first = target.split()[0]
    return normalize_doc_id(first.replace("**", ""))


def parse_speaker_line(line: str) -> tuple[str, str, str] | None:
    """Return (speaker, sprite_key, text) or None."""
    match = SPEAKER_LINE.match(line)
    if not match:
        return None
    speaker = match.group("speaker")
    if speaker == "Flash":
        speaker = "闪电蜗牛"
    sprite = match.group("sprite") or ""
    if not sprite:
        sprite = infer_sprite(speaker)
    text = match.group("text").strip()
    return speaker, sprite, text


def infer_sprite(name: str) -> str:
    if name in ("玩家", "描述", "大树"):
        return ""
    if name == "Flash":
        name = "闪电蜗牛"
    defaults = {
        "大黄": "醉倒",
        "淑芬": "守望",
        "黑猫": "高傲",
        "悲伤蛙": "丧",
        "乌鸦": "得意",
        "闪电蜗牛": "待机",
        "鼠哥": "兜售",
        "鼠弟": "兜售",
        "小鸡侦探团": "装酷",
        "阿满": "装酷",
        "米粒": "装酷",
        "瓜子": "装酷",
        "豆豆": "装酷",
    }
    return defaults.get(name, "")


def parse_carousel_variants(raw_lines: list[str]) -> list[list[str]]:
    variants: list[list[str]] = []
    current: list[str] = []
    in_carousel = False
    for raw in raw_lines:
        content = normalize_tree_line(raw)
        if "【轮播】" in content:
            in_carousel = True
            continue
        if not in_carousel:
            continue
        if re.match(r"^[├└]─", raw.strip()) and not raw.strip().startswith("│"):
            if current:
                variants.append(current)
            current = []
            rest = normalize_tree_line(raw)
            if rest and not is_tree_noise(rest):
                current.append(rest)
            continue
        if is_tree_noise(content):
            continue
        if content.startswith("→"):
            break
        if content.startswith("【变量】"):
            break
        current.append(content)
    if current:
        variants.append(current)
    return variants


def parse_section_tree(section: TreeSection) -> ParsedSection:
    result = ParsedSection(doc_id=section.doc_id)
    section_text = "\n".join(section.lines)

    normalized = [normalize_tree_line(l) for l in section.lines]
    if any(n == "【轮播】" for n in normalized):
        result.is_carousel_only = True
        result.carousel_variants = parse_carousel_variants(section.lines)
        mode = "dialogue"
        for content in normalized:
            if content.startswith("【变量】"):
                mode = "vars"
                continue
            if content.startswith("→"):
                result.exits.append(parse_exit_line(content))
            elif mode == "vars":
                match = VAR_LINE.match(content)
                if match:
                    result.variables.append((match.group("name"), match.group("value").strip()))
        return result

    if section.doc_id == "2-hub" and "E13_ViewDoorBlocked" in section_text:
        result.is_conditional_hub = True

    mode = "dialogue"
    current_cond: ConditionalBlock | None = None

    for content in normalized:
        if is_tree_noise(content):
            continue
        if content.startswith("【变量】"):
            mode = "vars"
            continue
        if match := COND_HEADER.match(content):
            mode = "condition"
            current_cond = ConditionalBlock(condition=match.group("expr"))
            if result.is_conditional_hub and not result.early_cond_block:
                result.early_cond_block = current_cond
            else:
                result.conditional_blocks.append(current_cond)
            continue
        if match := REVISIT_COND.match(content):
            result.revisit_condition = match.group("expr")
            mode = "revisit"
            continue
        if mode == "condition" and current_cond and content.startswith("【回访】"):
            mode = "revisit_in_cond"
            continue
        if content == "【回访】" or (content.startswith("【回访】") and mode != "condition"):
            mode = "revisit"
            continue
        if match := MENU_COND.match(content):
            result.menu_condition = match.group("expr")
            mode = "menu"
            continue
        if content.startswith("【菜单】"):
            mode = "menu"
            continue
        if content.startswith("→"):
            spec = parse_exit_line(content)
            if mode == "condition" and current_cond:
                current_cond.exits.append(spec)
            else:
                result.exits.append(spec)
            continue
        if mode == "vars":
            match = VAR_LINE.match(content)
            if match:
                result.variables.append((match.group("name"), match.group("value").strip()))
            continue
        if mode == "menu" or MENU_LINE.match(content):
            result.menu_lines.append(content)
            continue
        if mode == "revisit":
            parsed_line = parse_speaker_line(content)
            if parsed_line:
                result.revisit_speaker, result.revisit_sprite, result.revisit_text = parsed_line
            continue
        if mode == "revisit_in_cond" and current_cond:
            match = SPEAKER_LINE.match(content)
            if match:
                current_cond.revisit_lines.append(content)
            continue
        if mode == "condition" and current_cond:
            if content.startswith("【回访】"):
                mode = "revisit_in_cond"
                continue
            current_cond.lines.append(content)
            continue
        if mode == "dialogue":
            result.dialogue_lines.append(content)

    return result


def first_meaningful_tree_line(lines: list[str]) -> str:
    for raw in lines:
        content = normalize_tree_line(raw)
        if not content or is_tree_noise(content):
            continue
        if content.startswith("→") or content.startswith("【"):
            continue
        return content
    return ""


def infer_section_doc_id(first: str, *, ngplus_chapter: bool) -> str | None:
    if not first:
        return None
    id_match = re.match(r"^(\d+-[A-Za-z0-9'-]+)$", first)
    if id_match:
        return normalize_doc_id(id_match.group(1))
    if first.startswith("NGPlus"):
        return "NGPlus-revisit" if "回访" in first else "NGPlus"
    if ngplus_chapter and first.startswith("NGPlus"):
        return "NGPlus-revisit" if "回访" in first else "NGPlus"
    return None


def parse_sections(markdown: str, wanted: set[str] | None) -> list[TreeSection]:
    sections: list[TreeSection] = []
    current: TreeSection | None = None
    in_text = False
    text_buffer: list[str] = []
    ngplus_chapter = False
    pending_inline_section = False

    for raw_line in markdown.splitlines():
        stripped = raw_line.strip()
        if CHAPTER_HEADER.match(stripped) and "二周目" in stripped:
            ngplus_chapter = True
            continue
        if CHAPTER_HEADER.match(stripped):
            ngplus_chapter = False

        header = SECTION_HEADER.match(stripped)
        if header:
            if current and text_buffer:
                current.lines = text_buffer
                sections.append(current)
            doc_id = normalize_doc_id(header.group("doc_id"))
            current = TreeSection(doc_id=doc_id)
            text_buffer = []
            in_text = False
            pending_inline_section = False
            if wanted and doc_id not in wanted:
                current = None
            continue

        if stripped.startswith("```text"):
            in_text = True
            text_buffer = []
            pending_inline_section = current is None and not ngplus_chapter
            continue

        if current is None and not ngplus_chapter and not in_text:
            continue

        if in_text and stripped.startswith("```"):
            in_text = False
            if text_buffer:
                if current is None and (ngplus_chapter or pending_inline_section):
                    first = first_meaningful_tree_line(text_buffer)
                    doc_id = infer_section_doc_id(first, ngplus_chapter=ngplus_chapter)
                    if doc_id:
                        current = TreeSection(doc_id=doc_id)
                        if wanted and doc_id not in wanted and "NGPlus" not in wanted:
                            current = None
                if current:
                    current.lines = text_buffer
                    sections.append(current)
                    current = None
            pending_inline_section = False
            continue
        if in_text:
            if pending_inline_section and current is None:
                first = normalize_tree_line(raw_line.rstrip())
                id_match = re.match(r"^(\d+-[A-Za-z0-9'-]+)$", first)
                if id_match:
                    doc_id = normalize_doc_id(id_match.group(1))
                    current = TreeSection(doc_id=doc_id)
                    if wanted and doc_id not in wanted:
                        current = None
                elif first.startswith("NGPlus"):
                    doc_id = "NGPlus-revisit" if "回访" in first else "NGPlus"
                    current = TreeSection(doc_id=doc_id)
                    if wanted and doc_id not in wanted and "NGPlus" not in wanted:
                        current = None
            text_buffer.append(raw_line.rstrip())

    if current and text_buffer:
        current.lines = text_buffer
        sections.append(current)

    if wanted:
        expanded = set(wanted)
        if "NGPlus" in wanted:
            expanded.add("NGPlus-revisit")
        sections = [s for s in sections if s.doc_id in expanded]
    return sections


def load_cross_npc_map() -> dict[str, dict]:
    if CROSS_NPC_MAP.exists():
        return json.loads(CROSS_NPC_MAP.read_text(encoding="utf-8"))
    return {}


def apply_cross_npc(node: LuaNode, cross_key: str, cross_map: dict[str, dict]) -> None:
    key = cross_key.replace("__CROSS_NPC__", "")
    info = cross_map.get(key)
    if info:
        node.unlock_branches.append({
            "NpcName": info["NpcName"],
            "BranchId": info["BranchId"],
        })


def build_section(parsed: ParsedSection, builder: NodeBuilder, cross_map: dict[str, dict]) -> None:
    if parsed.skip:
        return

    if parsed.is_carousel_only:
        variant_starts: list[int] = []
        for vi, variant in enumerate(parsed.carousel_variants):
            chain = builder.add_dialogue_chain(variant, f"{parsed.doc_id}@v{vi + 1}")
            if chain:
                if parsed.variables:
                    builder.apply_variables(chain[-1], parsed.variables)
                chain[-1].next_id = -1
                variant_starts.append(chain[0].node_id)
        entry = builder.create(
            parsed.doc_id,
            "Normal",
            "描述",
            "",
        )
        entry.rotate_pool = variant_starts
        entry.next_id = -1
        builder.register_doc_entry(parsed.doc_id, entry.node_id)
        return

    if parsed.is_conditional_hub and parsed.early_cond_block:
        early = parsed.early_cond_block
        short_chain = builder.add_dialogue_chain(early.revisit_lines or early.lines, "2-hub!E13")
        if short_chain:
            short_chain[-1].next_id = -1
        else:
            for line in early.revisit_lines or early.lines:
                parsed_line = parse_speaker_line(line)
                if parsed_line:
                    sp, spr, txt = parsed_line
                    n = builder.create("2-hub!E13#1", "Normal", sp, txt, npc_sprite=spr)
                    n.next_id = -1
                    short_chain = [n]
                    break

        hub = builder.add_hub(
            "2-hub#menu",
            parsed.revisit_text,
            parsed.menu_lines,
            speaker=parsed.revisit_speaker,
            revisit_sprite=parsed.revisit_sprite or None,
        )
        builder.register_doc_entry("2-hub#menu", hub.node_id)
        if short_chain:
            gate = add_bool_gate(
                builder, "2-hub#gate", "E13_ViewDoorBlocked", True,
                "2-hub#menu", short_chain[0].node_id,
            )
            builder.register_doc_entry("2-hub", gate)
        return

    if parsed.menu_lines and not parsed.dialogue_lines:
        builder.add_hub(
            parsed.doc_id,
            parsed.revisit_text,
            parsed.menu_lines,
            speaker=parsed.revisit_speaker,
            revisit_sprite=parsed.revisit_sprite or None,
        )
        return

    chain = builder.add_dialogue_chain(parsed.dialogue_lines, parsed.doc_id)
    if not chain and not parsed.menu_lines:
        return

    if chain and parsed.doc_id not in builder.doc_to_lua:
        builder.register_doc_entry(parsed.doc_id, chain[0].node_id)

    if chain and parsed.variables:
        builder.apply_variables(chain[-1], parsed.variables)

    if chain and parsed.conditional_blocks:
        last = chain[-1]
        block = parsed.conditional_blocks[0]
        sub = builder.add_dialogue_chain(block.lines, f"{parsed.doc_id}@cond")
        hub_doc = None
        for ex in parsed.exits + block.exits:
            hub_doc = target_to_doc_id(ex.target)
            if hub_doc and hub_doc != "__END__":
                break
            hub_doc = None
        false_next = -1
        if hub_doc and hub_doc != "__END__":
            false_next = -2
            last._false_exit_doc = hub_doc  # type: ignore[attr-defined]
        true_next = sub[0].node_id if sub else false_next
        bool_info = parse_single_bool(block.condition)
        if bool_info:
            var_name, want_true = bool_info
            last.condition_branches.append({
                "VarName": var_name,
                "VarType": "bool",
                "TrueNext": true_next,
                "FalseNext": false_next,
            })
            if sub:
                if hub_doc and hub_doc != "__END__":
                    sub[-1]._exit_doc = hub_doc  # type: ignore[attr-defined]
                elif false_next == -1:
                    sub[-1].next_id = -1

    if chain and len(parsed.conditional_blocks) >= 2 and parsed.doc_id == "1-C":
        last = chain[-1]
        block_a, block_b = parsed.conditional_blocks[0], parsed.conditional_blocks[1]
        chain_a = builder.add_dialogue_chain(block_a.lines, "1-C@a")
        chain_b = builder.add_dialogue_chain(block_b.lines, "1-C@b")
        if chain_a:
            chain_a[-1].next_id = -1
        if chain_b:
            chain_b[-1].next_id = -1
        if chain_a and chain_b:
            last.condition_branches = [{
                "VarName": "E06_ViewNeedLadder",
                "VarType": "bool",
                "TrueNext": chain_b[0].node_id,
                "FalseNext": chain_a[0].node_id,
            }]

    if chain and parsed.exits and not parsed.conditional_blocks:
        builder.wire_exits(chain[-1], parsed.exits)
    if chain and parsed.exits and parsed.doc_id not in ("1-A", "1-C"):
        last = chain[-1]
        if len(parsed.exits) > 1 and not any(
            target_to_doc_id(s.target).startswith("__CROSS_NPC__") for s in parsed.exits
        ):
            last.condition_branches = []
            for spec in parsed.exits:
                target = target_to_doc_id(spec.target)
                if spec.condition and "DogStatus" in spec.condition:
                    value = int(spec.condition.split("==")[1].strip())
                    last.condition_branches.append({
                        "VarName": "DogStatus",
                        "VarType": "int",
                        "Op": "==",
                        "Value": value,
                        "Next": -2,
                        "_exit_doc": target,
                    })
                elif not spec.condition:
                    last._exit_doc = target  # type: ignore[attr-defined]
        elif len(parsed.exits) == 1:
            target = target_to_doc_id(parsed.exits[0].target)
            if target.startswith("__CROSS_NPC__"):
                apply_cross_npc(last, target, cross_map)
                last.next_id = -1
            elif not last.condition_branches:
                builder.wire_exits(last, parsed.exits)


def add_bool_gate(
    builder: NodeBuilder,
    doc_tag: str,
    var_name: str,
    want_true: bool,
    match_doc: str,
    else_next: int,
) -> int:
    node = builder.create(doc_tag, "Normal", "描述", "")
    if want_true:
        node.condition_branches.append({
            "VarName": var_name,
            "VarType": "bool",
            "TrueNext": -2,
            "FalseNext": else_next,
            "_exit_doc": match_doc,
        })
    else:
        node.condition_branches.append({
            "VarName": var_name,
            "VarType": "bool",
            "TrueNext": else_next,
            "FalseNext": -2,
            "_exit_doc": match_doc,
        })
    node.next_id = else_next
    return node.node_id


def add_int_gate(
    builder: NodeBuilder,
    doc_tag: str,
    var_name: str,
    value: int,
    match_doc: str,
    else_next: int,
) -> int:
    node = builder.create(doc_tag, "Normal", "描述", "")
    node.condition_branches.append({
        "VarName": var_name,
        "VarType": "int",
        "Op": "==",
        "Value": value,
        "Next": -2,
        "_exit_doc": match_doc,
    })
    node.next_id = else_next
    return node.node_id


def build_red_roof_entry(builder: NodeBuilder) -> int:
    """红顶入口按序：!Intro→2-A · !Summoned→2-hub · !Entered→2-C · !RoofWait→2-E · else→2-C。"""
    # 自底向上：else 链指向更低优先级；最后返回的节点为入口首检
    fail = -1
    fail = add_bool_gate(
        builder, "entry#rr5", "RedRoof_RoofWaitShown", True,
        "2-C", fail,
    )
    # RoofWait false → 2-E；true → rr5 → 2-C
    fail = add_bool_gate(
        builder, "entry#rr4", "RedRoof_RoofWaitShown", False,
        "2-E", fail,
    )
    # Entered false → 2-C；true → rr4
    fail = add_bool_gate(
        builder, "entry#rr3", "BlackCat_Entered", False,
        "2-C", fail,
    )
    # Summoned false → 2-hub；true → rr3
    fail = add_bool_gate(
        builder, "entry#rr2", "Dog_BlackCatSummoned", False,
        "2-hub", fail,
    )
    # Intro false → 2-A；true → rr2
    fail = add_bool_gate(
        builder, "entry#rr1", "RedRoof_IntroShown", False,
        "2-A", fail,
    )
    return fail


def build_entry_node(builder: NodeBuilder) -> None:
    """Insert DialogueConfig[0] entry dispatcher — Scene start ID should be 0."""
    red_roof = build_red_roof_entry(builder)
    ds4 = builder.create("entry#ds4", "Normal", "描述", "")
    ds4.condition_branches.append({
        "VarName": "DogStatus",
        "VarType": "int",
        "Op": "==",
        "Value": 4,
        "Next": red_roof,
    })
    ds4.next_id = -1

    barn_fail = ds4.node_id
    for val, doc in [(3, "1-D"), (2, "1-A'"), (1, "1-A")]:
        barn_fail = add_int_gate(builder, f"entry#barn{val}", "DogStatus", val, doc, barn_fail)

    entry = LuaNode(
        node_id=0,
        doc_id="entry#0",
        type="Normal",
        npc_name="描述",
        dialogue="",
        next_id=barn_fail,
    )
    entry.condition_branches.append({
        "VarName": "NGPlus",
        "VarType": "bool",
        "TrueNext": -2,
        "FalseNext": barn_fail,
        "_exit_doc": "NGPlus",
    })
    builder.nodes.insert(0, entry)
    builder.doc_to_lua["__entry__"] = 0


def resolve_links(builder: NodeBuilder, cross_map: dict[str, dict]) -> None:
    for node in builder.nodes:
        if node.type == "Question":
            for option in node.options:
                target_doc = option.pop("_target_doc", None)
                cross = option.pop("_cross_npc", None)
                if cross:
                    apply_cross_npc(node, cross, cross_map)
                    option["Next"] = -1
                elif target_doc and target_doc in builder.doc_to_lua:
                    option["Next"] = builder.doc_to_lua[target_doc]

        for cb in node.condition_branches:
            exit_doc = cb.pop("_exit_doc", None) or cb.pop("_false_exit_doc", None)
            if exit_doc and exit_doc in builder.doc_to_lua:
                if "TrueNext" in cb and cb["TrueNext"] == -2:
                    cb["TrueNext"] = builder.doc_to_lua[exit_doc]
                if "FalseNext" in cb and cb["FalseNext"] == -2:
                    cb["FalseNext"] = builder.doc_to_lua[exit_doc]
                if "Next" in cb and cb["Next"] == -2:
                    cb["Next"] = builder.doc_to_lua[exit_doc]

        if hasattr(node, "_exit_doc"):
            target = getattr(node, "_exit_doc")
            if target in builder.doc_to_lua:
                node.next_id = builder.doc_to_lua[target]
        if hasattr(node, "_false_exit_doc"):
            target = getattr(node, "_false_exit_doc")
            if target in builder.doc_to_lua and node.condition_branches:
                for cb in node.condition_branches:
                    if cb.get("FalseNext") in (-1, -2):
                        cb["FalseNext"] = builder.doc_to_lua[target]
        if node.doc_id.startswith("1-A@cond") and node.next_id == -1:
            hub = builder.doc_to_lua.get("1-A'")
            if hub:
                node.next_id = hub
        if hasattr(node, "_cross_npc"):
            apply_cross_npc(node, getattr(node, "_cross_npc"), cross_map)


def build_nodes(
    sections: list[TreeSection],
    cross_map: dict[str, dict],
    *,
    with_entry: bool = False,
) -> tuple[list[LuaNode], dict[str, int]]:
    builder = NodeBuilder(start_id=1)
    parsed_sections = [parse_section_tree(s) for s in sections]
    for parsed in parsed_sections:
        build_section(parsed, builder, cross_map)
    if with_entry:
        build_entry_node(builder)
    resolve_links(builder, cross_map)
    assign_layout_positions(builder.nodes)
    builder.nodes.sort(key=lambda n: n.node_id)
    return builder.nodes, builder.doc_to_lua


def lua_quote(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def render_lua(nodes: list[LuaNode], doc_to_lua: dict[str, int]) -> str:
    lines = [
        "-- 对话配置文件",
        "-- Generated by doc_to_lua.py (Phase 2 — do not overwrite production files)",
        "-- Scene DialogueTrigger start ID should be 0 (entry dispatcher)",
        "-- doc node map:",
    ]
    if "__entry__" in doc_to_lua:
        lines.append("--   __entry__ -> DialogueConfig[0]")
    for doc_id, node_id in sorted(doc_to_lua.items(), key=lambda x: x[1]):
        if doc_id == "__entry__":
            continue
        lines.append(f"--   {doc_id} -> DialogueConfig[{node_id}]")
    lines.extend(["", "DialogueConfig = {}", ""])

    for node in nodes:
        comment = "提问类型（玩家需要选择回答）" if node.type == "Question" else "普通对话类型"
        lines.append(f"-- {comment}  -- doc:{node.doc_id}")
        lines.append(f"-- Position: {{ {int(node.position_x)}, {int(node.position_y)} }}")
        lines.append(f"DialogueConfig[{node.node_id}] = {{")
        lines.append(f'    Type = "{node.type}",')
        lines.append(f'    DocTag = "{lua_quote(node.doc_id)}",')
        lines.append(f'    NpcName = "{lua_quote(node.npc_name)}",')
        lines.append(f'    NpcSprite = "{lua_quote(node.npc_sprite)}",')
        lines.append(f'    Dialogue = "{lua_quote(node.dialogue)}",')

        if node.set_variables:
            lines.append("    SetVariables = {")
            for idx, var in enumerate(node.set_variables):
                comma = "" if idx == len(node.set_variables) - 1 else ","
                if var["VarType"] == "bool":
                    val = "true" if var["Value"] else "false"
                    lines.append(
                        f'        {{ VarName = "{var["VarName"]}", VarType = "bool", Value = {val} }}{comma}'
                    )
                else:
                    lines.append(
                        f'        {{ VarName = "{var["VarName"]}", VarType = "int", Value = {var["Value"]} }}{comma}'
                    )
            lines.append("    },")

        if node.unlock_branches:
            lines.append("    UnlockBranches = {")
            for idx, ub in enumerate(node.unlock_branches):
                comma = "" if idx == len(node.unlock_branches) - 1 else ","
                lines.append(
                    f'        {{ NpcName = "{ub["NpcName"]}", BranchId = {ub["BranchId"]} }}{comma}'
                )
            lines.append("    },")

        if node.condition_branches:
            lines.append("    ConditionBranches = {")
            for idx, cb in enumerate(node.condition_branches):
                comma = "" if idx == len(node.condition_branches) - 1 else ","
                if cb.get("VarType") == "int":
                    cb_op, cb_val = lua_emit_int_op_value(cb["Op"], cb["Value"])
                    lines.append(
                        f'        {{ VarName = "{cb["VarName"]}", VarType = "int", Op = "{cb_op}", '
                        f'Value = {cb_val}, Next = {cb.get("Next", -1)} }}{comma}'
                    )
                else:
                    lines.append(
                        f'        {{ VarName = "{cb["VarName"]}", VarType = "bool", '
                        f'TrueNext = {cb.get("TrueNext", -1)}, FalseNext = {cb.get("FalseNext", -1)} }}{comma}'
                    )
            lines.append("    },")

        if node.rotate_pool:
            pool = ", ".join(str(x) for x in node.rotate_pool)
            lines.append(f"    RotatePool = {{ {pool} }},")

        if node.type == "Question":
            lines.append("    Options = {")
            for opt_idx, option in enumerate(node.options):
                opt_comma = "" if opt_idx == len(node.options) - 1 else ","
                lines.append("        {")
                lines.append(f'            Text = "{lua_quote(option["Text"])}",')
                lines.append(f'            Next = {option["Next"]},')
                if option.get("DisplayConditions"):
                    lines.append("            DisplayConditions = {")
                    dcs = option["DisplayConditions"]
                    for dc_idx, dc in enumerate(dcs):
                        dc_comma = "" if dc_idx == len(dcs) - 1 else ","
                        if dc["VarType"] == "bool":
                            val = "true" if dc["Value"] else "false"
                            lines.append(
                                f'                {{ VarName = "{dc["VarName"]}", VarType = "bool", Value = {val} }}{dc_comma}'
                            )
                        else:
                            dc_op, dc_val = lua_emit_int_op_value(dc["Op"], dc["Value"])
                            lines.append(
                                f'                {{ VarName = "{dc["VarName"]}", VarType = "int", Op = "{dc_op}", Value = {dc_val} }}{dc_comma}'
                            )
                    lines.append("            },")
                lines.append(f"        }}{opt_comma}")
            lines.append("    }")
        else:
            lines.append(f"    Next = {node.next_id}  -- 下一段对话ID")

        lines.append("}")
        lines.append("")

    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate DialogueConfig lua from tree markdown.")
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--sections", type=str, default="", help="Comma-separated doc node ids")
    parser.add_argument("--all", action="store_true", help="Include all default sections for 大黄样章")
    parser.add_argument(
        "--with-entry",
        action="store_true",
        help="Insert DialogueConfig[0] entry dispatcher (大黄 only; default off)",
    )
    parser.add_argument(
        "--no-entry",
        action="store_true",
        help="Explicitly skip entry dispatcher (default)",
    )
    args = parser.parse_args()

    if args.all or not args.sections:
        wanted = {normalize_doc_id(x.strip()) for x in DEFAULT_ALL_SECTIONS.split(",") if x.strip()}
    else:
        wanted = {normalize_doc_id(x.strip()) for x in args.sections.split(",") if x.strip()}

    with_entry = args.with_entry and not args.no_entry

    markdown = args.input.read_text(encoding="utf-8")
    sections = parse_sections(markdown, wanted)
    cross_map = load_cross_npc_map()
    nodes, mapping = build_nodes(sections, cross_map, with_entry=with_entry)
    if not nodes:
        print("ERROR: no nodes generated", file=sys.stderr)
        return 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(render_lua(nodes, mapping), encoding="utf-8")
    print(f"Wrote {args.output} ({len(nodes)} nodes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
