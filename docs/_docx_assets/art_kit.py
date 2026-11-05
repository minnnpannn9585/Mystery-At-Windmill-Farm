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


def ref_slot(doc, code, hint, height_cm=2.8):
    """一个虚线占位框：上半截写明这是谁的参考图位，下半截留白供贴图。"""
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    tbl.autofit = False
    _fix_tbl_width(tbl, [CONTENT_W_CM])
    _row_height(tbl.rows[0], height_cm)

    cell = tbl.cell(0, 0)
    _dashed_borders(cell)
    shade(cell, "FBFCFD")
    cell_margins(cell, top=80, bottom=80, left=140, right=140)

    p = cell.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run("▢  " + code + "　参考图位")
    set_run_font(r, size=9, color=GREY, bold=True)

    p2 = cell.add_paragraph()
    p2.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p2.paragraph_format.space_after = Pt(0)
    r2 = p2.add_run(hint)
    set_run_font(r2, size=8.5, color=GREY)

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
    from docx_helper import table, body, callout, page_break, h, figure

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

    callout(doc, "待决 P1 关闭：纸色统一到 #E5CBB0",
            "上一稿留的 P1 是「HUD 用 #E2C7A2、小游戏用 #FFF8DE，同屏会割裂」。"
            "新概念图给了一个更好的答案：纸面本身是 `#E5CBB0`，正好落在两者之间——比 HUD 的 `#E2C7A2` 亮 3%，"
            "比原来的奶白 `#FFF8DE` 暗 10%。所以这一版**把小游戏的纸面改成 `#E5CBB0`，奶白 `#FFF8DE` 退到只做『卡面』**"
            "（现在用 `#FBEBD0`，比奶白暖一点，压在米色纸上不跳）。这样从 HUD 点进小游戏，纸的色温是连的，不再亮一档。\n"
            "**代价**：`MiniGameTheme.Cream` 这个名字要拆成 `Paper` 和 `Card` 两个常量，M2 里所有用 `Cream` 的地方要逐处判断该取哪个。"
            "这个改动我等你点头再动代码。",
            fill="F7EFE2")

    page_break(doc)

    h(doc, "便签纸七色卡（本轮新增）", 2)
    body(doc, "右侧那张橙色便签不只是装饰，它是**这一局的色彩签名**：玩家进局第一眼看到它，就知道「这次要用哪只手」。所以七色必须同时满足三条——彼此一眼分得开、和纸面与插图不打架、同一个色系不出现两种。")
    figure(doc, "02-note-colors.png", 16.0,
           "图 0-1　便签纸七色卡（1:1 出图，可直接给美术取色）",
           "每张便签都画了投影与内层奶白卡，这才是它在局内的真实样子")

    body(doc, "取值规则（给美术的硬约束，不是建议）：")
    bullet(doc, "**明度锁在 0.63–0.78 之间。** 再亮会像塑料片，再暗会像贴纸叠在纸上——要「纸」，就必须比纸面（0.86）暗一档、又不掉到中间调的下面。")
    bullet(doc, "**彩度拉到 0.12 以上。** 便签色是唯一允许高彩度的 UI 元素；一旦灰掉，在模糊过的场景底上会显得脏。")
    bullet(doc, "**相邻色相差 ≥ 40°。** 七色走的是「暖 → 冷 → 回暖」一整圈，T1 的橙和 T7 的玫红故意不闭合：玩家不会把最后一关误认成第一关。")
    bullet(doc, "**每色必须同时给暗部。** 投影、纸背板、完成态下压全用它，现场不许临时把颜色调暗——那会让同一局的便签在不同状态下来回跳色。")

    _chip_table(doc, [
        ["T1", "**放大镜调查**\nQ06 / Q09 / Q11 / Q14", "#FB7447", "#C04E22", "概念图原色，直接沿用。铜镜与日光的暖，也是全案第一个建立「暖 = 观察」的色。"],
        ["T2", "**拨开遮挡**\nQ10 / Q12", "#F7B72B", "#C08415", "干草与阳光。比 T1 亮 3%、黄 35°，一眼分得开「掀开」和「看」两个动作。"],
        ["T3", "**翻转查验**\nQ02 / Q12 / Q15 / Q18", "#AFC93E", "#7F9421", "唯一与场景草绿同族的一色。**它靠投影与内层奶白卡拉距离，不能靠色块本身**——所以这一局的便签投影必须比其它局再深一档（见 §2.6）。"],
        ["T4", "**观察图拼合**\nQ19", "#33BFA6", "#1C8B78", "冷色段的起点。拼图是理性动作，和前面三个暖色断开；也和插图的天空蓝（#29ACFE）差着 45°，不会糊在一起。"],
        ["T5", "**痕迹拓印**\nQ17", "#3C7ED2", "#26599C", "炭与夜色的冷调。同样是蓝，但它比天空压暗两档（0.58 vs 0.72），是唯一能和天空同框不打架的蓝。"],
        ["T6", "**镊取物证**\nQ03 / Q16", "#9C6EE0", "#6B44A6", "最冷的一格。镊取是精细动作，紫能压住手抖带来的焦躁感——这是七色里唯一带情绪的一色。"],
        ["T7", "**证词归位**\nQ01 / Q04 / Q05 / Q07 / Q08 / Q13", "#E8629B", "#B23C68", "收束色。走完一圈回到暖，但**不回到 T1 的橙**——它是「说完了」，不是「又开始了」。"],
    ], widths=[1.4, 4.4, 2.0, 2.6, 8.0])

    callout(doc, "校验结果（供你复核，不必回）",
            "七色两两按 OKLab 算色差，最小的一对是 T2 金 / T3 青柠 = 10.9，其次 T1 橙 / T7 玫红 = 13.1、T5 蓝 / T6 紫 = 12.9。"
            "作为 UI 强调色这个距离已经够用——**它们从不同屏出现**，玩家永远只同时看到两种（当前局的便签 + 上一局的记忆）。\n"
            "唯一需要提醒的是 T3：它与场景草绿 `#61CF52` 的色差只有 8。这是刻意的取舍——"
            "草绿那一局的插图整片都是绿，便签如果也避开绿，七色就排不出完整色轮。**处置办法是投影，不是换色**（§2.6）。",
            fill="F7EFE2")

    table(doc,
          ["用在", "怎么用", "不要做的"],
          [
              ["便签纸本体", "100% 实色，**不加渐变、不加纹理、不加描边**。纸的质感交给纸面层（§2.1），便签本身要平。", "不要在便签上叠任何半透明层，会把它变成脏色"],
              ["投影", "暗部色 100%，offset (7, 9)，**硬边（blur = 0）**。概念图里是硬阴影，不是柔和投影。", "**不要用黑色投影**。黑投影落在米色纸上会发灰，像脏了一块"],
              ["纸背板", "同色 100%，就是它撑起整张纸的「厚度」（§2.1）", "——"],
              ["槽位完成态", "暗部色 @35% 垫在已填的槽底下面，代替原来的绿色对勾", "不要用 `GREEN`，绿色语义留给整个小游戏完成"],
              ["编号与卡内标题", "白字（便签上）/ 墨蓝 `#194D65`（奶白卡上）", "**不要拿便签色写字**，除了色卡里那个大编号"],
          ],
          widths=[2.8, 8.2, 5.0], size=8.5, align_center_cols=[0])

    page_break(doc)
