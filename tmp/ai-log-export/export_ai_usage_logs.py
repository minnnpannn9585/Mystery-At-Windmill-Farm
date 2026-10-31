"""Export project-scoped, user-visible AI history. Never export private reasoning."""
import collections
import gc
import datetime as dt
import hashlib
import html
import json
import pathlib
import re
import shutil
import sqlite3
import sys
import tempfile
import zipfile

sys.stdout.reconfigure(encoding="utf-8")
ROOT = pathlib.Path(__file__).resolve().parents[2]
HOME = pathlib.Path.home()
CODEX = HOME / ".codex"
CURSOR = HOME / ".cursor/projects/c-Users-minpa-Documents-GitHub-Mystery-At-Windmill-Farm/agent-transcripts"
OUT = ROOT / "output/AI工具使用日志_风车农场悬案_20261031"
CURRENT = "01a1915c-25f0-7fc2-a6db-f6a110240b4a"
TZ = dt.timezone(dt.timedelta(hours=8))
STAMP = dt.datetime.now(TZ).isoformat(timespec="seconds")
stats = collections.Counter()
sessions = []
supplements = []


def sha(data):
    return hashlib.sha256(data).hexdigest()


def norm(path):
    return str(path).removeprefix("\\\\?\\").replace("\\", "/").rstrip("/").lower()


def date(value, ms=False):
    return dt.datetime.fromtimestamp(value / (1000 if ms else 1), TZ).isoformat(timespec="seconds") if value else None


def scrub(value):
    if isinstance(value, str):
        # Replace local profile name while retaining useful project-relative paths.
        value, n = re.subn(r"(?i)C:[\\/]+Users[\\/]+minpa(?=[\\/])", "<USER_PROFILE>", value)
        stats["profile_path_replacements"] += n
        value, n = re.subn(r"data:(?:image|audio|video)/[^;\s]+;base64,[A-Za-z0-9+/=]+", "[媒体二进制省略；参见原记录路径]", value)
        stats["binary_payloads_omitted"] += n
        for pattern in [r"\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{20,}", r"\bgh[pousr]_[A-Za-z0-9]{30,}", r"\bgithub_pat_[A-Za-z0-9_]{30,}", r"(?i)Bearer\s+[A-Za-z0-9._-]{24,}"]:
            value, n = re.subn(pattern, "[凭据已脱敏]", value)
            stats["credential_replacements"] += n
        return value
    if isinstance(value, list):
        return [scrub(v) for v in value]
    if isinstance(value, dict):
        result = {}
        for key, val in value.items():
            if key.lower() in {"thinking", "reasoning", "reasoning_content", "encrypted_content", "system_prompt", "developer_prompt"}:
                continue
            if key.lower() in {"access_token", "refresh_token", "id_token", "api_key", "apikey", "authorization", "creator_user_id", "creator_account_id"}:
                result[key] = "[已脱敏]"
                stats["private_fields_redacted"] += 1
            elif key in {"data", "b64_json", "blob"} and isinstance(val, str) and len(val) > 1000:
                result[key] = "[二进制省略]"
                stats["binary_payloads_omitted"] += 1
            elif value.get("type") in {"image", "input_image", "image_url", "audio", "video"}:
                result = {"type": value["type"], "note": "媒体内容未嵌入日志；可在原会话中查看"}
                break
            else:
                result[key] = scrub(val)
        return result
    return value


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8-sig" if path.suffix == ".txt" else "utf-8")


def json_text(obj):
    return json.dumps(obj, ensure_ascii=False, indent=2)


def event_text(event):
    role = event.get("role")
    if role:
        parts = []
        for content in event.get("content", []):
            if content.get("type") == "text":
                parts.append(content.get("text", ""))
            else:
                parts.append("[工具/附件记录]\n" + json_text(content))
        return "\n\n".join(parts)
    item = event.get("item", {})
    kind = item.get("type")
    if kind == "agentMessage":
        return item.get("text", "")
    if kind == "userMessage":
        return "\n".join(c.get("text", json_text(c)) for c in item.get("content", []))
    return json_text(item or event)


def save_session(meta, events):
    folder = "02_辅助任务" if meta["is_subagent"] else "01_主会话"
    name = meta["source_tool"] + "_" + meta["id"]
    dest = OUT / folder / name
    meta["event_count"] = len(events)
    meta["user_message_count"] = sum(e.get("role") == "user" or e.get("item", {}).get("type") == "userMessage" for e in events)
    meta["text_file"] = dest.with_suffix(".txt").relative_to(OUT).as_posix()
    meta["jsonl_file"] = dest.with_suffix(".jsonl").relative_to(OUT).as_posix()
    write(dest.with_suffix(".jsonl"), "\n".join(json.dumps(e, ensure_ascii=False) for e in events) + "\n")
    parts = ["AI 工具使用日志 / 风车农场悬案", meta["title"], json_text(meta), "", "以下为历史记录导出。原回复中的完成/测试结论仅代表当时记录，不代表本次重新验证。", ""]
    for i, event in enumerate(events, 1):
        role = event.get("role") or event.get("item", {}).get("type") or event.get("type")
        timestamp = event.get("timestamp") or event.get("timestamp_text") or "原记录未提供逐条时间"
        parts.extend([f"{'=' * 68}\n记录 {i} | {role} | {timestamp}", event_text(event), ""])
    write(dest.with_suffix(".txt"), "\n".join(parts))
    sessions.append(meta)


def snapshot(source, temp):
    target = temp / source.name
    shutil.copy2(source, target)
    wal = pathlib.Path(str(source) + "-wal")
    if wal.exists():
        shutil.copy2(wal, pathlib.Path(str(target) + "-wal"))
    conn = sqlite3.connect(target.as_uri() + "?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    if conn.execute("PRAGMA quick_check").fetchone()[0] != "ok":
        raise RuntimeError("Database snapshot failed integrity check")
    return conn


def export_cursor(headers):
    for path in sorted(CURSOR.rglob("*.jsonl")):
        raw = path.read_bytes()
        header = headers.get(path.stem, {})
        events = []
        for line_no, line in enumerate(raw.decode("utf-8").splitlines(), 1):
            original = json.loads(line)
            role = original.get("role")
            if role in {"user", "assistant", "tool"}:
                content = [c for c in original.get("message", {}).get("content", []) if c.get("type") in {"text", "tool_use", "tool_result", "image"}]
                if not content:
                    continue
                all_text = "\n".join(c.get("text", "") for c in content)
                timestamp = re.search(r"<timestamp>(.*?)</timestamp>", all_text, re.S)
                event = {"source_line": line_no, "source_record_sha256": sha(line.encode()), "role": role, "timestamp_text": timestamp.group(1) if timestamp else None, "content": content}
            elif original.get("type") == "turn_ended":
                event = {"source_line": line_no, **original}
            else:
                stats["cursor_nonpublic_records_excluded"] += 1
                continue
            events.append(scrub(event))
        metadata = json.loads(header.get("value") or "{}")
        first_user = next((event_text(e) for e in events if e.get("role") == "user"), "未命名会话")
        title = metadata.get("name") or re.sub(r"<[^>]+>", "", first_user).strip().splitlines()[-1][:120]
        meta = {"id": path.stem, "title": scrub(title), "source_tool": "Cursor", "model": "原始导出未标注模型", "is_subagent": "subagents" in path.parts, "parent_id": path.parent.parent.name if "subagents" in path.parts else None, "created_at": date(header.get("createdAt"), True), "updated_at": date(header.get("lastUpdatedAt"), True), "source_path": scrub(str(path)), "source_sha256": sha(raw), "time_basis": "会话日期来自 Cursor 元数据；逐轮时间保留用户消息中的原始 timestamp；无时间的消息不推测时间。"}
        save_session(meta, events)
    # Compaction repeats prompts and replies but contains otherwise missing tool outputs.
    for path in CURSOR.rglob("segment_*.md"):
        raw = path.read_bytes()
        text = raw.decode("utf-8")
        matches = list(re.finditer(r"^### Turn (\d+) \(([^)]+)\)\s*$", text, re.M))
        parts = ["历史工具结果补充（与主会话有重叠，不另计会话）", "已排除 System 与环境上下文。按原始 Turn 编号保留工具请求、工具返回及可见对话。\n"]
        counts = collections.Counter()
        for i, match in enumerate(matches):
            role = match.group(2)
            body = text[match.end():matches[i + 1].start() if i + 1 < len(matches) else len(text)].strip()
            if role not in {"Assistant", "Function", "Human"} or role == "Human" and "<user_query>" not in body:
                continue
            counts[role] += 1
            parts.append(match.group(0) + "\n\n" + scrub(body))
        dest = OUT / "03_工具结果补充" / (path.parent.parent.name + "_" + path.name.replace(".md", ".txt"))
        write(dest, "\n\n".join(parts))
        supplements.append({"file": dest.relative_to(OUT).as_posix(), "source": scrub(str(path)), "source_sha256": sha(raw), "retained_types": dict(counts)})


CODEX_FIELDS = {
    "userMessage": ["type", "id", "content"],
    "agentMessage": ["type", "id", "text", "phase", "questions"],
    "commandExecution": ["type", "id", "command", "cwd", "status", "aggregatedOutput", "exitCode", "durationMs"],
    "mcpToolCall": ["type", "id", "server", "tool", "status", "arguments", "result", "error", "durationMs"],
    "fileChange": ["type", "id", "changes", "status"],
    "imageGeneration": ["type", "id", "status", "revisedPrompt", "transparentBackground", "failure", "savedPath"],
    "imageView": ["type", "id", "path"],
    "webSearch": ["type", "id", "query", "action", "status"],
    "subAgentActivity": ["type", "id", "kind", "agentThreadId", "agentPath"],
}


def export_codex(state, history, imported):
    rows = [dict(r) for r in state.execute("SELECT * FROM threads WHERE cwd LIKE '%Mystery-At-Windmill-Farm%'") if norm(r["cwd"]) == norm(ROOT)]
    excluded = {CURRENT}
    while True:
        before = len(excluded)
        for row in rows:
            try:
                source = json.loads(row["source"])
                parent = source.get("subagent", {}).get("thread_spawn", {}).get("parent_thread_id")
                if parent in excluded:
                    excluded.add(row["id"])
            except (ValueError, AttributeError):
                pass
        if len(excluded) == before:
            break
    for row in rows:
        if row["id"] in excluded or row["thread_source"] == "guardian_review" or "guardian" in row["source"]:
            continue
        query = "SELECT * FROM thread_items WHERE thread_id=? ORDER BY rollout_ordinal,created_at_ms"
        records = list(history.execute(query, (row["id"],)))
        if row["id"] in imported:
            # Imported messages item-N are identical copies of Cursor public history.
            records = [r for r in records if not r["item_id"].startswith("item-")]
            stats["deduplicated_imported_threads"] += 1
            if not records:
                continue
        events = []
        models = set()
        rollout = pathlib.Path(row["rollout_path"])
        if rollout.exists():
            for line in rollout.open(encoding="utf-8"):
                d = json.loads(line)
                if d.get("type") == "turn_context" and d.get("payload", {}).get("model"):
                    models.add(d["payload"]["model"])
        for record in records:
            item = json.loads(record["item_json"])
            kind = item.get("type")
            if kind not in CODEX_FIELDS:
                stats["codex_nonpublic_or_runtime_items_excluded"] += 1
                continue
            public = {key: item[key] for key in CODEX_FIELDS[kind] if key in item}
            events.append(scrub({"source_record_sha256": sha(record["item_json"].encode()), "thread_id": row["id"], "turn_id": record["turn_id"], "source_ordinal": record["rollout_ordinal"], "timestamp": date(record["created_at_ms"], True), "item": public}))
        if not events:
            continue
        source = row["source"]
        try:
            parent = json.loads(source).get("subagent", {}).get("thread_spawn", {}).get("parent_thread_id")
        except ValueError:
            parent = None
        meta = {"id": row["id"], "title": scrub(row["name"] or row["title"] or row["agent_path"] or "辅助任务"), "source_tool": "Codex", "model": sorted(models) or ([row["model"]] if row["model"] else []), "model_note": "优先列出原 turn_context 中明确记录的模型；缺失时仅采用会话元数据，不推断历史模型。", "is_subagent": row["thread_source"] == "subagent", "parent_id": parent, "created_at": date(row["created_at"]), "updated_at": date(row["updated_at"]), "source_path": "<USER_PROFILE>/.codex/thread_history_1.sqlite#thread_items/" + row["id"], "time_basis": "逐条时间来自历史库 created_at_ms；会话时间来自本地元数据。", "source_records_sha256": sha("\n".join(r["item_json"] for r in records).encode())}
        save_session(meta, events)


def finish():
    evidence = ROOT / "MissingEggDoc-main/docs/images/investigation-puzzles"
    evidence_dest = OUT / "04_图片生成记录与概念图"
    evidence_dest.mkdir(parents=True, exist_ok=True)
    image_log = json.loads((evidence / "生成记录.json").read_text(encoding="utf-8"))
    evidence_files = [evidence / "生成记录.json"] + [evidence / name for name in ["01-magnifier-flat.png", "02-uncover-flat.png", "03-rotate-flat.png", "04-jigsaw-flat.png", "05-rubbing-flat.png", "06-tweezers-flat.png", "07-testimony-flat.png"]]
    for path in evidence_files:
        shutil.copy2(path, evidence_dest / path.name)
    sessions.sort(key=lambda x: (x["is_subagent"], x.get("created_at") or "", x["id"]))
    main = [s for s in sessions if not s["is_subagent"]]
    children = [s for s in sessions if s["is_subagent"]]
    counts = collections.Counter(s["source_tool"] for s in main)
    readme = f"""风车农场悬案 / Mystery At Windmill Farm
AI 工具使用日志（比赛提交导出包）

导出时间：{STAMP}（Asia/Shanghai，UTC+8）
项目目录：Documents/GitHub/Mystery-At-Windmill-Farm

一、内容
本包收录当前电脑可读取、能由工作目录或 Cursor 项目目录确定归属的历史记录：
主会话 {len(main)} 个（Cursor {counts['Cursor']} 个，Codex {counts['Codex']} 个）；辅助任务 {len(children)} 个；工具结果补充 {len(supplements)} 份；图片生成记录 1 份及对应概念图 7 张。
Cursor 历史最早可追溯至 2026-08-14，Codex 记录截至 2026-10-31。具体时间和来源见会话索引。

二、阅读方法
打开 00_会话索引.html 可按会话进入 TXT 可读日志或 JSONL 结构化日志。
01_主会话：用户提问、AI 回复、原记录中存在的工具调用及结果。
02_辅助任务：主会话调用的子代理记录，单独列出，避免当成额外用户提问。
03_工具结果补充：Cursor 的两份历史段中额外保存的工具返回；与主日志部分重叠，不重复统计为会话。
04_图片生成记录与概念图：原项目中的生成记录.json 与七张 PNG，按原文件复制。记录阶段为“设计概念，未实施到运行时”，不据此认定已在游戏中落地。

三、真实性与范围
这是历史记录的整理导出，没有补写、润色或虚构用户提问和 AI 回复。工具调用失败、纠错及原回复的不确定说明均保留。
Cursor 已导入 Codex 的 8 份会话采用 Cursor 来源，不重复计算。Cursor 元数据时间、消息里的 timestamp、Codex 逐条时间分别标注；无时间或模型的记录不推测。
Cursor JSONL 主要保存提示词、回复和工具参数；仅两份历史补充段包含完整工具返回，其他缺失内容无法恢复。Codex 保存原历史库中可见的命令、输出、改动和工具记录，原来源已有的截断无法还原。
媒体二进制未嵌入聊天 JSONL；图片、附件路径保留为引用。本包只附带项目现存的七张谜题概念图，不是整个项目的素材备份。
机器用户目录以 <USER_PROFILE> 替代，常见密钥/令牌作脱敏；系统/开发者上下文、模型内部推理、后台自动审批记录不在本包范围。JSONL 是提取版，不宣称与整个应用数据库逐字节相同。
本次“导出日志”的会话及其辅助任务未计入开发历史；其他工作目录的美术/比赛材料会话未混入本项目导出。
项目说明曾提到 GPT、Tripo、混元等工具，本次未取得其独立原始操作日志，未补造记录。此包也不代表团队其他成员、其他电脑或已删除的全部历史。
原回复里的“已完成”“测试通过”等表述是当时 AI 的记录，不等于本次重新验证；比赛要求未提供专用模板，因此本包采用通用 TXT/JSONL/ZIP 格式。

四、校验
manifest.json 记录会话来源、源记录 SHA-256 与导出统计。
SHA256SUMS.txt 记录包内文件校验值，可用于核对解压后的内容。
"""
    write(OUT / "00_先读我.txt", readme)
    index_lines = ["AI 工具使用日志 / 会话索引", f"导出时间：{STAMP}", ""]
    cards = []
    for i, session in enumerate(sessions, 1):
        category = "辅助任务" if session["is_subagent"] else "主会话"
        index_lines += [f"{i:02d}. [{category} / {session['source_tool']}] {session['title']}", f"    日期：{session.get('created_at')} → {session.get('updated_at')}", f"    记录：{session['event_count']} 条；用户/任务消息：{session['user_message_count']} 条", "    文件：" + session["text_file"], "    ID：" + session["id"], ""]
        cards.append(f'<li><span>{html.escape(category)} · {html.escape(session["source_tool"])}</span><h3>{html.escape(session["title"])}</h3><p>{html.escape(str(session.get("created_at")))} · {session["event_count"]} 条记录</p><a href="{html.escape(session["text_file"])}">阅读 TXT</a>　<a href="{html.escape(session["jsonl_file"])}">JSONL</a></li>')
    write(OUT / "00_会话索引.txt", "\n".join(index_lines))
    write(OUT / "00_会话索引.html", '<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>风车农场悬案 · AI 工具使用日志</title><style>body{font:16px/1.65 system-ui,"Microsoft YaHei",sans-serif;background:#f5f3ed;color:#213a2e;max-width:1050px;margin:48px auto;padding:0 24px}h1{font-size:34px}a{color:#235a94}ol{padding:0;list-style:none}li{background:white;border:1px solid #dcded4;border-radius:12px;padding:22px;margin:18px 0}h3{margin:6px 0;font-size:18px;overflow-wrap:anywhere}span,p{color:#607268}pre{white-space:pre-wrap;font:inherit;font-size:14px}</style><h1>风车农场悬案<br>AI 工具使用日志</h1><p>真实历史记录 · 2026-08—2026-10 · 本地离线导出</p><p><a href="00_先读我.txt">范围与导出说明</a>　<a href="manifest.json">来源及校验信息</a></p><ol>' + ''.join(cards) + '</ol><details><summary>导出范围说明</summary><pre>' + html.escape(readme) + '</pre></details></html>')
    manifest = {"schema_version": 1, "project": ROOT.name, "exported_at": STAMP, "main_session_count": len(main), "auxiliary_session_count": len(children), "main_by_tool": dict(counts), "event_count": sum(s["event_count"] for s in sessions), "sessions": sessions, "supplements": supplements, "deduplication_and_redaction": dict(stats), "evidence": [{"path": (evidence_dest / p.name).relative_to(OUT).as_posix(), "source": p.relative_to(ROOT).as_posix(), "sha256": sha(p.read_bytes())} for p in evidence_files]}
    write(OUT / "manifest.json", json_text(manifest))
    files = sorted(p for p in OUT.rglob("*") if p.is_file() and p.name != "SHA256SUMS.txt")
    write(OUT / "SHA256SUMS.txt", "\n".join(sha(p.read_bytes()) + "  " + p.relative_to(OUT).as_posix() for p in files) + "\n")
    archive = OUT.with_suffix(".zip")
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as z:
        for path in sorted(OUT.rglob("*")):
            if path.is_file():
                z.write(path, OUT.name + "/" + path.relative_to(OUT).as_posix())
    with zipfile.ZipFile(archive) as z:
        assert z.testzip() is None
    print(json_text({"zip": str(archive), "bytes": archive.stat().st_size, "main_sessions": len(main), "auxiliary_sessions": len(children), "events": manifest["event_count"], "redactions": dict(stats)}))


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="private-snapshot-", dir=ROOT / "tmp/ai-log-export", ignore_cleanup_errors=True) as tmp:
        temp = pathlib.Path(tmp).resolve()
        assert temp.parent == (ROOT / "tmp/ai-log-export").resolve()
        state = snapshot(CODEX / "state_5.sqlite", temp)
        history = snapshot(CODEX / "thread_history_1.sqlite", temp)
        cursor_db = HOME / "AppData/Roaming/Cursor/User/globalStorage/state.vscdb"
        cursor = sqlite3.connect(cursor_db.as_uri() + "?mode=ro&immutable=1", uri=True)
        cursor.row_factory = sqlite3.Row
        headers = {r["composerId"]: dict(r) for r in cursor.execute("SELECT composerId,createdAt,lastUpdatedAt,isSubagent,value FROM composerHeaders WHERE workspaceId=?", ("cce37e6af7693f9051ece3de60eca9ea",))}
        cursor.close()
        imports = json.loads((CODEX / "external_agent_session_imports.json").read_text(encoding="utf-8"))["records"]
        imported = {x["imported_thread_id"]: x for x in imports if "Mystery-At-Windmill-Farm" in x["source_path"]}
        export_cursor(headers)
        export_codex(state, history, imported)
        state.close()
        history.close()
        del state, history
        gc.collect()
    finish()
