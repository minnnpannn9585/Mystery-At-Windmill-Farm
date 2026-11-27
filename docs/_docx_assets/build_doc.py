# -*- coding: utf-8 -*-
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from docx import Document
from docx.shared import Cm, Pt
from docx_helper import setup_styles, add_page_number_footer
import content_a
import content_b

QUESTIONS = os.path.join(HERE, "..")
OUT = os.environ.get("WB_DOCX_OUT") or os.path.abspath(
    os.path.join(HERE, "..", "MiniGameSystem-技术文档-T1至T7.docx"))


def main():
    doc = Document()
    setup_styles(doc)

    sec = doc.sections[0]
    sec.page_width = Cm(21.0)
    sec.page_height = Cm(29.7)
    sec.top_margin = Cm(2.0)
    sec.bottom_margin = Cm(2.0)
    sec.left_margin = Cm(2.4)
    sec.right_margin = Cm(2.4)
    sec.header_distance = Cm(1.2)
    sec.footer_distance = Cm(1.2)

    # 页眉
    from docx_helper import set_run_font, para_bottom_border
    from docx.shared import RGBColor as _C
    hp = sec.header.paragraphs[0]
    hp.text = ""
    hp.alignment = 1
    r = hp.add_run("《风车农场悬案》　MiniGameSystem 设计案　v2.17（ComfyUI 实机模板重生成素材投入）")
    set_run_font(r, size=8.5, color=_C(0x9A, 0xA3, 0xAA))
    para_bottom_border(hp, "E3EAEE", 4)

    add_page_number_footer(sec)

    content_a.build(doc)
    content_b.build(doc)

    doc.save(OUT)
    print("SAVED:", OUT)
    print("PARAGRAPHS:", len(doc.paragraphs), "TABLES:", len(doc.tables))


if __name__ == "__main__":
    main()
