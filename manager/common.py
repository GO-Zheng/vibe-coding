"""管理器共享的数据结构、源文件扫描和文件操作."""

from __future__ import annotations

import ast
import os
import re
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping


@dataclass(frozen=True)
class RuleSource:
    relative_path: Path
    content: str
    description: str
    always_apply: bool
    globs: str | None


@dataclass(frozen=True)
class SkillSource:
    name: str
    path: Path


@dataclass(frozen=True)
class InstallResult:
    kind: str
    name: str
    destination: Path


@dataclass(frozen=True)
class InstallStatus:
    kind: str
    name: str
    destination: Path
    installed: bool


def _parse_scalar(value: str) -> str | bool:
    value = value.strip()
    if value in {"true", "false"}:
        return value == "true"
    if value.startswith(("'", '"')) and value.endswith(value[0]):
        try:
            return ast.literal_eval(value)
        except (SyntaxError, ValueError) as exc:
            raise ValueError(f"manifest 标量无效: {value}") from exc
    return value


def parse_manifest(path: Path) -> dict[str, dict[str, str | bool]]:
    """读取当前 manifest 使用的简单 YAML 结构."""
    entries: dict[str, dict[str, str | bool]] = {}
    current: dict[str, str | bool] | None = None
    for line_number, line in enumerate(
        path.read_text(encoding="utf-8").splitlines(), start=1
    ):
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or stripped == "rules:":
            continue
        if stripped.startswith("- source:"):
            source = stripped.split(":", 1)[1].strip()
            parsed = _parse_scalar(source)
            if not isinstance(parsed, str):
                raise ValueError(f"{path}:{line_number} source 必须是字符串")
            current = {"source": parsed}
            entries[parsed] = current
            continue
        if current is None or ":" not in stripped:
            raise ValueError(f"{path}:{line_number} 无法解析 manifest 条目")
        key, raw_value = stripped.split(":", 1)
        if key not in {"description", "alwaysApply", "globs"}:
            continue
        current[key] = _parse_scalar(raw_value)
    return entries


def discover_rules(repo_root: Path) -> list[RuleSource]:
    manifest_path = repo_root / "rules" / "manifest.yaml"
    entries = parse_manifest(manifest_path)
    rules: list[RuleSource] = []
    for source, metadata in entries.items():
        source_path = repo_root / "rules" / source
        if not source_path.is_file():
            raise FileNotFoundError(f"Rules 源文件不存在: {source_path}")
        description = metadata.get("description", "")
        always_apply = metadata.get("alwaysApply", False)
        globs = metadata.get("globs")
        if not isinstance(description, str) or not isinstance(always_apply, bool):
            raise ValueError(f"manifest 条目字段无效: {source}")
        if globs is not None and not isinstance(globs, str):
            raise ValueError(f"manifest globs 无效: {source}")
        rules.append(
            RuleSource(Path(source), source_path.read_text(encoding="utf-8"), description,
                       always_apply, globs)
        )
    return rules


def discover_skills(repo_root: Path) -> list[SkillSource]:
    skills_root = repo_root / "skills"
    skills: list[SkillSource] = []
    for path in sorted(skills_root.iterdir()):
        if path.is_dir() and (path / "SKILL.md").is_file():
            skills.append(SkillSource(path.name, path))
    return skills


def resolve_user_home() -> Path:
    return Path.home()


def resolve_codex_home(user_home: Path) -> Path:
    return Path(os.environ.get("CODEX_HOME", user_home / ".codex")).expanduser()


def copy_file(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def copy_tree(source: Path, destination: Path) -> None:
    for path in source.rglob("*"):
        if path.is_file():
            copy_file(path, destination / path.relative_to(source))


def replace_managed_block(
    path: Path, content: str, begin: str, end: str
) -> None:
    existing = path.read_text(encoding="utf-8") if path.exists() else ""
    has_begin = begin in existing
    has_end = end in existing
    if has_begin != has_end:
        raise ValueError(f"受控区块标记不完整: {path}")
    block = f"{begin}\n{content.rstrip()}\n{end}"
    if has_begin:
        pattern = re.escape(begin) + r".*?" + re.escape(end)
        updated = re.sub(pattern, block, existing, count=1, flags=re.DOTALL)
    else:
        separator = "" if not existing or existing.endswith("\n") else "\n"
        updated = f"{existing}{separator}{block}\n"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(updated, encoding="utf-8")


def update_managed_rules(
    path: Path, selected: Mapping[str, str], begin: str, end: str
) -> None:
    existing = path.read_text(encoding="utf-8") if path.exists() else ""
    managed = ""
    if begin in existing:
        start = existing.index(begin) + len(begin)
        stop = existing.index(end, start)
        managed = existing[start:stop]
    elif end in existing:
        raise ValueError(f"受控区块标记不完整: {path}")
    entries = dict(_read_managed_rules(managed))
    entries.update(selected)
    rendered = []
    for name, content in entries.items():
        rendered.append(f"<!-- vibe-coding:rule:{name} -->\n"
                        f"{content.rstrip()}\n<!-- vibe-coding:rule-end -->")
    replace_managed_block(path, "\n".join(rendered), begin, end)


def _read_managed_rules(content: str) -> Iterable[tuple[str, str]]:
    pattern = (
        r"<!-- vibe-coding:rule:(.*?) -->\n"
        r"(.*?)\n<!-- vibe-coding:rule-end -->"
    )
    return ((match.group(1), match.group(2)) for match in re.finditer(
        pattern, content, flags=re.DOTALL
    ))


def managed_rule_installed(path: Path, name: str, begin: str, end: str) -> bool:
    if not path.is_file():
        return False
    content = path.read_text(encoding="utf-8")
    if begin not in content or end not in content:
        return False
    start = content.index(begin)
    stop = content.index(end, start)
    return f"<!-- vibe-coding:rule:{name} -->" in content[start:stop]


def cursor_rule_name(relative_path: Path) -> str:
    return relative_path.as_posix().replace("/", "__").removesuffix(".md") + ".mdc"


def _quote_yaml(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def render_cursor_rule(rule: RuleSource) -> str:
    lines = [
        "---",
        f"description: {_quote_yaml(rule.description)}",
        f"alwaysApply: {'true' if rule.always_apply else 'false'}",
    ]
    if rule.globs is not None:
        lines.append(f"globs: {_quote_yaml(rule.globs)}")
    lines.extend(["---", "", rule.content.rstrip(), ""])
    return "\n".join(lines)
