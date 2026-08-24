#!/usr/bin/env bash
# 将 vibe-coding 同步到 Antigravity (~/.gemini/config/).

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

  # 技能目录: 将每个 skill 目录复制到 ~/.gemini/config/skills/.
  copy_skill_dirs "$SKILLS_SRC" "$SKILLS_DST"

  # 将 SKILLS_DST 中剩余的第三方符号链接转换为真实目录, 例如 superpowers skills.
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

  # AGENTS.md: 展开 @ 引用, 并自动包含 alwaysApply 规则.
  expand_antigravity_agents "$ANTIGRAVITY_HOME/AGENTS.md"

  # 规则目录: 将 rules 目录扁平复制到 ~/.gemini/config/rules/.
  copy_rules_dir "$ANTIGRAVITY_HOME/rules"

  log "Antigravity rules and skills deployed to $ANTIGRAVITY_HOME"
}

sync_antigravity
