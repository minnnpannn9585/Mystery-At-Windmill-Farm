# Lua 对话文件 · 角色对照表

> **用途**：把拼音/缩写文件名对应到游戏内角色，避免改错脚本。  
> **数据路径**：运行时 `Assets/Data/DialogueData/` · 编辑源 `Assets/Editor/DialogueData/`  
> **树状生成稿**：`…/DialogueData/FROM_DOC/*_FROM_DOC.lua`（与定稿 `dahuang_01.lua` 等分开）  
> **NPC 分支注册**：`Assets/Data/GlobalData/NPCData_Config.lua`  
> **Scene 挂载**：`Mechanics_Code` → `DialogueData/{文件名}` DouyinScript

---

## 1.5 树状生成稿 `FROM_DOC/`

由 `doc_to_lua.py` + Agent 路由产出，**勿与定稿混放**：

| 文件 | NPC | 说明 |
|------|-----|------|
| `FROM_DOC/dahuang_01_FROM_DOC.lua` | 大黄 | 样章全量（替代旧 `dahuang_01~04`） |
| `FROM_DOC/shufang_01_FROM_DOC.lua` | 淑芬 | 委托 + hub（替代旧 `shufang_01`） |
| `FROM_DOC/xiaojiZTT_01_FROM_DOC.lua` | 小鸡侦探团 | 主交互（替代旧 `xiaojiZTT_01/02`） |
| `FROM_DOC/xiaojiZTT_e03_FROM_DOC.lua` | E03_Eavesdrop | 偷听（替代旧 `zttTouTing`） |
| `FROM_DOC/heimao_03_FROM_DOC.lua` | 黑猫 | 橡树下+揭穿+NGPlus（替代旧 `heimao_03`） |
| `FROM_DOC/heimao_tree_01_FROM_DOC.lua` | 大树 | ch1 轮播（替代旧 `heimao_01/02`） |
| `FROM_DOC/qingwa_01_FROM_DOC.lua` | 悲伤蛙 | 池塘+薄荷鱼（替代旧 `qingwa_01`） |
| `FROM_DOC/wuniu_01_FROM_DOC.lua` | 闪电蜗牛 | F-1～F-6 阶段锁（替代旧 `wuniu_01`） |

Scene 子物体名仍为 `luaModuleName`（无路径）；Publish 会同步 `Editor/…/FROM_DOC/` → `Data/…/FROM_DOC/`。

---

## 1. 拼音 / 缩写命名规则

前程序员用**汉语拼音**或**首字母缩写**命名文件，部分与标准拼音不一致（口音/笔误）：

| 文件名片段 | 实际含义 | 标准拼音参考 | 备注 |
|-----------|---------|-------------|------|
| `dahuang` | **大黄**（狗） | dà huáng | ✓ 一致 |
| `shufang` | **淑芬**（母鸡） | shū fēn | ⚠️ 应为 `shufen`，`ang/fen` 混用 |
| `heimao` | **黑猫** | hēi māo | ✓；也复用于「大树」NPC |
| `qingwa` | **青蛙** → 角色名 **悲伤蛙** | qīng wā | 文件名用动物名，NPC 用绰号 |
| `wuniu` | **蜗牛** → 角色名 **闪电蜗牛** | wō niú | ⚠️ 写成 `wuniu`，口语「乌牛」 |
| `wuya` | **乌鸦** | wū yā | ✓ 一致 |
| `xiaoji` | **小鸡** | xiǎo jī | 小鸡侦探团 |
| `ZTT` | **侦探团** | zhēn tàn tuán | 首字母缩写 |
| `TouTing` | **偷听** | tōu tīng | 场景 E03 偷听演出 |
| `miaosu` | **描述** | miáo shù | 旁白/系统叙述，非角色 |
| `_R1` `_R2` `_R3` | **回访**轮播分支 | huí fǎng | Random / Return 回访台词池 |

**特殊说话者**（出现在对话 `NpcName` 字段，不一定有独立 lua 文件）：

| NpcName | 含义 |
|---------|------|
| `玩家` | 小火人侦探（玩家） |
| `描述` | 旁白 / 动作描写 |
| `阿满` | 小鸡侦探团成员（hub 主声） |
| `米粒` | 小鸡侦探团成员 |
| `瓜子` | 小鸡侦探团成员 |
| `豆豆` | 小鸡侦探团成员；E03 偷听单独 NPC |
| `大树` | 大橡树交互（第一章黑猫伏笔，复用 heimao lua） |

---

## 2. 按角色汇总

### 大黄（狗）`dahuang_01_FROM_DOC.lua`

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `FROM_DOC/dahuang_01_FROM_DOC.lua` | 分支 1 | 树状全量（1-A~2-E、hub、NGPlus） | 点 **大黄** |
| `miaosu.lua` | —（属 **描述** NPC） | 环境叙述：缺梯、借梯流程 | E 点 / 描述触发，`npcname=描述` |

> 旧 `dahuang_01~04.lua` 已删除，由 FROM_DOC 单文件替代。

### 淑芬（母鸡）

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `FROM_DOC/shufang_01_FROM_DOC.lua` | 分支 1 | 委托、1-hub-intro 轮播、hub 菜单、1-B~G / 2-A / 3-A、NGPlus 一次性 + 轮播 | 点 **淑芬** |

> 旧 `shufang_01`、`shufang_02_R1/R2/R3` 已删除；回访轮播已并入 FROM_DOC 的 `1-hub-intro` RotatePool。

### 小鸡侦探团 `xiaojiZTT_*`

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `FROM_DOC/xiaojiZTT_01_FROM_DOC.lua` | 分支 1 | 主交互 + hub + NGPlus | 点 **小鸡侦探团** |

> 旧 `xiaojiZTT_01/02.lua` 已删除。

### 豆豆 / E03 偷听

| 文件 | NPCData 加载键 | 剧情说明 | Scene 触发 |
|------|---------------|---------|-----------|
| `FROM_DOC/xiaojiZTT_e03_FROM_DOC.lua` | **E03_Eavesdrop** | E03 身后偷听 | E03 `npcname=E03_Eavesdrop` |

> 旧 `zttTouTing.lua` 已删除。

### 黑猫 / 大树 `heimao_*`

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `FROM_DOC/heimao_03_FROM_DOC.lua` | 黑猫 分支 1 | 橡树下+揭穿+NGPlus | 点 **黑猫** |
| `FROM_DOC/heimao_tree_01_FROM_DOC.lua` | 大树 分支 1 | ch1 轮播 / 黑猫伏笔 | 点 **大树** |

> 旧 `heimao_01/02/03.lua` 已删除。

### 悲伤蛙（青蛙）

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `FROM_DOC/qingwa_01_FROM_DOC.lua` | 分支 1 | 2-A、2-hub 轮播+菜单、3-hub 薄荷鱼线、NGPlus | 点 **悲伤蛙** |

> 旧 `qingwa_01`、`qingwa_02`、`shufang_02`（误标氛围稿）已删除。

文件名 `qingwa` = 青蛙；游戏内 NPC 名 **悲伤蛙**。

### 闪电蜗牛 `wuniu_01_FROM_DOC.lua`

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `FROM_DOC/wuniu_01_FROM_DOC.lua` | 分支 1 | F-1～F-6 慢语速递进目击 + 二周目 meta | 点 **闪电蜗牛**（characters · startID=0）；**E32** 宽叶氛围 |

> 旧 `wuniu_01.lua` 已删除，由 FROM_DOC 单文件替代。

文件名 `wuniu` ≈ 蜗牛（口语）；角色名 **闪电蜗牛**。

### 老鼠兄弟 `laoshu_01_FROM_DOC.lua`

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `FROM_DOC/laoshu_01_FROM_DOC.lua` | 分支 1 | 墙缝 hub、盲盒情报、薄荷鱼/蛙兜底、NGPlus | 点 **老鼠兄弟 · 墙缝**（startID=0）；**E39** 强制 **0-A** |

经济侧：`CheeseCount` + `CheesePickup.lua`；商店路由 `MouseBrotherController.lua`。

### 乌鸦 `wuya_01_FROM_DOC.lua`

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `FROM_DOC/wuya_01_FROM_DOC.lua` | 分支 1 | entry#0 分发；谷仓底/攀爬喊话；屋顶对峙与 2-hub | 点 **乌鸦**（startID=0）；E06/E35/E36/E08/E10 等 |

### 描述（旁白）`miaosu.lua`

| 文件 | NPCData 分支 | 剧情说明 | Scene 触发 |
|------|-------------|---------|-----------|
| `miaosu.lua` | **描述** 分支 1 | 缺梯、借梯等环境叙述 | 多数 E 点，`npcname=描述` |

---

## 3. 尚未有独立 lua 的 NPC

| 角色 | 说明 |
|------|------|
| 米粒 / 瓜子 / 阿满 | 台词在 `xiaojiZTT_*` 内；已从 NPCData 删除空占位 |
| 玩家 | 无独立脚本；`NpcName=玩家` 散布各文件 |

---

## 4. 全文件速查表

| Lua 文件 | 主角色 | 注册 NPC | 分支 ID |
|----------|--------|---------|--------|
| `FROM_DOC/dahuang_01_FROM_DOC.lua` | 大黄 | 大黄 | 1 |
| `FROM_DOC/shufang_01_FROM_DOC.lua` | 淑芬 | 淑芬 | 1 |
| `FROM_DOC/xiaojiZTT_01_FROM_DOC.lua` | 小鸡侦探团 | 小鸡侦探团 | 1 |
| `FROM_DOC/xiaojiZTT_e03_FROM_DOC.lua` | E03 偷听 | **E03_Eavesdrop** | 1 |
| `FROM_DOC/heimao_03_FROM_DOC.lua` | 黑猫 | 黑猫 | 1 |
| `FROM_DOC/heimao_tree_01_FROM_DOC.lua` | 大树 | 大树 | 1 |
| `FROM_DOC/qingwa_01_FROM_DOC.lua` | 悲伤蛙 | 悲伤蛙 | 1 |
| `FROM_DOC/wuniu_01_FROM_DOC.lua` | 闪电蜗牛 | 闪电蜗牛 | 1 |
| `FROM_DOC/wuya_01_FROM_DOC.lua` | 乌鸦 | 乌鸦 | 1 |
| `miaosu.lua` | 描述 | 描述 | 1 |

---

## 5. Scene 中 `npcname` 触发对照

`DialogueTrigger` 的 Inspector 字段 `npcname` → 决定加载哪个 NPC 的 `currentBranchId` 分支：

| Scene `npcname` | 加载的 NPC 配置 | 典型 lua |
|----------------|----------------|---------|
| 大黄 | 大黄 | `dahuang_01_FROM_DOC` |
| 淑芬 | 淑芬 | `shufang_01_FROM_DOC` |
| 小鸡侦探团 | 小鸡侦探团 | `xiaojiZTT_01_FROM_DOC` |
| **E03_Eavesdrop** | E03 偷听 | `xiaojiZTT_e03_FROM_DOC` |
| 黑猫 | 黑猫 | `heimao_03_FROM_DOC` |
| 大树 | 大树 | `heimao_tree_01_FROM_DOC` |
| 悲伤蛙 | 悲伤蛙 | `qingwa_01_FROM_DOC` |
| 闪电蜗牛 | 闪电蜗牛 | `wuniu_01_FROM_DOC` |
| 乌鸦 | 乌鸦 | `wuya_01_FROM_DOC` |
| 描述 | 描述 | `miaosu`（或指定 ID 的其他描述段） |

环境 E 点多数设 `npcname=描述`，再配合起始节点 `ID` 跳转到对应对话段。

---

## 6. 已知命名问题（后续重构可参考）

1. **`shufang` → 淑芬**：标准拼音 `shufen`，`_fang` 为历史笔误，全套淑芬文件均受影响。
2. **`shufang_02.lua`**：内容属悲伤蛙，未进 NPCData；建议重命名为 `qingwa_00_intro.lua` 或类似。
3. **`heimao_*.lua` 绑大树**：黑猫第一章内容挂在「大树」NPC 上，文件名仍用 heimao。
4. **`qingwa` vs 悲伤蛙** / **`wuniu` vs 闪电蜗牛**：文件名用动物通名，NPC 配置用角色绰号。
5. **小鸡成员**（阿满/米粒/瓜子/豆豆）：无独立 lua；E03 偷听用加载键 `E03_Eavesdrop`，节点内仍写成员名。

---

## 7. 加载键 vs NpcName（Phase 1 规范）

| 层级 | 字段 | 示例 |
|------|------|------|
| **加载键** | `DialogueTrigger.npcname` = `NPCData.name` | `大黄` / `E03_Eavesdrop` |
| **显示键** | 节点 `NpcName` | `豆豆` / `阿满` / `描述` |

详见 [`DIALOGUE_PIPELINE.md`](./DIALOGUE_PIPELINE.md) §5。

---

*关联：[IMPLEMENTATION.md](./IMPLEMENTATION.md) · [NPCData_Config.lua](../Assets/Data/GlobalData/NPCData_Config.lua) · [06-角色与关系网](../MissingEggDoc-main/docs/06-角色与关系网.md)*
