"""manager 的核心行为测试."""

import os
import tempfile
import unittest
from contextlib import redirect_stderr
from io import StringIO
from pathlib import Path
from unittest.mock import patch

from manager import common
from manager.cli import main
from manager.integrations import check_target
from manager.targets import antigravity, claude, codex, cursor


REPO_ROOT = Path(__file__).resolve().parents[2]


class CommonTest(unittest.TestCase):
    def test_discover_sources_uses_manifest_and_skill_directories(self) -> None:
        rules = common.discover_rules(REPO_ROOT)
        skills = common.discover_skills(REPO_ROOT)

        self.assertIn(Path("core/communication.md"), [item.relative_path for item in rules])
        self.assertIn("quick", [item.name for item in skills])
        self.assertNotIn("README.md", [item.relative_path.name for item in rules])

    def test_codex_home_honors_environment(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            with patch.dict(os.environ, {"CODEX_HOME": directory}):
                self.assertEqual(common.resolve_codex_home(Path("/home/user")),
                                 Path(directory))

    def test_managed_block_preserves_user_content_and_updates(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "AGENTS.md"
            common.replace_managed_block(
                path, "first", "<!-- begin -->", "<!-- end -->"
            )
            path.write_text(
                "before\n" + path.read_text(encoding="utf-8").rstrip() + "\nafter\n",
                encoding="utf-8",
            )
            common.replace_managed_block(
                path, "second", "<!-- begin -->", "<!-- end -->"
            )

            content = path.read_text(encoding="utf-8")
            self.assertIn("before\n", content)
            self.assertIn("second", content)
            self.assertIn("\nafter\n", content)

    def test_managed_rules_update_only_selected_entry(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "AGENTS.md"
            begin = "<!-- vibe-coding:begin -->"
            end = "<!-- vibe-coding:end -->"
            common.update_managed_rules(path, {"one": "old", "two": "keep"}, begin, end)
            common.update_managed_rules(path, {"one": "new"}, begin, end)

            content = path.read_text(encoding="utf-8")
            self.assertIn("new", content)
            self.assertIn("keep", content)
            self.assertTrue(common.managed_rule_installed(path, "two", begin, end))


class TargetTest(unittest.TestCase):
    def setUp(self) -> None:
        self.rules = common.discover_rules(REPO_ROOT)
        self.skills = common.discover_skills(REPO_ROOT)
        self.rule = next(item for item in self.rules
                         if item.relative_path == Path("core/communication.md"))
        self.skill = next(item for item in self.skills if item.name == "quick")

    def test_claude_copies_rule_and_skill(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            claude.install_rules([self.rule], home)
            claude.install_skills([self.skill], home)

            rule_path = home / ".claude/rules/core/communication.md"
            skill_path = home / ".claude/skills/quick/SKILL.md"
            self.assertTrue(rule_path.is_file())
            self.assertTrue(skill_path.is_file())
            rule_path.write_text("stale", encoding="utf-8")
            skill_path.write_text("stale", encoding="utf-8")
            claude.install_rules([self.rule], home)
            claude.install_skills([self.skill], home)
            self.assertEqual(rule_path.read_text(encoding="utf-8"), self.rule.content)
            self.assertNotEqual(skill_path.read_text(encoding="utf-8"), "stale")

    def test_codex_preserves_existing_agents_content(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            path = home / ".codex/AGENTS.md"
            path.parent.mkdir(parents=True)
            path.write_text("user content\n", encoding="utf-8")
            codex.install_rules([self.rule], home)

            content = path.read_text(encoding="utf-8")
            self.assertIn("user content", content)
            self.assertIn("core/communication.md", content)

    def test_cursor_renders_mdc_and_antigravity_uses_config_paths(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            cursor.install_rules([self.rule], home)
            antigravity.install_rules([self.rule], home)
            antigravity.install_skills([self.skill], home)

            cursor_rule = home / ".cursor/rules/core__communication.mdc"
            self.assertIn("alwaysApply:", cursor_rule.read_text(encoding="utf-8"))
            self.assertTrue((home / ".gemini/config/GEMINI.md").is_file())
            self.assertTrue((home / ".gemini/config/skills/quick/SKILL.md").is_file())


class IntegrationTest(unittest.TestCase):
    def test_checks_detect_installed_superpowers_and_context7(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / ".cursor/plugins/superpowers").mkdir(parents=True)
            (home / ".cursor/plugins/context7-plugin").mkdir(parents=True)

            statuses = check_target("cursor", home)

            self.assertEqual([item.state for item in statuses],
                             ["installed", "installed"])

    def test_checks_context7_mcp_configuration(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            mcp_path = home / ".cursor/mcp.json"
            mcp_path.parent.mkdir(parents=True)
            mcp_path.write_text('{"mcpServers": {"context7": {}}}', encoding="utf-8")

            statuses = check_target("cursor", home)

            self.assertEqual(statuses[1].state, "installed")

    def test_antigravity_uses_config_paths(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / ".gemini/config/skills/superpowers").mkdir(parents=True)
            mcp_path = home / ".gemini/config/mcp_config.json"
            mcp_path.parent.mkdir(parents=True, exist_ok=True)
            mcp_path.write_text('{"context7": {}}', encoding="utf-8")

            statuses = check_target("antigravity", home)

            self.assertEqual([item.state for item in statuses],
                             ["installed", "installed"])

    def test_install_warns_but_continues_when_integrations_are_missing(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            output = StringIO()
            with patch("manager.cli.resolve_user_home", return_value=home):
                with redirect_stderr(output):
                    result = main(["install", "--target", "cursor",
                                   "--rule", "core/communication.md"])

            self.assertEqual(result, 0)
            self.assertIn("warning:", output.getvalue())
            self.assertTrue((home / ".cursor/rules/core__communication.mdc").is_file())


if __name__ == "__main__":
    unittest.main()
