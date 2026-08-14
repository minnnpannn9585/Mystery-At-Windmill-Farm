-- 对话配置文件
-- 大树 ch1（树状准稿）→ heimao_tree_01_FROM_DOC.lua
-- Scene DialogueTrigger start ID should be 0 (entry dispatcher)
-- doc node map:
--   entry#0 -> DialogueConfig[0]
--   1-A -> DialogueConfig[1]
--   1-B -> DialogueConfig[100]

DialogueConfig = {}

-- ==================== entry#0 ====================

DialogueConfig[0] = {
    Type = "Normal",
    DocTag = "entry#0",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "Dog_BlackCatSummoned", VarType = "bool", TrueNext = -1, FalseNext = 79 }
    },
    Next = 79
}

DialogueConfig[79] = {
    Type = "Normal",
    DocTag = "entry#shake",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "BlackCat_TreeShakeStarted", VarType = "bool", TrueNext = -1, FalseNext = 80 }
    },
    Next = 80
}

DialogueConfig[80] = {
    Type = "Normal",
    DocTag = "entry#first",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "BlackCat_TreeHardShown", VarType = "bool", TrueNext = 100, FalseNext = 1 }
    },
    Next = 100
}

-- ==================== 1-A · 首次靠近 ====================

DialogueConfig[1] = {
    Type = "Normal",
    DocTag = "1-A#1",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "傻子在炫耀，瞎子在到处问。",
    Next = 2
}

DialogueConfig[2] = {
    Type = "Normal",
    DocTag = "1-A#2",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "谁？大树？大树说话了？",
    Next = 3
}

DialogueConfig[3] = {
    Type = "Normal",
    DocTag = "1-A#3",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "咳……是本树在说话。",
    Next = 4
}

DialogueConfig[4] = {
    Type = "Normal",
    DocTag = "1-A#4",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "你刚才说的傻子和瞎子——到底是谁？",
    Next = 5
}

DialogueConfig[5] = {
    Type = "Normal",
    DocTag = "1-A#5",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "……走吧，凡人。别踩我的根。",
    SetVariables = {
        { VarName = "BlackCat_TreeHardShown", VarType = "bool", Value = true }
    },
    Next = -1
}

-- ==================== 1-B · 点击大树轮播 ====================

DialogueConfig[100] = {
    Type = "Normal",
    DocTag = "1-B#gate",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "",
    ConditionBranches = {
        { VarName = "DogStatus", VarType = "int", Op = ">=", Value = 2, Next = 101 }
    },
    Next = 102
}

DialogueConfig[101] = {
    Type = "Normal",
    DocTag = "1-B#poolFull",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "",
    RotatePool = { 6, 11, 15, 19, 26 },
    Next = -1
}

DialogueConfig[102] = {
    Type = "Normal",
    DocTag = "1-B#poolBase",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "",
    RotatePool = { 6, 11, 15 },
    Next = -1
}

-- pool v1
DialogueConfig[6] = {
    Type = "Normal",
    DocTag = "1-B@v1#1",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "大树？",
    Next = 7
}
DialogueConfig[7] = {
    Type = "Normal",
    DocTag = "1-B@v1#2",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "你踩到我的根了。",
    Next = 8
}
DialogueConfig[8] = {
    Type = "Normal",
    DocTag = "1-B@v1#3",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "哦，对不起。",
    Next = 9
}
DialogueConfig[9] = {
    Type = "Normal",
    DocTag = "1-B@v1#4",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "……",
    Next = 10
}
DialogueConfig[10] = {
    Type = "Normal",
    DocTag = "1-B@v1#5",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "无趣。",
    Next = -1
}

-- pool v2
DialogueConfig[11] = {
    Type = "Normal",
    DocTag = "1-B@v2#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "大树，农场里出大事了，你知道吗？",
    Next = 12
}
DialogueConfig[12] = {
    Type = "Normal",
    DocTag = "1-B@v2#2",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "吵。",
    Next = 13
}
DialogueConfig[13] = {
    Type = "Normal",
    DocTag = "1-B@v2#3",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "什么吵？",
    Next = 14
}
DialogueConfig[14] = {
    Type = "Normal",
    DocTag = "1-B@v2#4",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "你说话，吵。",
    Next = -1
}

-- pool v3
DialogueConfig[15] = {
    Type = "Normal",
    DocTag = "1-B@v3#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "大树你每天在这里，能看到什么？",
    Next = 16
}
DialogueConfig[16] = {
    Type = "Normal",
    DocTag = "1-B@v3#2",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "凡人……只会看见想看见的。",
    Next = 17
}
DialogueConfig[17] = {
    Type = "Normal",
    DocTag = "1-B@v3#3",
    NpcName = "玩家",
    NpcSprite = "",
    Dialogue = "……听不太懂。",
    Next = 18
}
DialogueConfig[18] = {
    Type = "Normal",
    DocTag = "1-B@v3#4",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "走吧。",
    Next = -1
}

-- pool v4 (DogStatus>=2)
DialogueConfig[19] = {
    Type = "Normal",
    DocTag = "1-B@v4#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "大树，谷仓屋顶上是不是有什么东西？",
    Next = 20
}
DialogueConfig[20] = {
    Type = "Normal",
    DocTag = "1-B@v4#2",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "屋顶那只蠢鸟，还守着它的宝贝。",
    Next = 22
}
DialogueConfig[21] = {
    Type = "Normal",
    DocTag = "1-B@v4#3",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "还守着它的宝贝呢。",
    Next = 22
}
DialogueConfig[22] = {
    Type = "Normal",
    DocTag = "1-B@v4#4",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "什么宝贝？",
    Next = 23
}
DialogueConfig[23] = {
    Type = "Normal",
    DocTag = "1-B@v4#5",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "有什么好守的。",
    Next = 24
}
DialogueConfig[24] = {
    Type = "Normal",
    DocTag = "1-B@v4#6",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "你是说乌鸦吗？",
    Next = 25
}
DialogueConfig[25] = {
    Type = "Normal",
    DocTag = "1-B@v4#7",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "本树不指名道姓。",
    Next = -1
}

-- pool v5 (DogStatus>=2)
DialogueConfig[26] = {
    Type = "Normal",
    DocTag = "1-B@v5#1",
    NpcName = "玩家",
    NpcSprite = "疑惑",
    Dialogue = "大树，你有没有听到什么奇怪的声音？",
    Next = 27
}
DialogueConfig[27] = {
    Type = "Normal",
    DocTag = "1-B@v5#2",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "谷仓顶上那个，天没亮又叫起来了……",
    Next = 28
}
DialogueConfig[28] = {
    Type = "Normal",
    DocTag = "1-B@v5#3",
    NpcName = "玩家",
    NpcSprite = "惊讶",
    Dialogue = "谁在叫？",
    Next = 29
}
DialogueConfig[29] = {
    Type = "Normal",
    DocTag = "1-B@v5#4",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "每天四点。叫了三年。",
    Next = 30
}
DialogueConfig[30] = {
    Type = "Normal",
    DocTag = "1-B@v5#5",
    NpcName = "大树",
    NpcSprite = "",
    Dialogue = "……走吧。",
    Next = -1
}
