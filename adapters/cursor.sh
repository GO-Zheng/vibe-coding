#!/usr/bin/env bash
# Sync vibe-coding to Cursor (~/.cursor/)

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

  # Skills: symlink each skill-name/ directory
  link_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  # AGENTS.md: optional global pointer (Cursor also reads project AGENTS.md)
  link_path "$VIBE_CODING_ROOT/AGENTS.md" "$CURSOR_HOME/AGENTS.md"

  # Rules: generate .mdc from rules/ + manifest.yaml
  generate_cursor_rules

  log "Cursor User Rules in app settings: keep tool-specific prefs only (see ROADMAP.md)"
}

sync_cursor
