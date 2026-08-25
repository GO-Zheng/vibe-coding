"""vibe-coding manager 命令行入口."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Optional, Sequence

from .common import (
    InstallStatus,
    RuleSource,
    SkillSource,
    discover_rules,
    discover_skills,
    resolve_user_home,
)
from .integrations import check_target
from .targets import Target, expand_target


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="python -m manager",
        description="查看和安装 vibe-coding 的用户级 Rules 与 Skills.",
    )
    commands = parser.add_subparsers(dest="command", required=True)
    for name, description in (
        ("list", "查看源项和用户级安装状态"),
        ("install", "安装或覆盖用户级 Rules 与 Skills"),
    ):
        command = commands.add_parser(name, help=description)
        command.add_argument(
            "--target",
            default="all",
            choices=["all", "claude", "codex", "cursor", "antigravity",
                     "antigravity-cli", "antigravity-ide"],
            help="安装目标, 默认处理全部目标",
        )
        command.add_argument(
            "--kind", choices=["all", "rules", "skills"], default="all",
            help="内容类型, 默认处理 Rules 和 Skills",
        )
    install = commands.choices["install"]
    selection = install.add_mutually_exclusive_group()
    selection.add_argument("--rule", help="只安装指定 Rule, 例如 core/communication.md")
    selection.add_argument("--skill", help="只安装指定 Skill, 例如 quick")
    return parser


def _select_sources(
    args: argparse.Namespace,
    rules: list[RuleSource],
    skills: list[SkillSource],
) -> tuple[list[RuleSource], list[SkillSource]]:
    selected_rules = rules if args.kind in {"all", "rules"} else []
    selected_skills = skills if args.kind in {"all", "skills"} else []
    if args.rule:
        if args.kind == "skills":
            raise ValueError("--rule 不能与 --kind skills 一起使用")
        selected_rules = [
            item for item in rules if item.relative_path.as_posix() == args.rule
        ]
        if not selected_rules:
            raise ValueError(f"找不到 Rule: {args.rule}")
        selected_skills = []
    if args.skill:
        if args.kind == "rules":
            raise ValueError("--skill 不能与 --kind rules 一起使用")
        selected_skills = [item for item in skills if item.name == args.skill]
        if not selected_skills:
            raise ValueError(f"找不到 Skill: {args.skill}")
        selected_rules = []
    return selected_rules, selected_skills


def _print_statuses(target: Target, statuses: list[InstallStatus]) -> None:
    print(f"[{target.name}]")
    for status in statuses:
        state = "installed" if status.installed else "missing"
        print(f"  {status.kind:5} {status.name} -> {status.destination} [{state}]")


def _warn_missing_integrations(target: Target, user_home: Path) -> None:
    for status in check_target(target.name, user_home, target.variant):
        if not status.installed:
            print(
                f"warning: [{target.name}] {status.name} {status.state}: "
                f"{status.detail}",
                file=sys.stderr,
            )


def list_command(
    args: argparse.Namespace, repo_root: Path, user_home: Path
) -> int:
    rules = discover_rules(repo_root)
    skills = discover_skills(repo_root)
    for target in expand_target(args.target):
        statuses = target.module.list_status(rules, skills, user_home, target.variant)
        if args.kind != "all":
            statuses = [item for item in statuses if item.kind == args.kind[:-1]]
        _print_statuses(target, statuses)
    return 0


def install_command(
    args: argparse.Namespace, repo_root: Path, user_home: Path
) -> int:
    rules, skills = _select_sources(
        args, discover_rules(repo_root), discover_skills(repo_root)
    )
    for target in expand_target(args.target):
        _warn_missing_integrations(target, user_home)
        if rules:
            results = target.module.install_rules(rules, user_home, target.variant)
            print(f"[{target.name}] installed {len(rules)} Rules: "
                  f"{results[0].destination}")
        if skills:
            results = target.module.install_skills(skills, user_home, target.variant)
            print(f"[{target.name}] installed {len(skills)} Skills: "
                  f"{results[0].destination}")
    return 0


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)
    repo_root = Path(__file__).resolve().parents[1]
    try:
        if args.command == "list":
            return list_command(args, repo_root, resolve_user_home())
        return install_command(args, repo_root, resolve_user_home())
    except (OSError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
