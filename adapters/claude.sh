#!/usr/bin/env bash
# 将 vibe-coding 同步到 Claude Code (~/.claude/).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SKILLS_SRC="$VIBE_CODING_ROOT/skills"
SKILLS_DST="$CLAUDE_HOME/skills"

sync_claude() {
  log "=== Claude Code ==="
  ensure_dir "$CLAUDE_HOME"

  # Claude Code 原生读取 CLAUDE.md, 不读取 AGENTS.md, 因此需要桥接文件.
  copy_path "$VIBE_CODING_ROOT/AGENTS.md" "$CLAUDE_HOME/AGENTS.md"
  write_claude_bridge "$CLAUDE_HOME"

  # 规则目录: 保留子目录结构, 确保 AGENTS.md 中的 @rules/sub/file.md 能正确解析.
  sync_claude_rules "$CLAUDE_HOME/rules"

  # 技能目录: 复制 skill 目录.
  copy_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"
}

sync_claude
