#!/usr/bin/env python3
"""端到端冒烟测试：创建 Session → 发消息 → 等待 Agent 回复。

用法（在项目根目录）：
  .venv\\Scripts\\python.exe scripts\\smoke_agent_e2e.py
  .venv\\Scripts\\python.exe scripts\\smoke_agent_e2e.py --base http://127.0.0.1:8899
"""

from __future__ import annotations

import argparse
import json
import sys
import time
import urllib.error
import urllib.request

DEFAULT_PROMPT = (
    "请用一句话中文自我介绍，说明你是 Vibe-Trading 助手。"
    "不要调用任何工具，直接文字回答。"
)


def _request(method: str, url: str, body: dict | None = None, timeout: float = 30) -> dict | list:
    data = None
    headers = {"Content-Type": "application/json"}
    if body is not None:
        data = json.dumps(body, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description="Vibe-Trading Agent E2E smoke test")
    parser.add_argument("--base", default="http://127.0.0.1:8899", help="API base URL")
    parser.add_argument("--prompt", default=DEFAULT_PROMPT, help="Test message content")
    parser.add_argument("--timeout", type=int, default=120, help="Max seconds to wait for reply")
    args = parser.parse_args()
    base = args.base.rstrip("/")

    print(f"[1/4] 检查服务 {base}/docs ...")
    try:
        urllib.request.urlopen(f"{base}/docs", timeout=10)
    except urllib.error.URLError as e:
        print(f"FAIL: 服务不可达 — {e}\n请先运行 start-full.bat 或 vibe-trading serve")
        return 1
    print("OK")

    print("[2/4] 创建 Session ...")
    session = _request("POST", f"{base}/sessions", {"title": "smoke-e2e"})
    sid = session["session_id"]
    print(f"OK session_id={sid}")

    print("[3/4] 发送测试消息 ...")
    _request("POST", f"{base}/sessions/{sid}/messages", {"content": args.prompt})
    print("OK 已提交，等待 Agent 回复 ...")

    deadline = time.time() + args.timeout
    assistant_text = ""
    while time.time() < deadline:
        time.sleep(3)
        messages = _request("GET", f"{base}/sessions/{sid}/messages")
        for m in messages:
            if m.get("role") == "assistant" and (m.get("content") or "").strip():
                assistant_text = m["content"].strip()
                break
        if assistant_text:
            break
        print("  ... 仍在等待", end="\r")

    print()
    if not assistant_text:
        print(f"FAIL: {args.timeout}s 内未收到 assistant 回复")
        print(f"可手动查看: {base}/agent  或 GET {base}/sessions/{sid}/messages")
        return 2

    preview = assistant_text[:200] + ("..." if len(assistant_text) > 200 else "")
    print("[4/4] Agent 回复成功:")
    print("-" * 50)
    print(preview)
    print("-" * 50)
    print("PASS: 端到端 Agent 链路正常")
    return 0


if __name__ == "__main__":
    sys.exit(main())
