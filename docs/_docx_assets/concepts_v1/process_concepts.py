# -*- coding: utf-8 -*-
"""
概念图后处理：米底 -> 透明 PNG + 按 alpha 边界重框 + 按美术规格输出尺寸。

方案：纯 Pillow 实现的确定性边缘 flood fill（键控）。
  1) 从四条边向内漫水，凡与边缘连通、且颜色接近边缘米色的像素 -> alpha 0
  2) alpha 边缘 1px 羽化，消除手绘纸纹造成的锯齿
  3) 按 alpha>阈值 求包围盒裁切（重框边界）
  4) 四周补 2px 透明边（文档 §12.3 硬约束）
  5) 等比缩放并居中到目标规格尺寸（不拉伸变形）

不处理满幅场景图（背景板 / 母图 / 抓痕 / 取样纸）：它们在 SKIP 集合里。
输入原始图在 _raw/，输出写回当前目录（docx 通过 cv1() 读这里）。
"""
import os
from collections import deque

from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "_raw")
OUT = HERE

# 不处理：满幅场景图（背景板 B / T4-01 母图 / T5 抓痕 / 取样纸）
SKIP = {"RT1A", "RT4A", "RT5A", "RT5B"}

# 目标规格尺寸（来自美术需求文档各节规格表）
# 组合展示图（同图多件）用能容纳各件的画布；单件用文档给的精确尺寸。
SPEC = {
    "RG20B": (48, 48),       # G-20b 提示按钮 48×48
    "RT1W": (300, 400),      # W-01 镜片 260 + W-02 手柄 150（斜向组合展示）
    "RT1B": (360, 180),      # T1-05 焦稻草 200×140 + T1-06 卷毛 140×110
    "RT1C": (420, 140),      # T1-07 划痕 160×70 + T1-08 亮边 240×80
    "RT2A": (144, 220),      # M-01 草束母版 144×220
    "RT2B": (460, 240),      # T2-03/04 白圆石两面 220×220 ×2
    "RT2C": (260, 420),      # 停放区虚线框 260×420
    "RT3A": (920, 420),      # M-06 食碗两姿态 460×400 ×2
    "RT3B": (920, 420),      # M-07 水桶内外 460×400 ×2
    "RT3C": (96, 96),        # W-04 翻转把手（提示图标，按图标档）
    "RT4B": (280, 280),      # T4-02/03 方向示意 260×120 ×2
    "RT6A": (440, 220),      # 镊子两态
    "RT6B": (400, 400),      # 观察盘底 400×400
    "RT7A": (960, 480),      # 18 卡面图标 96×96 网格
    "RT7B": (320, 130),      # Q07 三张隐语图标
    "RF01": (256, 256),      # F-01 纸张折角 128×128（2x 展示）
    "RN01": (56, 56),        # N-01 角标 28×28（2x 展示）
}

# 键控容差：种子色与各通道的最大差。手绘米底有 ±10 纹理浮动，取 26。
TOL = 26
# 边缘种子密度（每条边取的点数）
SEEDS = 12
# alpha 包围盒判定阈值
ALPHA_CUT = 8
PAD = 2  # 文档要求的透明边


def sample_bg_color(im):
    """取四角与四边中点的中位色作为米底参考色。"""
    w, h = im.size
    px = im.load()
    pts = []
    for x in (2, w // 2, w - 3):
        for y in (2, h - 3):
            pts.append(px[x, y])
    for y in (h // 2,):
        for x in (2, w - 3):
            pts.append(px[x, y])
    chans = list(zip(*pts))
    return tuple(int(sorted(c)[len(c) // 2]) for c in chans)


def close(a, b, tol):
    return abs(a[0] - b[0]) <= tol and abs(a[1] - b[1]) <= tol and abs(a[2] - b[2]) <= tol


def edge_flood_alpha(im, tol=TOL, seeds=SEEDS):
    """从边缘漫水，返回 alpha 图：与边缘米底连通且颜色接近的像素=0。"""
    w, h = im.size
    src = im.convert("RGB")
    px = src.load()
    bg = sample_bg_color(src)

    visited = bytearray(w * h)
    q = deque()

    # 边缘像素：若接近米底则入队作为种子；否则也在四角强制取点
    def push(x, y):
        if 0 <= x < w and 0 <= y < h:
            i = y * w + x
            if not visited[i]:
                visited[i] = 1
                q.append((x, y))

    for k in range(seeds + 1):
        x = int(k * (w - 1) / seeds)
        push(x, 0); push(x, h - 1)
    for k in range(seeds + 1):
        y = int(k * (h - 1) / seeds)
        push(0, y); push(w - 1, y)

    # 用局部色做种子参照更像人眼：每个连通点与其初始种子色比较不够稳，
    # 这里统一用全局米底 bg；手绘米底渐变已被 tol=26 覆盖。
    while q:
        x, y = q.popleft()
        if not close(px[x, y], bg, tol):
            continue
        if x > 0: push(x - 1, y)
        if x < w - 1: push(x + 1, y)
        if y > 0: push(x, y - 1)
        if y < h - 1: push(x, y + 1)

    alpha = Image.new("L", (w, h), 255)
    ap = alpha.load()
    for i in range(w * h):
        if visited[i]:
            ap[i % w, i // w] = 0
    return alpha


def trim_and_pad(rgba, alpha_cut=ALPHA_CUT, pad=PAD):
    a = rgba.getchannel("A")
    bbox = a.point(lambda v: 255 if v > alpha_cut else 0).getbbox()
    if bbox is None:
        return rgba
    x0, y0, x1, y1 = bbox
    x0 = max(0, x0 - pad); y0 = max(0, y0 - pad)
    x1 = min(rgba.width, x1 + pad); y1 = min(rgba.height, y1 + pad)
    return rgba.crop((x0, y0, x1, y1))


def fit_to(rgba, size):
    """等比缩放居中到目标尺寸，不拉伸；透明边保持。"""
    tw, th = size
    im = rgba.copy()
    im.thumbnail((tw, th), Image.LANCZOS)
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    canvas.alpha_composite(im, ((tw - im.width) // 2, (th - im.height) // 2))
    return canvas


def process(code, tol=TOL, preview=False):
    src = os.path.join(RAW, code + ".png")
    if not os.path.exists(src):
        return None, "missing source"
    im = Image.open(src).convert("RGBA")
    alpha = edge_flood_alpha(im.convert("RGB"), tol)
    # 轻微羽化：只作用于 alpha，去掉纸纹噪声造成的硬锯齿
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.6))
    rgba = im.copy()
    rgba.putalpha(alpha)
    rgba = trim_and_pad(rgba)
    target = SPEC.get(code, rgba.size)
    out = fit_to(rgba, target)
    if not preview:
        out.save(os.path.join(OUT, code + ".png"))
    return out, "ok bg=%s -> %s" % (sample_bg_color(im.convert("RGB")), target)


if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        code = sys.argv[1]
        tol = int(sys.argv[2]) if len(sys.argv) > 2 else TOL
        out, msg = process(code, tol)
        print(code, msg)
        if out:
            out.save(os.path.join(OUT, "_preview_" + code + ".png"))
    else:
        for code in sorted(SPEC):
            out, msg = process(code)
            print(code, msg)
