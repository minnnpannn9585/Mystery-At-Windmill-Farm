# -*- coding: utf-8 -*-
"""
用本地 Photoshop 2022 (COM) 对浅色主体概念图做「米底键控 -> 透明 PNG」。

对 flood fill 误伤的浅色主体图（提示按钮 / 虚线框 / 翻转箭头 / 飞行纸片），
用 PS 的「魔棒点四角选背景 -> 清除」保留浅色主体。

单次进程内完成：启动 PS -> 逐张 open -> 转普通图层 -> 魔棒选米底 -> 清除 -> 存透明 PNG -> 关闭 -> 退出。
"""
import os
import sys
import comtypes.client

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "_raw")

CODES = sys.argv[1:] if len(sys.argv) > 1 else ["RG20B", "RT2C", "RT3C", "RF01"]

# 魔棒在四角点选米底 -> 加选 -> 羽化 -> 清除。
# 用 ActionDescriptor 兼容 PS2022 的 charID。
JS = r"""
var doc = app.activeDocument;
var w = doc.width.as('px'), h = doc.height.as('px');
// 背景层转普通层，才能清除成透明
var layer = doc.activeLayer;
if (layer.isBackgroundLayer) { layer.isBackgroundLayer = false; }
// 透明像素锁定要关闭
try { layer.lockTransparency = false; } catch(e) {}

var tol = 32;
function magicWandAt(x, y, add) {
    var d = new ActionDescriptor();
    var ref = new ActionReference();
    ref.putProperty(charIDToTypeID('Prpr'), charIDToTypeID('Slct'));
    ref.putEnumerated(charIDToTypeID('Dcmn'), charIDToTypeID('Ordn'), charIDToTypeID('Trgt'));
    d.putReference(charIDToTypeID('null'), ref);
    var pt = new ActionDescriptor();
    pt.putDouble(charIDToTypeID('Hrzn'), x);
    pt.putDouble(charIDToTypeID('Vrtc'), y);
    d.putObject(charIDToTypeID('Nw  '), charIDToTypeID('Pnt '), pt);
    d.putInteger(charIDToTypeID('Tlrn'), tol);
    d.putBoolean(charIDToTypeID('AntA'), true);
    d.putBoolean(charIDToTypeID('Cnsg'), false);  // 不连续：选中全图同色米底
    executeAction(charIDToTypeID('MbS '), d, DialogModes.NO);
    if (add) {
        // 后续点用加选：先按 Shift 效果 —— 通过 selection 的 Action 追加较繁，
        // 这里改为只点一次 + 不连续（Cnsg=false 已选全图同色），够用。
    }
}
// 点左上角米底
magicWandAt(8, 8, false);
// 羽化 0.8px
doc.selection.feather(0.8);
// 清除为透明
doc.selection.clear();
doc.selection.deselect();
"""

def main():
    app = comtypes.client.CreateObject("Photoshop.Application")
    app.Visible = False
    app.DisplayAlerts = 2
    try:
        for code in CODES:
            src = os.path.join(RAW, code + ".png")
            if not os.path.exists(src):
                print(code, "MISSING")
                continue
            doc = app.open(src)
            app.doJavaScript(JS)
            out = os.path.join(HERE, code + "_ps.png")
            png_opts = comtypes.client.CreateObject("Photoshop.PNGSaveOptions")
            png_opts.transparency = True
            doc.saveAs(out, png_opts, True)
            doc.close(2)
            print(code, "PS done ->", out)
    finally:
        app.Quit()

if __name__ == "__main__":
    main()
