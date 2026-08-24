#!/usr/bin/env bash
# 将 vibe-coding 同步到 Codex.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_SRC="$VIBE_CODING_ROOT/skills"
SKILLS_DST="$CODEX_HOME/skills"

sync_codex() {
  log "=== Codex ==="
  ensure_dir "$CODEX_HOME"

  # AGENTS.md: 展开 @ 引用, 并为 Codex 自动包含 alwaysApply 规则.
  expand_antigravity_agents "$CODEX_HOME/AGENTS.md"

  # 规则目录: 保留目录结构同步规则.
  sync_claude_rules "$CODEX_HOME/rules"

  # 技能目录: 同步到 ~/.codex/skills/.
  copy_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  log "Codex rules and skills deployed to $CODEX_HOME"
}

sync_codex
