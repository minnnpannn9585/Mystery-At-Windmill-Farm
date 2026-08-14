#!/usr/bin/env python3
"""Inject missing E-point placeholders into Mechanics_Code.unity (YAML duplicate of 短木炭)."""

import json
import random
import re
from pathlib import Path

SCENE = Path(__file__).resolve().parents[1] / "Assets/Scenes/Mechanics_Code.unity"
PARENT_TRANSFORM = 1935063811
TEMPLATE_START = "--- !u!1 &1526912815"
TEMPLATE_END = "--- !u!1 &1546310099"

SPECS = [
    {"name": "E11 · 狗窝旁旧木桶", "npc": "描述", "id": 36, "pos": (12.0, 8.4, -22.0)},
    {"name": "E19 · 关闭二层窗", "npc": "描述", "id": 54, "pos": (-30.0, 12.0, 14.0)},
    {"name": "E21 · 窗台下爪痕", "npc": "描述", "id": 55, "pos": (-27.0, 6.0, 13.0)},
    {"name": "E22 · 狗窝空窝", "npc": "描述", "id": 320, "pos": (10.0, 8.2, -20.0)},
    {"name": "E24 · 压平稻草", "npc": "描述", "id": 47, "pos": (15.0, 8.3, -25.0)},
    {"name": "E26 · 发酵苹果渣", "npc": "描述", "id": 48, "pos": (-6.0, 5.5, -38.0)},
    {"name": "E29 · 窗缝暖黄灯", "npc": "描述", "id": 58, "pos": (-26.0, 6.5, 11.0)},
    {"name": "E30 · 鸡羽毛", "npc": "描述", "id": 42, "pos": (-0.5, 5.6, -26.5)},
    {"name": "E30 · 狗毛", "npc": "描述", "id": 43, "pos": (0.3, 5.6, -26.8)},
    {"name": "E30 · 鼠毛", "npc": "描述", "id": 44, "pos": (-0.2, 5.55, -27.1)},
    {"name": "E30 · 黑色细毛", "npc": "描述", "id": 45, "clue1": "E30_BlackFurSeen", "pos": (0.6, 5.58, -27.4)},
    {"name": "E31 · 旧蛋壳碎片", "npc": "描述", "id": 49, "pos": (16.0, 8.4, -26.0)},
    {"name": "E32 · Flash宽叶", "npc": "描述", "id": 51, "pos": (-18.0, 5.5, 5.0)},
    {"name": "E33 · 泥里松果", "npc": "描述", "id": 52, "pos": (-8.0, 5.4, -8.0)},
    {"name": "E34 · 瓶盖", "npc": "描述", "id": 39, "pos": (-1.3, 5.55, -27.5)},
    {"name": "E34 · 发卡", "npc": "描述", "id": 40, "pos": (-1.6, 5.55, -27.2)},
    {"name": "E34 · 奶糖", "npc": "描述", "id": 41, "pos": (-1.9, 5.55, -27.8)},
    {"name": "E37 · 攻顶喊话·F-1", "npc": "黑猫", "id": 170, "pos": (-25.0, 9.0, 10.0)},
    {"name": "E38 · 攻顶喊话·F-2", "npc": "黑猫", "id": 180, "pos": (-28.0, 11.0, 13.0)},
]

COMIC_SPEC = {
    "name": "E20 · 打开二层窗",
    "pos": (-29.0, 12.5, 15.0),
    "button": "进入二层窗",
}


def esc_unicode(s: str) -> str:
    return "".join(f"\\u{ord(c):04x}" if ord(c) > 127 else c for c in s)


def npc_unicode(npc: str) -> str:
    if npc == "描述":
        return '"\\u63CF\\u8FF0"'
    if npc == "黑猫":
        return '"\\u9ED1\\u732B"'
    return json.dumps(npc)


def make_clue_block(base_rid: int, clue1):
    if not clue1:
        v1 = ""
        v2 = "0"
        vt2 = "0"
        vi2 = "0"
        ia2 = "0"
    else:
        v1 = clue1
        v2 = "0"
        vt2 = "0"
        vi2 = "0"
        ia2 = "0"

    rids = [base_rid + j for j in range(10)]
    lines = [
        "  ParaLuaBindingData:",
    ]
    for r in rids:
        lines.append(f"  - rid: {r}")
    lines += [
        "  IsServerScript: 0",
        "  IsManualedVar: 1",
        "  eNetState: 0",
        "  autoUpdate: 1",
        "  references:",
        "    version: 2",
        "    RefIds:",
    ]
    fields = [
        ("DouyinLuaDataString", "varName1", v1),
        ("DouyinLuaDataString", "varType1", "bool" if clue1 else ""),
        ("DouyinLuaDataVarBoolean", "varValue1", "1" if clue1 else "0"),
        ("DouyinLuaDataVarInt", "varIntValue1", "0"),
        ("DouyinLuaDataVarBoolean", "varIsAdd1", "0"),
        ("DouyinLuaDataString", "varName2", v2),
        ("DouyinLuaDataString", "varType2", vt2),
        ("DouyinLuaDataVarBoolean", "varValue2", "0"),
        ("DouyinLuaDataVarInt", "varIntValue2", vi2),
        ("DouyinLuaDataVarBoolean", "varIsAdd2", ia2),
    ]
    for rid, (cls, var_name, data) in zip(rids, fields):
        lines += [
            f"    - rid: {rid}",
            f"      type: {{class: {cls}, ns: , asm: com.douyin.script}}",
            "      data:",
            f"        varName: {var_name}",
            f"        Data: {data if data != '' else '0'}",
        ]
    return "\n".join(lines)


def make_dialogue_block(base_rid: int, npc: str, start_id: int) -> str:
    return f"""  ParaLuaBindingData:
  - rid: {base_rid}
  - rid: {base_rid + 1}
  IsServerScript: 0
  IsManualedVar: 1
  eNetState: 0
  autoUpdate: 1
  references:
    version: 2
    RefIds:
    - rid: {base_rid}
      type: {{class: DouyinLuaDataVarInt, ns: , asm: com.douyin.script}}
      data:
        varName: ID
        Data: {start_id}
    - rid: {base_rid + 1}
      type: {{class: DouyinLuaDataString, ns: , asm: com.douyin.script}}
      data:
        varName: npcname
        Data: {npc_unicode(npc)}"""


def make_comic_block(base_rid: int) -> str:
    return f"""  ParaLuaBindingData:
  - rid: {base_rid}
  IsServerScript: 0
  IsManualedVar: 1
  eNetState: 0
  autoUpdate: 1
  references:
    version: 2
    RefIds:
    - rid: {base_rid}
      type: {{class: DouyinLuaDataVarInt, ns: , asm: com.douyin.script}}
      data:
        varName: placeholderDialogueId
        Data: 600"""


def make_interactor_block(dialogue_id: int, clue_id: int, button_text: str, comic: bool = False) -> str:
    method = "OnComicInteract" if comic else "StartDialogue"
    actions = f"""          ButtonActions:
          - varName: 
            Data: {{fileID: {dialogue_id}}}
            methodName: {method}"""
    if not comic:
        actions += f"""
          - varName: 
            Data: {{fileID: {clue_id}}}
            methodName: SetClue"""
    btn_esc = esc_unicode(button_text)
    return f"""  ParaLuaBindingData:
  - rid: 1037837089713946634
  - rid: 1037837089713946635
  - rid: 1037837089713946636
  - rid: 1037837089713946637
  - rid: 1037837089713946638
  IsServerScript: 0
  IsManualedVar: 1
  eNetState: 0
  autoUpdate: 1
  references:
    version: 2
    RefIds:
    - rid: 1037837089713946634
      type: {{class: DouyinLuaDataEnum, ns: , asm: com.douyin.script}}
      data:
        varName: InteractionType
        varType: InteractionType
        EnumStr: Range
        eData:
          rid: 1037837089713946639
    - rid: 1037837089713946635
      type: {{class: DouyinLuaDataFloat, ns: , asm: com.douyin.script}}
      data:
        varName: InteractionRange
        Data: 1
    - rid: 1037837089713946636
      type: {{class: DouyinLuaDataUObject, ns: , asm: com.douyin.script}}
      data:
        varName: InteractionArea
        Data: {{fileID: 0}}
        varType: UnityEngine.Collider
    - rid: 1037837089713946637
      type: {{class: DouyinLuaDataEnum, ns: , asm: com.douyin.script}}
      data:
        varName: InteractionMode
        varType: Interaction3DType
        EnumStr: Click
        eData:
          rid: 1037837089713946640
    - rid: 1037837089713946638
      type: {{class: DouyinLuaDataDouyinButtonArr, ns: , asm: com.douyin.script}}
      data:
        varName: ButtonConfigs
        Data:
        - Param:
            ButtonVarName: ButtonConfigs
            Title: "\\u4EA4\\u4E92\\u6309\\u94AE\\u8BBE\\u7F6E"
            ButtonFlags: 9
            DefaultText: "\\u70B9\\u51FB\\u4EA4\\u4E92"
            DefaultTextColor: {{r: 0.03137255, g: 0.023529412, b: 0.13725491, a: 1}}
            TextLimitCharCount: 14
            NormalImageText: "\\u6309\\u94AE\\u56FE\\u6807"
            NormalImageTooltip: "\\u63A8\\u8350\\u5C3A\\u5BF872*72"
            NormalBackgroundImageText: "\\u6309\\u94AE\\u5E95\\u677F"
            NormalBackgroundImageTooltip: "\\u63A8\\u8350\\u5C3A\\u5BF8372*84"
            TextColorDesc: "\\u6587\\u672C\\u989C\\u8272"
            TextDesc: "\\u6309\\u94AE\\u6587\\u672C"
            Index: 0
          Transition: 0
          Colors:
            normalColor: {{r: 0, g: 0, b: 0, a: 0}}
            pressedColor: {{r: 0, g: 0, b: 0, a: 0}}
            disabledColor: {{r: 0, g: 0, b: 0, a: 0}}
          SpriteState:
            Param:
              ButtonVarName: ButtonConfigs
              Title: "\\u4EA4\\u4E92\\u6309\\u94AE\\u8BBE\\u7F6E"
              ButtonFlags: 9
              DefaultText: "\\u70B9\\u51FB\\u4EA4\\u4E92"
              DefaultTextColor: {{r: 0.03137255, g: 0.023529412, b: 0.13725491, a: 1}}
              TextLimitCharCount: 14
              NormalImageText: "\\u6309\\u94AE\\u56FE\\u6807"
              NormalImageTooltip: "\\u63A8\\u8350\\u5C3A\\u5BF872*72"
              NormalBackgroundImageText: "\\u6309\\u94AE\\u5E95\\u677F"
              NormalBackgroundImageTooltip: "\\u63A8\\u8350\\u5C3A\\u5BF8372*84"
              TextColorDesc: "\\u6587\\u672C\\u989C\\u8272"
              TextDesc: "\\u6309\\u94AE\\u6587\\u672C"
              Index: 0
            normalImage: {{fileID: 0}}
            normalBackgroundImage: {{fileID: 0}}
          ButtonText: 1
          Text: "{btn_esc}"
          TextSize: 0
          TextColor: {{r: 0.03137255, g: 0.023529412, b: 0.13725491, a: 1}}
{actions}
    - rid: 1037837089713946639
      type: {{class: InteractionType, ns: , asm: com.douyin.world}}
      data:
        value__: 0
    - rid: 1037837089713946640
      type: {{class: Interaction3DType, ns: , asm: com.douyin.world}}
      data:
        value__: 0"""


def build_point(idx: int, spec: dict, comic: bool = False) -> tuple[str, int]:
    base = 880_001_000 + idx * 20
    go_id = base
    tr_id = base + 1
    clue_id = base + 2
    inter_id = base + 3
    dial_id = base + 4
    net_id = base + 5
    box_id = base + 6
    clue_rid = 880_010_000 + idx * 20
    dial_rid = 880_020_000 + idx * 10

    name = spec["name"]
    pos = spec["pos"]
    name_esc = esc_unicode(name)
    n1 = random.randint(10**18, 10**19 - 1)
    n2 = random.randint(10**18, 10**19 - 1)

    if comic:
        components = f"""  m_Component:
  - component: {{fileID: {tr_id}}}
  - component: {{fileID: {net_id}}}
  - component: {{fileID: {dial_id}}}
  - component: {{fileID: {inter_id}}}
  - component: {{fileID: {box_id}}}"""
        dial_block = make_comic_block(dial_rid)
        inter_block = make_interactor_block(dial_id, clue_id, COMIC_SPEC["button"], comic=True)
        clue_yaml = ""
    else:
        components = f"""  m_Component:
  - component: {{fileID: {tr_id}}}
  - component: {{fileID: {net_id}}}
  - component: {{fileID: {dial_id}}}
  - component: {{fileID: {inter_id}}}
  - component: {{fileID: {clue_id}}}
  - component: {{fileID: {box_id}}}"""
        dial_block = make_dialogue_block(dial_rid, spec["npc"], spec["id"])
        inter_block = make_interactor_block(dial_id, clue_id, name, comic=False)
        clue_block = make_clue_block(clue_rid, spec.get("clue1"))
        clue_yaml = f"""--- !u!114 &{clue_id}
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: {go_id}}}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {{fileID: -413692930, guid: c1a957cff7a534cbab677bbff81abab2, type: 3}}
  m_Name: 
  m_EditorClassIdentifier: 
  ScriptAsset: {{fileID: -4320198879241519195, guid: 2090c1a586d0445408748c8c4e87103f, type: 3}}
{clue_block}
"""

    dial_script_guid = "a8b3c4d5e6f7489012345678abcdef01" if comic else "dbdfa9057e4e5a347b4a500a3d30bd57"

    yaml = f"""--- !u!1 &{go_id}
GameObject:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  serializedVersion: 6
{components}
  m_Layer: 0
  m_Name: "{name_esc}"
  m_TagString: Untagged
  m_Icon: {{fileID: 0}}
  m_NavMeshLayer: 0
  m_StaticEditorFlags: 0
  m_IsActive: 1
--- !u!4 &{tr_id}
Transform:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: {go_id}}}
  m_LocalRotation: {{x: 0, y: 0, z: 0, w: 1}}
  m_LocalPosition: {{x: {pos[0]}, y: {pos[1]}, z: {pos[2]}}}
  m_LocalScale: {{x: 1, y: 1, z: 1}}
  m_ConstrainProportionsScale: 0
  m_Children: []
  m_Father: {{fileID: {PARENT_TRANSFORM}}}
  m_RootOrder: {100 + idx}
  m_LocalEulerAnglesHint: {{x: 0, y: 0, z: 0}}
--- !u!65 &{box_id}
BoxCollider:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: {go_id}}}
  m_Material: {{fileID: 0}}
  m_IsTrigger: 0
  m_Enabled: 1
  serializedVersion: 2
  m_Size: {{x: 1.5, y: 1.5, z: 1.5}}
  m_Center: {{x: 0, y: 0.75, z: 0}}
{clue_yaml}--- !u!114 &{inter_id}
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: {go_id}}}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {{fileID: -413692930, guid: c1a957cff7a534cbab677bbff81abab2, type: 3}}
  m_Name: 
  m_EditorClassIdentifier: 
  ScriptAsset: {{fileID: -4320198879241519195, guid: 0a6b2e5dd40d0804b81a27cdfccd5ba5, type: 3}}
{inter_block}
--- !u!114 &{dial_id}
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: {go_id}}}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {{fileID: -413692930, guid: c1a957cff7a534cbab677bbff81abab2, type: 3}}
  m_Name: 
  m_EditorClassIdentifier: 
  ScriptAsset: {{fileID: -4320198879241519195, guid: {dial_script_guid}, type: 3}}
{dial_block}
--- !u!114 &{net_id}
MonoBehaviour:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: {go_id}}}
  m_Enabled: 1
  m_EditorHideFlags: 0
  m_Script: {{fileID: 540439951, guid: 3ead8c7f8efe8473b8d110669e8128d8, type: 3}}
  m_Name: 
  m_EditorClassIdentifier: 
  NetGUID:
    n1: {n1}
    n2: {n2}
  RunContext: 0
"""
    return yaml, tr_id


def main():
    text = SCENE.read_text(encoding="utf-8")

    existing = set(re.findall(r'm_Name: "([^"]+)"', text))
    blocks = []
    transform_ids = []
    idx = 0

    all_specs = list(SPECS)
    # insert E20 after E19
    e19_i = next(i for i, s in enumerate(all_specs) if s["name"].startswith("E19"))
    all_specs.insert(e19_i + 1, {"comic": True, **COMIC_SPEC})

    for spec in all_specs:
        if spec["name"] in existing or esc_unicode(spec["name"]) in existing:
            print("skip existing:", spec["name"])
            continue
        comic = spec.get("comic", False)
        block, tr_id = build_point(idx, spec, comic=comic)
        blocks.append(block)
        transform_ids.append(tr_id)
        idx += 1
        print("created:", spec["name"])

    if not blocks:
        print("Nothing to add.")
        return

    insert_at = text.find(TEMPLATE_END)
    if insert_at == -1:
        raise SystemExit("TEMPLATE_END marker not found")

    new_text = text[:insert_at] + "".join(blocks) + text[insert_at:]

    # append children to InteractionPoint transform
    parent_pat = rf"(m_GameObject: {{fileID: 1935063810}}\n(?:.*\n)*?  m_Children:\n(?:  - {{fileID: \d+}}\n)*)"
    m = re.search(parent_pat, new_text)
    if not m:
        raise SystemExit("InteractionPoint children not found")

    child_lines = "".join(f"  - {{fileID: {tid}}}\n" for tid in transform_ids)
    insert_pos = m.end()
    new_text = new_text[:insert_pos] + child_lines + new_text[insert_pos:]

    SCENE.write_text(new_text, encoding="utf-8")
    print(f"Wrote {len(blocks)} E-points to {SCENE}")


if __name__ == "__main__":
    main()
