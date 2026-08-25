"""Cursor 用户级 Rules 和 Skills 目标."""

from __future__ import annotations

from pathlib import Path

from ..common import (
    InstallResult,
    InstallStatus,
    RuleSource,
    SkillSource,
    copy_tree,
    cursor_rule_name,
    render_cursor_rule,
)


def rules_root(user_home: Path, variant: str | None = None) -> Path:
    del variant
    return user_home / ".cursor" / "rules"


def skills_root(user_home: Path, variant: str | None = None) -> Path:
    del variant
    return user_home / ".cursor" / "skills"


def install_rules(
    rules: list[RuleSource], user_home: Path, variant: str | None = None
) -> list[InstallResult]:
    destination = rules_root(user_home, variant)
    results = []
    for rule in rules:
        target = destination / cursor_rule_name(rule.relative_path)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(render_cursor_rule(rule), encoding="utf-8")
        results.append(InstallResult("rule", str(rule.relative_path), target))
    return results


def install_skills(
    skills: list[SkillSource], user_home: Path, variant: str | None = None
) -> list[InstallResult]:
    destination = skills_root(user_home, variant)
    results = []
    for skill in skills:
        target = destination / skill.name
        copy_tree(skill.path, target)
        results.append(InstallResult("skill", skill.name, target))
    return results


def list_status(
    rules: list[RuleSource],
    skills: list[SkillSource],
    user_home: Path,
    variant: str | None = None,
) -> list[InstallStatus]:
    rules_path = rules_root(user_home, variant)
    skills_path = skills_root(user_home, variant)
    return [
        *[
            InstallStatus("rule", str(rule.relative_path),
                          rules_path / cursor_rule_name(rule.relative_path),
                          (rules_path / cursor_rule_name(rule.relative_path)).is_file())
            for rule in rules
        ],
        *[
            InstallStatus("skill", skill.name, skills_path / skill.name,
                          (skills_path / skill.name / "SKILL.md").is_file())
            for skill in skills
        ],
    ]


statuses = list_status
