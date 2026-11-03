# -*- coding: utf-8 -*-
"""docx 排版助手：中文样式、表格、图片、页脚页码（含 OOXML 元素顺序安全插入）"""
import os
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from PIL import Image

DEEP = RGBColor(0x19, 0x4D, 0x65)
MID = RGBColor(0x2A, 0x6B, 0x86)
GREY = RGBColor(0x6B, 0x72, 0x80)
DARK = RGBColor(0x24, 0x2A, 0x30)
ORANGE = RGBColor(0xEF, 0x78, 0x49)

HDR_FILL = "D9E6EC"
ALT_FILL = "F4F8FA"
NOTE_FILL = "FFF8DE"

CONTENT_W_CM = 16.2   # A4 21cm - 左右各 2.4cm
EMU_PER_CM = 360000

PPR_ORDER = ["w:pStyle", "w:keepNext", "w:keepLines", "w:pageBreakBefore", "w:framePr",
             "w:widowControl", "w:numPr", "w:suppressLineNumbers", "w:pBdr", "w:shd",
             "w:tabs", "w:suppressAutoHyphens", "w:kinsoku", "w:wordWrap", "w:overflowPunct",
             "w:topLinePunct", "w:autoSpaceDE", "w:autoSpaceDN", "w:bidi", "w:adjustRightInd",
             "w:snapToGrid", "w:spacing", "w:ind", "w:contextualSpacing", "w:mirrorIndents",
             "w:suppressOverlap", "w:jc", "w:textDirection", "w:textAlignment",
             "w:textboxTightWrap", "w:outlineLvl", "w:divId", "w:cnfStyle", "w:rPr",
             "w:sectPr", "w:pPrChange"]

TCPR_ORDER = ["w:cnfStyle", "w:tcW", "w:gridSpan", "w:hMerge", "w:vMerge", "w:tcBorders",
              "w:shd", "w:noWrap", "w:tcMar", "w:textDirection", "w:tcFitText", "w:vAlign",
              "w:hideMark", "w:headers", "w:cellIns", "w:cellDel", "w:cellMerge", "w:tcPrChange"]

TBLPR_ORDER = ["w:tblStyle", "w:tblpPr", "w:tblOverlap", "w:bidiVisual", "w:tblStyleRowBandSize",
               "w:tblStyleColBandSize", "w:tblW", "w:jc", "w:tblCellSpacing", "w:tblInd",
               "w:tblBorders", "w:shd", "w:tblLayout", "w:tblCellMar", "w:tblLook",
               "w:tblCaption", "w:tblDescription", "w:tblPrChange"]

TRPR_ORDER = ["w:cnfStyle", "w:divId", "w:gridBefore", "w:gridAfter", "w:wBefore", "w:wAfter",
              "w:cantSplit", "w:trHeight", "w:tblHeader", "w:tblCellSpacing", "w:jc",
              "w:hidden", "w:ins", "w:del", "w:trPrChange"]


def _insert_ordered(parent, elm, tag, order):
    for child in parent.findall(qn(tag)):
        parent.remove(child)
    successors = order[order.index(tag) + 1:]
    parent.insert_element_before(elm, *successors)


def set_run_font(run, name="Microsoft YaHei", size=None, bold=None, color=None, italic=None):
    run.font.name = name
    rpr = run._element.get_or_add_rPr()
    rf = rpr.find(qn("w:rFonts"))
    if rf is None:
        rf = OxmlElement("w:rFonts")
        rpr.insert(0, rf)
    rf.set(qn("w:ascii"), name)
    rf.set(qn("w:hAnsi"), name)
    rf.set(qn("w:eastAsia"), name)
    rf.set(qn("w:cs"), name)
    if size is not None:
        run.font.size = Pt(size)
    if bold is not None:
        run.font.bold = bold
    if italic is not None:
        run.font.italic = italic
    if color is not None:
        run.font.color.rgb = color


_INLINE = None


def _set_code_font(run, size, color):
    """行内代码：西文 Consolas、中文回落雅黑，不加粗不斜体"""
    rpr = run._element.get_or_add_rPr()
    rf = rpr.find(qn("w:rFonts"))
    if rf is None:
        rf = OxmlElement("w:rFonts")
        rpr.insert(0, rf)
    rf.set(qn("w:ascii"), "Consolas")
    rf.set(qn("w:hAnsi"), "Consolas")
    rf.set(qn("w:eastAsia"), "Microsoft YaHei")
    rf.set(qn("w:cs"), "Consolas")
    run.font.size = Pt(size)
    run.font.color.rgb = color


def _rich(p, text, size=10.5, color=None, bold=False, code_color=None):
    """解析 **加粗** 与 `代码`（支持二者嵌套），生成多个 run"""
    base = color or DARK
    ccol = code_color or MID
    text = "" if text is None else str(text)

    def emit(chunk, is_bold):
        if not chunk:
            return
        # 第二层：切反引号
        segs = chunk.split("`")
        for si, seg in enumerate(segs):
            if not seg:
                continue
            if si % 2 == 1:
                r = p.add_run(seg)
                _set_code_font(r, size - 0.5, ccol)
                if is_bold:
                    r.font.bold = True
            else:
                r = p.add_run(seg)
                set_run_font(r, size=size, color=base, bold=is_bold)

    # 第一层：切 ** 加粗
    segs = text.split("**")
    for si, seg in enumerate(segs):
        emit(seg, si % 2 == 1)
    return p


def shade(cell, hexfill):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), hexfill)
    _insert_ordered(tcPr, shd, "w:shd", TCPR_ORDER)


def cell_margins(cell, top=60, bottom=60, left=100, right=100):
    tcPr = cell._tc.get_or_add_tcPr()
    mar = OxmlElement("w:tcMar")
    for tag, val in (("w:top", top), ("w:left", left), ("w:bottom", bottom), ("w:right", right)):
        el = OxmlElement(tag)
        el.set(qn("w:w"), str(val))
        el.set(qn("w:type"), "dxa")
        mar.append(el)
    _insert_ordered(tcPr, mar, "w:tcMar", TCPR_ORDER)


def cell_left_bar(cell, color="FFD447", sz=24):
    tcPr = cell._tc.get_or_add_tcPr()
    borders = OxmlElement("w:tcBorders")
    left = OxmlElement("w:left")
    left.set(qn("w:val"), "single")
    left.set(qn("w:sz"), str(sz))
    left.set(qn("w:space"), "0")
    left.set(qn("w:color"), color)
    borders.append(left)
    _insert_ordered(tcPr, borders, "w:tcBorders", TCPR_ORDER)


def para_bottom_border(p, color="194D65", sz=8):
    pPr = p._p.get_or_add_pPr()
    bdr = OxmlElement("w:pBdr")
    bottom = OxmlElement("w:bottom")
    bottom.set(qn("w:val"), "single")
    bottom.set(qn("w:sz"), str(sz))
    bottom.set(qn("w:space"), "4")
    bottom.set(qn("w:color"), color)
    bdr.append(bottom)
    _insert_ordered(pPr, bdr, "w:pBdr", PPR_ORDER)


def setup_styles(doc):
    st = doc.styles["Normal"]
    st.font.name = "Microsoft YaHei"
    st.font.size = Pt(10.5)
    st.font.color.rgb = DARK
    st.element.rPr.rFonts.set(qn("w:eastAsia"), "Microsoft YaHei")
    pf = st.paragraph_format
    pf.line_spacing = 1.55
    pf.space_after = Pt(6)
    pf.space_before = Pt(0)
    pf.widow_control = True

    for name, size, color, before, after in (
        ("Heading 1", 17, DEEP, 20, 10),
        ("Heading 2", 13.5, MID, 14, 6),
        ("Heading 3", 11.5, DEEP, 10, 4),
        ("Heading 4", 10.5, GREY, 8, 3),
    ):
        s = doc.styles[name]
        s.font.name = "Microsoft YaHei"
        s.font.size = Pt(size)
        s.font.bold = True
        s.font.color.rgb = color
        s.element.rPr.rFonts.set(qn("w:eastAsia"), "Microsoft YaHei")
        s.paragraph_format.space_before = Pt(before)
        s.paragraph_format.space_after = Pt(after)
        s.paragraph_format.line_spacing = 1.25
        s.paragraph_format.keep_with_next = True


def h(doc, text, level=1, rule=False):
    p = doc.add_heading(text, level=level)
    if level == 1 and rule:
        para_bottom_border(p, "C8D8E0", 6)
    return p


def body(doc, text, size=10.5, color=None, space_after=6, align=None, bold=False):
    p = doc.add_paragraph()
    _rich(p, text, size=size, color=color or DARK, bold=bold)
    p.paragraph_format.space_after = Pt(space_after)
    if align:
        p.alignment = align
    return p


def bullet(doc, text, level=0, size=10.5, marker="•  "):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Cm(0.6 + 0.6 * level)
    p.paragraph_format.first_line_indent = Cm(-0.45)
    p.paragraph_format.space_after = Pt(3)
    _rich(p, marker + text, size=size)
    return p


def callout(doc, title, text, fill=NOTE_FILL, bar="FFD447"):
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    _fix_tbl_width(tbl, [CONTENT_W_CM], fixed=True)
    c = tbl.cell(0, 0)
    shade(c, fill)
    cell_margins(c, 120, 120, 180, 160)
    cell_left_bar(c, bar)
    p0 = c.paragraphs[0]
    p0.text = ""
    _rich(p0, title, size=10.5, color=DEEP, bold=True)
    p0.paragraph_format.space_after = Pt(3)
    p1 = c.add_paragraph()
    _rich(p1, text, size=10)
    p1.paragraph_format.space_after = Pt(0)
    p1.paragraph_format.line_spacing = 1.4
    doc.add_paragraph().paragraph_format.space_after = Pt(2)


def _fix_tbl_width(tbl, widths_cm=None, total_cm=CONTENT_W_CM, fixed=True):
    """把表格总宽强制归一化到版心宽度，避免溢出右边距。"""
    tblPr = tbl._tbl.tblPr
    ncols = len(tbl.columns)
    if not widths_cm or len(widths_cm) != ncols:
        widths_cm = [total_cm / ncols] * ncols
    s = float(sum(widths_cm))
    if s > total_cm:
        k = total_cm / s
        widths_cm = [w * k for w in widths_cm]
    # tblW
    tblW = OxmlElement("w:tblW")
    tblW.set(qn("w:w"), str(int(sum(widths_cm) * 567)))
    tblW.set(qn("w:type"), "dxa")
    _insert_ordered(tblPr, tblW, "w:tblW", TBLPR_ORDER)
    # tblLayout
    lay = OxmlElement("w:tblLayout")
    lay.set(qn("w:type"), "fixed" if fixed else "autofit")
    _insert_ordered(tblPr, lay, "w:tblLayout", TBLPR_ORDER)
    # grid + 每个 cell 宽度
    grid = tbl._tbl.find(qn("w:tblGrid"))
    if grid is not None:
        for gc, w in zip(grid.findall(qn("w:gridCol")), widths_cm):
            gc.set(qn("w:w"), str(int(w * 567)))
    for row in tbl.rows:
        for cell, w in zip(row.cells, widths_cm):
            cell.width = Cm(w)


def table(doc, headers, rows, widths=None, size=9.5, hdr_size=9.5, zebra=True, align_center_cols=None):
    ncols = len(headers)
    tbl = doc.add_table(rows=1, cols=ncols)
    tbl.style = "Table Grid"
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER

    hdr = tbl.rows[0]
    for i, htxt in enumerate(headers):
        c = hdr.cells[i]
        shade(c, HDR_FILL)
        cell_margins(c)
        p = c.paragraphs[0]
        p.text = ""
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(0)
        p.paragraph_format.line_spacing = 1.2
        r = p.add_run(htxt)
        set_run_font(r, size=hdr_size, bold=True, color=DEEP)
    trPr = hdr._tr.get_or_add_trPr()
    th = OxmlElement("w:tblHeader")
    _insert_ordered(trPr, th, "w:tblHeader", TRPR_ORDER)

    for ri, row in enumerate(rows):
        cells = tbl.add_row().cells
        for ci, val in enumerate(row):
            c = cells[ci]
            cell_margins(c)
            if zebra and ri % 2 == 1:
                shade(c, ALT_FILL)
            lines = str(val).split("\n")
            p = c.paragraphs[0]
            p.text = ""
            p.paragraph_format.space_after = Pt(0)
            p.paragraph_format.line_spacing = 1.25
            if align_center_cols and ci in align_center_cols:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            for li, ln in enumerate(lines):
                if li > 0:
                    p = c.add_paragraph()
                    p.paragraph_format.space_after = Pt(0)
                    p.paragraph_format.line_spacing = 1.25
                    if align_center_cols and ci in align_center_cols:
                        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                _rich(p, ln, size=size)

    _fix_tbl_width(tbl, widths)
    return tbl


def figure(doc, path, width_cm, caption=None, note=None):
    doc.add_picture(path, width=Cm(width_cm))
    p = doc.paragraphs[-1]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(2)
    if caption:
        cp = doc.add_paragraph()
        cp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        cp.paragraph_format.space_after = Pt(2 if note else 8)
        r = cp.add_run(caption)
        set_run_font(r, size=9, color=GREY, bold=True)
    if note:
        np_ = doc.add_paragraph()
        np_.alignment = WD_ALIGN_PARAGRAPH.CENTER
        np_.paragraph_format.space_after = Pt(9)
        _rich(np_, note, size=9, color=GREY)


def _fld(p, instr, placeholder="1", size=8.5, color=None):
    col = color or GREY
    fld = OxmlElement("w:fldSimple")
    fld.set(qn("w:instr"), instr)
    r = OxmlElement("w:r")
    rPr = OxmlElement("w:rPr")
    rf = OxmlElement("w:rFonts")
    rf.set(qn("w:ascii"), "Microsoft YaHei")
    rf.set(qn("w:hAnsi"), "Microsoft YaHei")
    rf.set(qn("w:eastAsia"), "Microsoft YaHei")
    rPr.append(rf)
    c = OxmlElement("w:color")
    c.set(qn("w:val"), "%02X%02X%02X" % (col[0], col[1], col[2]))
    rPr.append(c)
    sz = OxmlElement("w:sz")
    sz.set(qn("w:val"), str(int(size * 2)))
    rPr.append(sz)
    r.append(rPr)
    t = OxmlElement("w:t")
    t.text = placeholder
    r.append(t)
    fld.append(r)
    p._p.append(fld)


def add_page_number_footer(section, prefix="MiniGameSystem 设计案　　"):
    footer = section.footer
    p = footer.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(prefix)
    set_run_font(r, size=8.5, color=GREY)
    _fld(p, "PAGE")
    rr = p.add_run(" / ")
    set_run_font(rr, size=8.5, color=GREY)
    _fld(p, "NUMPAGES")


def hr(doc, space_before=2, space_after=8):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(space_before)
    p.paragraph_format.space_after = Pt(space_after)
    para_bottom_border(p, "DCE6EB", 6)
    return p


def page_break(doc):
    from docx.enum.text import WD_BREAK
    doc.add_paragraph().add_run().add_break(WD_BREAK.PAGE)
