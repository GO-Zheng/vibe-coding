#!/usr/bin/env bash
# Sync vibe-coding to Claude Code (~/.claude/)

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

  # Claude Code reads CLAUDE.md, NOT AGENTS.md natively — bridge required
  copy_path "$VIBE_CODING_ROOT/AGENTS.md" "$CLAUDE_HOME/AGENTS.md"
  write_claude_bridge "$CLAUDE_HOME"

  # Rules — preserve subdirectory structure so @rules/sub/file.md in AGENTS.md resolves correctly
  sync_claude_rules "$CLAUDE_HOME/rules"

  # Skills
  copy_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"
}

sync_claude
