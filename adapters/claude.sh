#!/usr/bin/env bash
# Sync vibe-coding to Claude Code (~/.claude/)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SKILLS_SRC="$VIBE_CODING_ROOT/skills"
SKILLS_DST="$CLAUDE_HOME/skills"

# Sync rules/ -> ~/.claude/rules/ preserving subdirectory structure.
# Each .md rule file is symlinked individually so that @rules/... references
# in AGENTS.md resolve correctly from the Claude home directory.
sync_claude_rules() {
  local src="$VIBE_CODING_ROOT/rules"
  local dst="$CLAUDE_HOME/rules"

  if [[ ! -d "$src" ]]; then
    warn "rules dir missing: $src"
    return 0
  fi

  # Symlink each rule file, preserving subdirectory structure.
  # Exclude README.md which is top-level documentation, not a rule.
  while IFS= read -r -d '' file; do
    local rel="${file#$src/}"
    link_path "$file" "$dst/$rel"
  done < <(find "$src" -name '*.md' -not -name 'README.md' -print0 | sort -z)

  log "rules synced"
}

sync_claude() {
  log "=== Claude Code ==="
  ensure_dir "$CLAUDE_HOME"

  # Claude Code reads CLAUDE.md, NOT AGENTS.md natively — bridge required
  link_path "$VIBE_CODING_ROOT/AGENTS.md" "$CLAUDE_HOME/AGENTS.md"
  write_claude_bridge "$CLAUDE_HOME"

  # Rules — so that @rules/... in AGENTS.md resolves correctly
  sync_claude_rules

  # Skills
  link_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"
}

sync_claude
