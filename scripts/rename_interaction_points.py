#!/usr/bin/env python3
"""Rename InteractionPoint children to unified E## · description format."""

from pathlib import Path

SCENE = Path(__file__).resolve().parents[1] / "Assets/Scenes/Mechanics_Code.unity"

# old m_Name / Button Text (exact YAML value) -> new
RENAMES = {
    '"\\u5077\\u542C\\u70B9"': '"E03 \\u00b7 \\u8EAB\\u540E\\u5077\\u542C\\u70B9"',
    '"\\u77ED\\u6728\\u70AD"': '"E01 \\u00b7 \\u77ED\\u6728\\u70AD"',
    '"\\u9EC4\\u8272\\u7ED2\\u6BDB"': '"E02 \\u00b7 \\u6563\\u843D\\u7FBD\\u6BDB"',
    '"\\u60B2\\u4F24\\u86D9\\u8EAB\\u4E0B\\u7EFF\\u57AB"': '"E12 \\u00b7 \\u60B2\\u4F24\\u86D9\\u8EAB\\u4E0B\\u7EFF\\u57AB"',
    '"\\u53D1\\u73B0\\u7F3A\\u5C11\\u68AF\\u5B50"': '"E06 \\u00b7 \\u53D1\\u73B0\\u7F3A\\u5C11\\u68AF\\u5B50"',
    '"\\u5348\\u7761\\u70B9"': '"E07 \\u00b7 \\u5348\\u7761\\u70B9"',
    '"\\u8C37\\u7269\\u6CE1\\u6C34"': '"E05 \\u00b7 \\u8C37\\u7269\\u6CE1\\u6C34"',
    '"\\u70E7\\u7126\\u7684\\u7A3B\\u8349"': '"E08 \\u00b7 \\u7126\\u9ED1\\u7A3B\\u8349"',
    '"\\u52A8\\u7269\\u722A\\u5370"': '"E09 \\u00b7 \\u52A8\\u7269\\u722A\\u5370"',
    '"\\u8C37\\u4ED3\\u9AD8\\u5904\\u7684\\u5F69\\u8272\\u53CD\\u5149"': '"E27 \\u00b7 \\u8C37\\u4ED3\\u9AD8\\u5904\\u5F69\\u8272\\u53CD\\u5149"',
    '"\\u4E4C\\u9E26\\u5DE2 \\xB7 \\u73BB\\u7483\\u5236\\u54C1"': '"E34 \\u00b7 \\u73BB\\u7483\\u73E0"',
    '"\\u4E4C\\u9E26\\u5DE2\\u767D\\u77F3\\u5934\\uFF08\\u5047\\u86CB\\uFF09"': '"E10 \\u00b7 \\u4E4C\\u9E26\\u5DE2\\u767D\\u77F3\\u5934\\uFF08\\u5047\\u86CB\\uFF09"',
    '"\\u7A7A\\u6C34\\u6876"': '"E17 \\u00b7 \\u7A7A\\u6C34\\u6876"',
    '"\\u96E8\\u9774\\u6CE5\\u811A\\u5370"': '"E18 \\u00b7 \\u96E8\\u9774\\u6CE5\\u811A\\u5370"',
    '"\\u7CBE\\u7F8E\\u732B\\u95E8"': '"E14 \\u00b7 \\u7CBE\\u7F8E\\u732B\\u95E8"',
    '"\\u5927\\u6A61\\u6811\\u6839\\u7684\\u6293\\u75D5"': '"E28 \\u00b7 \\u5927\\u6A61\\u6811\\u6839\\u6293\\u75D5"',
    '"\\u95E8\\u5916\\u9676\\u74F7\\u7897"': '"E15 \\u00b7 \\u95E8\\u5916\\u9676\\u74F7\\u7897"',
    '"\\u95E8\\u8FB9\\u517D\\u6BDB"': '"E16 \\u00b7 \\u95E8\\u8FB9\\u517D\\u6BDB"',
    '"\\u7D27\\u95ED\\u5927\\u95E8"': '"E13 \\u00b7 \\u7D27\\u95ED\\u5927\\u95E8"',
    '"\\u6C60\\u5858\\u5CB8\\u8FB9\\u8E5A\\u6C34\\u75D5\\u8FF9"': '"E23 \\u00b7 \\u6C60\\u5858\\u5CB8\\u8FB9\\u8E5A\\u6C34\\u75D5\\u8FF9"',
    '"\\u6C60\\u5858\\u8FB9\\u5C0F\\u9E21\\u811A\\u5370"': '"E25 \\u00b7 \\u6C60\\u5858\\u8FB9\\u5C0F\\u9E21\\u811A\\u5370"',
    '"CrowRoofDialogue"': '"CrowRoof \\u00b7 \\u4E4C\\u9E26\\u5C4B\\u98762-A"',
    'm_Name: TreeDialogue': 'm_Name: "Tree \\u00b7 \\u5927\\u6A61\\u6811\\u4EA4\\u4E92"',
    'm_Name: CrowRoofDialogue': 'm_Name: "CrowRoof \\u00b7 \\u4E4C\\u9E26\\u5C4B\\u98762-A"',
    '"\\u8C37\\u4ED3\\u9AD8\\u5904\\u7684\\u5F69\\u8272"': '"E27 \\u00b7 \\u8C37\\u4ED3\\u9AD8\\u5904\\u5F69\\u8272\\u53CD\\u5149"',
    '"E35 \\xB7 \\u6500\\u722C\\u653E\\u72E0\\u8BDD\\xB7B-1"': '"E35 \\u00b7 \\u6500\\u722C\\u653E\\u72E0\\u8BDD\\u00b7B-1"',
    '"E36 \\xB7 \\u6500\\u722C\\u653E\\u72E0\\u8BDD\\xB7B-2"': '"E36 \\u00b7 \\u6500\\u722C\\u653E\\u72E0\\u8BDD\\u00b7B-2"',
}


def main():
    text = SCENE.read_text(encoding="utf-8")
    count = 0
    for old, new in RENAMES.items():
        if old in text:
            n = text.count(old)
            text = text.replace(old, new)
            count += n
            print(f"  {old} -> {new}  ({n}x)")
    SCENE.write_text(text, encoding="utf-8")
    print(f"Done. {count} replacements.")


if __name__ == "__main__":
    main()
