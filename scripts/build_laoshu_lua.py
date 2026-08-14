#!/usr/bin/env python3
"""Build laoshu_01_FROM_DOC.lua from老鼠兄弟树状 md (content + routing)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MD = ROOT / "MissingEggDoc-main/docs/characters/老鼠兄弟-对话脚本-树状.md"
OUT = ROOT / "Assets/Editor/DialogueData/FROM_DOC/laoshu_01_FROM_DOC.lua"
RUNTIME_OUT = ROOT / "Assets/Data/DialogueData/FROM_DOC/laoshu_01_FROM_DOC.lua"

HUB = 100
HUB_REVISIT = 95  # 【回访】想买什么？/没情报了 → then HUB menu
ENTRY = 0
NODE_0A = 1
NODE_1A = 20
NODE_1D = 200
NODE_1E = 210
NODE_1EF = 250
NODE_1EA = 260
NODE_1EB = 270
NODE_1EC = 290
NODE_1G = 310
NODE_1GP = 320
NODE_1GA = 330
NODE_1GT = 340
NODE_1H = 350
NGPLUS = 900
CHEAP_BASE = 500
PREMIUM_BASE = 600

nodes: dict[int, dict] = {}
next_id = 1000


def alloc() -> int:
    global next_id
    next_id += 1
    return next_id


def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace('"', '\\"')


def add_node(nid: int, body: str) -> None:
    nodes[nid] = body


def chain_lines(nid_start: int, lines: list[tuple[str, str, str]], final_next: int, set_vars: list[str] | None = None) -> int:
    """lines: [(speaker, sprite, text), ...] returns last node id"""
    if not lines:
        return nid_start
    ids = [nid_start + i for i in range(len(lines))]
    for i, (speaker, sprite, text) in enumerate(lines):
        nid = ids[i]
        nxt = ids[i + 1] if i + 1 < len(ids) else final_next
        sv = ""
        if i == len(lines) - 1 and set_vars:
            sv = "    SetVariables = {\n"
            for v in set_vars:
                sv += f'        {{ VarName = "{v}", VarType = "bool", Value = true }},\n'
            sv += "    },\n"
        spr = sprite if sprite else ""
        add_node(
            nid,
            f"""-- Position: {{ 50, 150 }}
DialogueConfig[{nid}] = {{
    Type = "Normal",
    NpcName = "{esc(speaker)}",
    NpcSprite = "{esc(spr)}",
    Dialogue = "{esc(text)}",
{sv}    Next = {nxt}
}}""",
        )
    return ids[-1]


def parse_tree_block(text: str) -> list[tuple[str, str, str]]:
    """Return [(speaker, sprite, dialogue), ...]"""
    lines = []
    for raw in text.splitlines():
        raw = raw.strip()
        if not raw or raw.startswith("│") or raw.startswith("├") or raw.startswith("└"):
            continue
        if raw.startswith("→") or raw.startswith("【"):
            continue
        if raw.startswith("「") and "→" in raw:
            continue
        m = re.match(r"^(描述|玩家|鼠哥|鼠弟)(?:·([^：:]+))?[:：](.+)$", raw)
        if m:
            sp, spr, dlg = m.group(1), m.group(2) or "", m.group(3).strip()
            if sp == "描述":
                dlg = dlg if dlg.startswith("（") else f"（{dlg}）"
            if sp in ("鼠哥", "鼠弟") and not spr:
                spr = "兜售"
            lines.append((sp, spr, dlg))
    return lines


def extract_section(md: str, header: str) -> str:
    pat = re.compile(rf"### {re.escape(header)}.*?\n```text\n(.*?)```", re.DOTALL)
    m = pat.search(md)
    return m.group(1) if m else ""


def build_intel_cheap(md: str) -> dict[int, int]:
    """Returns index -> start node id"""
    block = extract_section(md, "1-B · 便宜情报（1 块）")
    mapping = {}
    parts = re.split(r"1-B · #(\d+)", block)
    for i in range(1, len(parts), 2):
        idx = int(parts[i])
        content = parts[i + 1]
        lines = parse_tree_block(content)
        if not lines:
            continue
        start = CHEAP_BASE + (idx - 1) * 10
        var = f"Mouse_CheapSold_{idx:02d}"
        chain_lines(start, lines, HUB_REVISIT, [var])
        mapping[idx] = start
    return mapping


def build_intel_premium(md: str) -> dict[int, int]:
    block = extract_section(md, "1-C · 贵情报（5 块）")
    mapping = {}
    parts = re.split(r"1-C · #(\d+)", block)
    for i in range(1, len(parts), 2):
        idx = int(parts[i])
        content = parts[i + 1]
        lines = parse_tree_block(content)
        if not lines:
            continue
        start = PREMIUM_BASE + (idx - 1) * 10
        var = f"Mouse_PremiumSold_{idx:02d}"
        chain_lines(start, lines, HUB_REVISIT, [var])
        mapping[idx] = start
    return mapping


def build_simple_section(md: str, header_substr: str, start_id: int, set_vars: list[str] | None = None) -> int:
    block = ""
    for h in re.findall(r"### (.+)", md):
        if header_substr in h:
            block = extract_section(md, h)
            break
    lines = parse_tree_block(block)
    if lines:
        chain_lines(start_id, lines, HUB_REVISIT, set_vars)
    return start_id


def main() -> None:
    md = MD.read_text(encoding="utf-8")
    cheap_map = build_intel_cheap(md)
    premium_map = build_intel_premium(md)

    # 0-A
    lines_0a = parse_tree_block(extract_section(md, "0-A · 靠近喊话（强制播放）"))
    chain_lines(NODE_0A, lines_0a, -1, ["Mouse_AreaCalloutShown"])

    # 1-A
    lines_1a = parse_tree_block(extract_section(md, "1-A · 首次问候"))
    chain_lines(NODE_1A, lines_1a, HUB_REVISIT, ["Mouse_FirstGreetShown"])

    # 1-D
    build_simple_section(md, "1-D · 黑猫盯视闲聊", NODE_1D, ["Mouse_BlackCatStareShown"])

    # 1-E (quote, then dispatch by whether the player already holds the fish)
    block_1e = extract_section(md, "1-E · 薄荷鱼报价（未闻价；报价后按是否持鱼分流）")
    lines_1e = parse_tree_block(block_1e.split("└─ 【菜单】")[0])
    qid = NODE_1E + 20
    dispatch_id = qid - 1
    chain_lines(NODE_1E, lines_1e, dispatch_id)
    add_node(
        dispatch_id,
        f"""DialogueConfig[{dispatch_id}] = {{
    Type = "Normal",
    DocTag = "1-E-after-quote-dispatch",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    SetVariables = {{
        {{ VarName = "Mouse_MintFishPitchShown", VarType = "bool", Value = true }},
    }},
    ConditionBranches = {{
        {{ VarName = "MintFish_Obtained", VarType = "bool", TrueNext = {NODE_1H}, FalseNext = {qid} }},
    }},
    Next = {qid}
}}""",
    )
    add_node(
        qid,
        f"""DialogueConfig[{qid}] = {{
    Type = "Question",
    DocTag = "1-E-menu",
    NpcName = "鼠哥",
    NpcSprite = "兜售",
    Dialogue = "",
    Options = {{
        {{
            Text = "给你。",
            Next = {NODE_1EB},
            ShopAction = "pay8_mint",
            DisplayConditions = {{
                {{ VarName = "Frog_PadRefused", VarType = "bool", Value = false }},
                {{ VarName = "Mouse_CanAffordMint8InGame", VarType = "bool", Value = true }},
            }},
        }},
        {{
            Text = "先不给。",
            Next = {NODE_1EA},
            DisplayConditions = {{
                {{ VarName = "Frog_PadRefused", VarType = "bool", Value = false }},
            }},
        }},
        {{
            Text = "我已经找到了。",
            Next = {NODE_1EF},
            DisplayConditions = {{
                {{ VarName = "Frog_PadRefused", VarType = "bool", Value = true }},
            }},
        }},
    }},
    Next = -1
}}""",
    )

    build_simple_section(md, "1-E-F · 拒付 · 方向费豁免（**1-E** 内出口 · 路径 **G0-E**）", NODE_1EF, None)
    build_simple_section(md, "1-E-A · 拒绝支付", NODE_1EA, None)
    build_simple_section(md, "1-E-B · 支付成功", NODE_1EB, ["Mouse_MintFishPaid", "Mouse_PremiumPoolUnlocked"])
    build_simple_section(md, "1-E-C · 对峙开池（已取鱼 · 已闻价 · 免费开后组）", NODE_1EC, ["Mouse_PremiumPoolUnlocked"])

    # 1-G menu
    lines_1g = parse_tree_block(extract_section(md, "1-G · 青蛙兜底 · 未付入口（蛙线已败）").split("└─ 【菜单】")[0])
    chain_lines(NODE_1G, lines_1g, NODE_1G + 1)
    add_node(
        NODE_1G + 1,
        f"""DialogueConfig[{NODE_1G + 1}] = {{
    Type = "Question",
    DocTag = "1-G-menu",
    NpcName = "鼠哥",
    NpcSprite = "兜售",
    Dialogue = "",
    Options = {{
        {{
            Text = "给你。",
            Next = {NODE_1GP},
            ShopAction = "pay8_frog",
            DisplayConditions = {{
                {{ VarName = "Mouse_CanAffordMint8InGame", VarType = "bool", Value = true }},
            }},
        }},
        {{
            Text = "算了。",
            Next = {HUB_REVISIT},
        }},
    }},
    Next = -1
}}""",
    )

    build_simple_section(md, "1-G-P · 蛙兜底 · 付 8 块", NODE_1GP, ["Mouse_MintFishPaid", "Mouse_PremiumPoolUnlocked"])
    # 1-G-P should go to 1-G-T
    nodes[NODE_1GP] = re.sub(r"Next = \d+", f"Next = {NODE_1GT}", nodes[NODE_1GP])

    build_simple_section(md, "1-G-A · 青蛙兜底 · 已付入口（含在 8 块包内）", NODE_1GA, None)
    nodes[NODE_1GA] = re.sub(r"Next = \d+", f"Next = {NODE_1GT}", nodes[NODE_1GA])
    build_simple_section(md, "1-G-T · 排第七口诀（兜底正文）", NODE_1GT, ["Mouse_FrogFallbackGiven"])

    # 1-H: already holding fish, expose the lie immediately after the first quote
    build_simple_section(
        md,
        "1-H · 未询价持鱼 · 报价现场亮鱼恐吓开池",
        NODE_1H,
        ["Mouse_PremiumPoolUnlocked"],
    )

    # hub revisit dispatchers
    add_node(
        95,
        f"""DialogueConfig[95] = {{
    Type = "Normal",
    DocTag = "1-hub-revisit-dispatch",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {{
        {{ VarName = "Mouse_CheapPoolAvailable", VarType = "bool", TrueNext = 96, FalseNext = 97 }},
    }},
    Next = 96
}}""",
    )
    add_node(
        96,
        f"""DialogueConfig[96] = {{
    Type = "Normal",
    DocTag = "1-hub-revisit-available",
    NpcName = "鼠哥",
    NpcSprite = "兜售",
    Dialogue = "想买什么？",
    ConditionBranches = {{
        {{ VarName = "Mouse_PremiumPoolAvailable", VarType = "bool", TrueNext = {HUB}, FalseNext = {HUB} }},
    }},
    Next = {HUB}
}}""",
    )
    add_node(
        97,
        f"""DialogueConfig[97] = {{
    Type = "Normal",
    DocTag = "1-hub-revisit-empty",
    NpcName = "鼠哥",
    NpcSprite = "兜售",
    Dialogue = "没情报了，别的还有事吗？",
    ConditionBranches = {{
        {{ VarName = "Mouse_PremiumPoolAvailable", VarType = "bool", TrueNext = {HUB}, FalseNext = {HUB} }},
    }},
    Next = {HUB}
}}""",
    )

    # Fix revisit: if cheap unavailable but premium available, still show 想买什么
    add_node(
        95,
        f"""DialogueConfig[95] = {{
    Type = "Normal",
    DocTag = "1-hub-revisit-dispatch",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {{
        {{ VarName = "Mouse_CheapPoolAvailable", VarType = "bool", TrueNext = 96, FalseNext = 98 }},
    }},
    Next = 96
}}""",
    )
    add_node(
        98,
        f"""DialogueConfig[98] = {{
    Type = "Normal",
    DocTag = "1-hub-revisit-premium-only",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {{
        {{ VarName = "Mouse_PremiumPoolAvailable", VarType = "bool", TrueNext = 96, FalseNext = 97 }},
    }},
    Next = 97
}}""",
    )

    # 1-hub
    add_node(
        HUB,
        f"""DialogueConfig[{HUB}] = {{
    Type = "Question",
    DocTag = "1-hub",
    NpcName = "鼠哥",
    NpcSprite = "兜售",
    Dialogue = "",
    MenuCap = 0,
    Options = {{
        {{
            Text = "便宜的，一块。",
            ShopAction = "cheap",
            Next = {HUB_REVISIT},
            DisplayConditions = {{
                {{ VarName = "Mouse_CheapPoolAvailable", VarType = "bool", Value = true }},
                {{ VarName = "CheeseCount", VarType = "int", Op = ">=", Value = 1 }},
            }},
        }},
        {{
            Text = "贵一点的，五块。",
            ShopAction = "premium",
            Next = {HUB_REVISIT},
            DisplayConditions = {{
                {{ VarName = "Mouse_PremiumPoolAvailable", VarType = "bool", Value = true }},
                {{ VarName = "CheeseCount", VarType = "int", Op = ">=", Value = 5 }},
            }},
        }},
        {{
            Text = "那只黑猫好像一直盯着你们……",
            Next = {NODE_1D},
            DisplayConditions = {{
                {{ VarName = "Dog_BlackCatSummoned", VarType = "bool", Value = true }},
                {{ VarName = "Mouse_BlackCatStareShown", VarType = "bool", Value = false }},
            }},
        }},
        {{
            Text = "黑猫叫我来找你……",
            Next = {NODE_1E},
            DisplayConditions = {{
                {{ VarName = "BlackCat_MintFishPending", VarType = "bool", Value = true }},
                {{ VarName = "Mouse_MintFishPaid", VarType = "bool", Value = false }},
                {{ VarName = "Mouse_MintFishPitchShown", VarType = "bool", Value = false }},
                {{ VarName = "Mouse_PremiumPoolUnlocked", VarType = "bool", Value = false }},
            }},
        }},
        {{
            Text = "八块奶酪碎，给你。",
            Next = {NODE_1EB},
            ShopAction = "pay8_mint",
            DisplayConditions = {{
                {{ VarName = "BlackCat_MintFishPending", VarType = "bool", Value = true }},
                {{ VarName = "Mouse_MintFishPaid", VarType = "bool", Value = false }},
                {{ VarName = "MintFish_Obtained", VarType = "bool", Value = false }},
                {{ VarName = "Mouse_MintFishPitchShown", VarType = "bool", Value = true }},
                {{ VarName = "Frog_PadRefused", VarType = "bool", Value = false }},
                {{ VarName = "Mouse_CanAffordMint8InGame", VarType = "bool", Value = true }},
            }},
        }},
        {{
            Text = "那个青蛙，有没有什么办法搞定？",
            Next = {NODE_1G},
            DisplayConditions = {{
                {{ VarName = "Frog_PadRefused", VarType = "bool", Value = true }},
                {{ VarName = "Mouse_FrogFallbackGiven", VarType = "bool", Value = false }},
                {{ VarName = "MintFish_Obtained", VarType = "bool", Value = false }},
                {{ VarName = "Mouse_MintFishPaid", VarType = "bool", Value = false }},
            }},
        }},
        {{
            Text = "青蛙那边有点麻烦。",
            Next = {NODE_1GA},
            DisplayConditions = {{
                {{ VarName = "Frog_PadRefused", VarType = "bool", Value = true }},
                {{ VarName = "Mouse_FrogFallbackGiven", VarType = "bool", Value = false }},
                {{ VarName = "MintFish_Obtained", VarType = "bool", Value = false }},
                {{ VarName = "Mouse_MintFishPaid", VarType = "bool", Value = true }},
            }},
        }},
        {{
            Text = "你不是说东西还在你手里吗？",
            Next = {NODE_1EC},
            DisplayConditions = {{
                {{ VarName = "MintFish_Obtained", VarType = "bool", Value = true }},
                {{ VarName = "Mouse_MintFishPitchShown", VarType = "bool", Value = true }},
                {{ VarName = "Mouse_MintFishPaid", VarType = "bool", Value = false }},
                {{ VarName = "Mouse_PremiumPoolUnlocked", VarType = "bool", Value = false }},
            }},
        }},
        {{
            Text = "没事了。",
            Next = -1,
        }},
    }},
    Next = -1
}}""",
    )

    # entry
    add_node(
        ENTRY,
        f"""DialogueConfig[{ENTRY}] = {{
    Type = "Normal",
    DocTag = "entry#0",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {{
        {{ VarName = "NGPlus", VarType = "bool", TrueNext = {NGPLUS}, FalseNext = 80 }},
    }},
    Next = 80
}}""",
    )
    add_node(
        80,
        f"""DialogueConfig[80] = {{
    Type = "Normal",
    DocTag = "entry#wall",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {{
        {{ VarName = "Mouse_FirstGreetShown", VarType = "bool", TrueNext = 95, FalseNext = {NODE_1A} }},
    }},
    Next = {NODE_1A}
}}""",
    )

    # NGPlus pool - minimal from md
    ng_lines = [
        ("鼠哥", "兜售", "还有没买的，自己来挑。"),
        ("鼠弟", "兜售", "奶酪够的话——"),
        ("鼠哥", "兜售", "够不够是他们的事。"),
    ]
    v1 = alloc()
    chain_lines(v1, ng_lines, -1)
    add_node(
        NGPLUS,
        f"""DialogueConfig[{NGPLUS}] = {{
    Type = "Normal",
    DocTag = "NGPlus",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    RotatePool = {{ {v1} }},
    Next = -1
}}""",
    )

    # mapping comment for controller
    cheap_entries = ", ".join(f"[{k}]={v}" for k, v in sorted(cheap_map.items()))
    prem_entries = ", ".join(f"[{k}]={v}" for k, v in sorted(premium_map.items()))

    header = f"""-- 老鼠兄弟 · 墙缝黑市（树状准稿）
-- Generated by scripts/build_laoshu_lua.py
-- Scene DialogueTrigger start ID = 0 (entry)
-- HUB={HUB} CHEAP_INTEL={{{cheap_entries}}}
-- PREMIUM_INTEL={{{prem_entries}}}

DialogueConfig = {{}}

"""
    body = "\n\n".join(nodes[k] for k in sorted(nodes.keys()))
    output = header + body + "\n"
    OUT.write_text(output, encoding="utf-8")
    RUNTIME_OUT.write_text(output, encoding="utf-8")
    print(f"Wrote {OUT} and {RUNTIME_OUT} ({len(nodes)} nodes)")


if __name__ == "__main__":
    main()
