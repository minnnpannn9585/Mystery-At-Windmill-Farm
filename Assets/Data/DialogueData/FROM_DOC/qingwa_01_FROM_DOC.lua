-- 对话配置文件
-- 悲伤蛙树状准稿 → qingwa_01_FROM_DOC.lua
-- Scene DialogueTrigger start ID should be 0 (entry dispatcher)
-- doc node map:
--   entry#0 -> DialogueConfig[0]
--   2-A -> DialogueConfig[1]
--   2-hub-intro -> DialogueConfig[100]
--   2-hub#menu -> DialogueConfig[200]
--   2-hub#return#menu -> DialogueConfig[205]
--   2-B -> DialogueConfig[16]
--   2-C -> DialogueConfig[21]
--   2-D -> DialogueConfig[24]
--   3-hub-intro -> DialogueConfig[40]
--   3-hub#menu -> DialogueConfig[600]
--   3-hub#return#menu -> DialogueConfig[605]
--   3-A -> DialogueConfig[42]
--   3-B -> DialogueConfig[50]
--   3-C -> DialogueConfig[52]
--   3-D -> DialogueConfig[64]
--   NGPlus -> DialogueConfig[297]

DialogueConfig = {}

-- ==================== entry#0 ====================

DialogueConfig[0] = {
    Type = "Normal",
    DocTag = "entry#0",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "NGPlus", VarType = "bool", TrueNext = 297, FalseNext = 80 }
    },
    Next = 80
}

DialogueConfig[80] = {
    Type = "Normal",
    DocTag = "entry#first",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Frog_FirstMeetShown", VarType = "bool", TrueNext = 81, FalseNext = 1 }
    },
    Next = 81
}

DialogueConfig[81] = {
    Type = "Normal",
    DocTag = "entry#mint",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "BlackCat_MintFishPending", VarType = "bool", TrueNext = 82, FalseNext = 100 }
    },
    Next = 100
}

DialogueConfig[82] = {
    Type = "Normal",
    DocTag = "entry#mint2",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "MintFish_Obtained", VarType = "bool", TrueNext = 100, FalseNext = 40 }
    },
    Next = 100
}

-- ==================== 2-A · 首次对话 ====================

DialogueConfig[1] = {
    Type = "Normal",
    DocTag = "2-A#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（一股刺鼻的草本甜味，混着池水腥气）",
    Next = 2
}

DialogueConfig[2] = {
    Type = "Normal",
    DocTag = "2-A#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……你来了。",
    Next = 3
}

DialogueConfig[3] = {
    Type = "Normal",
    DocTag = "2-A#3",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "或者……你只是路过这片死水。",
    Next = 4
}

DialogueConfig[4] = {
    Type = "Normal",
    DocTag = "2-A#4",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "……这里是你的地方？",
    Next = 5
}

DialogueConfig[5] = {
    Type = "Normal",
    DocTag = "2-A#5",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "这里是虚无的地方。",
    Next = 6
}

DialogueConfig[6] = {
    Type = "Normal",
    DocTag = "2-A#6",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "我在这儿坐了很久了。",
    SetVariables = {
        { VarName = "Frog_FirstMeetShown", VarType = "bool", Value = true }
    },
    Next = 200  -- 2-hub（首访不经 intro，同淑芬 1-A→1-hub）
}

-- ==================== 2-hub-intro · 条件轮播 ====================

DialogueConfig[100] = {
    Type = "Normal",
    DocTag = "2-hub-intro#gate",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Frog_WaterMonsterQueried", VarType = "bool", TrueNext = 150, FalseNext = 101 }
    },
    Next = 101
}

DialogueConfig[101] = {
    Type = "Normal",
    DocTag = "2-hub-intro#poolA",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    RotatePool = { 110, 120, 130, 140 },
    Next = 200
}

-- pool A v1
DialogueConfig[110] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v1#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（水面纹丝不动）",
    Next = 111
}
DialogueConfig[111] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v1#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "今天的水……跟昨天的水一样。",
    Next = 112
}
DialogueConfig[112] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v1#3",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "但昨天已经消失了。",
    Next = 113
}
DialogueConfig[113] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v1#4",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "所以其实……不一样。",
    Next = 200
}

-- pool A v2
DialogueConfig[120] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v2#1",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……你好。",
    Next = 121
}
DialogueConfig[121] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v2#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "好什么好。",
    Next = 122
}
DialogueConfig[122] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v2#3",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（水面重归沉默）",
    Next = 123
}
DialogueConfig[123] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v2#4",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……来过就是来过。",
    Next = 200
}

-- pool A v3
DialogueConfig[130] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v3#1",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "活着，就是在等一个不会来的东西。",
    Next = 131
}
DialogueConfig[131] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v3#2",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "等……什么？",
    Next = 132
}
DialogueConfig[132] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v3#3",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "不知道。",
    Next = 133
}
DialogueConfig[133] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v3#4",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "可感觉上，就是在等。",
    Next = 200
}

-- pool A v4
DialogueConfig[140] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v4#1",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "农场里出事了……",
    Next = 141
}
DialogueConfig[141] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v4#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "一直在出事。",
    Next = 142
}
DialogueConfig[142] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v4#3",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "只是你们才刚注意到。",
    Next = 200
}

DialogueConfig[150] = {
    Type = "Normal",
    DocTag = "2-hub-intro#poolB",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    RotatePool = { 151, 160, 165 },
    Next = 200
}

-- pool B v1
DialogueConfig[151] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v5#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙重新盯向水面，不再看过来）",
    Next = 152
}
DialogueConfig[152] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v5#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "你已经知道了。",
    Next = 153
}
DialogueConfig[153] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v5#3",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "但知道了也没有用。",
    Next = 200
}

-- pool B v2
DialogueConfig[160] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v6#1",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……虚无不会因为被发现而消失。",
    Next = 200
}

-- pool B v3
DialogueConfig[165] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v7#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "……你还好吗？",
    Next = 166
}
DialogueConfig[166] = {
    Type = "Normal",
    DocTag = "2-hub-intro@v7#2",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "还好，是一种很奢侈的状态。",
    Next = 200
}

-- ==================== 2-hub · 主菜单 ====================

DialogueConfig[200] = {
    Type = "Question",
    DocTag = "2-hub#menu",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……",
    Options = {
        {
            Text = "水怪……这池塘里真的有水怪？",
            Next = 24,
            DisplayConditions = {
                { VarName = "ChickStatus", VarType = "int", Op = ">=", Value = 2 },
                { VarName = "Frog_WaterMonsterQueried", VarType = "bool", Value = false }
            },
        },
        {
            Text = "这里有没有见过……一颗蛋？",
            Next = 16,
            DisplayConditions = {
                { VarName = "Shufen_CommissionDone", VarType = "bool", Value = true },
                { VarName = "Frog_EggAsked", VarType = "bool", Value = false }
            },
        },
        {
            Text = "谷仓那边……你去过吗？",
            Next = 21,
            DisplayConditions = {
                { VarName = "E07_ViewNapSpot", VarType = "bool", Value = true },
                { VarName = "Frog_NapSpotAsked", VarType = "bool", Value = false }
            },
        },
        {
            Text = "……",
            Next = -1,
        }
    }
}

DialogueConfig[205] = {
    Type = "Question",
    DocTag = "2-hub#return#menu",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……还有事吗？",
    Options = {
        {
            Text = "水怪……这池塘里真的有水怪？",
            Next = 24,
            DisplayConditions = {
                { VarName = "ChickStatus", VarType = "int", Op = ">=", Value = 2 },
                { VarName = "Frog_WaterMonsterQueried", VarType = "bool", Value = false }
            },
        },
        {
            Text = "这里有没有见过……一颗蛋？",
            Next = 16,
            DisplayConditions = {
                { VarName = "Shufen_CommissionDone", VarType = "bool", Value = true },
                { VarName = "Frog_EggAsked", VarType = "bool", Value = false }
            },
        },
        {
            Text = "谷仓那边……你去过吗？",
            Next = 21,
            DisplayConditions = {
                { VarName = "E07_ViewNapSpot", VarType = "bool", Value = true },
                { VarName = "Frog_NapSpotAsked", VarType = "bool", Value = false }
            },
        },
        {
            Text = "……",
            Next = -1,
        }
    }
}

-- ==================== 2-B · 蛋 ====================

DialogueConfig[16] = {
    Type = "Normal",
    DocTag = "2-B#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "这里有没有见过……一颗蛋？",
    Next = 17
}

DialogueConfig[17] = {
    Type = "Normal",
    DocTag = "2-B#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "蛋……什么蛋。",
    Next = 18
}

DialogueConfig[18] = {
    Type = "Normal",
    DocTag = "2-B#3",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "这片水里，早就没有新生了。",
    Next = 19
}

DialogueConfig[19] = {
    Type = "Normal",
    DocTag = "2-B#4",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "所以是……有，还是没有？",
    Next = 20
}

DialogueConfig[20] = {
    Type = "Normal",
    DocTag = "2-B#5",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "问错了人。",
    SetVariables = {
        { VarName = "Frog_EggAsked", VarType = "bool", Value = true }
    },
    Next = 205
}

-- ==================== 2-C · 谷仓 ====================

DialogueConfig[21] = {
    Type = "Normal",
    DocTag = "2-C#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "谷仓那边……你去过吗？",
    Next = 22
}

DialogueConfig[22] = {
    Type = "Normal",
    DocTag = "2-C#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "我只趴水边。",
    Next = 23
}

DialogueConfig[23] = {
    Type = "Normal",
    DocTag = "2-C#3",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "离水远的地方……连虚无都是干的。",
    SetVariables = {
        { VarName = "Frog_NapSpotAsked", VarType = "bool", Value = true }
    },
    Next = 205
}

-- ==================== 2-D · 水怪质询 ====================

DialogueConfig[24] = {
    Type = "Normal",
    DocTag = "2-D#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "水怪……这池塘里真的有水怪？",
    Next = 25
}

DialogueConfig[25] = {
    Type = "Normal",
    DocTag = "2-D#2",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙缓缓转头，目光第一次落过来，却散着）",
    Next = 26
}

DialogueConfig[26] = {
    Type = "Normal",
    DocTag = "2-D#3",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "水怪。",
    Next = 27
}

DialogueConfig[27] = {
    Type = "Normal",
    DocTag = "2-D#4",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "……没有水怪。",
    Next = 28
}

DialogueConfig[28] = {
    Type = "Normal",
    DocTag = "2-D#5",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "但有比水怪更让人心碎的东西。",
    Next = 29
}

DialogueConfig[29] = {
    Type = "Normal",
    DocTag = "2-D#6",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "这片水……看着一样接一样地消失。",
    Next = 30
}

DialogueConfig[30] = {
    Type = "Normal",
    DocTag = "2-D#7",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（水面平静，什么痕迹都没留下）",
    Next = 31
}

DialogueConfig[31] = {
    Type = "Normal",
    DocTag = "2-D#8",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "纯净，第一个死去。",
    Next = 32
}

DialogueConfig[32] = {
    Type = "Normal",
    DocTag = "2-D#9",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "然后……冰冷的器皿来了。",
    Next = 33
}

DialogueConfig[33] = {
    Type = "Normal",
    DocTag = "2-D#10",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙低头盯着水面，久久不抬）",
    Next = 34
}

DialogueConfig[34] = {
    Type = "Normal",
    DocTag = "2-D#11",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "生命之源……在枯竭。",
    Next = 35
}

DialogueConfig[35] = {
    Type = "Normal",
    DocTag = "2-D#12",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "一个黑色的恶魔……",
    Next = 36
}

DialogueConfig[36] = {
    Type = "Normal",
    DocTag = "2-D#13",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙喉咙动了一下，又哑住）",
    Next = 37
}

DialogueConfig[37] = {
    Type = "Normal",
    DocTag = "2-D#14",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "它带走了宝珠。",
    Next = 38
}

DialogueConfig[38] = {
    Type = "Normal",
    DocTag = "2-D#15",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "什么都不剩。",
    Next = 39
}

DialogueConfig[39] = {
    Type = "Normal",
    DocTag = "2-D#16",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……你到底在说什么。",
    SetVariables = {
        { VarName = "Frog_WaterMonsterQueried", VarType = "bool", Value = true }
    },
    Next = 205
}

-- ==================== 3-hub-intro ====================

DialogueConfig[40] = {
    Type = "Normal",
    DocTag = "3-hub-intro#1",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……又有东西来了。",
    Next = 41
}

DialogueConfig[41] = {
    Type = "Normal",
    DocTag = "3-hub-intro#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "或者……又有东西要走了。",
    Next = 600
}

-- ==================== 3-hub · 薄荷鱼菜单 ====================

DialogueConfig[600] = {
    Type = "Question",
    DocTag = "3-hub#menu",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……",
    Options = {
        {
            Text = "你身下那块绿垫子……能给我吗？",
            Next = 421,
            DisplayConditions = {
                { VarName = "Frog_PadRefused", VarType = "bool", Value = false },
                { VarName = "MintFish_Obtained", VarType = "bool", Value = false }
            },
            DisplayAnyConditions = {
                { VarName = "E12_ViewGreenPad", VarType = "bool", Value = true },
                { VarName = "Mouse_MintFishPaid", VarType = "bool", Value = true }
            },
        },
        {
            Text = "……我见过好多只跟你一样的蛙。",
            Next = 64,
            DisplayConditions = {
                { VarName = "Mouse_FrogFallbackGiven", VarType = "bool", Value = true },
                { VarName = "MintFish_Obtained", VarType = "bool", Value = false }
            },
        },
        {
            Text = "……",
            Next = -1,
        }
    }
}

DialogueConfig[605] = {
    Type = "Question",
    DocTag = "3-hub#return#menu",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……嗯。",
    Options = {
        {
            Text = "你身下那块绿垫子……能给我吗？",
            Next = 421,
            DisplayConditions = {
                { VarName = "Frog_PadRefused", VarType = "bool", Value = false },
                { VarName = "MintFish_Obtained", VarType = "bool", Value = false }
            },
            DisplayAnyConditions = {
                { VarName = "E12_ViewGreenPad", VarType = "bool", Value = true },
                { VarName = "Mouse_MintFishPaid", VarType = "bool", Value = true }
            },
        },
        {
            Text = "……我见过好多只跟你一样的蛙。",
            Next = 64,
            DisplayConditions = {
                { VarName = "Mouse_FrogFallbackGiven", VarType = "bool", Value = true },
                { VarName = "MintFish_Obtained", VarType = "bool", Value = false }
            },
        },
        {
            Text = "……",
            Next = -1,
        }
    }
}

-- ==================== 3-A · 对暗号（三轮） ====================

DialogueConfig[421] = {
    Type = "Normal",
    DocTag = "3-A#gate",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Mouse_MintFishPaid", VarType = "bool", TrueNext = 422, FalseNext = 42 }
    },
    Next = 42
}

DialogueConfig[422] = {
    Type = "Normal",
    DocTag = "3-A#supplement",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "E12_ViewGreenPad", VarType = "bool", TrueNext = 42, FalseNext = 423 }
    },
    Next = 42
}

DialogueConfig[423] = {
    Type = "Normal",
    DocTag = "3-A#supplement#set",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    SetVariables = {
        { VarName = "E12_ViewGreenPad", VarType = "bool", Value = true }
    },
    Next = 42
}

DialogueConfig[42] = {
    Type = "Normal",
    DocTag = "3-A#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "你身下那块绿垫子……能给我吗？",
    Next = 43
}

DialogueConfig[43] = {
    Type = "Normal",
    DocTag = "3-A#2",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙身下压着绿油油的东西，一阵草本甜气从那里飘过来）",
    Next = 44
}

DialogueConfig[44] = {
    Type = "Normal",
    DocTag = "3-A#3",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙低头看了一眼身下，再抬头，目光仍散着）",
    Next = 430
}

DialogueConfig[430] = {
    Type = "Question",
    DocTag = "3-A#r1",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……你来这里，是因为什么？",
    Options = {
        { Text = "我来拿你身下那块绿垫子。", Next = 606 },
        { Text = "因为我在找丢失的蛋。", Next = 607 },
        { Text = "……不知道。感觉到了，就来了。", Next = 608 },
    }
}

DialogueConfig[46] = {
    Type = "Normal",
    DocTag = "3-A#4",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙没有立刻回应，视线在水面上停了一会儿）",
    Next = 472
}

DialogueConfig[472] = {
    Type = "Question",
    DocTag = "3-A#r2",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "你懂什么叫失去吗？",
    Options = {
        { Text = "懂。丢了还能找回来。", Next = 609 },
        { Text = "懂。我丢过重要的东西。", Next = 610 },
        { Text = "……不懂。或者说，懂了又怎样。", Next = 611 },
    }
}

DialogueConfig[48] = {
    Type = "Normal",
    DocTag = "3-A#5",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙视线从水面慢慢移到身下，又移回来）",
    Next = 492
}

DialogueConfig[492] = {
    Type = "Question",
    DocTag = "3-A#r3",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "它一直陪着我……直到现在。",
    Options = {
        { Text = "那你留着吧。我不拿了。", Next = 612 },
        { Text = "但它现在该让人带走了。", Next = 613 },
        { Text = "……陪着，也是一种消耗。", Next = 614 },
    }
}

-- 3-A 选项 → 玩家首句 stub
DialogueConfig[606] = {
    Type = "Normal",
    DocTag = "3-A#r1#pick-A",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "我来拿你身下那块绿垫子。",
    Next = 50
}

DialogueConfig[607] = {
    Type = "Normal",
    DocTag = "3-A#r1#pick-B",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "因为我在找丢失的蛋。",
    Next = 50
}

DialogueConfig[608] = {
    Type = "Normal",
    DocTag = "3-A#r1#pick-C",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……不知道。感觉到了，就来了。",
    Next = 46
}

DialogueConfig[609] = {
    Type = "Normal",
    DocTag = "3-A#r2#pick-A",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "懂。丢了还能找回来。",
    Next = 50
}

DialogueConfig[610] = {
    Type = "Normal",
    DocTag = "3-A#r2#pick-B",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "懂。我丢过重要的东西。",
    Next = 50
}

DialogueConfig[611] = {
    Type = "Normal",
    DocTag = "3-A#r2#pick-C",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……不懂。或者说，懂了又怎样。",
    Next = 48
}

DialogueConfig[612] = {
    Type = "Normal",
    DocTag = "3-A#r3#pick-A",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "那你留着吧。我不拿了。",
    Next = 50
}

DialogueConfig[613] = {
    Type = "Normal",
    DocTag = "3-A#r3#pick-B",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "但它现在该让人带走了。",
    Next = 50
}

DialogueConfig[614] = {
    Type = "Normal",
    DocTag = "3-A#r3#pick-C",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……陪着，也是一种消耗。",
    Next = 52
}

-- ==================== 3-B · 对暗号失败 ====================

DialogueConfig[50] = {
    Type = "Normal",
    DocTag = "3-B#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙重新盯向水面，不再看过来）",
    Next = 51
}

DialogueConfig[51] = {
    Type = "Normal",
    DocTag = "3-B#2",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "……你还没懂。",
    SetVariables = {
        { VarName = "Frog_PadRefused", VarType = "bool", Value = true }
    },
    Next = 605
}

-- ==================== 3-C · 成功交出薄荷鱼 ====================

DialogueConfig[52] = {
    Type = "Normal",
    DocTag = "3-C#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙缓缓挪开身体，绿色的东西露出来，草本甜气骤然加重）",
    Next = 53
}

DialogueConfig[53] = {
    Type = "Normal",
    DocTag = "3-C#2",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "……拿去吧。",
    Next = 54
}

DialogueConfig[54] = {
    Type = "Normal",
    DocTag = "3-C#3",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "它散发着腐朽又甜的气味……",
    Next = 55
}

DialogueConfig[55] = {
    Type = "Normal",
    DocTag = "3-C#4",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "像生命流走时，那种让人发晕的气息。",
    Next = 56
}

DialogueConfig[56] = {
    Type = "Normal",
    DocTag = "3-C#5",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "既然你要把这片虚无收走……",
    Next = 57
}

DialogueConfig[57] = {
    Type = "Normal",
    DocTag = "3-C#6",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙重新望向水面，眼神比刚才更空）",
    Next = 58
}

DialogueConfig[58] = {
    Type = "Normal",
    DocTag = "3-C#7",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "……那就都给你。",
    Next = 59
}

DialogueConfig[59] = {
    Type = "Normal",
    DocTag = "3-C#8",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "这东西……你一直坐在上面？",
    Next = 60
}

DialogueConfig[60] = {
    Type = "Normal",
    DocTag = "3-C#9",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "它和我一样……正在腐烂。",
    Next = 61
}

DialogueConfig[61] = {
    Type = "Normal",
    DocTag = "3-C#10",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "但至少还留着气味。",
    Next = 62
}

DialogueConfig[62] = {
    Type = "Normal",
    DocTag = "3-C#11",
    NpcName = "悲伤蛙",
    NpcSprite = "丧",
    Dialogue = "证明曾经存在过。",
    Next = 63
}

DialogueConfig[63] = {
    Type = "Normal",
    DocTag = "3-C#12",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（一阵风掠过，水面荡开，月影散了又聚）",
    SetVariables = {
        { VarName = "MintFish_Obtained", VarType = "bool", Value = true }
    },
    Next = 605
}

-- ==================== 3-D · 威胁路径 ====================

DialogueConfig[64] = {
    Type = "Normal",
    DocTag = "3-D#1",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……我见过好多只跟你一样的蛙。",
    Next = 65
}

DialogueConfig[65] = {
    Type = "Normal",
    DocTag = "3-D#2",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙缓缓转头，目光第一次集中起来）",
    Next = 66
}

DialogueConfig[66] = {
    Type = "Normal",
    DocTag = "3-D#3",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "……什么？",
    Next = 67
}

DialogueConfig[67] = {
    Type = "Normal",
    DocTag = "3-D#4",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "一样的台词，一样的姿势，一样的池塘。",
    Next = 68
}

DialogueConfig[68] = {
    Type = "Normal",
    DocTag = "3-D#5",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "你是这个地区的第七名。",
    Next = 69
}

DialogueConfig[69] = {
    Type = "Normal",
    DocTag = "3-D#6",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙发呆了好几秒，眼睛猛地定住）",
    Next = 70
}

DialogueConfig[70] = {
    Type = "Normal",
    DocTag = "3-D#7",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "……第七。",
    Next = 71
}

DialogueConfig[71] = {
    Type = "Normal",
    DocTag = "3-D#8",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（沉默片刻）",
    Next = 72
}

DialogueConfig[72] = {
    Type = "Normal",
    DocTag = "3-D#9",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "……第七？",
    Next = 73
}

DialogueConfig[73] = {
    Type = "Normal",
    DocTag = "3-D#10",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙低头，慢慢把身下的东西推了出来，不说话）",
    Next = 74
}

DialogueConfig[74] = {
    Type = "Normal",
    DocTag = "3-D#11",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙把身体偏向另一侧，不再看这边）",
    SetVariables = {
        { VarName = "MintFish_Obtained", VarType = "bool", Value = true }
    },
    Next = 605
}

-- ==================== NGPlus · 二周目轮播 ====================
-- 二周目薄荷鱼线必已完成；四条等权轮播，不再分 MintFish 条件池。

DialogueConfig[297] = {
    Type = "Normal",
    DocTag = "NGPlus#gate",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    Next = 298
}

DialogueConfig[296] = {
    Type = "Normal",
    DocTag = "NGPlus",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    RotatePool = { 301, 305, 310, 320 },
    Next = -1
}

DialogueConfig[298] = {
    Type = "Normal",
    DocTag = "NGPlus",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "",
    RotatePool = { 301, 305, 310, 320 },
    Next = -1
}

-- NGPlus v1
DialogueConfig[301] = {
    Type = "Normal",
    DocTag = "NGPlus@v1#1",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "宝珠……昨夜又浮上来了。",
    Next = 302
}
DialogueConfig[302] = {
    Type = "Normal",
    DocTag = "NGPlus@v1#2",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "沉入深渊的，从来只是倒影。",
    Next = 303
}
DialogueConfig[303] = {
    Type = "Normal",
    DocTag = "NGPlus@v1#3",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（水面平静，月影完整）",
    Next = -1
}

-- NGPlus v2
DialogueConfig[305] = {
    Type = "Normal",
    DocTag = "NGPlus@v2#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙没有转头）",
    Next = 306
}
DialogueConfig[306] = {
    Type = "Normal",
    DocTag = "NGPlus@v2#2",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "黑色的恶魔……也许只是恨自己的倒影。",
    Next = 307
}
DialogueConfig[307] = {
    Type = "Normal",
    DocTag = "NGPlus@v2#3",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "恨的，不止它一个。",
    Next = -1
}

-- NGPlus v3
DialogueConfig[310] = {
    Type = "Normal",
    DocTag = "NGPlus@v3#1",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "生命之源……仍在被舀走。",
    Next = 311
}
DialogueConfig[311] = {
    Type = "Normal",
    DocTag = "NGPlus@v3#2",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "虚无依然存在。",
    Next = 312
}
DialogueConfig[312] = {
    Type = "Normal",
    DocTag = "NGPlus@v3#3",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……该查的，都查完了。",
    Next = 313
}
DialogueConfig[313] = {
    Type = "Normal",
    DocTag = "NGPlus@v3#4",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "查完什么……虚无还是虚无。",
    Next = -1
}

-- NGPlus v4（腐朽浮木；二周目与前三条等权轮播）
DialogueConfig[320] = {
    Type = "Normal",
    DocTag = "NGPlus@v4#1",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "那块腐朽浮木走了……",
    Next = 321
}
DialogueConfig[321] = {
    Type = "Normal",
    DocTag = "NGPlus@v4#2",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "身下空了，冰凉。",
    Next = 322
}
DialogueConfig[322] = {
    Type = "Normal",
    DocTag = "NGPlus@v4#3",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蛙叹了一口气）",
    Next = 323
}
DialogueConfig[323] = {
    Type = "Normal",
    DocTag = "NGPlus@v4#4",
    NpcName = "悲伤蛙",
    NpcSprite = "介入",
    Dialogue = "……倒也契合。",
    Next = -1
}
