#!/usr/bin/env bash
# 将 vibe-coding 同步到 Hermes (~/.hermes/skills/), 并提示 external_dirs 配置.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SKILLS_SRC="$VIBE_CODING_ROOT/skills"
SKILLS_DST="$HERMES_HOME/skills"
CONFIG_FILE="$HERMES_HOME/config.yaml"

sync_hermes() {
  log "=== Hermes ==="
  ensure_dir "$HERMES_HOME"

  # 技能目录: 复制每个 skill 目录.
  copy_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  # 提示在配置中添加 external_dirs, 不修改配置文件.
  log "Hermes external_dirs (optional, add to $CONFIG_FILE):"
  log "  skills:"
  log "    external_dirs:"
  log "      - $SKILLS_SRC"

  if [[ -f "$CONFIG_FILE" ]] && grep -q "vibe-coding" "$CONFIG_FILE" 2>/dev/null; then
    log "external_dirs already references vibe-coding"
  else
    warn "add external_dirs manually if you prefer single source over copying into ~/.hermes/skills/"
  fi
}

sync_hermes
