#!/usr/bin/env bash
# Sync vibe-coding to Xcode Claude Agent config

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

XCODE_AGENT_HOME="${XCODE_AGENT_HOME:-$HOME/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig}"
SKILLS_SRC="$VIBE_CODING_ROOT/skills"
SKILLS_DST="$XCODE_AGENT_HOME/.claude/skills"

sync_xcode() {
  log "=== Xcode (Claude Agent) ==="

  if [[ ! -d "$(dirname "$XCODE_AGENT_HOME")" ]]; then
    warn "Xcode CodingAssistant dir not found — create after installing Xcode 26.3+ agent support"
    warn "expected: $XCODE_AGENT_HOME"
  fi

  ensure_dir "$XCODE_AGENT_HOME"

  # AGENTS.md + CLAUDE.md bridge
  link_path "$VIBE_CODING_ROOT/AGENTS.md" "$XCODE_AGENT_HOME/AGENTS.md"
  write_claude_bridge "$XCODE_AGENT_HOME"

  # Skills under .claude/skills/
  link_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  log "restart Xcode / Claude Agent after sync for skills to reload"
}

sync_xcode
