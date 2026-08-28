"""目标工具的 superpowers 和 Context7 本地配置检查."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from .common import resolve_codex_home


@dataclass(frozen=True)
class IntegrationStatus:
    name: str
    state: str
    detail: str

    @property
    def installed(self) -> bool:
        return self.state == "installed"


def _find_named_path(roots: Iterable[Path], name: str) -> Path | None:
    lowered_name = name.lower()
    for root in roots:
        try:
            if not root.exists():
                continue
            candidates = [root, *root.rglob("*")]
        except OSError:
            continue
        for candidate in candidates:
            if lowered_name in candidate.name.lower():
                return candidate
    return None


def _check_superpowers(roots: Iterable[Path]) -> IntegrationStatus:
    location = _find_named_path(roots, "superpowers")
    if location is None:
        return IntegrationStatus("superpowers", "missing", "未找到用户级 Skill 或 Plugin")
    return IntegrationStatus("superpowers", "installed", str(location))


def _check_context7(paths: Iterable[Path], plugin_roots: Iterable[Path]) -> IntegrationStatus:
    plugin = _find_named_path(plugin_roots, "context7")
    if plugin is not None:
        return IntegrationStatus("context7", "installed", str(plugin))
    existing = [path for path in paths if path.is_file()]
    unreadable: list[Path] = []
    for path in existing:
        try:
            if "context7" in path.read_text(encoding="utf-8").lower():
                return IntegrationStatus("context7", "installed", str(path))
        except OSError:
            unreadable.append(path)
    if unreadable:
        return IntegrationStatus("context7", "unknown", f"无法读取配置: {unreadable[0]}")
    if existing:
        return IntegrationStatus("context7", "missing", "已检查配置但未找到 Context7")
    return IntegrationStatus("context7", "missing", "未找到 MCP 配置")


def _paths_for_target(
    target: str, user_home: Path, variant: str | None
) -> tuple[list[Path], list[Path], list[Path]]:
    if target == "claude":
        base = user_home / ".claude"
        return (
            [base / "skills", base / "plugins"],
            [user_home / ".claude.json", base / "settings.json",
             base / "mcp.json", user_home / ".mcp.json"],
            [base / "plugins"],
        )
    if target == "codex":
        base = resolve_codex_home(user_home)
        return (
            [user_home / ".agents" / "skills", base / "skills", base / "plugins"],
            [base / "config.toml", base / "mcp.json"],
            [base / "plugins"],
        )
    if target == "cursor":
        base = user_home / ".cursor"
        return (
            [base / "skills", base / "plugins", base / "extensions"],
            [base / "mcp.json", base / "settings.json"],
            [base / "plugins", base / "extensions"],
        )
    if target == "antigravity":
        base = user_home / ".gemini" / "config"
        return (
            [base / "skills", base / "plugins", base / "extensions"],
            [base / "config.json", base / "settings.json",
             base / "mcp.json", base / "mcp_config.json"],
            [base / "plugins", base / "extensions"],
        )
    raise ValueError(f"不支持的 target: {target}")


def check_target(
    target: str, user_home: Path, variant: str | None = None
) -> list[IntegrationStatus]:
    skill_roots, config_paths, plugin_roots = _paths_for_target(
        target, user_home, variant
    )
    return [
        _check_superpowers(skill_roots),
        _check_context7(config_paths, plugin_roots),
    ]
