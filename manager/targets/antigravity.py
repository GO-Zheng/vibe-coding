"""Antigravity CLI 和 IDE 用户级 Rules 与 Skills 目标."""

from __future__ import annotations

from pathlib import Path

from ..common import (
    InstallResult,
    InstallStatus,
    RuleSource,
    SkillSource,
    copy_tree,
    managed_rule_installed,
    update_managed_rules,
)

BEGIN = "<!-- vibe-coding:begin -->"
END = "<!-- vibe-coding:end -->"


def rules_path(user_home: Path, variant: str | None = None) -> Path:
    del variant
    return user_home / ".gemini" / "config" / "GEMINI.md"


def skills_root(user_home: Path, variant: str | None = None) -> Path:
    if variant not in {"cli", "ide"}:
        raise ValueError("Antigravity target 必须指定 cli 或 ide")
    return user_home / ".gemini" / "config" / "skills"


def install_rules(
    rules: list[RuleSource], user_home: Path, variant: str | None = None
) -> list[InstallResult]:
    path = rules_path(user_home, variant)
    selected = {rule.relative_path.as_posix(): rule.content for rule in rules}
    update_managed_rules(path, selected, BEGIN, END)
    return [InstallResult("rules", "GEMINI.md", path)]


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
    path = rules_path(user_home, variant)
    skills_path = skills_root(user_home, variant)
    return [
        *[
            InstallStatus("rule", str(rule.relative_path), path,
                          managed_rule_installed(path, rule.relative_path.as_posix(),
                                                  BEGIN, END))
            for rule in rules
        ],
        *[
            InstallStatus("skill", skill.name, skills_path / skill.name,
                          (skills_path / skill.name / "SKILL.md").is_file())
            for skill in skills
        ],
    ]


statuses = list_status
