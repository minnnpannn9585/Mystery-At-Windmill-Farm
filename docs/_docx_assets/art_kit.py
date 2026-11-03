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


def palette(doc):
    """色板：先定色，后面各表只写色号。"""
    from docx_helper import table, body
    body(doc, "本文件所有色号都取自 `MiniGameTheme.cs` 里的实际值——也就是说，**下表不是「建议配色」，而是当前 build 里肉眼看到的颜色**。占位阶段它们就是最终验收的对照基准；美术出图时按这里的色号取色，换上正式图后颜色不应出现整体偏移。")

    table(doc,
          ["代号", "名称", "色号", "用在哪", "说明"],
          [
              ["`DEEP`", "深蓝", "#194D65", "主文字 / 描边 / 完成横幅底色", "全案的主色，比纯黑柔和，和纸色搭配不脏"],
              ["`CREAM`", "奶白", "#FFF8DE", "面板底 / 卡面 / 槽底", "不是纯白：纯白在稻草场景里会发光，偏黄的奶白才像纸"],
              ["`YELLOW`", "亮黄", "#FFD447", "可交互高亮 / 主按钮 / 图块", "只在「这里可以动」的地方出现，用作可点性的信号"],
              ["`ORANGE`", "橙", "#EF7849", "进度 / 错位警示", "错位格闪烁用它，不用红——红的语义留给失败"],
              ["`BLUE`", "蓝", "#26A9FF", "二级提示指示", "提示第二级用来指出「该去哪」"],
              ["`GREEN`", "绿", "#65D443", "完成态填充", "放在 0.45 透明度下当作「已归位」的底色"],
              ["`DARKGREEN`", "深绿", "#24A348", "右栏勾选文字", "与 GREEN 成对：填充用浅、文字用深"],
              ["`INK`", "墨色", "#242A30", "正文", "极少用，主要给长段说明"],
              ["`GREY`", "灰", "#6B7280", "次要文字 / 未激活", "错位块的降饱和填充也用它"],
              ["`PAPER`", "HUD 纸色", "#E2C7A2", "**仅 HUD / 笔记本**，小游戏不用", "见下方待决 P1"],
          ],
          widths=[2.0, 2.2, 2.2, 6.0, 3.8], size=8.5, align_center_cols=[0, 1, 2])

    from docx_helper import callout
    callout(doc, "待决 P1：两套纸色并存",
            "游戏 HUD 与笔记本用 `HudPaperStyle.Paper = #E2C7A2`（偏卡其的旧纸），"
            "小游戏用 `MiniGameTheme.Cream = #FFF8DE`（偏亮的奶白）。两套同时出现在同一屏时会明显割裂："
            "小游戏从 HUD 按钮点进去，底色会整体亮一档。\n"
            "**我的建议**：小游戏保持 `#FFF8DE`（它是 19-文档 §19.7 定的，且小游戏是「展开的一页纸」，比 HUD 更亮是合理的），"
            "但要给 Body 区压一层 `#E2C7A2` 的 8% 蒙版，让两张纸在色温上连得上。"
            "这件事需要你拍板，定了我再回写技术文档 §19.7 的用色说明。",
            fill="FFF8DE")

    from docx_helper import page_break
    page_break(doc)
