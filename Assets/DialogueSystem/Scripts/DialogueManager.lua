--对话配置文件
---@var DialogueConfig :DouyinScript
--立绘图片
---@var Sprites :UnityEngine.Sprite[]
---@end

--对话面板
local dialoguePanel
--左边角色立绘
local roleLeft
--右边角色立绘
local roleRight
--左边角色名字文本
local leftName
--右边角色名字文本
local rightName
--对话文本
local dialogueText

--NPC立绘
local allSprite={}
--当前剧情ID
local currentDialogueID=-1

function Awake()
    _G["_DialogueManager"] = self.script
    dialoguePanel=self.transform:Find("Canvas/DialoguePanel")
    roleLeft=dialoguePanel:Find("Background/Role_Left"):GetComponent(typeof(UnityEngine.UI.Image))
    roleRight=dialoguePanel:Find("Background/Role_Right"):GetComponent(typeof(UnityEngine.UI.Image))
    leftName=dialoguePanel:Find("Background/Name_Left/Name_Text"):GetComponent(typeof(UnityEngine.UI.Text))
    rightName=dialoguePanel:Find("Background/Name_Right/Name_Text"):GetComponent(typeof(UnityEngine.UI.Text))
    dialogueText=dialoguePanel:Find("Background/Dialogue_Text"):GetComponent(typeof(UnityEngine.UI.Text))
    for i=1,Sprites.Length do
        allSprite[Sprites[i-1].name]=Sprites[i-1]
    end
    dialoguePanel.gameObject:SetActive(false)
    local nextBut=dialoguePanel:Find("DialogueNextTrigger"):GetComponent(typeof(UnityEngine.UI.Button))
    nextBut.onClick:AddListener(NextDialogue)
end

--开始对话
function StartDialogue(dialogue_id)
    if DialogueConfig.script.DialogueConfig[dialogue_id]==nil then
        DouyinUtility.Toast("对话id出现配置错误，请检查～")
        return
    end
    SetCurrentDialogueID(dialogue_id)
    dialoguePanel.gameObject:SetActive(true)
    DouyinUIService.SetUIVisible(false)
    UpdateUI()
end

--切换到下一段对话
function NextDialogue()
    SetCurrentDialogueID(DialogueConfig.script.DialogueConfig[currentDialogueID].Next)
    if DialogueConfig.script.DialogueConfig[currentDialogueID]==nil then
        EndDialogue()
    else
        UpdateUI()
    end
end

--刷新UI界面信息
function UpdateUI()
    local dialogueData=DialogueConfig.script.DialogueConfig[currentDialogueID]
    rightName.text=dialogueData.RightName
    if dialogueData.LeftName=="" then
        leftName.transform.parent.gameObject:SetActive(false)
    else
        leftName.text=dialogueData.LeftName
        leftName.transform.parent.gameObject:SetActive(true)
    end
    if dialogueData.RightName=="" then
        rightName.transform.parent.gameObject:SetActive(false)
    else
        rightName.text=dialogueData.RightName
        rightName.transform.parent.gameObject:SetActive(true)
    end
    if allSprite[dialogueData.RoleLeft]~=nil then
        roleLeft.sprite=allSprite[dialogueData.RoleLeft]
        roleLeft.gameObject:SetActive(true)
    else
        roleLeft.gameObject:SetActive(false)
    end

    if allSprite[dialogueData.RoleRight]~=nil then
        roleRight.sprite=allSprite[dialogueData.RoleRight]
        roleRight.gameObject:SetActive(true)
    else
        roleRight.gameObject:SetActive(false)
    end
    dialogueText.text=dialogueData.Dialogue
end

--结束对话
function EndDialogue()
    SetCurrentDialogueID(-1)
    dialoguePanel.gameObject:SetActive(false)
    DouyinUIService.SetUIVisible(true)
end

function SetCurrentDialogueID(id)
    local actor=DouyinActorService.GetLocalActor()
    if actor then
        currentDialogueID=id
        actor:SetActorTag("CurrentDialogueID",tostring(currentDialogueID))
    end
end

function OnActorOperationChanged(actor)
    if actor==nil then return end
    if actor.isLocal then
        currentDialogueID=actor:GetActorTag("CurrentDialogueID")==nil and -1 or tonumber(actor:GetActorTag("CurrentDialogueID"))
        if currentDialogueID>0 then
            StartDialogue(currentDialogueID)
        end
    elseif actor.isObserverMode then
        if currentDialogueID>0 then
            EndDialogue()
        end
    end
end
