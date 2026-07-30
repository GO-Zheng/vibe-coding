#!/usr/bin/env bash
# Sync vibe-coding to Codex

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

  # AGENTS.md: expand @references & auto-include alwaysApply rules for Codex
  expand_antigravity_agents "$CODEX_HOME/AGENTS.md"

  # Rules: sync rules with directory structure
  sync_claude_rules "$CODEX_HOME/rules"

  # Skills under ~/.codex/skills/
  copy_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  log "Codex rules and skills deployed to $CODEX_HOME"
}

sync_codex
