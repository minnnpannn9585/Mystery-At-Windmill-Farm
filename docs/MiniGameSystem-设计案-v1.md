# MiniGameSystem 设计案 v1（待逐条审查）

> **已被 v2 取代**：正式版见 `MiniGameSystem-技术文档-T1至T7.docx`（v2.1，评审后取消分册制，本文件升级为 MiniGameSystem 唯一技术文档；T1 定稿、T2 初稿）。本 md 保留作为框架草案的历史记录。

> 依据：[19-关键线索调查解谜](../MissingEggDoc-main/docs/19-关键线索调查解谜.md)、[20-典型玩家完整游玩流程](../MissingEggDoc-main/docs/20-典型玩家完整游玩流程.md)、[09-侦探笔记本](../MissingEggDoc-main/docs/09-侦探笔记本.md)、[17-全局游戏状态变量](../MissingEggDoc-main/docs/17-全局游戏状态变量.md)、[13-玩家线索与交互点总表](../MissingEggDoc-main/docs/13-玩家线索与交互点总表.md)
>
> 本文只做方案，不改工程代码。审查通过后按 §10 分期落地。

---

## 0 审查清单（请逐条打勾）

| # | 章节 | 审查关注点 |
|---|---|---|
| A | §1 目标与边界 | 交互定位、是否允许改原对白 |
| B | §3 统一 UI 骨架 | 区域坐标、风格是否与 Notebook 一致 |
| C | §4 七种模板 T1–T7 | 操作手法、判定阈值、提示分级 |
| D | §5 19 局映射表 | 入口点、提交变量、笔记本条目是否对得上 |
| E | §6 与笔记本融合 | 入册反馈链路、是否要新增笔记本 UI |
| F | §7 程序框架 | 类结构、存档、对话接入方式 |
| G | §8 接入改造清单 | 要改哪些现有组件 |
| H | §10 分期落地 | 先做哪几局、验收口径 |

---

## 1 目标与边界

### 1.1 目标

给每个关键线索加一局 5–40 秒的 2D 独立交互。成功才发线索、自动入册，然后接回原流程。

### 1.2 硬边界（来自 19 文档，不自行放宽）

| 项 | 规定 |
|---|---|
| 时限 | 无倒计时 |
| 失败惩罚 | 无。无生命、无次数限制、不扣奶酪 |
| 提示 | 两级（一级给方向，二级高亮目标），玩家仍须自己完成最后一步 |
| 退出 | 随时可退，保留本局进度；线索不提前发 |
| 工具 | 由当局界面提供，无工具背包、无工具购买 |
| 奖励 | 不发奶酪 |
| 笔记本职责 | **只被动记录与回看**，不承载启动谜题或答题 |
| 对白 | 原文完整播放，不删改、不压缩 |
| 剧情闸 | 借梯/架梯/叫醒/摇树/取鱼/交还等原有动作不被替代 |

### 1.3 七种模板定位

| 代码 | 模板 | 主用途 | 复用局数 |
|---|---|---|---|
| T1 | 放大镜调查 | 找局部细节差异 | 4（Q06/Q09/Q11/Q14） |
| T2 | 拨开遮挡 | 拖开遮挡物露出目标 | 2（Q10/Q12 前半） |
| T3 | 翻转查验 | 换角度/翻面看另一侧 | 4（Q02/Q12 后半/Q15/Q18） |
| T4 | 观察图拼合 | 6 块拼图 + 方向判断 | 1（Q19） |
| T5 | 痕迹拓印 | 按住涂出覆盖区 | 1（Q17） |
| T6 | 镊取物证 | 夹取→拖入观察区 | 2（Q03/Q16） |
| T7 | 证词要点归位 | 卡片拖入槽位 | 6（Q01/Q04/Q05/Q07/Q08/Q13） |

---

## 2 全局架构总览

```
[3D 场景]  E 点交互 / 对话节点末尾
      │
      ├─ MiniGameClueTrigger（环境物证）────┐
      └─ MiniGameDialogueHook（证词）──────┤
                                            ▼
                                  MiniGameHost（单例 / 门面）
                                  ├ 打开局：MiniGameRegistry 取 Def
                                  ├ 暂停 3D 与输入（复用 GameEvents.SetPaused）
                                  ├ 调用对应模板 Board 构建 UI
                                  ├ 订阅 Board.OnSubmit → 统一提交
                                  └ 待完成记录持久化
                                            │
                    ┌───────────────────────┼───────────────────────┐
                    ▼                       ▼                       ▼
          T1..T7 Board（各一控制器）   MiniGameDef（19 条数据）  MiniGameSave（存档）
                    │
                    ▼
          OnSubmit(def)
                    │
                    ├─ GameState.SetBool(def.Var, true)   ← 唯一写入口
                    ├─ 计数追加（ChickTraceCount / TreeClueCount）
                    └─ GameEvents.RaiseVariableChanged（已有）
                                            │
                                            ▼
                                  BookController（不改）
                                  ├ CheckAllEntries → Unlock
                                  ├ QueueReveal：淡入 + blink
                                  ├ 红点 + 图标弹跳 + 音效
                                  ├ 连线 / 修饰 / 翻页（已有逻辑）
                                  └ 抽屉（D12/D13…）自动补
```

**核心结论：笔记本侧零改动。** 现有 `BookController` 已实现「变量变化 → 解锁 → 淡入 + 红点 + 弹跳 + 音效 + 连线 + 翻页」全链，小游戏只需在成功时写对变量。

---

## 3 统一 UI 骨架

### 3.1 参考尺寸

`CanvasScaler`：ScaleWithScreenSize，`1920 × 1080`，`matchWidthOrHeight = 0.5`（与 `PauseMenu` 一致）。所有板共用同一套骨架，只替换主操作区内容与工具。

### 3.2 区域划分（美术坐标，y 自顶部向下）

| 区域 | x | y | 内容 |
|---|---|---|---|
| 顶栏 | 0–1920 | 0–96 | 左「← 返回调查」；中标题；右「操作帮助」 |
| 目标句 | 115–1400 | 96–168 | 一句操作指令，如「移动放大镜，找到两处异常」 |
| 主操作区 | 115–1400 | 216–853 | 对象、可动层、拖动余量、背景色块 |
| 右侧进度 | 1498–1805 | 238–756 | 发现进度 N/M、已确认局部缩略、完成勾 |
| 底部工具区 | 115–1920 | 950–1058 | 工具、复位、手势说明 |
| 提示 | 1610–1900 | 900–944 | 一级/二级提示按钮；证词局加「重听这一段」 |

Unity `RectTransform` 换算（anchor 左上角，`anchoredPosition` 相对父级中心）：

```
x_center = X + W/2 − 960
y_center = 540 − Y − H/2
```

### 3.3 视觉规范（19.7）

| 项 | 值 |
|---|---|
| 晴天蓝 | `#26A9FF` |
| 鲜草绿 | `#65D443` |
| 深叶绿 | `#24A348` |
| 奶油白 | `#FFF8DE` |
| 亮黄 | `#FFD447` |
| 珊瑚屋顶 | `#EF7849` |
| 深蓝文字/轮廓 | `#194D65` |

约束：封闭轮廓 + 有限纯色面 + 硬边明暗；**禁用**渐变、噪点、纸张纹理、铅笔质感、写实材质、灰暗滤镜、笔记本底板。字体用项目 `UiFontCatalog.Load()`（MiSans）。

### 3.4 与 Notebook 的视觉一致性

| 元素 | 复用 Notebook 现有值 |
|---|---|
| 纸底 | `Paper (1, .985, .95)` |
| 描边 | `Outline 2px, (0.60,0.53,0.40)` |
| 标题字 | 深蓝 `(0.16,0.27,0.36)`，加粗 |
| 完成勾 | 绿 `(0.31,0.69,0.36)` |
| 卡片圆角 | 沿用 NoteBook 卡片同一 sprite（`Res/Sprites/BiJiBen` 内） |

### 3.5 热区下限

点击热区 ≥ `64×64`，拖入落区 ≥ `96×96`。细小目标（毛尖、草尖）图形可小，但热区必须放大到 64。

### 3.6 通用状态机

```
Enter(手势示意 1 次)
   ↓ 玩家首次点击/拖动
Play ──错误→ Feedback(轻弹/「再观察一下」) → Play
   │
   ├─ 提示1 → 文案（不改变操作）
   ├─ 提示2 → 高亮目标（玩家仍须完成动作）
   ├─ 返回 → Exit（保留进度，不提交）
   ├─ 复位 → Reset（只清未确认项）
   └─ 全部目标完成 → Complete（先演完成反馈 0.6s）
                        ↓
                     Submit（一次性写变量 + 计数）
                        ↓
                     ReturnToSource（原对白出口 / 原环境点）
```

---

## 4 七种交互模板

> 概念图见 `MissingEggDoc-main/docs/images/investigation-puzzles/`，本节给实现级操作与判定。

### T1 放大镜调查

**概念图**：`01-magnifier-flat.png`（E08 浅焦痕）

| 项 | 定义 |
|---|---|
| 手势 | 镜片跟随指针移动；镜内 2.0–2.6× 放大当前局部；点击确认 |
| 目标 | 2 处（个别 1 处），各带独立命中半径 |
| 判定 | 镜片中心进入目标热区（归一化距离 < R）且左键点击 → 确认 |
| 干扰 | 普通材质点击只给「轻反馈」，不打勾、不报错文案 |
| 进度 | 右侧槽：未发现=灰底「？」，已发现=绿底「✓」+ 名称 |
| 提示1 | 描述目标方位（如「看末端的颜色」） |
| 提示2 | 目标轮廓虚线高亮 |
| 输出 | 全部确认 → 绿色横幅「已找齐线索」→ 提交 |
| 复用 | Q06 绿垫 / Q09 泡水 / Q11 焦痕 / Q14 猫门 |

**镜片边界**：走出主操作区时钳制在安全边界（不丢失、不穿透到 UI 区）。

### T2 拨开遮挡

**概念图**：`02-uncover-flat.png`（E10 白石，前段）

| 项 | 定义 |
|---|---|
| 手势 | 拖动可动草束到停放区（左侧） |
| 目标 | 清理阶段 N/N（Q10=2 束，Q12=3 束） |
| 判定 | 草束拖动位移超过阈值（≥ 自身宽 60%）→ 吸附入停放区，计 1 |
| 松手未过阈值 | 弹回原位 |
| 背景草 | 不可拖，只给轻反馈 |
| 清理完成后 | 才允许确认被露出的目标（Q10：压痕 + 细毛；Q12：转 T3） |
| 提示1 | 「从草窝前缘露出的两端向外拨」 |
| 提示2 | 高亮未移草束 + 箭头方向 |
| 输出 | 清理 N/N + 目标确认 M/M → 提交 |

### T3 翻转查验

**概念图**：`03-rotate-flat.png`（E17 空桶）

| 项 | 定义 |
|---|---|
| 手势 | 水平/垂直拖动 → 对象在两个观察面之间转动（角度插值 + 吸附到 2 个停靠位） |
| 目标 | 2 处，分属两个面 |
| 判定 | 处于 A 面才能确认 A 目标；处于 B 面才能确认 B 目标 |
| 吸附 | 拖动超过 50% 行程 → 吸附到对面；否则回到原位 |
| 目标面互斥 | 在错误面点击目标 → 「再观察一下」 |
| 提示1 | 「一处在它自己身上，一处留在它碰过的草上」 |
| 提示2 | 显示翻转箭头 + 高亮尚缺目标 |
| 复用 | Q02 木炭（炭尖/草上炭粉）、Q15 食碗（碗沿/碗底）、Q18 空桶（内部/桶底泥沙）、Q12 后半（爱心/鬼脸） |

### T4 观察图拼合

**概念图**：`04-jigsaw-flat.png`（E18 雨靴脚印）

| 项 | 定义 |
|---|---|
| 布局 | 左 3 列 × 2 行拼合框；右侧 6 块待放图块打乱 |
| 图块 | 固定朝向、同尺寸，不可旋转；正确格吸附，错误格弹回 |
| 阶段1 | 6/6 归位 |
| 阶段2 | 切换为完整现场小图，出现「朝鸡舍 / 朝红顶屋」选择 |
| 判定 | 6/6 且选「朝鸡舍」 → 成功 |
| 提示1 | 「先接上斜向宽鞋底纹，再对齐地面色块边界」 |
| 提示2 | 高亮一块未归位图 + 正确格；阶段2 高亮朝鸡舍箭头 |
| 复用 | 仅 Q19 |

### T5 痕迹拓印

**概念图**：`05-rubbing-flat.png`（E28 树根抓痕）

| 项 | 定义 |
|---|---|
| 布局 | 主区树根 + 奶油白取样薄纸；纸下 3 段揭露区；右侧 3 组进度 |
| 手势 | 按住炭条在纸上拖动；经过路径留下深蓝拓痕 |
| 判定 | 每段揭露区**被覆盖 ≥ 80%** → 该段完成；3/3 完成即成功 |
| 实现 | 每段维护一张低分辨率遮罩（如 128×128），笔刷半径写入；覆盖率 = 已覆盖像素 / 目标区像素 |
| 纸外拖动 | 不落色 |
| 提示1 | 「用长一点的笔触，依次涂过三段」 |
| 提示2 | 虚线标出未达 80% 的区 |
| 复用 | 仅 Q17（炭条由 UI 提供，不要求先拿 E01） |

### T6 镊取物证

**概念图**：`06-tweezers-flat.png`（E16 兽毛）

| 项 | 定义 |
|---|---|
| 两段进度 | ① 夹起 ② 放入观察区 |
| 手势 | 点镊子 → 夹住目标（放大显示）；拖到观察区松手 |
| 判定 | 夹住正确目标 → 1/N；拖入落区（≥96×96）→ 2/N |
| Q03 特化 | 3 根独立目标，各自「夹起→入盘」，共 3/3；盘有 3 个宽松落点，落点任意 |
| 错误 | 夹到草叶/石子 → 原位轻晃；拖到盘外 → 回到来源 |
| 提示1 | 「找弯弯的、边缘蓬松的黄色小毛，草叶更平直」 |
| 提示2 | 高亮一根未收取目标 + 观察盘 |
| 复用 | Q03 黄绒毛 / Q16 兽毛 |

### T7 证词要点归位

**概念图**：`07-testimony-flat.png`（D01 委托）

| 项 | 定义 |
|---|---|
| 布局 | 左：现场插画；右：N 个槽；底：M 张卡（含干扰卡） |
| 手势 | 拖卡入槽；吸附后保留文字；可点「重听这一段」 |
| 判定 | 每槽匹配正确卡 → 计 1；干扰卡应留在待选区 |
| 多卡槽 | Q13 允许一槽多卡，按叙述顺序自动排齐 |
| 卡数 | Q01=3 卡 2 槽（1 干扰）；Q04/Q05/Q07/Q08=3 卡 3 槽；Q13=3 卡 2 槽 |
| 错误 | 错槽卡弹回待选区 |
| 提示1 | 复述要点 |
| 提示2 | 高亮正确卡 + 目标槽 |
| 输出 | 全部正确 → 提交原节点变量 + 原出口 |

---

## 5 19 局 → 模板映射表

> 变量名与笔记本条目严格照 17 / 09 文档；「提交」= 成功时一次性写入。

### 第一章

| 局 | 入口 | 模板 | 目标 | 提交变量 | 入册条目 | 原出口 |
|---|---|---|---|---|---|---|
| Q01 | 淑芬 1-A 播毕 | T7 | 2 槽 3 卡（1 干扰） | `Shufen_CommissionDone=true` | D01 | 淑芬 1-hub |
| Q02 | E01 木炭 | T3 | 2 处（炭尖/草上炭粉） | `E01_ViewCharcoal=true` + `ChickTraceCount+1` | E01 | E01 原结束点 |
| Q03 | E02 羽毛碎片 | T6 | 3 根 | `E02_ViewFeather=true` + `ChickTraceCount+1` | E02 | E02 原结束点 |
| Q04 | E03 偷听 1-A 播毕 | T7 | 3 槽 3 卡 | `E03_Overheard=true` + `ChickTraceCount+1` | D02 | 对话结束 |
| Q05 | 小鸡 2-B 播毕 | T7 | 3 槽 3 卡 | `ChickStatus=2` | D03 | 小鸡 2-hub |
| Q06 | E12 绿边 / 蛙 3-A 补录 | T1 | 2 处 | `E12_ViewGreenPad=true` | E12（D13 自动补） | E12 原结束点 / 3-A |
| Q07 | 蛙 2-D 播毕 | T7 | 3 槽按顺序 | `Frog_WaterMonsterQueried=true` | D04+D05+D06 同批 | 蛙 2-hub |
| Q08 | 大黄 1-A 播毕 | T7 | 3 槽 3 卡 | `DogStatus=2`（E04/D07 同批） | E04 + D07 | 大黄 1-A′ |
| Q09 | E05 水槽 | T1 | 2 处 | `E05_GrainSoakGet=true` | E05（D08 加 ✓get） | E05 原出口 |
| Q10 | E07 草窝 | T2 | 拨 2 束 + 2 确认 | `E07_ViewNapSpot=true` | E07 | E07 原出口 |
| Q11 | E08 稻草皮毛 | T1 | 2 处 | `E08_ViewBurnMark=true` | E08 | E08 原出口 |
| Q12 | E10 白石头 | T2→T3 | 拨 3 束 + 双面 2 处 | `E10_ViewWhiteStone=true` | E10（D07 划掉+旁注） | 乌鸦 2-B → 2-hub |
| Q13 | 小鸡 2-E / 2-G 播毕 | T7 | 2 槽 3 卡（一槽多卡） | `ChickStatus=3`（2-G 时补 D03） | D09（D03 划掉） | 小鸡 2-hub |

### 第二章

| 局 | 入口 | 模板 | 目标 | 提交变量 | 入册条目 | 原出口 |
|---|---|---|---|---|---|---|
| Q14 | E14 猫门 | T1 | 2 处（锁扣/磨亮边） | `E14_ViewCatDoor=true` + `TreeClueCount+1` | E14 | E14 原出口 |
| Q15 | E15 食碗 | T3 | 2 处（碗沿/碗底） | `E15_ViewFoodBowl=true` + `TreeClueCount+1` | E15 | E15 原出口 |
| Q16 | E16 兽毛 | T6 | 1 撮（2 步） | `E16_ViewFur=true` + `TreeClueCount+1` | E16 | E16 原出口 |
| Q17 | E28 树根 | T5 | 3 段 ≥80% | `E28_ViewTreeScratch=true` + `TreeClueCount+1` | E28 | E28 原出口 |
| Q18 | E17 空桶 | T3 | 2 处（内部/桶底） | `E17_ViewEmptyBucket=true` | E17 | E17 原出口 |
| Q19 | E18 雨靴印 | T4→选择 | 6/6 + 朝鸡舍 | `E18_ViewBootprints=true` | E18 | E18 原出口 |

### 不计入 19 局（沿用原反馈，只做 2D 大图或纯对话）

E06 小围墙、E13 正门、E09 爪印、E23 蹚水、E25 小鸡脚印、E27 反光、E34 玻璃珠、E30 黑毛、E11/E20 空间闸。

---

## 6 与笔记本系统的融合

### 6.1 数据流（不新增笔记本 API）

```
MiniGameHost.Submit()
   ├ GameState.SetBool(def.Var, true)
   │     └ Set() → DispatchSideEffects() → GameEvents.RaiseVariableChanged(name)   ← 已有
   │           └ BookController.OnVarChanged → CheckAllEntries → Unlock(id)          ← 已有
   │                 ├ entry.SetActive(true)
   │                 ├ QueueReveal → 淡入 1s + blink 0.35s                          ← 已有
   │                 ├ AudioDirector.PlayAudio("audio_unlockClue")                  ← 已有
   │                 ├ PlayIconBounce（未打开时图标弹到 2×）                          ← 已有
   │                 ├ UpdateRedDot（开红点）                                        ← 已有
   │                 └ Reconcile → 连线 / Mod（划掉、旁注）                            ← 已有
   └ 计数追加：ChickTraceCount / TreeClueCount（int +1）
```

**结论：笔记本 UI 不需要新增任何东西。** 若后续要「小游戏专属」的入册表现，可加一条可选 hook：`MiniGameResultToast`（在小游戏关闭瞬间，于屏幕右侧浮出「已记入侦探笔记 · D01」2 秒）。这条是本方案唯一建议新增的笔记本相关 UI，且不影响现有逻辑。

### 6.2 玩家可见的完整反馈序列

| 时刻 | 玩家看到 |
|---|---|
| 局内 | 目标确认 → 深蓝描边 + 小勾 + 轻音；进度条 N/M |
| 全部完成 | 绿横幅「已找齐线索」/「已理清」+ `audio_receiveClue` |
| 提交后 0.2s | 屏幕右上角笔记本图标弹跳（或已打开时条目位置淡入） |
| 打开笔记本 | 新条目 1s 淡入 + 0.35s 呼吸闪烁；页码红点提示 |
| 条目内容 | 原文案 + 已有插图（E08「几根焦黑的稻草 / 一小撮被燎卷的深色毛」已就位） |
| 关联 | 两端都在册时自动出现连线；被推翻条目自动划掉+旁注 |

### 6.3 笔记本条目的「来源可见性」

现有条目没有「这条是小游戏解出来的」标识。建议（可选）：在小游戏解锁的条目右上角加一枚小放大镜角标，参数 `来自调查`。不改结构，只加一个 `GameObject` 显隐，代价低。

### 6.4 待完成状态与笔记本的关系

19 文档要求「刚听完但未整理」的记录可恢复。存 `MiniGameSave`，**不写任何 `Note_*` 变量**，避免污染笔记本条件判断。

---

## 7 程序框架

### 7.1 目录

```
Assets/MiniGameSystem/
├─ Core/
│  ├─ MiniGameHost.cs            门面：Open/Close/Submit/恢复
│  ├─ MiniGameDef.cs             单局数据定义
│  ├─ MiniGameRegistry.cs        19 局数据表（唯一数据源）
│  ├─ MiniGameBoard.cs           模板基类（构建骨架、状态机、提示、退出）
│  ├─ MiniGameTheme.cs           色板 / 字体 / 通用 sprite
│  ├─ MiniGameUIKit.cs           建 Label/Button/Card/Slot 的工厂
│  └─ MiniGameSave.cs            待完成记录 + 局内进度（接 SaveService）
├─ Boards/
│  ├─ MagnifierBoard.cs          T1
│  ├─ UncoverBoard.cs            T2
│  ├─ RotateBoard.cs             T3
│  ├─ JigsawBoard.cs             T4
│  ├─ RubbingBoard.cs            T5
│  ├─ TweezerBoard.cs            T6
│  └─ TestimonyBoard.cs          T7
├─ Hooks/
│  ├─ MiniGameClueTrigger.cs     环境物证入口（替代 ClueTrigger 写变量）
│  └─ MiniGameDialogueHook.cs    证词局入口（挂对话节点末尾）
└─ Data/
   └─ MiniGameContent.cs         每局的文案、卡面、目标坐标、资源引用
```

### 7.2 核心接口

```csharp
// 一局的定义（纯数据）
[Serializable]
public sealed class MiniGameDef
{
    public string Id;              // "Q11"
    public MiniGameTemplate Template;   // Magnifier / Uncover / ...
    public string Title;           // "微观调查"
    public string Objective;       // "找到焦黑的草尖和卷曲的毛尖"
    public string EnterVar;        // 可选：入口前置变量（如 E07_ViewNapSpot）
    public string SubmitVar;       // 成功后写入的变量（如 E08_ViewBurnMark）
    public string CountVar;        // 可选计数：ChickTraceCount / TreeClueCount
    public string[] Hints;         // [一级, 二级]
    public string ContentKey;      // 指向 MiniGameContent 的配置键
    public string SourceId;        // 来源点（E08 / 淑芬 1-A / 小鸡 2-B）
}

// 模板基类
public abstract class MiniGameBoard : MonoBehaviour
{
    public event Action<MiniGameBoard> OnSubmit;
    public event Action<MiniGameBoard> OnExit;

    public abstract void Initialize(MiniGameDef def, MiniGameTheme theme);
    public abstract void Restore(MiniGameProgress progress);   // 续局
    public abstract MiniGameProgress Capture();                // 退出时快照
    protected abstract bool IsComplete { get; }
    protected void RaiseSubmit();                              // 内部调
    protected void RaiseExit();

    // 骨架（统一实现，子类不重复写）
    protected void BuildChrome();     // 顶栏/目标句/进度栏/工具栏/提示
    protected void ShowHint(int level);
    protected void ResetUnconfirmed();
}
```

### 7.3 Host 关键行为

```csharp
public static class MiniGameHost
{
    public static bool Open(string defId, Action onReturn);
    public static void Close();                       // 保留进度
    public static bool IsOpen;
    static void Submit(MiniGameDef def);              // 统一写变量 + 计数
}
```

职责：
1. 取 `MiniGameRegistry.Get(defId)`。
2. `GameEvents.SetPaused(true)`（复用现有暂停与鼠标解锁）。
3. 实例化对应 Board，`Initialize(def, theme)`。
4. 订阅 `OnSubmit` / `OnExit`。
5. `Submit` 内顺序：写 `SubmitVar` → 写 `CountVar+1`（去重判断）→ 清 `MiniGameSave` → 回调 `onReturn`。
6. `Close` 时 `GameEvents.SetPaused(false)`。

### 7.4 去重与一次性

```csharp
static void Submit(MiniGameDef def)
{
    if (!string.IsNullOrEmpty(def.SubmitVar) && GameState.GetBool(def.SubmitVar))
        { ClearSave(def.Id); return; }             // 已获得：只展示完成态
    if (!string.IsNullOrEmpty(def.SubmitVar)) GameState.SetBool(def.SubmitVar, true);
    if (!string.IsNullOrEmpty(def.CountVar)) GameState.SetInt(def.CountVar, GameState.GetInt(def.CountVar) + 1);
    ClearSave(def.Id);
}
```

计数只在**首次**提交时 +1，重复游玩不再加。

### 7.5 存档结构（接 `SaveService`）

```csharp
[Serializable]
public sealed class MiniGameSave
{
    public string DefId;
    public string SourceId;
    public bool[] Confirmed;              // 目标确认位
    public float[] DraggedPositions;      // 草束 / 图块 / 卡位
    public float[] RubbingMaskCoverage;   // T5 三段覆盖率
}
```

- 强退、切场景、读档后，再次点同一入口优先恢复。
- 入口条件不满足（如 `ChickStatus>=3` 作废 Q04）→ 丢弃记录，不发线索。

### 7.6 接入方式（两种，都很薄）

**A. 环境物证（改一处现有组件）**

```csharp
// 原来：ClueTrigger.SetClue() 直接写变量
// 现在：MiniGameClueTrigger 打开局，成功后才写
[RequireComponent(typeof(Interactable))]
public sealed class MiniGameClueTrigger : MonoBehaviour
{
    [SerializeField] string defId;   // "Q11"
    void OnInteract() => MiniGameHost.Open(defId, OnReturn);
    void OnReturn() { InteractionPointVfx.DiscoverFrom(gameObject); /* 播原线索描述 */ }
}
```

**B. 证词局（对话节点末尾挂）**

```csharp
public sealed class MiniGameDialogueHook : MonoBehaviour
{
    [SerializeField] string defId;    // "Q01"
    [SerializeField] string npcName;  // "淑芬"
    [SerializeField] int nodeId;      // 1
    public void Open() => MiniGameHost.Open(defId, () => DialogueManager.Instance.StartNpc(npcName, nodeId));
}
```

> 对话脚本侧需要「节点播完 → 调 Hook → 等小游戏关闭 → 执行原出口」。这块要看 `TREE_TO_LUA_SPEC.md` 的节点出口能力，落地前需确认能否在节点末插回调。

### 7.7 模板与数据分离

19 局共用 7 个 Board；每局差异全在 `MiniGameContent`：

```csharp
public sealed class MagnifierContent
{
    public Vector2[] Targets;     // 归一化坐标
    public float[] Radius;
    public string[] Names;        // "草尖焦黑" "毛尖燎卷"
    public Sprite Background;     // 稻草堆 / 荷叶 / 水面 / 猫门
    public Sprite[] TargetThumbs; // 进度槽缩略
}
```

新增一局放大镜 = 加一条 Content + 一条 Def，**不写新代码**。

---

## 8 接入改造清单

| 现有资产 | 改动 | 影响面 |
|---|---|---|
| `ClueTrigger` | 保留不动（其它非小游戏线索点仍用） | 无 |
| E01/E02/E03/E05/E07/E08/E10/E12/E14/E15/E16/E17/E18/E28 交互点 | 把 `ClueTrigger` 换为 `MiniGameClueTrigger`（填 defId） | 13 处 |
| 对话节点末尾（淑芬 1-A、小鸡 2-B/2-E/2-G、蛙 2-D、大黄 1-A、E03 偷听） | 挂 `MiniGameDialogueHook` | 6 处 |
| `BookController` | **不改** | 无 |
| `global_variables.txt` | 仅新增 `MiniGame_*` 存档辅助变量（如需要） | 1 处 |
| `SaveService` | 增加 `MiniGameSave` 序列化字段 | 1 处 |
| 场景 | 13 个 E 点各加一个组件；不新增 3D 物体 | 场景文件 |

**回退友好**：所有改动都是「加组件 + 换组件」，不删原数据；`MiniGameClueTrigger` 不填 defId 时回落到原直写行为。

---

## 9 美术资源清单

| 类别 | 数量 | 说明 |
|---|---|---|
| 背景板 | 7 | 稻草堆 / 草窝 / 巢草 / 树根 / 草地门脚 / 池塘水面 / 门板（各模板 1 张，19 局复用同模板背景可换色块） |
| 可动层 | 19 组 | 草束 ×3、木炭、水桶、陶瓷碗、白石、6 块图块、取样纸、镊子、卡片组 |
| 目标层 | 19 组 | 焦尖、卷毛、炭粉、胀谷粒、锁扣、磨亮边、鬼脸等 |
| 工具 | 5 | 放大镜、镊子、炭条、翻转把手、复位 |
| UI | 1 套 | 槽、卡、进度条、勾、提示按钮（复用 Notebook 组件） |

七张概念图已存在，可直接作为美术交底；正式绘制按 19.7「拆层」要求：场景底、不可动对象、可动层、双面/角度状态、高亮层、工具、卡片槽、完成反馈、文字。

---

## 10 分期落地（建议）

| 期 | 内容 | 验收 |
|---|---|---|
| P0 | 框架：Host / Def / Registry / Board 基类 / UIKit / Theme / Save | 能空跑一个 Debug 局，开关、暂停、退出正常 |
| P1 | T1 放大镜 + Q11（E08）+ Q14 | 两局可玩，成功入册 E08/E14，笔记本淡入正常 |
| P2 | T3 翻转 + Q18、T2 拨开 + Q10 | 覆盖谷仓段与红顶屋段各 1 局 |
| P3 | T6 镊取 + Q16、T7 证词 + Q01 | 打通证词接入链路 |
| P4 | T4 拼合 Q19、T5 拓印 Q17 | 两个重操作模板 |
| P5 | 其余 9 局批量配数据 | 19 局全通，替代路径与计数验证 |

每期结束做：单局 5–40s 计时、提示两级可用、退出续局、重复进入不重复计数、笔记本条目/连线/划掉正确。

---

## 11 风险与待确认

| # | 风险 | 处理建议 |
|---|---|---|
| 1 | 证词局需要「对白节点末尾插回调」，现有 Lua/树状脚本是否支持 | 需确认 `TREE_TO_LUA_SPEC.md` 的节点出口能力；若不支持，改为「节点末播放完后由 `DialogueManager` 抛事件」 |
| 2 | 拓印的覆盖率判定在低端机性能 | 用 128×128 遮罩 + 每帧合并写入，不在 CPU 逐像素判 |
| 3 | 19 局 UI 全是代码构建，维护成本高 | Theme + UIKit 抽共用，单局只写内容 |
| 4 | 客观评分「操作是否够好玩」 | P1 出可玩版先做 2 局手感验证，再批量 |
| 5 | 与 3D 场景的光照/雾/后处理冲突 | 2D 全屏 Overlay（sortingOrder 400），不受 3D 影响 |
| 6 | 小游戏期间玩家输入是否完全锁定 | 复用 `GameEvents.SetPaused(true)`，与 Notebook 打开同机制 |
| 7 | 上次回退事故（误动场景摆放） | 本次落地前先 `git status` 存档，全程只加新文件 + 精确 Edit，不整体 checkout |

---

## 附：UI 骨架示意

见随附示意图（顶部返回 / 中标题 / 目标句 / 左主操作区 / 右进度 / 底工具栏 / 右提示）。
