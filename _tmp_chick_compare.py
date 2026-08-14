# -*- coding: utf-8 -*-
import re
import pathlib
import hashlib
from collections import defaultdict

ROOT = pathlib.Path(r"D:\Game projects\XiaoHuoRen_EggRescue")
MD = ROOT / r"MissingEggDoc-main\docs\characters\小鸡侦探团-对话脚本-树状.md"
MAIN = ROOT / r"Assets\Data\DialogueData\FROM_DOC\xiaojiZTT_01_FROM_DOC.lua"
E03 = ROOT / r"Assets\Data\DialogueData\FROM_DOC\xiaojiZTT_e03_FROM_DOC.lua"
MAIN_ED = ROOT / r"Assets\Editor\DialogueData\FROM_DOC\xiaojiZTT_01_FROM_DOC.lua"
E03_ED = ROOT / r"Assets\Editor\DialogueData\FROM_DOC\xiaojiZTT_e03_FROM_DOC.lua"
OUT = ROOT / "_tmp_chick_compare_out.txt"


def file_hash(p):
    data = pathlib.Path(p).read_bytes()
    return hashlib.md5(data).hexdigest(), len(data)


def parse_lua(path):
    text = pathlib.Path(path).read_text(encoding="utf-8")
    entries = {}
    for m in re.finditer(r"DialogueConfig\[(\d+)\]\s*=\s*\{(.*?)\n\}", text, re.S):
        idx = int(m.group(1))
        body = m.group(2)
        doctag = re.search(r'DocTag\s*=\s*"([^"]*)"', body)
        dialogue = re.search(r'Dialogue\s*=\s*"((?:\\.|[^"\\])*)"', body)
        speaker = re.search(r'SpeakerName\s*=\s*"((?:\\.|[^"\\])*)"', body)
        nextm = re.search(r"Next\s*=\s*(-?\d+)", body)
        setvars_m = re.search(r"SetVariables\s*=\s*\{([^}]*)\}", body, re.S)
        has_options = bool(re.search(r"\bOptions\s*=", body))

        def unesc(s):
            if s is None:
                return None
            return (
                s.replace("\\n", "\n")
                .replace('\\"', '"')
                .replace("\\\\", "\\")
            )

        entries[idx] = {
            "DocTag": doctag.group(1) if doctag else None,
            "Dialogue": unesc(dialogue.group(1)) if dialogue else None,
            "Speaker": unesc(speaker.group(1)) if speaker else None,
            "Next": int(nextm.group(1)) if nextm else None,
            "SetVariables": " ".join(setvars_m.group(1).split()) if setvars_m else None,
            "HasOptions": has_options,
        }
    return entries


def follow_chain(entries, start, stop_before=None, max_steps=300, include_options_stop=True):
    """Follow Next chain. stop_before: set of idxs to not enter.
    Stop when Next==-1 or missing or HasOptions (if include_options_stop).
    """
    chain = []
    i = start
    seen = set()
    while i is not None and i != -1 and i not in seen and len(chain) < max_steps:
        if stop_before and i in stop_before:
            break
        seen.add(i)
        e = entries.get(i)
        if not e:
            chain.append({"idx": i, "MISSING": True})
            break
        item = {"idx": i, **e}
        chain.append(item)
        if include_options_stop and e["HasOptions"]:
            break
        nxt = e["Next"]
        if nxt is None or nxt == -1:
            break
        i = nxt
    return chain


def parse_md_nodes(md_text):
    """Extract dialogue lines from ```text blocks keyed by first line node name."""
    nodes = {}
    # find fenced text blocks
    for m in re.finditer(r"```text\n(.*?)```", md_text, re.S):
        block = m.group(1)
        lines = block.splitlines()
        if not lines:
            continue
        name = lines[0].strip()
        dlg_lines = []
        carousel = []
        current_branch = None
        for line in lines[1:]:
            raw = line.rstrip()
            s = raw.strip()
            if not s or s in ("│", "├─", "└─") or s.startswith("→"):
                continue
            # carousel branch markers
            if s.startswith("├─ 【轮播】") or s.startswith("└─ 【轮播】") or s == "【轮播】":
                continue
            if s.startswith("└─ 【菜单】") or s.startswith("【菜单】") or "「" in s and "」" in s and "→" in s:
                # menu options - store separately
                if "menu" not in nodes.setdefault(name + "_meta", {}):
                    nodes.setdefault(name + "_meta", {})["menu"] = []
                if "「" in s:
                    nodes[name + "_meta"]["menu"].append(s)
                continue
            # strip tree prefixes
            content = re.sub(r"^[│├└─\s]+", "", raw).strip()
            if not content:
                continue
            # revisit sections under hub
            if content.startswith("【回访】"):
                current_branch = content
                if name not in nodes:
                    nodes[name] = []
                # store as marker
                dlg_lines.append(("REVISIT_HEADER", content))
                continue
            if content.startswith("└─ 【菜单】") or content.startswith("├─ 【菜单】"):
                continue
            # carousel variants start with ├─ or └─ after 【轮播】
            # lines like "├─ 豆豆·心虚：..."
            if re.match(r"^[├└]─\s+\S", content) and "【" not in content[:6]:
                # start new carousel variant
                content2 = re.sub(r"^[├└]─\s+", "", content)
                if current_branch is None and ("轮播" in block or name in ("3-A", "NGPlus 回访", "NGPlus")):
                    if carousel and carousel[-1]:
                        pass
                    carousel.append([])
                    current_branch = f"variant{len(carousel)}"
                    if content2:
                        carousel[-1].append(content2)
                    continue
            # continuation under carousel with │
            if carousel and re.match(r"^│", raw.strip() if False else "x"):
                pass
            # Normal line: Speaker：text or 描述：
            if "：" in content or ":" in content:
                # clean leading tree chars again
                content = re.sub(r"^[│\s]+", "", content)
                content = re.sub(r"^[├└]─\s+", "", content)
                if content.startswith("「") and "→" in content:
                    nodes.setdefault(name + "_meta", {}).setdefault("menu", []).append(content)
                    continue
                if content.startswith("【"):
                    continue
                dlg_lines.append(content)
                if carousel:
                    # if we're in carousel mode parsing differently
                    pass
            elif content.startswith("「"):
                nodes.setdefault(name + "_meta", {}).setdefault("menu", []).append(content)

        # Better carousel parse for 3-A and NGPlus revisit
        if "【轮播】" in block:
            variants = []
            cur = None
            for line in lines[1:]:
                raw = line.rstrip()
                s = raw.strip()
                if not s or s in ("│",) or s.startswith("→"):
                    continue
                # variant start: ├─ SPEAKER or └─ SPEAKER or ├─ 描述
                mvar = re.match(r"^[├└]─\s+(.+)$", s)
                if mvar and not mvar.group(1).startswith("【"):
                    cur = [mvar.group(1).strip()]
                    variants.append(cur)
                    continue
                # continuation │  SPEAKER
                mcont = re.match(r"^│\s+(.+)$", s)
                if mcont and cur is not None:
                    c = mcont.group(1).strip()
                    if c and not c.startswith("【"):
                        cur.append(c)
                    continue
            nodes[name] = {"carousel": variants}
        elif name.startswith("2-hub"):
            revisits = {}
            cur_key = None
            menu = []
            for line in lines[1:]:
                s = line.strip()
                if not s or s == "│":
                    continue
                mh = re.match(r"^[├└]─\s+(【回访】.+)$", s)
                if mh:
                    cur_key = mh.group(1)
                    revisits[cur_key] = []
                    continue
                if "【菜单】" in s:
                    cur_key = "MENU"
                    continue
                if cur_key == "MENU":
                    if "「" in s:
                        menu.append(re.sub(r"^[│\s]+", "", s))
                    continue
                if cur_key and cur_key != "MENU":
                    content = re.sub(r"^[│\s]+", "", s)
                    if content and "：" in content:
                        revisits[cur_key].append(content)
            nodes[name] = {"revisits": revisits, "menu": menu}
        else:
            # flat dialogue: take speaker lines only
            flat = []
            for line in lines[1:]:
                s = line.strip()
                if not s or s in ("│", "├─", "└─") or s.startswith("→") or s.startswith("【"):
                    continue
                content = re.sub(r"^[│├└─\s]+", "", s).strip()
                if not content or content.startswith("【") or content.startswith("「"):
                    continue
                if "：" in content or content.startswith("描述"):
                    flat.append(content)
            nodes[name] = flat
    return nodes


def norm_line(s):
    """Normalize md 'Speaker·emo：text' vs lua Dialogue-only for comparison helpers."""
    if s is None:
        return ""
    # If contains Chinese colon, take after last speaker prefix
    if "：" in s:
        # speaker part before first ：
        sp, rest = s.split("：", 1)
        return rest.strip()
    if ":" in s:
        sp, rest = s.split(":", 1)
        return rest.strip()
    return s.strip()


def md_speaker_text(s):
    if "：" in s:
        return s.split("：", 1)
    if ":" in s:
        return s.split(":", 1)
    return ("", s)


def compare_chain(label, lua_chain, md_lines, w):
    w.write(f"\n{'='*80}\n")
    w.write(f"NODE: {label}\n")
    w.write(f"{'='*80}\n")
    w.write(f"\n--- LUA ({len(lua_chain)} steps) ---\n")
    for e in lua_chain:
        if e.get("MISSING"):
            w.write(f"  [{e['idx']}] MISSING\n")
            continue
        dial = (e["Dialogue"] or "").replace("\n", "\\n")
        sv = e["SetVariables"] or ""
        opts = " [OPTIONS]" if e["HasOptions"] else ""
        w.write(
            f"  [{e['idx']}] DocTag={e['DocTag']} Speaker={e['Speaker']!r}\n"
            f"         Dialogue={dial!r}\n"
            f"         Next={e['Next']} SetVariables={{{sv}}}{opts}\n"
        )
    w.write(f"\n--- MD TREE ({len(md_lines)} lines) ---\n")
    for i, line in enumerate(md_lines, 1):
        w.write(f"  {i}. {line}\n")

    # Compare by dialogue text (after colon)
    lua_texts = [norm_line(e.get("Dialogue") or "") for e in lua_chain if not e.get("MISSING") and not e.get("HasOptions")]
    # For lua, Dialogue field IS the text (no speaker prefix usually)
    lua_texts = [(e.get("Dialogue") or "").replace("\n", " ") for e in lua_chain if not e.get("MISSING") and e.get("Dialogue") is not None and not e.get("HasOptions")]
    md_texts = [norm_line(x) for x in md_lines]

    w.write(f"\n--- COUNT: lua_dialogue={len(lua_texts)} md={len(md_texts)} ")
    if len(lua_texts) == len(md_texts):
        w.write("MATCH\n")
    else:
        w.write(f"MISMATCH (delta={len(md_texts)-len(lua_texts):+d})\n")

    # line-by-line text compare
    n = max(len(lua_texts), len(md_texts))
    mismatches = []
    for i in range(n):
        lt = lua_texts[i] if i < len(lua_texts) else None
        mt = md_texts[i] if i < len(md_texts) else None
        # normalize whitespace
        def clean(t):
            if t is None:
                return None
            return re.sub(r"\s+", " ", t).strip()

        lt, mt = clean(lt), clean(mt)
        status = "OK" if lt == mt else "DIFF"
        if lt != mt:
            mismatches.append(i)
            w.write(f"  line {i+1}: {status}\n")
            w.write(f"    LUA: {lt!r}\n")
            w.write(f"    MD:  {mt!r}\n")
            # classify
            if lt is None:
                w.write(f"    ACTION: INSERT in lua at this position (or after idx check)\n")
            elif mt is None:
                w.write(f"    ACTION: DELETE lua line / remove from Next chain\n")
            else:
                w.write(f"    ACTION: REWRITE Dialogue at lua index (see chain[{i}])\n")
                if i < len(lua_chain):
                    w.write(f"             -> DialogueConfig[{lua_chain[i]['idx']}] DocTag={lua_chain[i].get('DocTag')}\n")

    if not mismatches:
        w.write("  All dialogue texts match (normalized).\n")
    else:
        w.write(f"\n  Mismatched indices (0-based): {mismatches}\n")
        w.write(f"  Lua idx needing attention: ")
        idxs = []
        for i in mismatches:
            if i < len(lua_chain) and not lua_chain[i].get("MISSING"):
                idxs.append(lua_chain[i]["idx"])
        w.write(str(idxs) + "\n")

    # final node SetVariables / Next
    if lua_chain:
        last = lua_chain[-1]
        # find last non-options with setvars, or true last content node
        content = [e for e in lua_chain if not e.get("HasOptions") and not e.get("MISSING")]
        if content:
            fin = content[-1]
            w.write(f"\n--- FINAL CONTENT NODE ---\n")
            w.write(f"  idx={fin['idx']} DocTag={fin['DocTag']} Next={fin['Next']} SetVariables={{{fin['SetVariables'] or ''}}}\n")
            # if next continues to hub without being in chain
            if fin["Next"] not in (None, -1) and (not stop_check(fin["Next"], lua_chain)):
                w.write(f"  Next target {fin['Next']} not in this chain (likely hub/entry) — PRESERVE\n")
    return mismatches


def stop_check(nxt, chain):
    return any(e["idx"] == nxt for e in chain)


def main():
    lines_out = []
    def wwrite(s=""):
        lines_out.append(s)

    # hashes
    for a, b, name in [(MAIN, MAIN_ED, "01"), (E03, E03_ED, "e03")]:
        ha, la = file_hash(a)
        hb, lb = file_hash(b)
        wwrite(f"Editor copy {name}: Data==Editor={ha==hb} Data({la}) Editor({lb})")

    main = parse_lua(MAIN)
    e03 = parse_lua(E03)
    md_text = MD.read_text(encoding="utf-8")
    nodes = parse_md_nodes(md_text)

    wwrite(f"\nParsed MD node keys: {sorted(nodes.keys())}")
    wwrite(f"Main lua entries: {len(main)} max={max(main)}")
    wwrite(f"E03 lua entries: {len(e03)} max={max(e03)}")

    # Dump all DocTags for main by prefix
    by = defaultdict(list)
    for idx, e in sorted(main.items()):
        tag = e["DocTag"] or f"noidx{idx}"
        pref = tag.split("#")[0]
        by[pref].append((idx, tag, e["Dialogue"], e["Next"], e["SetVariables"], e["HasOptions"], e["Speaker"]))

    wwrite("\n=== RAW LUA BY DOCTAG PREFIX ===")
    for pref in sorted(by, key=lambda p: by[p][0][0]):
        wwrite(f"\n## {pref} ({len(by[pref])} entries)")
        for idx, tag, dial, nxt, sv, opts, sp in by[pref]:
            d = (dial or "").replace("\n", "\\n")
            flag = " OPTIONS" if opts else ""
            svs = f" SetVars={{{sv}}}" if sv else ""
            wwrite(f"  [{idx}] {tag} sp={sp!r} Next={nxt}{svs}{flag}")
            wwrite(f"       {d!r}")

    # E03
    wwrite("\n=== E03 RAW ===")
    for idx in sorted(e03):
        e = e03[idx]
        d = (e["Dialogue"] or "").replace("\n", "\\n")
        sv = f" SetVars={{{e['SetVariables']}}}" if e["SetVariables"] else ""
        wwrite(f"  [{idx}] {e['DocTag']} sp={e['Speaker']!r} Next={e['Next']}{sv}")
        wwrite(f"       {d!r}")

    # Known starts from header comments
    starts = {
        "1-A": (e03, 1, None),
        "2-A": (main, 1, {23}),  # stop before hub
        "2-G": (main, 200, {23, 177, 173, 174, 175}),
        "2-B": (main, 24, {23, 177, 173}),
        "2-C": (main, 45, {23, 177}),
        "2-D": (main, 51, {23, 177}),
        "2-F": (main, 60, {23, 177}),
        "2-E": (main, 74, {23, 177}),
        "NGPlus": (main, 131, None),
        "NGPlus-revisit": (main, 172, None),
    }

    # 3-A variants: 130 might be router; also 184/185/186
    # Hub revisits: need to find

    with OUT.open("w", encoding="utf-8") as w:
        for line in lines_out:
            w.write(line + "\n")

        # Compare each flat node
        md_flat_keys = {
            "1-A": "1-A",
            "2-A": "2-A",
            "2-G": "2-G",
            "2-B": "2-B",
            "2-C": "2-C",
            "2-D": "2-D",
            "2-F": "2-F",
            "2-E": "2-E",
            "NGPlus": "NGPlus",
        }

        for label, (ents, start, stop) in starts.items():
            if label == "NGPlus-revisit":
                continue
            md_key = md_flat_keys.get(label, label)
            md_data = nodes.get(md_key)
            if isinstance(md_data, dict):
                md_lines = []
            else:
                md_lines = md_data or []
            chain = follow_chain(ents, start, stop_before=stop)
            # trim trailing if Next goes to hub - already stopped
            compare_chain(label, chain, md_lines, w)

        # Hub revisits
        w.write(f"\n{'='*80}\nNODE: 2-hub revisits\n{'='*80}\n")
        md_hub = nodes.get("2-hub", {})
        if isinstance(md_hub, dict):
            w.write("\n--- MD ---\n")
            for k, v in md_hub.get("revisits", {}).items():
                w.write(f"  {k}:\n")
                for line in v:
                    w.write(f"    - {line}\n")
            w.write("  MENU:\n")
            for m in md_hub.get("menu", []):
                w.write(f"    - {m}\n")

        # Find hub-related by DocTag
        hub_tags = [x for x in by if "hub" in x.lower() or x.startswith("2-hub")]
        # Also check idx 23 and nearby
        for idx in [23, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183]:
            if idx in main:
                e = main[idx]
                w.write(f"\n  LUA[{idx}] DocTag={e['DocTag']} Speaker={e['Speaker']!r} Next={e['Next']} SetVars={{{e['SetVariables'] or ''}}} opts={e['HasOptions']}\n")
                w.write(f"    Dialogue={e['Dialogue']!r}\n")

        # Follow from 23 briefly
        w.write("\n--- Chain from 23 (hub entry) first 15 ---\n")
        chain = follow_chain(main, 23, include_options_stop=False, max_steps=15)
        for e in chain:
            w.write(f"  [{e['idx']}] {e.get('DocTag')} Next={e.get('Next')} opts={e.get('HasOptions')} Dial={e.get('Dialogue')!r} SV={{{e.get('SetVariables') or ''}}}\n")

        # 3-A carousel
        w.write(f"\n{'='*80}\nNODE: 3-A\n{'='*80}\n")
        md_3a = nodes.get("3-A", {})
        if isinstance(md_3a, dict) and "carousel" in md_3a:
            for vi, var in enumerate(md_3a["carousel"]):
                w.write(f"\n--- MD variant {vi+1} ({len(var)} lines) ---\n")
                for j, line in enumerate(var, 1):
                    w.write(f"  {j}. {line}\n")

        # Find 3-A lua chains
        for tag, start_idx in [("3-A#?", 130), ("entry#3a1", 184), ("entry#3a2", 185), ("entry#3a0", 186)]:
            if start_idx in main:
                w.write(f"\n--- LUA start {start_idx} DocTag={main[start_idx]['DocTag']} ---\n")
                chain = follow_chain(main, start_idx, max_steps=40)
                compare_chain(f"3-A@{start_idx}", chain, [], w)

        # Also dump all DocTags starting with 3-A
        w.write("\n--- All 3-A* DocTags ---\n")
        for idx, tag, dial, nxt, sv, opts, sp in by.get("3-A", []) + [x for p, lst in by.items() if p.startswith("3") for x in lst]:
            pass
        for pref, lst in by.items():
            if "3-A" in pref or pref.startswith("3"):
                for idx, tag, dial, nxt, sv, opts, sp in lst:
                    w.write(f"  [{idx}] {tag} Next={nxt} SV={{{sv or ''}}} {dial!r}\n")

        # NGPlus revisit
        w.write(f"\n{'='*80}\nNODE: NGPlus revisit\n{'='*80}\n")
        md_ngr = nodes.get("NGPlus 回访", {})
        if isinstance(md_ngr, dict) and "carousel" in md_ngr:
            for vi, var in enumerate(md_ngr["carousel"]):
                w.write(f"\n--- MD variant {vi+1} ({len(var)} lines) ---\n")
                for j, line in enumerate(var, 1):
                    w.write(f"  {j}. {line}\n")

        # Find NGPlus revisit entries
        for pref, lst in by.items():
            if "NG" in pref or "ng" in pref.lower() or "轮播" in pref:
                w.write(f"\nprefix {pref}:\n")
                for item in lst:
                    idx, tag, dial, nxt, sv, opts, sp = item
                    w.write(f"  [{idx}] {tag} Next={nxt} SV={{{sv or ''}}} opts={opts} {dial!r}\n")

        chain = follow_chain(main, 172, max_steps=50, include_options_stop=False)
        w.write("\n--- Chain from 172 ---\n")
        for e in chain:
            w.write(f"  [{e['idx']}] {e.get('DocTag')} Next={e.get('Next')} opts={e.get('HasOptions')} Dial={e.get('Dialogue')!r} SV={{{e.get('SetVariables') or ''}}}\n")

        # Also check entry 188/189
        for start_idx in [131, 172, 188, 189]:
            if start_idx in main:
                chain = follow_chain(main, start_idx, max_steps=40)
                md_lines = nodes.get("NGPlus", []) if start_idx in (131, 188) else []
                if start_idx == 131:
                    compare_chain("NGPlus@131", chain, md_lines if isinstance(md_lines, list) else [], w)

    print(f"Wrote {OUT}")
    print(f"MD keys: {list(nodes.keys())}")


if __name__ == "__main__":
    main()
