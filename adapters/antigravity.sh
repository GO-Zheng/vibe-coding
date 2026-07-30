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

  # Skills: copy each skill directory into ~/.gemini/config/skills/
  copy_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  # Convert any remaining third-party symlinks in SKILLS_DST (e.g. superpowers skills) to real physical directories
  if [[ -d "$SKILLS_DST" ]]; then
    for item in "$SKILLS_DST"/*; do
      if [[ -L "$item" ]]; then
        local target
        target="$(readlink -f "$item")"
        if [[ -d "$target" ]]; then
          rm -f "$item"
          cp -r "$target" "$item"
          log "converted symlink skill to physical directory: $item"
        fi
      fi
    done
  fi

  # AGENTS.md: expand @references (e.g. @rules/communication.md) & auto-include alwaysApply rules
  expand_antigravity_agents "$ANTIGRAVITY_HOME/AGENTS.md"

  # Rules: copy rules directory flatly into ~/.gemini/config/rules/
  copy_rules_dir "$ANTIGRAVITY_HOME/rules"

  log "Antigravity rules and skills deployed to $ANTIGRAVITY_HOME"
}

sync_antigravity
