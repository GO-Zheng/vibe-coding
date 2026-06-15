#!/usr/bin/env bash
# vibe-coding — install/sync to AI coding tools
#
# Usage:
#   ./adapters/install.sh              # sync all tools
#   ./adapters/install.sh --cursor     # sync one tool
#   ./adapters/install.sh --dry-run    # preview only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

TARGETS=()

usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS] [TARGET...]

Targets (default: all):
  --cursor    Sync to ~/.cursor/
  --claude    Sync to ~/.claude/ (with CLAUDE.md bridge)
  --hermes    Sync to ~/.hermes/skills/
  --xcode     Sync to Xcode ClaudeAgentConfig

Options:
  --dry-run   Print actions without writing
  -h, --help  Show this help

Examples:
  ./adapters/install.sh
  ./adapters/install.sh --claude --cursor
  ./adapters/install.sh --dry-run
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cursor) TARGETS+=("cursor") ;;
    --claude) TARGETS+=("claude") ;;
    --hermes) TARGETS+=("hermes") ;;
    --xcode)  TARGETS+=("xcode") ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
  shift
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=("cursor" "claude" "hermes" "xcode")
fi

log "source: $VIBE_CODING_ROOT"
[[ "$DRY_RUN" == true ]] && log "mode: dry-run"

export DRY_RUN

for target in "${TARGETS[@]}"; do
  bash "$SCRIPT_DIR/${target}.sh"
done

log "done."
