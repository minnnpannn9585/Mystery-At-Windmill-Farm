-- 闪电蜗牛 Flash（树状准稿）→ wuniu_01_FROM_DOC.lua
-- Scene DialogueTrigger start ID should be 0 (entry dispatcher)
-- doc node map:
--   entry#0 -> DialogueConfig[0]
--   gate80–85 -> DialogueConfig[80–85]（85 = DogStatus==4 后再判 Dog_BlackCatSummoned）
--   F-1 -> DialogueConfig[1]
--   F-2 -> DialogueConfig[10]
--   F-3 -> DialogueConfig[20]
--   F-4 -> DialogueConfig[30]
--   F-5 -> DialogueConfig[40]
--   F-6 -> DialogueConfig[50]

DialogueConfig = {}

-- ==================== entry#0 ====================

DialogueConfig[0] = {
    Type = "Normal",
    DocTag = "entry#0",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "NGPlus", VarType = "bool", TrueNext = 80, FalseNext = 81 }
    },
    Next = 81
}

DialogueConfig[80] = {
    Type = "Normal",
    DocTag = "entry#ngplus",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Flash_Stage6Shown", VarType = "bool", TrueNext = 40, FalseNext = 50 }
    },
    Next = 50
}

DialogueConfig[81] = {
    Type = "Normal",
    DocTag = "entry#week1-dog4",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "DogStatus", VarType = "int", Op = "==", Value = 4, Next = 85 }
    },
    Next = 82
}

DialogueConfig[85] = {
    Type = "Normal",
    DocTag = "entry#week1-dog4-cat",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Dog_BlackCatSummoned", VarType = "bool", TrueNext = 40, FalseNext = 82 }
    },
    Next = 82
}

DialogueConfig[82] = {
    Type = "Normal",
    DocTag = "entry#chick3",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "ChickStatus", VarType = "int", Op = ">=", Value = 3, Next = 30 }
    },
    Next = 83
}

DialogueConfig[83] = {
    Type = "Normal",
    DocTag = "entry#e10",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "E10_ViewWhiteStone", VarType = "bool", TrueNext = 20, FalseNext = 84 }
    },
    Next = 84
}

DialogueConfig[84] = {
    Type = "Normal",
    DocTag = "entry#dog2",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "DogStatus", VarType = "int", Op = ">=", Value = 2, Next = 10 }
    },
    Next = 1
}

-- ==================== F-1 · 阶段 1 ====================

DialogueConfig[1] = {
    Type = "Normal",
    DocTag = "F-1#1",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（宽叶上，一只极小蜗牛眼柄慢慢转向你）",
    Next = 2
}

DialogueConfig[2] = {
    Type = "Normal",
    DocTag = "F-1#2",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "我……",
    Next = 3
}

DialogueConfig[3] = {
    Type = "Normal",
    DocTag = "F-1#3",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "看……",
    Next = 4
}

DialogueConfig[4] = {
    Type = "Normal",
    DocTag = "F-1#4",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "见……",
    Next = 5
}

DialogueConfig[5] = {
    Type = "Normal",
    DocTag = "F-1#5",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（眼柄又转回去，像一句话说累了）",
    Next = 6
}

DialogueConfig[6] = {
    Type = "Normal",
    DocTag = "F-1#6",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "这蜗牛……话说到一半就没有了？",
    Next = -1
}

-- ==================== F-2 · 阶段 2 ====================

DialogueConfig[10] = {
    Type = "Normal",
    DocTag = "F-2#1",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "我……",
    Next = 11
}

DialogueConfig[11] = {
    Type = "Normal",
    DocTag = "F-2#2",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "看……",
    Next = 12
}

DialogueConfig[12] = {
    Type = "Normal",
    DocTag = "F-2#3",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "见……",
    Next = 13
}

DialogueConfig[13] = {
    Type = "Normal",
    DocTag = "F-2#4",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "乌……鸦……",
    Next = 14
}

DialogueConfig[14] = {
    Type = "Normal",
    DocTag = "F-2#5",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "叼……走……了……",
    Next = 15
}

DialogueConfig[15] = {
    Type = "Normal",
    DocTag = "F-2#6",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蜗牛停住，壳纹丝不动）",
    Next = 16
}

DialogueConfig[16] = {
    Type = "Normal",
    DocTag = "F-2#7",
    NpcName = "玩家",
    NpcSprite = "正常",
    Dialogue = "——乌鸦？叼走了什么？你倒是说完啊……",
    Next = -1
}

-- ==================== F-3 · 阶段 3 ====================

DialogueConfig[20] = {
    Type = "Normal",
    DocTag = "F-3#1",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "我……",
    Next = 21
}

DialogueConfig[21] = {
    Type = "Normal",
    DocTag = "F-3#2",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "看……",
    Next = 22
}

DialogueConfig[22] = {
    Type = "Normal",
    DocTag = "F-3#3",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "见……",
    Next = 23
}

DialogueConfig[23] = {
    Type = "Normal",
    DocTag = "F-3#4",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "乌……鸦……",
    Next = 24
}

DialogueConfig[24] = {
    Type = "Normal",
    DocTag = "F-3#5",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "叼……走……了……",
    Next = 25
}

DialogueConfig[25] = {
    Type = "Normal",
    DocTag = "F-3#6",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "白……",
    Next = 26
}

DialogueConfig[26] = {
    Type = "Normal",
    DocTag = "F-3#7",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "石……",
    Next = 27
}

DialogueConfig[27] = {
    Type = "Normal",
    DocTag = "F-3#8",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "头……",
    Next = 28
}

DialogueConfig[28] = {
    Type = "Normal",
    DocTag = "F-3#9",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蜗牛眼柄垂下来，像还有下半句）",
    Next = 29
}

DialogueConfig[29] = {
    Type = "Normal",
    DocTag = "F-3#10",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "白石头？！你早就看见了？！后面呢？！",
    Next = -1
}

-- ==================== F-4 · 阶段 4 ====================

DialogueConfig[30] = {
    Type = "Normal",
    DocTag = "F-4#1",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "我……",
    Next = 31
}

DialogueConfig[31] = {
    Type = "Normal",
    DocTag = "F-4#2",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "看……",
    Next = 32
}

DialogueConfig[32] = {
    Type = "Normal",
    DocTag = "F-4#3",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "见……",
    Next = 33
}

DialogueConfig[33] = {
    Type = "Normal",
    DocTag = "F-4#4",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "乌……鸦……",
    Next = 34
}

DialogueConfig[34] = {
    Type = "Normal",
    DocTag = "F-4#5",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "叼……走……了……",
    Next = 35
}

DialogueConfig[35] = {
    Type = "Normal",
    DocTag = "F-4#6",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "白……石……头……，",
    Next = 36
}

DialogueConfig[36] = {
    Type = "Normal",
    DocTag = "F-4#7",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "真……蛋……被……",
    Next = 37
}

DialogueConfig[37] = {
    Type = "Normal",
    DocTag = "F-4#8",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蜗牛眼柄垂下来，像卡在最后一个字上）",
    Next = 38
}

DialogueConfig[38] = {
    Type = "Normal",
    DocTag = "F-4#9",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "真蛋被……怎么了？！接着说啊！！",
    Next = -1
}

-- ==================== F-5 · 阶段 5 ====================

DialogueConfig[40] = {
    Type = "Normal",
    DocTag = "F-5#1",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "我……",
    Next = 41
}

DialogueConfig[41] = {
    Type = "Normal",
    DocTag = "F-5#2",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "看……",
    Next = 42
}

DialogueConfig[42] = {
    Type = "Normal",
    DocTag = "F-5#3",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "见……",
    Next = 43
}

DialogueConfig[43] = {
    Type = "Normal",
    DocTag = "F-5#4",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "乌……鸦……",
    Next = 44
}

DialogueConfig[44] = {
    Type = "Normal",
    DocTag = "F-5#5",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "叼……走……了……",
    Next = 45
}

DialogueConfig[45] = {
    Type = "Normal",
    DocTag = "F-5#6",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "白……石……头……，",
    Next = 46
}

DialogueConfig[46] = {
    Type = "Normal",
    DocTag = "F-5#7",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "真……蛋……被……",
    Next = 47
}

DialogueConfig[47] = {
    Type = "Normal",
    DocTag = "F-5#8",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "主……人……",
    Next = 48
}

DialogueConfig[48] = {
    Type = "Normal",
    DocTag = "F-5#9",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蜗牛彻底不动了）",
    Next = 49
}

DialogueConfig[49] = {
    Type = "Normal",
    DocTag = "F-5#10",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "主人？！被主人怎么了？！不指望你了，去找黑猫开门！",
    Next = -1
}

-- ==================== F-6 · 阶段 6（二周目 · 一次性） ====================

DialogueConfig[50] = {
    Type = "Normal",
    DocTag = "F-6#1",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "我……",
    Next = 51
}

DialogueConfig[51] = {
    Type = "Normal",
    DocTag = "F-6#2",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "看……",
    Next = 52
}

DialogueConfig[52] = {
    Type = "Normal",
    DocTag = "F-6#3",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "见……",
    Next = 53
}

DialogueConfig[53] = {
    Type = "Normal",
    DocTag = "F-6#4",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "乌……鸦……",
    Next = 54
}

DialogueConfig[54] = {
    Type = "Normal",
    DocTag = "F-6#5",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "叼……走……了……",
    Next = 55
}

DialogueConfig[55] = {
    Type = "Normal",
    DocTag = "F-6#6",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "白……石……头……，",
    Next = 56
}

DialogueConfig[56] = {
    Type = "Normal",
    DocTag = "F-6#7",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "真……蛋……被……主……人……",
    Next = 57
}

DialogueConfig[57] = {
    Type = "Normal",
    DocTag = "F-6#8",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "抱……进……了……屋……子……",
    Next = 58
}

DialogueConfig[58] = {
    Type = "Normal",
    DocTag = "F-6#9",
    NpcName = "描述",
    NpcSprite = "",
    Dialogue = "（蜗牛眼柄对准你，极慢地眨了一下）",
    Next = 59
}

DialogueConfig[59] = {
    Type = "Normal",
    DocTag = "F-6#10",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "跑遍整个农场……你倒好，永远说到一半……",
    Next = 60
}

DialogueConfig[60] = {
    Type = "Normal",
    DocTag = "F-6#11",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "大……侦……探……，",
    Next = 61
}

DialogueConfig[61] = {
    Type = "Normal",
    DocTag = "F-6#12",
    NpcName = "闪电蜗牛",
    NpcSprite = "待机",
    Dialogue = "案……子……破……了……吗……？",
    SetVariables = {
        { VarName = "Flash_Stage6Shown", VarType = "bool", Value = true }
    },
    Next = -1
}
