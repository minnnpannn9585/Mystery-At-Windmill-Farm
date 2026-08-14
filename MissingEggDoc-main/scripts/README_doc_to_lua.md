# doc_to_lua.py — 树状 md → 台词草稿（辅助工具）

## 定位

**批量抄台词与简单结构**，不是一键产出可运行 lua。

生成稿通常 **缺少路由**（`DialogueConfig[0]`、intro→hub、hub 多回访 gate 等）。**生成后必须由 Agent 读 md §路由规则，直接在 lua 里接线路**，再 Publish / 点测。详见 [`docs/TREE_TO_LUA_SPEC.md`](../../docs/TREE_TO_LUA_SPEC.md) §1。

[`apply_routing.py`](./apply_routing.py) **已 deprecated**，勿再使用。

## 用法

```bash
# 大黄样章（历史：含 entry 链，仅大黄用 --with-entry）
python3 MissingEggDoc-main/scripts/doc_to_lua.py \
  --input MissingEggDoc-main/docs/characters/大黄-对话脚本-树状样章.md \
  --output Assets/Editor/DialogueData/FROM_DOC/dahuang_01_FROM_DOC.lua \
  --all --with-entry

# 新 NPC：只要内容层（默认 --no-entry）
python3 MissingEggDoc-main/scripts/doc_to_lua.py --no-entry \
  --input MissingEggDoc-main/docs/characters/淑芬-对话脚本-树状.md \
  --output Assets/Editor/DialogueData/FROM_DOC/shufang_01_FROM_DOC.lua \
  --sections "1-A,1-hub-intro,1-hub,1-B,1-C,1-D,1-E,1-F,1-G,2-A,3-A,NGPlus"

# 指定章节
python3 MissingEggDoc-main/scripts/doc_to_lua.py --no-entry \
  --input MissingEggDoc-main/docs/characters/大黄-对话脚本-树状样章.md \
  --output Assets/Editor/DialogueData/FROM_DOC/dahuang_01_FROM_DOC.lua \
  --sections "1-A,1-A',1-B,1-C"
```

**生成后必做（Agent）**

1. 对照 md §路由规则，在 lua 里接 entry / Next / hub gate（抄 `dahuang_01_FROM_DOC.lua`）。
2. `compare_doc_lua.py` 台词 missing=0。
3. Unity 导入无语法错误 → Publish → Scene 点测。

## 能生成什么

| 支持 | 说明 |
|------|------|
| `Normal` 对白链 | 解析 `玩家：` / `{NPC}：` / `描述：（…）` |
| `Question` hub | 【回访】+【菜单】→ **单个** Question + Options（多回访 hub 须手改） |
| `SetVariables` | 【变量】块 |
| `DisplayConditions` | 菜单行括号内条件（含 `>=`；`\|\|` 拆成多条 option） |
| `ConditionBranches` | 节点内【条件】分支 |
| `RotatePool` | 【轮播】变体 |
| `UnlockBranches` | 跨 NPC，见 [`cross_npc_map.json`](./cross_npc_map.json) |
| `DialogueConfig[0]` | **仅**大黄 `--with-entry` |

## 不生成 / Agent 手改

| 项目 | 原因 |
|------|------|
| entry 链、intro→hub、子项 bypass | 每 NPC 不同 → Agent 改 lua |
| hub 多回访（Status 1/2/3 + 子项短回访） | 需多个 Question + gate |
| 无 `###` 的 inline 节 | parser 可能漏 |
| Scene `DialogueTrigger` startID | Unity Inspector |
| NPCData 指向 `_FROM_DOC` | 测试接线 |

## 何时不用本脚本

节点少、结构特殊、或 parser 已对同一 md 失手两次 → **Agent 直接从 md 写 lua 更快**。见 `TREE_TO_LUA_SPEC.md` §1.1。

## 验收

```bash
python3 MissingEggDoc-main/scripts/compare_doc_lua.py \
  --input MissingEggDoc-main/docs/characters/{角色}-对话脚本-树状.md \
  --lua Assets/Data/DialogueData/FROM_DOC/{npc}_FROM_DOC.lua
```

- 台词 **missing = 0**（多文件 NPC 如小鸡 E03 须分开比）
- 路由 checklist（md 自检表）由 Agent 人工勾选
- 现有生产 lua（`dahuang_01.lua` 等）**不覆盖**

## 关联

- [`compare_doc_lua.py`](./compare_doc_lua.py) — 台词对照
- [`validate_lua_vars.py`](./validate_lua_vars.py) — 变量名校验
- [`docs/TREE_TO_LUA_SPEC.md`](../../docs/TREE_TO_LUA_SPEC.md) — 混合式生产规范
- [`docs/DIALOGUE_PIPELINE.md`](../../docs/DIALOGUE_PIPELINE.md) — 发布流程
