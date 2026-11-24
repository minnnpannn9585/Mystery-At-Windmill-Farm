# -*- coding: utf-8 -*-
"""把桌面「组件」文件夹的骨架组件原稿裁切拼合成一张素材总览图。
   组件即最终效果，不再新出图；提示按钮无合适组件，留虚线占位。"""

import os
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = r"C:\Users\Administrator\Desktop\组件"
OUT = os.path.join(HERE, "component_sheet.png")

FONT = "C:/Windows/Fonts/msyh.ttc"
FONT_B = "C:/Windows/Fonts/msyhbd.ttc"

# (文件, 编号, 名称, 说明)
ITEMS = [
    ("纸叠层.png", "G-16", "纸叠层", "1164×800 · #DCC0A2 · 只露 8px 页边"),
    ("纸面.png", "G-17", "纸面 + 横线", "1156×792 · #E5CBB0 + 26px 横线"),
    ("纸背板.png", "G-15", "纸背板", "1172×812 · 色随本局便签色变"),
    ("便签栏.png", "G-06", "便签栏", "170×663 · 七色卡 · T4 用 240 宽"),
    ("标题行.png", "G-04", "标题行", "1037×80 · 32px 墨蓝文字带"),
    ("底栏（只做位置参考，具体图案不参考这个）.png", "G-09", "底栏", "1080×104 · 仅位置参考，图案不沿用"),
    ("关闭X.png", "G-02", "X 关闭按钮", "82×82 · 奶白填充 · 手绘粗描边"),
    ("回形针.png", "G-18", "回形针", "38×196 · 手绘黑线 · 纯装饰"),
    ("放大镜图标（玩家交互UI可移动）.png", "G-20a", "放大镜图标", "玩家可移动 UI · 镜圈墨蓝 / 柄橙黄"),
]
PLACEHOLDER = ("G-20b", "提示按钮", "暂无合适组件 · 待补参考图")

DEEP = (25, 77, 101)
ORANGE = (239, 120, 73)
GREY = (107, 114, 128)
LINE = (216, 226, 232)
PAPER = (245, 242, 235)
WHITE = (255, 255, 255)

W = 1620
MARGIN = 44
GAP = 26
COLS = 3
CARD_W = (W - MARGIN * 2 - GAP * (COLS - 1)) // COLS  # 494
CARD_H = 430
HEADER_H = 148
ROWS = (len(ITEMS) + 1 + COLS - 1) // COLS
H = HEADER_H + ROWS * CARD_H + (ROWS - 1) * GAP + 46

canvas = Image.new("RGB", (W, H), (250, 251, 252))
d = ImageDraw.Draw(canvas)

f_title = ImageFont.truetype(FONT_B, 40)
f_sub = ImageFont.truetype(FONT, 20)
f_chip = ImageFont.truetype(FONT_B, 18)
f_name = ImageFont.truetype(FONT_B, 24)
f_note = ImageFont.truetype(FONT, 17)
f_ph = ImageFont.truetype(FONT_B, 22)
f_ph2 = ImageFont.truetype(FONT, 17)

# 顶部标题带
d.rectangle([0, 0, W, HEADER_H - 24], fill=(247, 250, 251))
d.rectangle([0, 0, 12, HEADER_H - 24], fill=ORANGE)
d.text((MARGIN, 26), "骨架层现有组件原稿一览", font=f_title, fill=DEEP)
d.text((MARGIN, 82),
       "以下 9 件即当前效果，直接采用、不再新出图 · 全部按 alpha 边界裁切展示 · 原稿为 1920×1080 全画布透明 PNG",
       font=f_sub, fill=GREY)

IMG_TOP = 62
IMG_BOTTOM = 322
IMG_LEFT = 16
IMG_RIGHT = CARD_W - 16


def rounded(draw, box, radius, fill=None, outline=None, width=1):
    draw.rounded_rectangle(list(box), radius=radius, fill=fill, outline=outline, width=width)


def draw_card(idx, code, name, note, image=None):
    r = idx // COLS
    c = idx % COLS
    x = MARGIN + c * (CARD_W + GAP)
    y = HEADER_H + r * (CARD_H + GAP)

    rounded(d, [x, y, x + CARD_W, y + CARD_H], 12, fill=WHITE, outline=LINE, width=2)

    # 编号 chip
    chip_w = 76
    rounded(d, [x + 14, y + 13, x + 14 + chip_w, y + 45], 7, fill=DEEP)
    tw = d.textlength(code, font=f_chip)
    d.text((x + 14 + (chip_w - tw) / 2, y + 19), code, font=f_chip, fill=WHITE)

    nw = d.textlength(name, font=f_name)
    d.text((x + 14 + chip_w + 14, y + 17), name, font=f_name, fill=DEEP)

    # 图区（纸色底）
    ix0, iy0, ix1, iy1 = x + IMG_LEFT, y + IMG_TOP, x + IMG_RIGHT, y + IMG_BOTTOM
    rounded(d, [ix0, iy0, ix1, iy1], 8, fill=PAPER)

    if image is not None:
        bbox = image.getchannel("A").getbbox()
        if bbox:
            crop = image.crop(bbox)
        else:
            crop = image
        max_w, max_h = (ix1 - ix0) - 20, (iy1 - iy0) - 20
        scale = min(max_w / crop.width, max_h / crop.height)
        nw2 = max(1, int(crop.width * scale))
        nh2 = max(1, int(crop.height * scale))
        crop = crop.resize((nw2, nh2), Image.LANCZOS)
        canvas.paste(crop, (int(ix0 + (ix1 - ix0 - nw2) / 2),
                            int(iy0 + (iy1 - iy0 - nh2) / 2)), crop)

    # 说明（两行）
    d.text((x + 16, y + 340), note, font=f_note, fill=GREY)
    d.text((x + 16, y + 372), "原稿 1:1 · 不可再调角度 / 笔触", font=f_note, fill=(155, 162, 170))


for i, (fn, code, name, note) in enumerate(ITEMS):
    path = os.path.join(SRC, fn)
    im = Image.open(path).convert("RGBA") if os.path.exists(path) else None
    draw_card(i, code, name, note, im)

# 提示按钮占位
idx = len(ITEMS)
r, c = idx // COLS, idx % COLS
x = MARGIN + c * (CARD_W + GAP)
y = HEADER_H + r * (CARD_H + GAP)
rounded(d, [x, y, x + CARD_W, y + CARD_H], 12, fill=(253, 249, 249), outline=(214, 118, 118), width=2)
chip_w = 76
rounded(d, [x + 14, y + 13, x + 14 + chip_w, y + 45], 7, fill=(176, 70, 70))
tw = d.textlength(PLACEHOLDER[0], font=f_chip)
d.text((x + 14 + (chip_w - tw) / 2, y + 19), PLACEHOLDER[0], font=f_chip, fill=WHITE)
d.text((x + 14 + chip_w + 14, y + 17), PLACEHOLDER[1], font=f_name, fill=(150, 60, 60))

ix0, iy0, ix1, iy1 = x + IMG_LEFT, y + IMG_TOP, x + IMG_RIGHT, y + IMG_BOTTOM
d.rounded_rectangle([ix0, iy0, ix1, iy1], radius=8, fill=(255, 252, 252),
                    outline=(206, 138, 138), width=2)
for gx in range(ix0 + 12, ix1 - 12, 18):
    d.line([(gx, iy1 - 10), (gx + 8, iy1 - 18)], fill=(236, 206, 206), width=1)
cx, cy = (ix0 + ix1) / 2, (iy0 + iy1) / 2
q = "?  "
qw = d.textlength(q, font=f_title)
d.text((cx - qw / 2, cy - 74), q, font=f_title, fill=(206, 138, 138))
t = "暂无合适组件"
tw = d.textlength(t, font=f_ph)
d.text((cx - tw / 2, cy - 8), t, font=f_ph, fill=(150, 60, 60))
t2 = "待补参考图 · 不硬凑现有件"
tw2 = d.textlength(t2, font=f_ph2)
d.text((cx - tw2 / 2, cy + 30), t2, font=f_ph2, fill=GREY)
d.text((x + 16, y + 340), "建议尺寸 48×48 · 实心墨蓝灯泡 + 三根短线当光", font=f_note, fill=GREY)
d.text((x + 16, y + 372), "现有组件均不匹配，留位待美术补", font=f_note, fill=(155, 162, 170))

canvas.save(OUT)
print("SAVED:", OUT, canvas.size)
