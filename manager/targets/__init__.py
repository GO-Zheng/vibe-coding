"""各 AI 工具的用户级安装目标."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from . import antigravity, claude, codebuddy, codex, cursor


@dataclass(frozen=True)
class Target:
    name: str
    module: Any
    variant: str | None = None


TARGETS = {
    "claude": Target("claude", claude),
    "codebuddy": Target("codebuddy", codebuddy),
    "codex": Target("codex", codex),
    "cursor": Target("cursor", cursor),
    "antigravity": Target("antigravity", antigravity),
}


def expand_target(name: str) -> list[Target]:
    if name == "all":
        names = ["claude", "codebuddy", "codex", "cursor", "antigravity"]
        return [TARGETS[item] for item in names]
    return [TARGETS[name]]
