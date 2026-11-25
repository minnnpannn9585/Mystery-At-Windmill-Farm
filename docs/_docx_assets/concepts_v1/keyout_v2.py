# -*- coding: utf-8 -*-
"""
浅色 / 深色主体图专用抠图（替代 flood fill 对这 4 张的误抠）。

分两类策略：
  dark    —— 深蓝图标配米底（RG20B 灯泡 / RT3C 箭头）：
              用「与四角米底色的最大通道差」做前景概率，阈值化后取最大连通域，
              顺带滤掉右下角 AI 生成水印。
  grabcut —— 浅米色主体配米底（RT2C 虚线框 / RF01 折角纸）：
              OpenCV GrabCut 矩形初始化，学习前景/背景颜色模型，
              保留与背景同色系但纹理/阴影可分的主体。

统一后处理：形态学去噪 -> 羽化 -> alpha bbox 裁切 -> 2px 透明边 -> 等比 fit 到 SPEC。
输出写回 concepts_v1/<code>.png（docx 通过 cv1() 读这里）。
"""
import os
import cv2
import numpy as np
from PIL import Image, ImageFilter

from process_concepts import HERE, RAW, SPEC, trim_and_pad, fit_to

# mode / 参数
RECIPE = {
    "RG20B": dict(mode="dark", lo=55, hi=105, multi=True),
    "RT3C":  dict(mode="dark", lo=55, hi=105, multi=True),
    # 虚线框是「比米底更亮」的浅米色线，用局部对比度提取亮笔画
    "RT2C":  dict(mode="lightstroke", sigma=45, boost=5.0, cutoff=7.0),
    "RF01":  dict(mode="grabcut", rect=(0.24, 0.18, 0.50, 0.60), iters=6, sat_floor=52),
}


def read_rgb(path):
    # 用 PIL 读，规避 cv2.imread 对中文路径的兼容问题
    return np.array(Image.open(path).convert("RGB"))


def corner_bg(rgb):
    h, w = rgb.shape[:2]
    pts = [rgb[2, 2], rgb[2, w - 3], rgb[h - 3, 2], rgb[h - 3, w - 3]]
    return np.median(np.stack(pts), axis=0).astype(np.int16)


def largest_component(mask):
    n, labels, stats, _ = cv2.connectedComponentsWithStats(mask.astype(np.uint8), 8)
    if n <= 1:
        return mask
    # 跳过 label 0（背景），取面积最大的前景
    idx = 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])
    return (labels == idx)


def keep_components(mask, min_area, max_keep=None):
    """保留面积 >= min_area 的连通域（可限数量），用于保住图标的分离笔画/光芒。"""
    n, labels, stats, _ = cv2.connectedComponentsWithStats(mask.astype(np.uint8), 8)
    out = np.zeros_like(mask, dtype=np.uint8)
    if n <= 1:
        return out
    comps = [(i, stats[i, cv2.CC_STAT_AREA]) for i in range(1, n)
             if stats[i, cv2.CC_STAT_AREA] >= min_area]
    comps.sort(key=lambda t: -t[1])
    if max_keep:
        comps = comps[:max_keep]
    for i, _ in comps:
        out[labels == i] = 1
    return out


def matte_from_dark(rgb, lo, hi, multi=False):
    h, w = rgb.shape[:2]
    img = rgb.astype(np.int16)
    bg = corner_bg(img)
    dist = np.max(np.abs(img - bg), axis=2).astype(np.float32)
    a = np.clip((dist - lo) / float(hi - lo) * 255.0, 0, 255).astype(np.uint8)
    bw = (a > 90).astype(np.uint8)
    if multi:
        # 图标有分离的笔画（灯泡光芒、箭头），全保留；排除右下角水印区
        keep = keep_components(bw, min_area=24)
        keep[int(h * 0.86):, int(w * 0.72):] = 0
    else:
        keep = largest_component(bw)
    a = (a * keep).astype(np.uint8)
    return a


def matte_from_lightstroke(rgb, sigma, boost, cutoff):
    """提取「比局部背景更亮」的笔画（RT2C 米底上的浅色虚线框）。"""
    gray = cv2.cvtColor(rgb, cv2.COLOR_RGB2GRAY).astype(np.float32)
    base = cv2.GaussianBlur(gray, (0, 0), sigma)
    diff = gray - base                      # 亮笔画 > 0
    hi = cv2.GaussianBlur(diff, (0, 0), 2)
    resp = np.clip((hi - cutoff) / boost * 255.0, 0, 255).astype(np.uint8)
    bw = (resp > 55).astype(np.uint8)
    # 右下角 AI 生成水印是白色小字，会被当亮笔画 -> 直接清掉
    h, w = rgb.shape[:2]
    bw[int(h * 0.84):, int(w * 0.78):] = 0
    # 虚线是细线但成框，取面积合格的所有连通域（多个框）
    keep = keep_components(bw, min_area=40)
    return (resp * keep).astype(np.uint8)


def matte_from_grabcut(rgb, rect, iters, sat_floor=None):
    h, w = rgb.shape[:2]
    x0 = int(rect[0] * w); y0 = int(rect[1] * h)
    rw = int(rect[2] * w); rh = int(rect[3] * h)
    mask = np.zeros((h, w), np.uint8)
    bgd = np.zeros((1, 65), np.float64)
    fgd = np.zeros((1, 65), np.float64)
    cv2.grabCut(cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR), mask,
                (x0, y0, rw, rh), bgd, fgd, iters, cv2.GC_INIT_WITH_RECT)
    fg = ((mask == cv2.GC_FGD) | (mask == cv2.GC_PR_FGD)).astype(np.uint8)
    fg = largest_component(fg).astype(np.uint8)
    if sat_floor is not None:
        # 折角纸比米底饱和度高：滤掉 GrabCut 误吃进来的低饱和米底
        sat = rgb.max(axis=2).astype(np.int16) - rgb.min(axis=2).astype(np.int16)
        fg[sat < sat_floor] = 0
    return fg * 255


def finalize(rgb, alpha, code):
    alpha_img = Image.fromarray(alpha, "L").filter(ImageFilter.GaussianBlur(0.6))
    rgba = Image.fromarray(rgb, "RGB").convert("RGBA")
    rgba.putalpha(alpha_img)
    rgba = trim_and_pad(rgba)
    out = fit_to(rgba, SPEC[code])
    out.save(os.path.join(HERE, code + ".png"))
    return out


def main():
    codes = __import__("sys").argv[1:] or list(RECIPE)
    for code in codes:
        r = RECIPE[code]
        rgb = read_rgb(os.path.join(RAW, code + ".png"))
        if r["mode"] == "dark":
            a = matte_from_dark(rgb, r["lo"], r["hi"], r.get("multi", False))
        elif r["mode"] == "lightstroke":
            a = matte_from_lightstroke(rgb, r["sigma"], r["boost"], r["cutoff"])
        else:
            a = matte_from_grabcut(rgb, r["rect"], r["iters"], r.get("sat_floor"))
        out = finalize(rgb, a, code)
        occ = float(np.count_nonzero(a > 8)) / a.size
        print("%-6s %-8s alpha>8 占比 %.1f%% -> %s" % (
            code, r["mode"], occ * 100, SPEC[code]))


if __name__ == "__main__":
    main()
