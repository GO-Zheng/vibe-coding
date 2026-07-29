#!/usr/bin/env bash
# Sync vibe-coding to Antigravity (~/.gemini/config/)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

ANTIGRAVITY_HOME="${ANTIGRAVITY_HOME:-$HOME/.gemini/config}"
SKILLS_SRC="$VIBE_CODING_ROOT/skills"
SKILLS_DST="$ANTIGRAVITY_HOME/skills"

sync_antigravity() {
  log "=== Antigravity ==="
  ensure_dir "$ANTIGRAVITY_HOME"

  # Skills: symlink each skill-name/ directory into ~/.gemini/config/skills/
  link_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  # AGENTS.md: global pointer
  link_path "$VIBE_CODING_ROOT/AGENTS.md" "$ANTIGRAVITY_HOME/AGENTS.md"

  log "Antigravity rules and skills synchronized to $ANTIGRAVITY_HOME"
}

sync_antigravity
