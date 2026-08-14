-- 对话配置文件
-- 乌鸦全章（树状准稿）→ wuya_01_FROM_DOC.lua
-- Scene DialogueTrigger start ID should be 0 (entry dispatcher)
-- doc node map:
--   entry#0 -> DialogueConfig[0]
--   1-A -> DialogueConfig[1]
--   1-B -> DialogueConfig[5]
--   1-C -> DialogueConfig[7]
--   2-A -> DialogueConfig[10]
--   2-B -> DialogueConfig[30]
--   2-hub -> DialogueConfig[38]
--   2-C -> DialogueConfig[39]
--   2-D -> DialogueConfig[45]
--   2-E -> DialogueConfig[58]
--   NGPlus -> DialogueConfig[210]

DialogueConfig = {}

-- ==================== entry#0 ====================

DialogueConfig[0] = {
    Type = "Normal",
    DocTag = "entry#0",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "NGPlus", VarType = "bool", TrueNext = 201, FalseNext = 202 }
    },
    Next = 202
}

DialogueConfig[201] = {
    Type = "Normal",
    DocTag = "entry#ng1",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Crow_NGPlusShown", VarType = "bool", TrueNext = 202, FalseNext = 210 }
    },
    Next = 202
}

DialogueConfig[202] = {
    Type = "Normal",
    DocTag = "entry#roof",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Crow_RoofIntroShown", VarType = "bool", TrueNext = 205, FalseNext = -1 }
    },
    Next = -1
}

DialogueConfig[205] = {
    Type = "Normal",
    DocTag = "entry#2e1",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "E08_ViewBurnMark", VarType = "bool", TrueNext = 206, FalseNext = 58 }
    },
    Next = 58
}

DialogueConfig[206] = {
    Type = "Normal",
    DocTag = "entry#2e2",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Crow_GlassBeadAsked", VarType = "bool", TrueNext = 58, FalseNext = 207 }
    },
    Next = 58
}

DialogueConfig[207] = {
    Type = "Normal",
    DocTag = "entry#2e3",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "",
    SetVariables = {
        { VarName = "Crow_GlassBeadRemedial", VarType = "bool", Value = true }
    },
    Next = 39
}

-- 普通对话类型  -- doc:1-A#1
-- Position: { 50, 150 }
DialogueConfig[1] = {
    Type = "Normal",
    DocTag = "1-A#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（谷仓顶传来一阵得意的嘎嘎声）",
    Next = 2  -- 下一段对话ID
}

-- 普通对话类型  -- doc:1-A#2
-- Position: { 400, 150 }
DialogueConfig[2] = {
    Type = "Normal",
    DocTag = "1-A#2",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "本王的垃圾王国——今日也光辉灿烂！",
    Next = 3  -- 下一段对话ID
}

-- 普通对话类型  -- doc:1-A#3
-- Position: { 750, 150 }
DialogueConfig[3] = {
    Type = "Normal",
    DocTag = "1-A#3",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（一声鸦叫拖长尾音，又归于安静）",
    Next = 4  -- 下一段对话ID
}

-- 普通对话类型  -- doc:1-A#4
-- Position: { 1100, 150 }
DialogueConfig[4] = {
    Type = "Normal",
    DocTag = "1-A#4",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "我得上去看看。",
    Next = -1  -- 下一段对话ID
}

-- 普通对话类型  -- doc:1-B#1
-- Position: { 1550, 150 }
DialogueConfig[5] = {
    Type = "Normal",
    DocTag = "1-B#1",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "谁？！谁在本王阵法边缘乱踩！",
    Next = 6  -- 下一段对话ID
}

-- 普通对话类型  -- doc:1-B#2
-- Position: { 1900, 150 }
DialogueConfig[6] = {
    Type = "Normal",
    DocTag = "1-B#2",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "滚远点！凡人免进！",
    SetVariables = {
        { VarName = "E35_CrowTauntShown", VarType = "bool", Value = true }
    },
    Next = -1  -- 下一段对话ID
}

-- 普通对话类型  -- doc:1-C#1
-- Position: { 2350, 150 }
DialogueConfig[7] = {
    Type = "Normal",
    DocTag = "1-C#1",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "往上爬啊！往上爬！",
    Next = 8  -- 下一段对话ID
}

-- 普通对话类型  -- doc:1-C#2
-- Position: { 2700, 150 }
DialogueConfig[8] = {
    Type = "Normal",
    DocTag = "1-C#2",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "本王倒要看看你怎么上来！",
    Next = 9  -- 下一段对话ID
}

-- 普通对话类型  -- doc:1-C#3
-- Position: { 3050, 150 }
DialogueConfig[9] = {
    Type = "Normal",
    DocTag = "1-C#3",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（一阵嘎嘎大笑从屋顶传下来）",
    SetVariables = {
        { VarName = "E36_CrowTauntShown", VarType = "bool", Value = true }
    },
    Next = -1  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#1
-- Position: { 4350, 150 }
DialogueConfig[10] = {
    Type = "Normal",
    DocTag = "2-A#1",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "站住。",
    Next = 11  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#2
-- Position: { 4700, 150 }
DialogueConfig[11] = {
    Type = "Normal",
    DocTag = "2-A#2",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "踏入垃圾王国领地的凡人——报上名来。",
    Next = 12  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#3
-- Position: { 5050, 150 }
DialogueConfig[12] = {
    Type = "Normal",
    DocTag = "2-A#3",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "我是侦探。我来找淑芬的蛋。",
    Next = 13  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#4
-- Position: { 5400, 150 }
DialogueConfig[13] = {
    Type = "Normal",
    DocTag = "2-A#4",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "蛋？",
    Next = 14  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#5
-- Position: { 5750, 150 }
DialogueConfig[14] = {
    Type = "Normal",
    DocTag = "2-A#5",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（乌鸦歪头，眼珠子贼亮地转了一圈）",
    Next = 15  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#6
-- Position: { 6100, 150 }
DialogueConfig[15] = {
    Type = "Normal",
    DocTag = "2-A#6",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "本王这儿只有神灵宝石。",
    Next = 16  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#7
-- Position: { 6450, 150 }
DialogueConfig[16] = {
    Type = "Normal",
    DocTag = "2-A#7",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "部落图腾，绝版手办。你找错门了。",
    Next = 17  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#8
-- Position: { 6800, 150 }
DialogueConfig[17] = {
    Type = "Normal",
    DocTag = "2-A#8",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "大黄说，你把淑芬的蛋叼走了。",
    Next = 18  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#9
-- Position: { 7150, 150 }
DialogueConfig[18] = {
    Type = "Normal",
    DocTag = "2-A#9",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "那条跳跃能力为零的地毯？",
    Next = 19  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#10
-- Position: { 7500, 150 }
DialogueConfig[19] = {
    Type = "Normal",
    DocTag = "2-A#10",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "它隔那么远乱吠，懂什么。",
    Next = 20  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#11
-- Position: { 7850, 150 }
DialogueConfig[20] = {
    Type = "Normal",
    DocTag = "2-A#11",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "本王捡的是白白亮亮的大宝贝。",
    Next = 21  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#12
-- Position: { 8200, 150 }
DialogueConfig[21] = {
    Type = "Normal",
    DocTag = "2-A#12",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "就连那位也爬上来，瞪了本王的神灵宝石一眼——",
    Next = 22  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#13
-- Position: { 8550, 150 }
DialogueConfig[22] = {
    Type = "Normal",
    DocTag = "2-A#13",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（乌鸦得意地扬起下巴）",
    Next = 23  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#14
-- Position: { 8900, 150 }
DialogueConfig[23] = {
    Type = "Normal",
    DocTag = "2-A#14",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "然后他就怂了，一声不吭下去了。嫉妒，肯定是嫉妒。",
    Next = 24  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#15
-- Position: { 9250, 150 }
DialogueConfig[24] = {
    Type = "Normal",
    DocTag = "2-A#15",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "让我看看你那个神灵宝石行吗？",
    Next = 25  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#16
-- Position: { 9600, 150 }
DialogueConfig[25] = {
    Type = "Normal",
    DocTag = "2-A#16",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "看可以。",
    Next = 26  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#17
-- Position: { 9950, 150 }
DialogueConfig[26] = {
    Type = "Normal",
    DocTag = "2-A#17",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（乌鸦翅尖张开，挡住白石头）",
    Next = 27  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#18
-- Position: { 10300, 150 }
DialogueConfig[27] = {
    Type = "Normal",
    DocTag = "2-A#18",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "拿？想都别想。",
    Next = 28  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#19
-- Position: { 10650, 150 }
DialogueConfig[28] = {
    Type = "Normal",
    DocTag = "2-A#19",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……我就看看。",
    Next = 29  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-A#20
-- Position: { 11000, 150 }
DialogueConfig[29] = {
    Type = "Normal",
    DocTag = "2-A#20",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "凡人，你最好只是看看。",
    SetVariables = {
        { VarName = "Crow_RoofIntroShown", VarType = "bool", Value = true }
    },
    Next = -1
}

-- 普通对话类型  -- doc:2-B#1
-- Position: { 11900, 150 }
DialogueConfig[30] = {
    Type = "Normal",
    DocTag = "2-B#1",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……",
    Next = 31  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-B#2
-- Position: { 12250, 150 }
DialogueConfig[31] = {
    Type = "Normal",
    DocTag = "2-B#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "这就是块石头。",
    Next = 32  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-B#3
-- Position: { 12600, 150 }
DialogueConfig[32] = {
    Type = "Normal",
    DocTag = "2-B#3",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "放肆！",
    Next = 33  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-B#4
-- Position: { 12950, 150 }
DialogueConfig[33] = {
    Type = "Normal",
    DocTag = "2-B#4",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "你懂什么图腾学？！",
    Next = 34  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-B#5
-- Position: { 13300, 150 }
DialogueConfig[34] = {
    Type = "Normal",
    DocTag = "2-B#5",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "看清楚——正面是爱心，那是远古封印！",
    Next = 35  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-B#6
-- Position: { 13650, 150 }
DialogueConfig[35] = {
    Type = "Normal",
    DocTag = "2-B#6",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "翻过来是鬼脸，那是驱邪结界！",
    Next = 36  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-B#7
-- Position: { 14000, 150 }
DialogueConfig[36] = {
    Type = "Normal",
    DocTag = "2-B#7",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（乌鸦翅膀死死盖住白石头，只故意露出爱心那一面）",
    Next = 37  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-B#8
-- Position: { 14350, 150 }
DialogueConfig[37] = {
    Type = "Normal",
    DocTag = "2-B#8",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "里头充满神秘力量！",
    Next = 38  -- 下一段对话ID
}

-- 提问类型（玩家需要选择回答）  -- doc:2-hub
-- Position: { 11450, 150 }
DialogueConfig[38] = {
    Type = "Question",
    DocTag = "2-hub",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "凡人，记清楚本王的辉煌。",
    Options = {
        {
            Text = "谷仓下面烧焦痕迹，是你干的？",
            Next = 39,
            DisplayConditions = {
                { VarName = "E08_ViewBurnMark", VarType = "bool", Value = true },
                { VarName = "Crow_GlassBeadAsked", VarType = "bool", Value = false }
            },
        },
        {
            Text = "我先走了。",
            Next = 45,
        }
    }
}

-- 普通对话类型  -- doc:2-C#1
-- Position: { 4350, 700 }
DialogueConfig[39] = {
    Type = "Normal",
    DocTag = "2-C#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "谷仓下面那些烧焦的痕迹，是你干的？",
    Next = 40  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-C#2
-- Position: { 4700, 700 }
DialogueConfig[40] = {
    Type = "Normal",
    DocTag = "2-C#2",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "那是本王布的玻璃珠法阵。",
    Next = 41  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-C#3
-- Position: { 5050, 700 }
DialogueConfig[41] = {
    Type = "Normal",
    DocTag = "2-C#3",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "阳光一照，珠子聚成火点——防贼、防盗、防黑毛。",
    Next = 42  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-C#4
-- Position: { 5400, 700 }
DialogueConfig[42] = {
    Type = "Normal",
    DocTag = "2-C#4",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "所以下面稻草是被聚光点着的？",
    Next = 43  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-C#5
-- Position: { 5750, 700 }
DialogueConfig[43] = {
    Type = "Normal",
    DocTag = "2-C#5",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "烧着稻草……那是阵法余波。",
    Next = 44  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-C#6
-- Position: { 6100, 700 }
DialogueConfig[44] = {
    Type = "Normal",
    DocTag = "2-C#6",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "说明本王威力过猛。",
    SetVariables = {
        { VarName = "Crow_GlassBeadAsked", VarType = "bool", Value = true }
    },
    Next = 900
}

DialogueConfig[900] = {
    Type = "Normal",
    DocTag = "2-C#gate",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Crow_GlassBeadRemedial", VarType = "bool", TrueNext = -1, FalseNext = 38 }
    },
    Next = 38
}

-- 普通对话类型  -- doc:2-D#1
-- Position: { 7700, 700 }
DialogueConfig[45] = {
    Type = "Normal",
    DocTag = "2-D#1",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "我先走了。",
    Next = 46  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-D#2
-- Position: { 8050, 700 }
DialogueConfig[46] = {
    Type = "Normal",
    DocTag = "2-D#2",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "下去吧。",
    Next = 47  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-D#3
-- Position: { 8400, 700 }
DialogueConfig[47] = {
    Type = "Normal",
    DocTag = "2-D#3",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "别踩本王的宝贝。",
    Next = 48  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-D#4
-- Position: { 8750, 700 }
DialogueConfig[48] = {
    Type = "Normal",
    DocTag = "2-D#4",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（一声又长又得意的嘎嘎）",
    Next = -1  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-E@v1#1
-- Position: { 6550, 600 }
DialogueConfig[49] = {
    Type = "Normal",
    DocTag = "2-E@v1#1",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "又来了？",
    Next = 50  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-E@v1#2
-- Position: { 6900, 600 }
DialogueConfig[50] = {
    Type = "Normal",
    DocTag = "2-E@v1#2",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "随便走走。",
    Next = 51  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-E@v1#3
-- Position: { 7250, 600 }
DialogueConfig[51] = {
    Type = "Normal",
    DocTag = "2-E@v1#3",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "参观收费。",
    Next = -1
}

-- 普通对话类型  -- doc:2-E@v2#1
-- Position: { 6550, 880 }
DialogueConfig[52] = {
    Type = "Normal",
    DocTag = "2-E@v2#1",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "宝石还在。",
    Next = 53  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-E@v2#2
-- Position: { 6900, 880 }
DialogueConfig[53] = {
    Type = "Normal",
    DocTag = "2-E@v2#2",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "不用问。",
    Next = 54  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-E@v2#3
-- Position: { 7250, 880 }
DialogueConfig[54] = {
    Type = "Normal",
    DocTag = "2-E@v2#3",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（乌鸦用翅尖敲了敲白石头）",
    Next = -1
}

-- 普通对话类型  -- doc:2-E@v3#1
-- Position: { 6550, 1160 }
DialogueConfig[55] = {
    Type = "Normal",
    DocTag = "2-E@v3#1",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "案子还没破。",
    Next = 56  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-E@v3#2
-- Position: { 6900, 1160 }
DialogueConfig[56] = {
    Type = "Normal",
    DocTag = "2-E@v3#2",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "和本王有什么关系。",
    Next = 57  -- 下一段对话ID
}

-- 普通对话类型  -- doc:2-E@v3#3
-- Position: { 7250, 1160 }
DialogueConfig[57] = {
    Type = "Normal",
    DocTag = "2-E@v3#3",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "本王的王国一切正常。",
    Next = -1
}

-- 普通对话类型  -- doc:2-E
-- Position: { 6550, 1440 }
DialogueConfig[58] = {
    Type = "Normal",
    DocTag = "2-E",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "",
    RotatePool = { 49, 52, 55 },
    Next = -1
}

-- ==================== NGPlus ====================

DialogueConfig[210] = {
    Type = "Normal",
    DocTag = "NGPlus#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（乌鸦蹲在巢边，比平时安静）",
    Next = 211
}

DialogueConfig[211] = {
    Type = "Normal",
    DocTag = "NGPlus#2",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "……你来了。",
    Next = 212
}

DialogueConfig[212] = {
    Type = "Normal",
    DocTag = "NGPlus#3",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "案子破了。",
    Next = 213
}

DialogueConfig[213] = {
    Type = "Normal",
    DocTag = "NGPlus#4",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "本王知道。那就是块石头。",
    Next = 214
}

DialogueConfig[214] = {
    Type = "Normal",
    DocTag = "NGPlus#5",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "……你现在承认了？",
    Next = 215
}

DialogueConfig[215] = {
    Type = "Normal",
    DocTag = "NGPlus#6",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "本王从来都知道！爱心封印、鬼脸结界——",
    Next = 300
}

DialogueConfig[300] = {
    Type = "Normal",
    DocTag = "NGPlus#6b",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "都是本王亲自设计的考题！",
    Next = 216
}

DialogueConfig[216] = {
    Type = "Normal",
    DocTag = "NGPlus#7",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "鬼脸是小鸡画的。",
    Next = 217
}

DialogueConfig[217] = {
    Type = "Normal",
    DocTag = "NGPlus#8",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "……考题的一部分。",
    Next = 218
}

DialogueConfig[218] = {
    Type = "Normal",
    DocTag = "NGPlus#9",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（乌鸦别过脸，翅尖把白石头往身下按了按）",
    Next = 219
}

DialogueConfig[219] = {
    Type = "Normal",
    DocTag = "NGPlus#10",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "黑猫呢？你们和好了吗？",
    Next = 220
}

DialogueConfig[220] = {
    Type = "Normal",
    DocTag = "NGPlus#11",
    NpcName = "乌鸦",
    NpcSprite = "叫嚣",
    Dialogue = "那只黑毛？！昨天凌晨四点又来本王阵法边缘晃。",
    Next = 221
}

DialogueConfig[221] = {
    Type = "Normal",
    DocTag = "NGPlus#12",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "本王用碎玻璃反光晃了他一眼——",
    Next = 301
}

DialogueConfig[301] = {
    Type = "Normal",
    DocTag = "NGPlus#12b",
    NpcName = "乌鸦",
    NpcSprite = "吝啬",
    Dialogue = "他就甩着尾巴下去了。",
    Next = 222
}

DialogueConfig[222] = {
    Type = "Normal",
    DocTag = "NGPlus#13",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……还是没和好。",
    Next = 223
}

DialogueConfig[223] = {
    Type = "Normal",
    DocTag = "NGPlus#14",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "本王不需要和好。全农场最高的王，不需要。",
    Next = 224
}

DialogueConfig[224] = {
    Type = "Normal",
    DocTag = "NGPlus#15",
    NpcName = "乌鸦",
    NpcSprite = "得意",
    Dialogue = "下去吧，戴帽子的。",
    Next = 225
}

DialogueConfig[225] = {
    Type = "Normal",
    DocTag = "NGPlus#16",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（乌鸦用翅膀盖住白石头，低下头）",
    SetVariables = {
        { VarName = "Crow_NGPlusShown", VarType = "bool", Value = true }
    },
    Next = -1
}
