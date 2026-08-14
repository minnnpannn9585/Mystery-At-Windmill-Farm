# 实现架构（Mechanics_Code）

> **用途**：代码侧技术地图，供开发者和 AI 快速理解「怎么跑」。  
> **策划文档**：玩法 / 叙事 / 变量语义见 [`MissingEggDoc-main/`](../MissingEggDoc-main/README.md)。  
> **主开发 / 可运行 Scene**：`Assets/Scenes/Mechanics_Code.unity`（Addressables 分组 `Mechanics_Code`，非传统 Build Settings 入口）。  
> **遗留**：`ArtTest_MRL.unity` 为早期美术白盒场景，新功能与点测以 Mechanics_Code 为准。

---

## 1. 技术栈

| 层级 | 技术 |
|------|------|
| 引擎 | Unity + URP 12.1.8 |
| 平台 | 抖音小火人 World SDK（`DouyinVCreateSDK`、`com.douyin.*` 本地包） |
| 游戏逻辑 | **Lua**（挂载于 `DouyinScript` 组件） |
| 对话 / 状态数据 | Lua 表（`DialogueConfig`、`GlobalVariables`、`NPCData`） |
| 编辑器 | C# 自定义窗口（对话图、NPC 管理） |
| 发布 | Addressables（`Assets/AddressableAssetsData/`，分组 **`Mechanics_Code`**） |

C# 业务脚本极少，主要是工具：`MeshCombiner`、`MergeModelToFbxExporter`、`EditorMeshCountChecker`、`DialogueGraphEditorWindow`、`NPCAssetManagerWindow`。

---

## 2. Scene 根节点结构

```
Mechanics_Code
├── Directional Light
├── Main Camera
├── Counter                 ← EditorMeshCountChecker（网格统计）
├── Combind                 ← MeshCombiner（子网格合并）
├── MianController          ← MainController.lua（隐藏 SDK 原生 UI）
├── DialogueManager         ← NpcDialogueManager.lua + 对话 UI
├── GlobalVariables         ← GlobalVariablesManager.lua + 配置 DouyinScript
├── Canvas                  ← 对话面板、侦探笔记本、调试 UI
├── characters              ← 可交互 NPC（挂 DialogueTrigger）
├── environment             ← 农场环境（谷仓 Garner、红顶屋等）
├── InteractionPoint        ← 环境线索 E 点（挂 ClueTrigger + DialogueTrigger）
└── DialogueData            ← 20 个子物体，各挂一份 DialogueConfig DouyinScript
```

### 2.1 角色（`characters`）

| 场景物体 | `npcname` | 备注 |
|---------|-----------|------|
| 大黄 | 大黄 | 另挂 `DaHuang.lua` 控制醉/醒模型与梯子 |
| 淑芬 | 淑芬 | 委托起点；`ShuFen.lua` 拖三点引用切换（二周目换「淑芬3」） |
| 黑猫 | 黑猫 | 第二章核心 |
| 悲伤蛙 | 悲伤蛙 | 池塘线；`BeiShangWa.lua` 拖两点引用，交薄荷鱼后切姿态 |
| 闪电蜗牛 | 闪电蜗牛 | 二周目 meta |
| 乌鸦 | 乌鸦 | 谷仓顶 |
| 小鸡侦探团 | 小鸡侦探团 | 第一章误导 |
| E03 偷听 | **E03_Eavesdrop** | 加载键；节点内 NpcName 仍为豆豆/阿满等 |

### 2.2 环境交互点（`InteractionPoint`）

典型挂载：

1. **`ClueTrigger.lua`** — 点击写入全局变量（E 点 bool / int）
2. **`DialogueTrigger.lua`** — 触发描述或 NPC 对话（`npcname` + 起始 `ID`）
3. **`DialogueAreaTrigger.lua`** — 进入 Trigger 区域**强制播**对话（不需按交互键；大树 1-A、老鼠 E39、乌鸦屋顶等复用）
4. 抖音网络组件（`NetGUID`）

**大树双阶段**（`InteractionPoint/TreeDialogue`）：

```
TreeDialogue          ← TreeInteractionController.lua（按变量切换 Force/Click）
├── TreeForceZone     ← DialogueAreaTrigger.lua + 大 BoxCollider(isTrigger)；1-A 强制播 startID=1
└── TreeClickZone     ← DouyinInteractor + DialogueTrigger(npcname=大树, ID=0)；1-B 点击轮播
```

`BlackCatInteractionController.lua` 挂 `characters/黑猫`：`!Dog_BlackCatSummoned` 时隐藏模型并禁用交互；摇树后启用。大黄 **2-B** 末节点 `ChainDialogue` 同链接力黑猫 **2-A**。

Scene 中已配置的 E 点变量示例：

`E01` 木炭 · `E02` 羽毛 · `E03` 偷听 · `E05` 谷物泡水 · `E06` 缺梯/借梯/架梯 · `E07` 午睡点 · `E08` 烧焦稻草 · `E09` 动物爪印 · `E10` 白石头 · `E12` 绿垫 · `E13`~`E18` 红顶屋外 · `E23` 踩水 · `E25` 鸡爪印 · `E27` 彩色反光 · `E28` 树抓痕 · `E34` 玻璃

完整 E 点策划说明见 [`13-玩家线索与交互点总表`](../MissingEggDoc-main/docs/13-玩家线索与交互点总表.md)。

### 2.3 对话数据（`DialogueData` 子物体）

```
dahuang_01 ~ dahuang_04
shufang_01, shufang_02, shufang_02_R1 ~ R3
heimao_01 ~ heimao_03
qingwa_01 ~ qingwa_02
wuniu_01_FROM_DOC, wuya_01_FROM_DOC
xiaojiZTT_01 ~ xiaojiZTT_02
zttTouTing, miaosu
```

---

## 3. Lua 模块职责

| 文件 | 挂载位置 | 职责 |
|------|---------|------|
| `GlobalVariablesManager.lua` | `GlobalVariables` | 启动加载变量、注册 `_G` API、重置 NPC 分支、调试 UI |
| `NpcDialogueManager.lua` | `DialogueManager` | 对话 UI、打字机、选项、条件分支、变量写入、分支解锁 |
| `DialogueTrigger.lua` | NPC / E 点 / 描述 | 按 `npcname` 加载对应分支对话并交给 Manager；暴露 `_G.StartNpcDialogue` |
| `DialogueAreaTrigger.lua` | 强制播 Trigger 区 | 进入 collider 自动 `StartNpcDialogue`（带变量 guard） |
| `TreeInteractionController.lua` | `TreeDialogue` | 大树 Force/Click 两阶段切换 |
| `BlackCatInteractionController.lua` | 黑猫 | 摇树前不可点，摇树后可点 |
| `ClueTrigger.lua` | E 点 | 点击写入 1~2 个全局变量 |
| `BookController.lua` | Canvas 笔记本 | 9.2.1 条目入册 + 9.2.2 连线/修饰；SetGlobalVar 实时刷新 |
| `DaHuang.lua` | 大黄 | 谷仓/红顶双点；醉醒模型与梯子 |
| `ShuFen.lua` | 淑芬 parent | 拖 `commissionSpot`/`hubSpot`/`ngPlusSpot`；只 SetActive 三个 Spot，不动 parent |
| `BeiShangWa.lua` | 悲伤蛙 parent | 拖 `beforeSpot`/`afterSpot`/`cushionSpot`（E12）；`MintFish_Obtained` 切换交鱼前后姿态与绿垫点 |
| `E03EavesdropController.lua` | `E03 · 身后偷听点` | `E03_Overheard \|\| ChickStatus>=3` 时 `DisableInteraction` |
| `MainController.lua` | `MianController` | 每帧隐藏 SDK 飞行按钮与聊天面板；注册 `PlayAudio`/`PlayParticle`。同房共场下 SFX 仅本机：共享 `OnPlayerTriggerEnter` 须先 `isLocal` 再 `PlayAudio`，禁止为远端玩家播 2D 游戏音效 |

路径：`Assets/luaScripts/`。

---

## 4. 运行时数据流

```
场景启动
  └─ GlobalVariablesManager.Start()
       ├─ 从 GlobalVariables.lua 初始化 ~90 个变量到内存
       ├─ ResetAllNPCBranchesToStart()（所有 NPC currentBranchId → 1）
       └─ 注册 _G：GetGlobalVar / SetGlobalVar / _GlobalVariables / _NPCDataConfig

玩家点击
  ├─ ClueTrigger.SetClue()  → SetGlobalVar(E点变量)
  └─ DialogueTrigger.StartDialogue()
       ├─ 查 NPCData_Config：npc.name → currentBranchId → luaAssetPath
       ├─ GameObject.Find("DialogueData").Find(模块名) → DouyinScript.DialogueConfig
       └─ _DialogueManager.StartDialogueWithData(config, startID)

对话节点 UpdateDialogueUI()
  ├─ ApplySetVariables()      → 写全局变量
  ├─ CheckAndUnlockBranch()   → 改 NPC currentBranchId
  ├─ Normal：打字机 → Next → GetNextNodeByCondition() 或 Next
  └─ Question：DisplayConditions 过滤选项 → 玩家选 → PerformOptionJump()

SetGlobalVar / 打开笔记本
  └─ BookController_OnVarChanged → ENTRY_DEFS 条件检查 → 渐显 entry_* → link_* / mod_*
```

### 4.1 全局变量 API

```lua
GetGlobalVar(name)           -- 读值，不存在返回 nil
SetGlobalVar(name, value, type)  -- 写值，type 为 "bool" 或 "int"
GetGlobalVarType(name)       -- 返回 "bool" / "int"
_G["_GlobalVariables"]       -- 内存字典 { name = { type, value } }
```

定义文件：`Assets/Data/GlobalData/GlobalVariables.lua`  
变量语义对照：[`17-全局游戏状态变量`](../MissingEggDoc-main/docs/17-全局游戏状态变量.md)

**注意**：`ClueTrigger.Awake()` 会将所有 **bool 变量重置为 false**。适合测试；正式存档需另做持久化。

### 4.2 对话节点字段（DialogueConfig）

| 字段 | 说明 |
|------|------|
| `Type` | `"Normal"` 普通对白 / `"Question"` 玩家选项 |
| `NpcName` | 说话者（`"玩家"` / `"描述"` / NPC 名） |
| `NpcSprite` | 头像 key，或从 NPC `avatarPath` 解析 |
| `Dialogue` | 文本 |
| `Next` | 下一节点 ID，`-1` 结束对话 |
| `Options` | Question 选项列表 |
| `Options[].DisplayConditions` | 选项显示条件（AND） |
| `Options[].ConditionBranches` | 选项内条件分支 |
| `ConditionBranches` | 节点级条件分支（bool true/false 或 int 比较） |
| `SetVariables` | 节点执行时写入的全局变量 |
| `UnlockBranches` | `{ NpcName, BranchId }` 解锁 NPC 新分支 |

### 4.3 NPC 分支机制

1. `NPCData_Config.lua` 中每个 NPC 有 `currentBranchId` 和 `storyGraphs[]`
2. 对话节点的 `UnlockBranches` 在运行时修改对应 NPC 的 `currentBranchId`
3. 下次点击该 NPC，`DialogueTrigger` 加载新分支对应的 lua 文件

NPC 配置：`Assets/Data/GlobalData/NPCData_Config.lua`

---

## 5. Editor → Runtime 数据管线

```
DialogueGraphEditorWindow（可视化编辑）
    ↓ 导出
Assets/Editor/DialogueData/*.lua          ← 编辑源
    ↓ Tools/Egg Rescue/Publish Editor to Data
Assets/Data/DialogueData/*.lua            ← 运行时副本
    ↓ 挂到 Scene
DialogueData/{模块名} 上的 DouyinScript

NPCAssetManagerWindow（菜单：抖音虚拟创作SDK / NpcEditor）
    ↓ 导出
Assets/Editor/EditData/NPCData_Config.lua
Assets/Editor/EditData/GlobalVariables.lua
    ↓ Publish
Assets/Data/GlobalData/NPCData_Config.lua
Assets/Data/GlobalData/GlobalVariables.lua
    ↓ 挂到
GlobalVariables 物体上的 DouyinScript
```

### 5.1 一键发布

Unity 菜单 **`Tools/Egg Rescue/Publish Editor to Data`**（`EggRescuePublishMenu.cs`）：

1. 复制 `Editor/DialogueData/*.lua` → `Data/DialogueData/`
2. 复制 `Editor/EditData/NPCData_Config.lua` → `Data/GlobalData/`，去掉 leading `local `
3. 复制 `Editor/EditData/GlobalVariables.lua` → `Data/GlobalData/`，去掉 `local` + `return`

可选：**`Tools/Egg Rescue/Refresh Scene DialogueData`** — 刷新 Scene 中 DialogueData 子物体。

### 5.2 发布 Checklist

| 步骤 | 动作 |
|------|------|
| 1 | 对话图导出到 `Assets/Editor/DialogueData/` |
| 2 | NPC / 变量保存到 `Assets/Editor/EditData/` |
| 3 | 执行 **Publish Editor to Data** |
| 4 | `python3 MissingEggDoc-main/scripts/validate_lua_vars.py` |
| 5 | （大改）Refresh Scene DialogueData |
| 6 | **Mechanics_Code** 点测 |
| **7** | **`NpcDialogueManager.lua`：`DIALOGUE_DEBUG = false`**（打包 / Addressables 发布前） |

完整流程见 [`DIALOGUE_PIPELINE.md`](./DIALOGUE_PIPELINE.md)。

### 5.4 对话调试日志（World Debugger）

排查 1-A→1-A′ 等分支问题时，在 **World Debugger → 调试** 面板搜 `[Dialogue]`、`[DialogueLoad]`（不是 Unity Play Console）。

| 位置 | 说明 |
|------|------|
| [`Assets/luaScripts/NpcDialogueManager.lua`](../Assets/luaScripts/NpcDialogueManager.lua) L49 `local DIALOGUE_DEBUG = true` | 开发设 `true`；**打包前必改 `false`** |
| 同文件 `Dbg()` / `DbgError()` | 进入节点、Leave 分支、SetVar、结束原因 |
| [`Assets/luaScripts/DialogueTrigger.lua`](../Assets/luaScripts/DialogueTrigger.lua) | `[DialogueLoad]` 加载 script / branchId / startID（无开关，一直 print） |
| Canvas ShowBtn（`GlobalVariablesManager`） | 查 `DogStatus` 等变量实时值 |

日志中的 `DocTag=1-A#10` 需对话 lua 含 `DocTag` 字段（`dahuang_01_FROM_DOC.lua` 等 doc 生成物）。

### 5.3 加载键命名（Phase 1）

| 层级 | 字段 | 规范 |
|------|------|------|
| **加载键** | `DialogueTrigger.npcname` = `NPCData.name` | 可点击 NPC → 中文名；环境/偷听 → `E{nn}_{Action}` |
| **显示键** | 节点 `NpcName` | 叙事说话人，与加载键无关 |

E03 偷听：`npcname=E03_Eavesdrop`，`zttTouTing.lua` 内容不变。

**改对话流程**：编辑对话图 → 导出 lua → **Publish** → （可选）Refresh Scene。

**改变量流程**：改 [doc 17](../MissingEggDoc-main/docs/17-全局游戏状态变量.md) → 改 `Editor/EditData/GlobalVariables.lua` → 改对话 / ClueTrigger → **Publish** → 跑 `validate_lua_vars.py`。

---

## 6. 侦探笔记本（BookController）

挂载：`Canvas/Notebook` · [`BookController.lua`](../Assets/luaScripts/BookController.lua)

### 壳层 UI（7）

| 字段 | 用途 |
|------|------|
| `open` | 入口按钮 |
| `openRedDot` | 有新条目入册且面板关闭时显示 |
| `boolPanel` | 笔记本面板根 |
| `pageContents` | 翻页底板（含第 4 页老鼠情报） |
| `page1TabBtns` … `page4TabBtns` | 各页底部页签（Button[4]，元素 i→第 i+1 页；本页槽位可空） |

### 9.2.1 主线条目（33 个 `entry_*`）

触发条件在 `BuildCatalog()` 的 `ENTRY_DEFS`，与 [`09` §9.2.1](../MissingEggDoc-main/docs/09-侦探笔记本.md) 一致。

### 老鼠情报（第 4 页 · 动态 prefab）

- `intelCheapPrefab` / `intelPremiumPrefab`：购入时实例化
- `intelLayoutLeft` / `intelLayoutRight`：先左后右堆叠（`intelLeftColumnMax` 默认 9）
- 变量 `Mouse_CheapSold_##` / `Mouse_PremiumSold_##` → §9.5 内文

### 9.2.2 关联符

- **连线** `link_D03_D04` 等 15 个：双端条目均已入册时 `SetActive(true)`
- **修饰** `mod_D03_strike` 等 13 个：按 §9.2.2 变量条件或「某条目入册」（如 D09→D03 划掉）点亮；晚入册时 `ReconcileLinksAndMods` 补全

### 数据流

```
SetGlobalVar（对话 / ClueTrigger / 老鼠商店）
  → BookController_OnVarChanged
  → CheckAllEntries（条件满足则渐显 entry_*）
  → ReconcileLinksAndMods（link_* / mod_*）
```

- 条件语法：`&` AND、`|` OR；`VarName==true`、`VarName>=2` 等
- 入册演出：解锁后保持 alpha=0；打开本子 / 翻页到该页时（`ShowCurrentPage`）播 1s 渐显 + 一次 alpha 闪烁
- `E10` 入册：自动 `currentIndex = 2`（翻到第二页）

完整 Inspector 字段名对照表见 [`09` §9.8](../MissingEggDoc-main/docs/09-侦探笔记本.md#98-inspector-接线对照bookcontroller)（与 `BookController.lua` `---@var` 一一对应）。

---

## 7. 策划文档 vs 代码现状

| 模块 | 策划文档 | 代码状态 |
|------|---------|---------|
| 对话框架（分支/质询锁/变量） | 16、17、18 | ✅ 已实现 |
| 主要 NPC 对话树 | characters/* | ✅ 大黄/淑芬/黑猫/蛙/乌鸦/小鸡等 |
| 环境 E 点 | 13 | ✅ Scene 已挂 ClueTrigger |
| 侦探笔记本 | 09 | ✅ 33 主线条目 + 老鼠 prefab 动态生成 + 15 连线 + 13 修饰 |
| 全局变量表 | 17 | ✅ GlobalVariables.lua 基本对齐 |
| 存档持久化 | — | ❌ 仅内存，重启丢失 |
| 奶酪碎经济 `CheeseCount` | 13 §13.5 | ✅ 48 个场景散点 + HUD + 一/五/八块商店扣费 |
| 老鼠兄弟对话 | 老鼠兄弟-* | ✅ 墙缝 hub、盲盒情报、薄荷鱼付费/免费开池、蛙兜底 |
| 漫画收束 `Comic_Revealed` | 漫画收束-* | ❌ 变量已定义，无 E20 演出 |
| 二周目 `NGPlus` | 07 §7.4 | ⚠️ 变量已定义，部分 NPC 树未完整 |
| 平台跳跃硬闸 | 03、08 | ⚠️ 场景有几何，逻辑主要靠 E 点变量 |

---

## 8. 典型第一章链路（代码视角）

1. 点 **淑芬** → `shufang_01` 分支 1 → `Shufen_CommissionDone=true`，UnlockBranches → 淑芬分支 2
2. 调查 **E01/E02/E03** → ClueTrigger 写入 → 间接推高 `ChickTraceCount`
3. 点 **小鸡侦探团** → `xiaojiZTT_02` hub → `ChickTraceCount>=2` 时显示质询选项 → `ChickStatus=2`
4. 点 **大黄** → `dahuang_01` → `DogStatus=2`
5. **E06** 发现缺梯 → `E06_ViewNeedLadder=true`
6. 大黄分支 2/3 → 借梯/醒酒 → `E06_LadderBorrowed=true` → `DaHuang.lua` 切换模型
7. 谷仓顶 **E10** 等 → 对应 `entry_*` 渐显；E10 自动翻到第二页
8. 进入第二章 → 红顶屋外 E13~E18 → 黑猫线 → 薄荷鱼线 → （漫画收束待实现）

详细步骤见 [`07-关卡与内容结构`](../MissingEggDoc-main/docs/07-关卡与内容结构.md)。

---

## 9. 关键文件索引

| 用途 | 路径 |
|------|------|
| **Lua 文件 ↔ 角色对照（含拼音解码）** | [`docs/DIALOGUE_INDEX.md`](./DIALOGUE_INDEX.md) |
| 可运行 Scene | `Assets/Scenes/Mechanics_Code.unity` |
| 运行时 Lua 逻辑 | `Assets/luaScripts/*.lua` |
| 全局变量定义 | `Assets/Data/GlobalData/GlobalVariables.lua` |
| NPC 配置 | `Assets/Data/GlobalData/NPCData_Config.lua` |
| 对话数据（运行时） | `Assets/Data/DialogueData/*.lua` |
| 对话数据（编辑源） | `Assets/Editor/DialogueData/*.lua` |
| NPC / 变量（编辑源） | `Assets/Editor/EditData/` |
| 对话图编辑器 | `Assets/Editor/DialogueGraphEditorWindow.cs` |
| NPC 编辑器 | `Assets/Editor/NPCAssetManagerWindow.cs` |
| 一键发布 | `Assets/Editor/EggRescuePublishMenu.cs` |
| 对话管线手册 | [`docs/DIALOGUE_PIPELINE.md`](./DIALOGUE_PIPELINE.md) |
| doc→lua 试点 | `MissingEggDoc-main/scripts/doc_to_lua.py` |
| 变量校验 | `MissingEggDoc-main/scripts/validate_lua_vars.py` |
| Addressables 配置 | `Assets/AddressableAssetsData/` |
| 策划文档库 | `MissingEggDoc-main/docs/` |

---

## 10. 开发备忘

- Scene 物体名 `MianController` 为历史拼写，脚本为 `MainController.lua`。
- `DialogueTrigger` 通过 `GameObject.Find("DialogueData")` 查找对话数据，Scene 中该节点名不可改。
- `_DialogueManager` 在 `NpcDialogueManager.Awake()` 注册；`DialogueTrigger.Start()` 会检查其是否存在。
- 对话进行中会 `DouyinUIService.SetUIVisible(false)`，结束后恢复。
- 测试全局变量：Scene 内 Canvas 调试区 `ShowBtn` / `SearchBtn` / `InfoText`。

---

*最后更新：2026-06-29 · 主开发 Scene：Mechanics_Code*
