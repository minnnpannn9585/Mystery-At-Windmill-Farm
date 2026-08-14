-- 对话配置文件 · 环境描述（miaosu / 描述 NPC）
-- E 点 startID 对照（doc 13）：
--   E01=1  E02=2  E12=3  E25=5  E23=7  E06发现=8  E05=90(gate→9|91)  E08=12  E07=14
--   E09=16  E27=17  E10=19  E17=21  E18=23  E14=24  E28=26  E15=27
--   E16=29  E13=30  E06架梯完成=31
--   E22未找到=32  E22已找到=34  E11=36  E06翻越=37
--   E34玻璃珠=38  E34瓶盖=39  E34发卡=40  E34奶糖=41
--   E30鸡羽=42  E30狗毛=43  E30鼠毛=44  E30黑毛=45
--   E24=47  E26=48  E31=49  E32=51  E33=52  E19=54  E21=55  E29=58
--   E22 gate=320 (DogStatus>=2→34 else→32)

DialogueConfig = {}

-- E01 · 短木炭
DialogueConfig[1] = {
    Type = "Normal",
    DocTag = "E01",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "草地上有一截短木炭棒，炭尖磨平，周边草叶蹭着炭粉。",
    Next = -1
}

-- E02 · 散落羽毛碎屑
DialogueConfig[2] = {
    Type = "Normal",
    DocTag = "E02",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "几根蓬松的黄色绒毛散落在草丛里。",
    Next = -1
}

-- E12 · 悲伤蛙身下绿垫
DialogueConfig[3] = {
    Type = "Normal",
    DocTag = "E12#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "蛙端坐的地方比周边荷叶略高，身下垫着一截绿色的东西，近闻有股奇异的气味。",
    Next = 4
}

DialogueConfig[4] = {
    Type = "Normal",
    DocTag = "E12#2",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "那个气味……垫着什么？",
    Next = -1
}

-- E25 · 池塘边小鸡脚印
DialogueConfig[5] = {
    Type = "Normal",
    DocTag = "E25#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "池塘边的软泥上印着几枚小小的三趾脚印，脚印边缘被水泡得有点散。",
    Next = 6
}

DialogueConfig[6] = {
    Type = "Normal",
    DocTag = "E25#2",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "有鸡来过池塘边？",
    Next = -1
}

-- E23 · 池塘岸边蹚水痕迹
DialogueConfig[7] = {
    Type = "Normal",
    DocTag = "E23",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "池塘近岸处有几处被踩进的浅坑，旁边留有一个圆底压印，底部粘着带水草腥气的湿泥。",
    Next = -1
}

-- E06 · 谷仓入口小围墙（首次发现）
DialogueConfig[8] = {
    Type = "Normal",
    DocTag = "E06#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一道矮围墙，太高，爬不上去。",
    Next = 11
}

-- E05 · 鸡舍水槽边谷物泡水（gate：D08 三源任一 → 取物链 9→10，否则仅氛围 91）
DialogueConfig[90] = {
    Type = "Normal",
    DocTag = "E05#gate",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Shufen_DaHuangWakeAsked", VarType = "bool", TrueNext = 9 },
        { VarName = "Chick_WakeDogHintShown", VarType = "bool", TrueNext = 9 },
        { VarName = "Mouse_CheapSold_07", VarType = "bool", TrueNext = 9 },
    },
    Next = 91
}

DialogueConfig[91] = {
    Type = "Normal",
    DocTag = "E05#preview",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一桶浑浊的液体，气味有点酸。",
    Next = -1
}

DialogueConfig[9] = {
    Type = "Normal",
    DocTag = "E05#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一桶浑浊的液体，水面浮着几粒胀开的谷粒，气味有点酸。",
    Next = 10
}

DialogueConfig[10] = {
    Type = "Normal",
    DocTag = "E05#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "这个气味……说不定正是大黄需要的。",
    SetVariables = {
        { VarName = "E05_GrainSoakGet", VarType = "bool", Value = true },
    },
    Next = -1
}

DialogueConfig[11] = {
    Type = "Normal",
    DocTag = "E06#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "缺个东西垫垫脚。",
    Next = -1
}

-- E08 · 烧焦稻草 / 皮毛
DialogueConfig[12] = {
    Type = "Normal",
    DocTag = "E08#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "几根稻草尖端焦黑，旁边粘着一小撮被燎卷的深色毛。",
    Next = 13
}

DialogueConfig[13] = {
    Type = "Normal",
    DocTag = "E08#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "这里被什么东西烫过，焦痕很浅，不像大火。",
    Next = -1
}

-- E07 · 午睡点
DialogueConfig[14] = {
    Type = "Normal",
    DocTag = "E07#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "干草被压出一片圆形凹陷，边缘沾着几根深色细毛。",
    Next = 15
}

DialogueConfig[15] = {
    Type = "Normal",
    DocTag = "E07#2",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "谁经常在这里睡觉？",
    Next = -1
}

-- E09 · 乌鸦巢前动物爪印
DialogueConfig[16] = {
    Type = "Normal",
    DocTag = "E09",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "乌鸦巢前的木板边缘有几枚浅浅的爪印，脚掌小而利。",
    Next = -1
}

-- E27 · 谷仓高处玻璃珠反光
DialogueConfig[17] = {
    Type = "Normal",
    DocTag = "E27#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "木梁缝里闪过一点彩色反光，角度一偏又看不见了。",
    Next = 18
}

DialogueConfig[18] = {
    Type = "Normal",
    DocTag = "E27#2",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "那是什么东西的反光——乌鸦在这里摆了什么亮晶晶的东西？",
    Next = -1
}

-- E10 · 乌鸦巢白石头（假蛋）
DialogueConfig[19] = {
    Type = "Normal",
    DocTag = "E10#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一颗天然白色圆石，表面用木炭画着歪歪的爱心，背面还有一张笔画稚嫩的鬼脸。",
    Next = 20
}

DialogueConfig[20] = {
    Type = "Normal",
    DocTag = "E10#2",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "这是……什么东西？？......反正不是蛋",
    Next = -1
}

-- E17 · 门旁空水桶
DialogueConfig[21] = {
    Type = "Normal",
    DocTag = "E17#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "倒扣着一只空水桶，桶底粘着湿泥和细沙，有股池塘边的水草味。",
    Next = 22
}

DialogueConfig[22] = {
    Type = "Normal",
    DocTag = "E17#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "这桶刚装过池塘水。",
    Next = -1
}

-- E18 · 雨靴泥脚印
DialogueConfig[23] = {
    Type = "Normal",
    DocTag = "E18",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "几枚很重的泥脚印，鞋底纹路宽大，从门口延向鸡舍方向，泥边已经干了一圈。",
    Next = -1
}

-- E14 · 精美猫门
DialogueConfig[24] = {
    Type = "Normal",
    DocTag = "E14#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一扇精致的小门，边缘磨得很亮，上面有个细小锁扣。",
    Next = 25
}

DialogueConfig[25] = {
    Type = "Normal",
    DocTag = "E14#2",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "这是给谁专用的小门？",
    Next = -1
}

-- E28 · 大橡树根抓痕
DialogueConfig[26] = {
    Type = "Normal",
    DocTag = "E28",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "树皮上有几道细长抓痕。",
    Next = -1
}

-- E15 · 门外陶瓷碗
DialogueConfig[27] = {
    Type = "Normal",
    DocTag = "E15#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一只干净的陶瓷小碗，碗沿印着小小的爪印花纹，碗底还残留一点细碎食渣。",
    Next = 28
}

DialogueConfig[28] = {
    Type = "Normal",
    DocTag = "E15#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "这里住着被照顾得很好的小动物。",
    Next = -1
}

-- E16 · 门边深色兽毛
DialogueConfig[29] = {
    Type = "Normal",
    DocTag = "E16#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一撮深色兽毛，毛尖细软。",
    Next = 290
}

DialogueConfig[290] = {
    Type = "Normal",
    DocTag = "E16#gate1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Dog_BlackCatSummoned", VarType = "bool", TrueNext = 292, FalseNext = 291 }
    },
    Next = -1
}

DialogueConfig[291] = {
    Type = "Normal",
    DocTag = "E16#gate2",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "E30_BlackFurSeen", VarType = "bool", TrueNext = 293, FalseNext = -1 }
    },
    Next = -1
}

DialogueConfig[292] = {
    Type = "Normal",
    DocTag = "E16#catDown",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "黑猫的毛。",
    Next = -1
}

DialogueConfig[293] = {
    Type = "Normal",
    DocTag = "E16#e30Seen",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "又是这种黑色细毛……乌鸦真的长毛吗？",
    Next = -1
}

-- E13 · 紧闭大门
DialogueConfig[30] = {
    Type = "Normal",
    DocTag = "E13",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "大门关得很紧，没有能钻进去的空隙。",
    Next = -1
}

-- E06 架梯完成 → 同链强制播乌鸦 1-A
DialogueConfig[31] = {
    Type = "Normal",
    DocTag = "E06#placed",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "现在可以爬进去看看了。",
    ChainDialogue = { NpcName = "乌鸦", StartId = 1 },
    Next = -1
}

-- E22 · 狗窝空窝（入口 gate：按 DogStatus 分支）
DialogueConfig[320] = {
    Type = "Normal",
    DocTag = "E22#gate",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "DogStatus", VarType = "int", Op = ">=", Value = 2, Next = 34 }
    },
    Next = 32
}

-- E22 · 狗窝空窝（未找到大黄）
DialogueConfig[32] = {
    Type = "Normal",
    DocTag = "E22#notFound#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "干草窝里留着压痕，谷仓方向隐约传来沉闷的鼾声。",
    Next = 33
}

DialogueConfig[33] = {
    Type = "Normal",
    DocTag = "E22#notFound#2",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "看守的狗呢？",
    Next = -1
}

-- E22 · 狗窝空窝（已找到大黄）
DialogueConfig[34] = {
    Type = "Normal",
    DocTag = "E22#found#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "干草窝里留着压痕。",
    Next = 35
}

DialogueConfig[35] = {
    Type = "Normal",
    DocTag = "E22#found#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "这是大黄住的地方。",
    Next = -1
}

-- E11 · 狗窝旁旧木桶
DialogueConfig[36] = {
    Type = "Normal",
    DocTag = "E11",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一只旧木桶，桶底粘着干掉的谷物渣，闻起来有股淡淡酸味。",
    Next = -1
}

-- E06 · 持梯翻越小围墙
DialogueConfig[37] = {
    Type = "Normal",
    DocTag = "E06#cross",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "这样就能翻过去了。",
    Next = -1
}

-- E34 · 乌鸦巢玻璃制品
DialogueConfig[38] = {
    Type = "Normal",
    DocTag = "E34#glass",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "十几颗大小不一的玻璃珠压在巢底，阳光下折出细碎彩光。",
    Next = -1
}

DialogueConfig[39] = {
    Type = "Normal",
    DocTag = "E34#cap",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "几枚被踩扁的金属瓶盖夹在草枝之间，边缘磨得发亮。",
    Next = -1
}

DialogueConfig[40] = {
    Type = "Normal",
    DocTag = "E34#clip",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一枚弯掉的发卡卡在巢边，黑漆掉了一小块。",
    Next = -1
}

DialogueConfig[41] = {
    Type = "Normal",
    DocTag = "E34#candy",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一颗没打开的奶糖埋在玻璃珠旁，糖纸皱得很厉害。",
    Next = -1
}

-- E30 · 乌鸦巢混杂毛发
DialogueConfig[42] = {
    Type = "Normal",
    DocTag = "E30#chicken",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一小撮浅黄绒羽。",
    Next = -1
}

DialogueConfig[43] = {
    Type = "Normal",
    DocTag = "E30#dog",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "几根粗硬的黄色短毛。",
    Next = -1
}

DialogueConfig[44] = {
    Type = "Normal",
    DocTag = "E30#mouse",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "几根灰褐色细毛。",
    Next = -1
}

DialogueConfig[45] = {
    Type = "Normal",
    DocTag = "E30#black#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一撮细软的黑色毛。",
    Next = 46
}

DialogueConfig[46] = {
    Type = "Normal",
    DocTag = "E30#black#2",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "我竟然不知道乌鸦是长毛的？",
    Next = -1
}

-- E24 · 鸡舍门槛压平稻草
DialogueConfig[47] = {
    Type = "Normal",
    DocTag = "E24",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "鸡舍门槛边的稻草被踩得很平，几根草茎折向不同方向，痕迹有新的也有旧的。",
    Next = -1
}

-- E26 · 谷仓墙根发酵苹果渣
DialogueConfig[48] = {
    Type = "Normal",
    DocTag = "E26",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一小堆发酵苹果渣，甜酸气味很重，渣堆里露着几颗被啃得很彻底的苹果核。",
    Next = -1
}

-- E31 · 鸡舍淑芬窝旧蛋壳碎片
DialogueConfig[49] = {
    Type = "Normal",
    DocTag = "E31#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "角落里压着几片旧蛋壳，边缘磨得很圆润，颜色比鸡舍其他地方的碎蛋都浅。",
    Next = 50
}

DialogueConfig[50] = {
    Type = "Normal",
    DocTag = "E31#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "前面有很多小鸡已经出生了。",
    Next = -1
}

-- E32 · Flash 宽叶粘液轨迹
DialogueConfig[51] = {
    Type = "Normal",
    DocTag = "E32",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "一道弯弯曲曲的粘液轨迹，起点和终点之间直线距离不超过一片叶子宽。",
    Next = -1
}

-- E33 · 池塘边踩进泥里的松果
DialogueConfig[52] = {
    Type = "Normal",
    DocTag = "E33#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "软泥里嵌着一颗松果，压得很深，周围留着一个靴底大小的坑，坑边泥湿而松果顶已晒干。",
    Next = 53
}

DialogueConfig[53] = {
    Type = "Normal",
    DocTag = "E33#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "有人走得很急，根本没注意脚下。",
    Next = -1
}

-- E19 · 红顶屋屋顶关闭的阁楼窗子
DialogueConfig[54] = {
    Type = "Normal",
    DocTag = "E19",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "阁楼的窗子从里面扣着，玻璃后只透出一层模糊的暖光。",
    Next = -1
}

-- E21 · 红顶屋窗台下磨亮爪痕
DialogueConfig[55] = {
    Type = "Normal",
    DocTag = "E21#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "木沿被小爪子磨得发亮，几道细浅抓痕集中在同一个落脚点。",
    Next = 560
}

DialogueConfig[560] = {
    Type = "Normal",
    DocTag = "E21#gate",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Dog_BlackCatSummoned", VarType = "bool", TrueNext = 57, FalseNext = 56 }
    },
    Next = 56
}

DialogueConfig[56] = {
    Type = "Normal",
    DocTag = "E21#catUp",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "有小动物经常待在这里看外面。",
    Next = -1
}

DialogueConfig[57] = {
    Type = "Normal",
    DocTag = "E21#catDown",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "黑猫常在这里守着……院子里的动静，他看得一清二楚。",
    Next = -1
}

-- E29 · 红顶屋窗缝暖黄灯
DialogueConfig[58] = {
    Type = "Normal",
    DocTag = "E29#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "红顶屋窗帘拉得很严，只从缝里漏出一线暖黄的光。",
    Next = 59
}

DialogueConfig[59] = {
    Type = "Normal",
    DocTag = "E29#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "不像客厅大灯，更像谁把一盏小灯一直留着。",
    Next = -1
}

-- E20 · 漫画收束占位（ComicGateTrigger 默认 startID）
DialogueConfig[600] = {
    Type = "Normal",
    DocTag = "E20#placeholder",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（漫画收束演出占位——真相即将揭晓。）",
    Next = -1
}
