"""各 AI 工具的用户级安装目标."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from . import antigravity, claude, codex, cursor


@dataclass(frozen=True)
class Target:
    name: str
    module: Any
    variant: str | None = None


TARGETS = {
    "claude": Target("claude", claude),
    "codex": Target("codex", codex),
    "cursor": Target("cursor", cursor),
    "antigravity-cli": Target("antigravity-cli", antigravity, "cli"),
    "antigravity-ide": Target("antigravity-ide", antigravity, "ide"),
}


def expand_target(name: str) -> list[Target]:
    if name == "all":
        names = ["claude", "codex", "cursor", "antigravity-cli", "antigravity-ide"]
        return [TARGETS[item] for item in names]
    if name == "antigravity":
        return [TARGETS["antigravity-cli"], TARGETS["antigravity-ide"]]
    return [TARGETS[name]]
