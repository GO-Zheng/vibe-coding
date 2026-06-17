#!/usr/bin/env python3
"""Convert Cursor agent-transcripts JSONL to readable Markdown.

Source files (WSL/Linux):
  ~/.cursor/projects/<project-id>/agent-transcripts/<uuid>/<uuid>.jsonl

Usage:
  python3 cursor-transcript-to-md.py INPUT.jsonl [-o OUTPUT.md] [--tools]

Options:
  --tools   Include tool_use blocks (default: skip, text only)
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


def strip_user_query(text: str) -> str:
    m = re.search(r"<user_query>\s*(.*?)\s*</user_query>", text, re.DOTALL)
    return m.group(1).strip() if m else text.strip()


def format_tool_use(item: dict) -> str:
    name = item.get("name", "tool")
    inp = item.get("input") or {}
    if isinstance(inp, dict):
        if "command" in inp:
            body = inp["command"]
            lang = "bash"
        elif "path" in inp:
            body = json.dumps(inp, ensure_ascii=False, indent=2)
            lang = "json"
        else:
            body = json.dumps(inp, ensure_ascii=False, indent=2)
            lang = "json"
    else:
        body = str(inp)
        lang = "text"
    return f"**Tool `{name}`**\n\n```{lang}\n{body}\n```\n"


def convert(lines: list[str], include_tools: bool) -> str:
    out: list[str] = ["# Cursor transcript\n"]
    turn = 0

    for raw in lines:
        raw = raw.strip()
        if not raw:
            continue
        try:
            obj = json.loads(raw)
        except json.JSONDecodeError:
            continue

        if obj.get("type") == "turn_ended":
            continue

        role = obj.get("role")
        message = obj.get("message")
        if role not in ("user", "assistant") or not isinstance(message, dict):
            continue

        parts: list[str] = []
        for item in message.get("content") or []:
            if not isinstance(item, dict):
                continue
            kind = item.get("type")
            if kind == "text":
                text = (item.get("text") or "").replace("[REDACTED]", "").strip()
                if not text:
                    continue
                if role == "user":
                    text = strip_user_query(text)
                if text:
                    parts.append(text)
            elif kind == "tool_use" and include_tools:
                parts.append(format_tool_use(item))

        if not parts:
            continue

        turn += 1
        heading = "User" if role == "user" else "Assistant"
        out.append(f"\n---\n\n## {turn}. {heading}\n\n")
        out.append("\n\n".join(parts))
        out.append("\n")

    return "".join(out)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="Path to *.jsonl transcript")
    parser.add_argument(
        "-o", "--output", type=Path, help="Output .md (default: stdout)"
    )
    parser.add_argument(
        "--tools", action="store_true", help="Include tool_use blocks"
    )
    args = parser.parse_args()

    if not args.input.is_file():
        print(f"error: not found: {args.input}", file=sys.stderr)
        return 1

    text = convert(args.input.read_text(encoding="utf-8").splitlines(), args.tools)

    if args.output:
        args.output.write_text(text, encoding="utf-8")
        print(f"wrote {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
