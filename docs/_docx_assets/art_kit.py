# -*- coding: utf-8 -*-
"""美术需求文档的排版件：参考图占位框 + 色板"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from docx.shared import Cm, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

from docx.shared import RGBColor

from docx_helper import (set_run_font, shade, cell_margins, _fix_tbl_width,
                         _insert_ordered, TCPR_ORDER, CONTENT_W_CM, GREY, DEEP)


def code(doc, lines, size=8.5):
    """等宽代码块（与主技术文档同一套样式）"""
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    _fix_tbl_width(tbl, [CONTENT_W_CM])
    c = tbl.cell(0, 0)
    shade(c, "F4F6F8")
    cell_margins(c, 100, 100, 160, 120)
    c.paragraphs[0].text = ""
    first = True
    for ln in lines:
        p = c.paragraphs[0] if first else c.add_paragraph()
        first = False
        p.paragraph_format.space_after = Pt(0)
        p.paragraph_format.line_spacing = 1.25
        r = p.add_run(ln if ln else " ")
        set_run_font(r, name="Consolas", size=size, color=RGBColor(0x24, 0x3A, 0x46))
    doc.add_paragraph().paragraph_format.space_after = Pt(2)


def _dashed_borders(cell, color="C2CED6"):
    tcPr = cell._tc.get_or_add_tcPr()
    borders = OxmlElement("w:tcBorders")
    for tag in ("w:top", "w:left", "w:bottom", "w:right"):
        el = OxmlElement(tag)
        el.set(qn("w:val"), "dashed")
        el.set(qn("w:sz"), "6")
        el.set(qn("w:space"), "0")
        el.set(qn("w:color"), color)
        borders.append(el)
    _insert_ordered(tcPr, borders, "w:tcBorders", TCPR_ORDER)


def _row_height(row, cm):
    trPr = row._tr.get_or_add_trPr()
    el = OxmlElement("w:trHeight")
    el.set(qn("w:val"), str(int(cm * 567)))
    el.set(qn("w:hRule"), "atLeast")
    trPr.append(el)


def ref_slot(doc, code, hint, height_cm=2.8, image=None, img_width_cm=13.0):
    """一个虚线框：上半截写明图位，下半截贴图。

    image 为空时是留白的「▢ 参考图位」（美术补图用）；传入 image 时变成
    「▣ 概念图（第一套·AI 生成）」，并在框内居中放入该图 —— M4 前根据
    文档规格生成的第一套概念参考，供美术对齐风格与形制。
    """
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl.autofit = False
    _fix_tbl_width(tbl, [CONTENT_W_CM])

    cell = tbl.cell(0, 0)
    _dashed_borders(cell)
    shade(cell, "FBFCFD")
    cell_margins(cell, top=80, bottom=80, left=140, right=140)

    p = cell.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_after = Pt(2)
    if image:
        r = p.add_run("▣  " + code + "　概念图（第一套 · AI 生成，供美术对齐风格 / 形制）")
        set_run_font(r, size=9, color=DEEP, bold=True)
    else:
        r = p.add_run("▢  " + code + "　参考图位")
        set_run_font(r, size=9, color=GREY, bold=True)

    p2 = cell.add_paragraph()
    p2.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p2.paragraph_format.space_after = Pt(0)
    r2 = p2.add_run(hint)
    set_run_font(r2, size=8.5, color=GREY)

    if image:
        _row_height(tbl.rows[0], 0.6)  # 让行高随图片撑开，不锁死
        pic_p = cell.add_paragraph()
        pic_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        pic_p.paragraph_format.space_before = Pt(4)
        pic_p.paragraph_format.space_after = Pt(2)
        pic_p.add_run().add_picture(image, width=Cm(img_width_cm))
        note_p = cell.add_paragraph()
        note_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        note_p.paragraph_format.space_after = Pt(2)
        nr = note_p.add_run("注：概念图仅用于确认风格与形制，非最终 sprite；尺寸 / 色号以本节规格表为准")
        set_run_font(nr, size=8, color=GREY)
    else:
        _row_height(tbl.rows[0], height_cm)
        # 留白：贴图用
        cell.add_paragraph()
        cell.add_paragraph()

    gap = doc.add_paragraph()
    gap.paragraph_format.space_after = Pt(4)
    gap.paragraph_format.line_spacing = 1.0
    return tbl


def _chip_table(doc, rows, widths):
    """带真实色块的表：第一列是填色的色卡单元。"""
    from docx.enum.table import WD_TABLE_ALIGNMENT

    ncols = len(rows[0])
    tbl = doc.add_table(rows=1, cols=ncols)
    tbl.style = "Table Grid"
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER

    heads = ["色卡", "游戏 / 模板", "便签色", "暗部（投影 · 纸背板）", "为什么是这个色"]
    hdr = tbl.rows[0]
    for i, htxt in enumerate(heads):
        c = hdr.cells[i]
        shade(c, "F2F5F7")
        cell_margins(c)
        p = c.paragraphs[0]
        p.text = ""
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(0)
        r = p.add_run(htxt)
        set_run_font(r, size=9, bold=True, color=DEEP)

    for ri, row in enumerate(rows):
        cells = tbl.add_row().cells
        # 1 色卡
        c = cells[0]
        shade(c, row[2].lstrip("#"))
        cell_margins(c, top=110, bottom=110, left=60, right=60)
        p = c.paragraphs[0]
        p.text = ""
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(0)
        r = p.add_run(row[0])
        set_run_font(r, size=13, bold=True, color=RGBColor(0xFF, 0xFF, 0xFF))

        for ci in range(1, ncols):
            c = cells[ci]
            cell_margins(c)
            p = c.paragraphs[0]
            p.text = ""
            p.paragraph_format.space_after = Pt(0)
            p.paragraph_format.line_spacing = 1.2
            if ci in (2, 3):
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            val = row[ci]
            if ci == 3:
                r = p.add_run(val)
                set_run_font(r, name="Consolas", size=8.5, color=RGBColor(0x8A, 0x5A, 0x44))
            else:
                from docx_helper import _rich
                _rich(p, val, size=8.5)

    _fix_tbl_width(tbl, widths)
    return tbl


def palette(doc):
    """色板：先定色，后面各表只写色号。"""
    from docx_helper import table, body, callout, page_break, h, figure, bullet

    body(doc, "本文件所有色号都取自 `MiniGameTheme.cs` 里的实际值——也就是说，**下表不是「建议配色」，而是当前 build 里肉眼看到的颜色**。占位阶段它们就是最终验收的对照基准；美术出图时按这里的色号取色，换上正式图后颜色不应出现整体偏移。")

    table(doc,
          ["代号", "名称", "色号", "用在哪", "说明"],
          [
              ["`DEEP`", "墨蓝", "#194D65", "主文字 / 描边 / 标题 / 完成横幅底色", "全案的主色，比纯黑柔和，和纸色搭配不脏"],
              ["`PAPER`", "纸面", "#E5CBB0", "**整张纸面板的正面**（新模板的底）", "新概念图定下来的米色纸，带 26px 横线"],
              ["`PAGESTACK`", "纸叠层", "#DCC0A2", "纸面板的页边（比纸面深一档）", "只露 8px 边，用来交代「这是一叠纸」"],
              ["`CARD`", "卡面", "#FBEBD0", "便签内层奶白卡 / 槽底", "比纸面亮，便签上的标题与槽都落在它上面"],
              ["`SLOT`", "槽", "#C6E1F2", "便签栏的槽底", "浅蓝只在槽上出现，是「这里待填」的唯一信号"],
              ["`YELLOW`", "亮黄", "#FFD447", "可交互高亮 / 图块 / 角标", "只在「这里可以动」的地方出现，用作可点性的信号"],
              ["`ORANGE`", "橙", "#EF7849", "进度 / 错位警示", "错位格闪烁用它，不用红——红的语义留给失败"],
              ["`BLUE`", "蓝", "#26A9FF", "二级提示指示", "提示第二级用来指出「该去哪」"],
              ["`GREEN`", "绿", "#65D443", "完成态填充", "放在 0.45 透明度下当作「已归位」的底色"],
              ["`DARKGREEN`", "深绿", "#24A348", "右栏勾选文字", "与 GREEN 成对：填充用浅、文字用深"],
              ["`INK`", "墨色", "#242A30", "正文 / X 关闭与回形针的描边", "新模板里它只出现在两个手绘件上"],
              ["`GREY`", "灰", "#6B7280", "次要文字 / 未激活", "错位块的降饱和填充也用它"],
          ],
          widths=[2.0, 1.8, 2.0, 6.2, 4.2], size=8.5, align_center_cols=[0, 1, 2])

    callout(doc, "纸色口径：#E5CBB0",
            "纸面板正面 `#E5CBB0`，页边 `#DCC0A2`，便签内层卡 `#FBEBD0`。"
            "这套米色比 HUD 的 `#E2C7A2` 亮 3%，两张纸在同一屏不会割裂。"
            "**代价**：代码里 `MiniGameTheme.Cream` 要拆成 `Paper` 和 `Card` 两个常量，M2 里所有用 `Cream` 的地方要逐处判断该取哪个。",
            fill="F7EFE2")

    page_break(doc)

    h(doc, "便签纸七色卡（v0.6 降饱和版）", 2)
    body(doc, "右侧那张便签是**这一局的色彩签名**：玩家进局第一眼看到它，就知道「这次要用哪只手」。本作是黄绿色调的吉卜力风，七色统一压低饱和度、偏暖偏灰；颜色只负责区分玩法，不抢纸面与插图的戏。")
    figure(doc, "02-note-colors.png", 16.0,
           "图 0-1　便签纸七色卡（1:1 出图，可直接给美术取色）",
           "每张便签都画了投影与内层奶白卡，这才是它在局内的真实样子")

    body(doc, "取值规则（给美术的硬约束，不是建议）：")
    bullet(doc, "**饱和度控制在 0.10–0.42，取消「彩度拉满」的旧规。** 高彩橙红 / 荧光粉紫会在暖灰纸面上跳出来，和吉卜力风打架。")
    bullet(doc, "**明度锁在 0.56–0.74。** 比纸面（0.86）暗一档即可；再亮像塑料片，再暗会脏。七色靠明度与色相双重错开，不靠高饱和。")
    bullet(doc, "**色相走暖 → 绿的收敛弧线，不走完整色轮。** T6 灰紫、T7 灰粉只留一点冷/暖暗示，饱和度已压到与相邻色同档，不再突兀。")
    bullet(doc, "**每色必须同时给暗部。** 投影、纸背板、完成态下压全用它，现场不许临时把颜色调暗——那会让同一局的便签在不同状态下来回跳色。")

    _chip_table(doc, [
        ["T1", "**放大镜调查**\nQ06 / Q09 / Q11 / Q14", "#C08A67", "#815C45", "暖赭。铜镜与日光的暖，降饱和后像旧纸上的干赭石，仍是全案第一个「暖 = 观察」。"],
        ["T2", "**拨开遮挡**\nQ10 / Q12", "#C7B474", "#88784A", "麦黄。干草与阳光；比 T1 亮一点、偏绿一点，一眼分得开「掀开」和「看」。"],
        ["T3", "**翻转查验**\nQ02 / Q12 / Q15 / Q18", "#A2B57A", "#6D7D51", "苔绿。与场景草绿同族但已压灰，靠投影与内层奶白卡拉距离，不再需要「例外加深投影」。"],
        ["T4", "**观察图拼合**\nQ19", "#8BA89C", "#5D736A", "灰青。拼图是理性动作，从暖色段过渡到冷静段；低饱和让它和插图天空蓝和平共处。"],
        ["T5", "**痕迹拓印**\nQ17", "#8AA2B1", "#5C6F7A", "雾蓝。炭与夜色的冷调，但灰到能和天空同框不打架。"],
        ["T6", "**镊取物证**\nQ03 / Q16", "#9E94A6", "#6B6470", "灰紫。只保留紫的暗示，不再用高饱和抢眼；镊取是精细动作，颜色要安静。"],
        ["T7", "**证词归位**\nQ01 / Q04 / Q05 / Q07 / Q08 / Q13", "#C09390", "#85635F", "陶粉（灰粉）。收束色，回到暖但不回 T1 的橙；低饱和处理掉原先「紫粉太跳」的问题。"],
    ], widths=[1.4, 4.4, 2.0, 2.6, 8.0])

    callout(doc, "校验结果（供你复核，不必回）",
            "七色按「色相 + 明度」双重区分，不再要求相邻色相差 ≥ 40°，也不再追求高彩度色轮。"
            "本版全部落在偏暖偏灰的黄绿体系内：T1/T7 虽然都偏暖，但一个是赭棕、一个是灰粉，明度与色相都错开；"
            "T5/T6 靠蓝灰与 lilac 灰的细微色相差区分。\n"
            "它们从不同屏出现，玩家永远只同时看到当前局这一张便签，所以不靠强对比也够用。"
            "采样色号与暗部色号已同步到 `MiniGameTheme.NoteColor()` / `NoteDeep()` 与七张预染纸背板 PNG。",
            fill="F7EFE2")

    table(doc,
          ["用在", "怎么用", "不要做的"],
          [
              ["便签纸本体", "100% 实色，**不加渐变、不加纹理、不加描边**。纸的质感交给纸面层（§2.1），便签本身要平。", "不要在便签上叠任何半透明层，会把它变成脏色"],
              ["投影", "暗部色 100%，offset (7, 9)，**硬边（blur = 0）**。概念图里是硬阴影，不是柔和投影。", "**不要用黑色投影**。黑投影落在米色纸上会发灰，像脏了一块"],
              ["纸背板", "同色 100%，就是它撑起整张纸的「厚度」（§2.1）", "——"],
              ["槽位完成态", "暗部色 @35% 垫在已填的槽底下面", "不要用 `GREEN`，绿色语义留给整个小游戏完成"],
              ["编号与卡内标题", "白字（便签上）/ 墨蓝 `#194D65`（奶白卡上）", "**不要拿便签色写字**，除了色卡里那个大编号"],
          ],
          widths=[2.8, 8.2, 5.0], size=8.5, align_center_cols=[0])

    page_break(doc)
