#!/usr/bin/env bash
# vibe-coding: 安装并同步到 AI 编程工具.
#
# 用法:
#   ./adapters/install.sh              # 同步所有工具
#   ./adapters/install.sh --cursor     # 同步单个工具
#   ./adapters/install.sh --dry-run    # 仅预览

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

TARGETS=()

usage() {
  cat <<'EOF'
Usage: install.sh [OPTIONS] [TARGET...]

Targets (default: all):
  --antigravity Sync to ~/.gemini/config/ (Antigravity IDE)
  --claude      Sync to ~/.claude/ (with CLAUDE.md bridge)
  --codex       Sync to ~/.codex/
  --cursor      Sync to ~/.cursor/
  --hermes      Sync to ~/.hermes/skills/

Options:
  --dry-run   Print actions without writing
  -h, --help  Show this help

Examples:
  ./adapters/install.sh
  ./adapters/install.sh --antigravity
  ./adapters/install.sh --dry-run
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --antigravity) TARGETS+=("antigravity") ;;
    --claude) TARGETS+=("claude") ;;
    --codex)  TARGETS+=("codex") ;;
    --cursor) TARGETS+=("cursor") ;;
    --hermes) TARGETS+=("hermes") ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
  shift
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  TARGETS=("antigravity" "cursor" "claude" "codex" "hermes")
fi

log "source: $VIBE_CODING_ROOT"
[[ "$DRY_RUN" == true ]] && log "mode: dry-run"

export DRY_RUN

for target in "${TARGETS[@]}"; do
  bash "$SCRIPT_DIR/${target}.sh"
done

log "done."
