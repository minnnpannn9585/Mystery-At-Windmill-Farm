#!/usr/bin/env python3
"""Extract cheese spawn positions from cheese_parent prefab into 奶酪散点 markers."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PREFAB = ROOT / "Assets/Prefabs/Min/cheese_parent.prefab"
SCENE = ROOT / "Assets/Scenes/Mechanics_Code.unity"
FACTORY = ROOT / "Assets/Editor/MouseSceneFactory.cs"

INTERACTION_POINT_OFFSET = (-20.344564, -8.477972, 10.602425)
SPAWNER_TRANSFORM_ID = 1261122869
CHEESE_PARENT_INSTANCE_RE = re.compile(
    r"--- !u!1001 &315114674\nPrefabInstance:.*?m_SourcePrefab: \{fileID: 100100000, guid: c399db781678a4a8398d71d7ca869437, type: 3\}\n",
    re.S,
)

EXISTING_TRANSFORMS = {
    "C01_001": 546756890,
    "C01_002": 823428926,
    "C01_003": 352980059,
    "C01_004": 1592174098,
    "C01_005": 2014131166,
    "C01_006": 677481318,
    "C01_007": 1935085074,
    "C01_008": 720471963,
    "C01_009": 2037721398,
    "C01_010": 173680377,
    "C01_011": 1810256695,
    "C01_012": 1361075944,
}


def parse_cheese_positions(prefab_text: str) -> list[tuple[str, tuple[float, float, float]]]:
    blocks = re.split(r"--- !u!1001 ", prefab_text)
    points: list[tuple[str, int | None, tuple[float, float, float]]] = []
    for block in blocks[1:]:
        name_m = re.search(r"propertyPath: m_Name\n\s+value: ([^\n]+)", block)
        if not name_m:
            continue
        name = name_m.group(1).strip()
        if "cheese" not in name.lower():
            continue
        x = re.search(r"propertyPath: m_LocalPosition\.x\n\s+value: ([^\n]+)", block)
        y = re.search(r"propertyPath: m_LocalPosition\.y\n\s+value: ([^\n]+)", block)
        z = re.search(r"propertyPath: m_LocalPosition\.z\n\s+value: ([^\n]+)", block)
        if not (x and y and z):
            continue
        num_m = re.search(r"cheeseSingle(?: \((\d+)\))?", name)
        idx = int(num_m.group(1)) if num_m and num_m.group(1) else None
        points.append(
            (
                name,
                idx,
                (float(x.group(1)), float(y.group(1)), float(z.group(1))),
            )
        )

    points.sort(key=lambda item: (item[1] if item[1] is not None else 999, item[0]))
    return [(f"C01_{i:03d}", pos) for i, (_, _, pos) in enumerate(points, 1)]


def world_to_marker_local(world: tuple[float, float, float]) -> tuple[float, float, float]:
    ox, oy, oz = INTERACTION_POINT_OFFSET
    return (world[0] - ox, world[1] - oy, world[2] - oz)


def fmt_component(value: float) -> str:
    text = f"{value:.6f}".rstrip("0").rstrip(".")
    return text if text else "0"


def fmt_vec3(vec: tuple[float, float, float]) -> str:
    x, y, z = vec
    return f"{{x: {fmt_component(x)}, y: {fmt_component(y)}, z: {fmt_component(z)}}}"


def make_marker_yaml(marker_id: str, go_id: int, transform_id: int, local_pos: tuple[float, float, float], root_order: int) -> str:
  return f"""--- !u!1 &{go_id}
GameObject:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  serializedVersion: 6
  m_Component:
  - component: {{fileID: {transform_id}}}
  m_Layer: 0
  m_Name: {marker_id}
  m_TagString: Untagged
  m_Icon: {{fileID: 0}}
  m_NavMeshLayer: 0
  m_StaticEditorFlags: 0
  m_IsActive: 1
--- !u!4 &{transform_id}
Transform:
  m_ObjectHideFlags: 0
  m_CorrespondingSourceObject: {{fileID: 0}}
  m_PrefabInstance: {{fileID: 0}}
  m_PrefabAsset: {{fileID: 0}}
  m_GameObject: {{fileID: {go_id}}}
  m_LocalRotation: {{x: 0, y: 0, z: 0, w: 1}}
  m_LocalPosition: {fmt_vec3(local_pos)}
  m_LocalScale: {{x: 1, y: 1, z: 1}}
  m_ConstrainProportionsScale: 0
  m_Children: []
  m_Father: {{fileID: {SPAWNER_TRANSFORM_ID}}}
  m_RootOrder: {root_order}
  m_LocalEulerAnglesHint: {{x: 0, y: 0, z: 0}}
"""


def update_transform_position(scene_text: str, transform_id: int, local_pos: tuple[float, float, float]) -> str:
    pattern = (
        rf"(--- !u!4 &{transform_id}\nTransform:.*?m_LocalPosition: )\{{[^}}]+\}}"
    )
    replacement = rf"\1{fmt_vec3(local_pos)}"
    new_text, count = re.subn(pattern, replacement, scene_text, count=1, flags=re.S)
    if count != 1:
        raise RuntimeError(f"Failed to update transform {transform_id}")
    return new_text


def update_spawner_children(scene_text: str, child_transform_ids: list[int]) -> str:
    children_block = "\n".join(f"  - {{fileID: {file_id}}}" for file_id in child_transform_ids)
    pattern = (
        rf"(--- !u!4 &{SPAWNER_TRANSFORM_ID}\nTransform:.*?m_Children:\n)"
        rf"(?:  - \{{fileID: \d+\}}\n)+"
    )
    replacement = rf"\1{children_block}\n"
    new_text, count = re.subn(pattern, replacement, scene_text, count=1, flags=re.S)
    if count != 1:
        raise RuntimeError("Failed to update 奶酪散点 children")
    return new_text


def update_factory_cheese_specs(specs: list[tuple[str, tuple[float, float, float]]]) -> None:
    lines = [
        "    private static readonly CheeseSpec[] CheeseSpecs =",
        "    {",
    ]
    for marker_id, local_pos in specs:
        x, y, z = local_pos
        lines.append(
            f'        new CheeseSpec {{ Id = "{marker_id}", LocalPos = new Vector3({fmt_component(x)}f, {fmt_component(y)}f, {fmt_component(z)}f) }},'
        )
    lines.append("    };")

    factory_text = FACTORY.read_text(encoding="utf-8")
    new_factory_text, count = re.subn(
        r"    private static readonly CheeseSpec\[\] CheeseSpecs =\s*\{.*?\};",
        "\n".join(lines),
        factory_text,
        count=1,
        flags=re.S,
    )
    if count != 1:
        raise RuntimeError("Failed to update MouseSceneFactory CheeseSpecs")
    FACTORY.write_text(new_factory_text, encoding="utf-8")


def main() -> None:
    specs = [
        (marker_id, world_to_marker_local(world))
        for marker_id, world in parse_cheese_positions(PREFAB.read_text(encoding="utf-8"))
    ]
    scene_text = SCENE.read_text(encoding="utf-8")

    child_transform_ids: list[int] = []
    new_marker_blocks: list[str] = []

    for index, (marker_id, local_pos) in enumerate(specs):
        if marker_id in EXISTING_TRANSFORMS:
            transform_id = EXISTING_TRANSFORMS[marker_id]
            scene_text = update_transform_position(scene_text, transform_id, local_pos)
            child_transform_ids.append(transform_id)
            continue

        go_id = 880003000 + (index - 12) * 2 + 1
        transform_id = go_id + 1
        new_marker_blocks.append(
            make_marker_yaml(marker_id, go_id, transform_id, local_pos, index)
        )
        child_transform_ids.append(transform_id)

    scene_text = update_spawner_children(scene_text, child_transform_ids)
    scene_text, removed = CHEESE_PARENT_INSTANCE_RE.subn("", scene_text, count=1)
    if removed != 1:
        raise RuntimeError("Failed to remove cheese_parent prefab instance from scene")

    if new_marker_blocks:
        insert_point = scene_text.find(f"--- !u!4 &{SPAWNER_TRANSFORM_ID}\nTransform:")
        if insert_point == -1:
            raise RuntimeError("Could not find 奶酪散点 transform block")
        scene_text = scene_text[:insert_point] + "".join(new_marker_blocks) + scene_text[insert_point:]

    SCENE.write_text(scene_text, encoding="utf-8")
    update_factory_cheese_specs(specs)
    print(f"Migrated {len(specs)} cheese markers into 奶酪散点 and removed cheese_parent instance.")


if __name__ == "__main__":
    main()
