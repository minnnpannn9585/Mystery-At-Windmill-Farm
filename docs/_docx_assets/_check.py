# -*- coding: utf-8 -*-
"""文档全量体检：目录↔标题、表格列数↔宽度、表格总宽、§ 引用悬空"""
import io, re, sys
from docx import Document
from docx.shared import Cm

path = sys.argv[1]
doc = Document(path)

# ---------- 1. 标题 / 目录 ----------
heads = []      # (level, text)
for p in doc.paragraphs:
    s = p.style.name
    if s in ("Heading 1", "Heading 2"):
        t = p.text.strip()
        if t:
            heads.append((1 if s == "Heading 1" else 2, t))

# 目录区：从 "目录" 标题后到第一个 Heading1 "1　修订说明..."
toc = []
in_toc = False
for p in doc.paragraphs:
    t = p.text.strip()
    if p.style.name == "Heading 1" and t == "目录":
        in_toc = True
        continue
    if in_toc:
        if p.style.name == "Heading 1":
            break
        m = re.match(r"^([0-9A-Z]+(?:\.[0-9]+)?)\u3000(.+)$", t)
        if m:
            toc.append((m.group(1), m.group(2)))

# 解析标题里的编号
head_pairs = []
LETTERS = ["A", "B", "C", "D"]
_li = 0
for lvl, t in heads:
    m = re.match(r"^([0-9]+(?:\.[0-9]+)?)\u3000(.+)$", t)
    if m:
        head_pairs.append((m.group(1), m.group(2), lvl))
        continue
    if t.startswith("附录"):
        head_pairs.append((LETTERS[_li], t, lvl)); _li += 1

print("HEADINGS(h1+h2):", len(head_pairs), " TOC entries:", len(toc))

toc_map = dict(toc)
n_bad = 0
for num, title, lvl in head_pairs:
    if num == "目录":
        continue
    if num not in toc_map:
        print("  [目录缺条目]", num, title); n_bad += 1
        continue
    if toc_map[num] != title:
        print("  [文字不符]", num, "\n     toc :", toc_map[num], "\n     head:", title); n_bad += 1

head_nums = set(n for n, _, _ in head_pairs)
for num, title in toc:
    if num not in head_nums:
        print("  [目录多出]", num, title); n_bad += 1
print("TOC/HEAD 不一致:", n_bad)

# ---------- 2. 表格 ----------
CONTENT_W = 16.2
bad_w = 0
for i, tb in enumerate(doc.tables, 1):
    ncol = len(tb.columns)
    grid = tb._tbl.tblGrid
    widths = []
    for gc in grid.findall(
            "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}gridCol"):
        w = gc.get("{http://schemas.openxmlformats.org/wordprocessingml/2006/main}w")
        widths.append(int(w) / 1440.0 * 2.54 if w else 0)
    total = sum(widths)
    if abs(total - CONTENT_W) > 0.35:
        print("  [表格总宽异常] #%d cols=%d total=%.2fcm" % (i, ncol, total)); bad_w += 1
    # 每行列数
    for r in tb.rows:
        if len(r.cells) != ncol:
            print("  [行列数不符] #%d 应有%d列 实有%d列" % (i, ncol, len(r.cells))); bad_w += 1
            break
print("表格数:", len(doc.tables), " 宽度/列数异常:", bad_w)

# ---------- 3. § 引用 ----------
full = "\n".join(p.text for p in doc.paragraphs)
for tb in doc.tables:
    for r in tb.rows:
        for c in r.cells:
            full += "\n" + c.text
refs = set(re.findall(r"§\s?([0-9]+(?:\.[0-9]+)*)", full))
valid = set(n for n in head_nums)
dangling = []
for r in sorted(refs):
    if r in valid:
        continue
    # 允许父级存在（如 §13 引用、§9.3.1 之类）
    if r.split(".")[0] in valid:
        continue
    dangling.append(r)
print("§ 引用种类:", len(refs), " 悬空:", dangling if dangling else 0)

print("PARAGRAPHS:", len(doc.paragraphs), "TABLES:", len(doc.tables))
imgs = len(doc.inline_shapes)
print("IMAGES:", imgs)
import os
print("SIZE: %.2f MB" % (os.path.getsize(path) / 1048576.0))
