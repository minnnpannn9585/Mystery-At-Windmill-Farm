# -*- coding: utf-8 -*-
"""构建《MiniGame 美术需求文档》"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from docx import Document
from docx.shared import Cm, RGBColor
from docx_helper import setup_styles, add_page_number_footer, set_run_font, para_bottom_border

import art_content_a
import art_content_b

OUT = os.environ.get("WB_ART_DOCX_OUT") or os.path.abspath(
    os.path.join(HERE, "..", "MiniGame美术需求文档-资源清单与复用筛查.docx"))


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

    hp = sec.header.paragraphs[0]
    hp.text = ""
    hp.alignment = 1
    r = hp.add_run("《风车农场悬案》　MiniGame 美术需求文档　v1.1（概念图导入 Unity · 19 局接入）")
    set_run_font(r, size=8.5, color=RGBColor(0x9A, 0xA3, 0xAA))
    para_bottom_border(hp, "E3EAEE", 4)

    add_page_number_footer(sec, prefix="MiniGame 美术需求文档　　")

    art_content_a.build(doc)
    art_content_b.build(doc)

    doc.save(OUT)
    print("SAVED:", OUT)
    print("PARAGRAPHS:", len(doc.paragraphs), "TABLES:", len(doc.tables))


if __name__ == "__main__":
    main()
