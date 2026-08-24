#!/usr/bin/env bash
# 将 vibe-coding 同步到 Cursor (~/.cursor/).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
SKILLS_SRC="$VIBE_CODING_ROOT/skills"
SKILLS_DST="$CURSOR_HOME/skills"

sync_cursor() {
  log "=== Cursor ==="
  ensure_dir "$CURSOR_HOME"

  # 技能目录: 复制每个 skill-name/ 目录.
  copy_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  # AGENTS.md: 可选的全局入口, Cursor 也会读取项目级 AGENTS.md.
  copy_path "$VIBE_CODING_ROOT/AGENTS.md" "$CURSOR_HOME/AGENTS.md"

  # 规则文件: 根据 rules/ 和 manifest.yaml 生成 .mdc 文件.
  generate_cursor_rules

  log "Cursor User Rules in app settings: keep tool-specific prefs only"
}

sync_cursor
