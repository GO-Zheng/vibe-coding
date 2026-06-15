#!/usr/bin/env bash
# vibe-coding adapters — shared helpers

set -euo pipefail

VIBE_CODING_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log()  { echo "[vibe-coding] $*"; }
warn() { echo "[vibe-coding] WARN: $*" >&2; }
die()  { echo "[vibe-coding] ERROR: $*" >&2; exit 1; }

DRY_RUN="${DRY_RUN:-false}"

ensure_dir() {
  local dir="$1"
  if [[ "$DRY_RUN" == true ]]; then
    log "[dry-run] mkdir -p $dir"
  else
    mkdir -p "$dir"
  fi
}

# Symlink src -> dst. Replaces existing symlink; skips if real file differs.
link_path() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    warn "source missing, skip: $src"
    return 0
  fi

  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      log "already linked: $dst"
      return 0
    fi
  elif [[ -e "$dst" ]]; then
    warn "dst exists and is not a symlink, skip: $dst"
    return 0
  fi

  ensure_dir "$(dirname "$dst")"
  if [[ "$DRY_RUN" == true ]]; then
    log "[dry-run] ln -sf $src $dst"
  else
    ln -sf "$src" "$dst"
    log "linked: $dst -> $src"
  fi
}

# Symlink each child directory in src_dir into dst_parent
link_skill_dirs() {
  local src_dir="$1"
  local dst_parent="$2"

  ensure_dir "$dst_parent"

  if [[ ! -d "$src_dir" ]]; then
    warn "skills dir missing: $src_dir"
    return 0
  fi

  local found=false
  for skill_dir in "$src_dir"/*/; do
    [[ -d "$skill_dir" ]] || continue
    [[ -f "${skill_dir}SKILL.md" ]] || continue
    found=true
    local name
    name="$(basename "$skill_dir")"
    link_path "$skill_dir" "${dst_parent%/}/$name"
  done

  if [[ "$found" == false ]]; then
    log "no skills with SKILL.md yet in $src_dir (expected after phase 2)"
  fi
}

# Write CLAUDE.md bridge for Claude Code (does not natively read AGENTS.md)
write_claude_bridge() {
  local target_dir="$1"
  local bridge_file="${target_dir%/}/CLAUDE.md"
  local content="@AGENTS.md
"

  if [[ "$DRY_RUN" == true ]]; then
    log "[dry-run] write $bridge_file"
    return 0
  fi

  ensure_dir "$target_dir"
  if [[ -f "$bridge_file" ]] && ! grep -q '@AGENTS.md' "$bridge_file" 2>/dev/null; then
    warn "CLAUDE.md exists with custom content, skip overwrite: $bridge_file"
    return 0
  fi

  printf '%s' "$content" > "$bridge_file"
  log "wrote Claude bridge: $bridge_file"
}

# Generate Cursor .mdc files from rules/manifest.yaml + pure Markdown sources
generate_cursor_rules() {
  local manifest="$VIBE_CODING_ROOT/rules/manifest.yaml"
  local rules_root="$VIBE_CODING_ROOT/rules"
  local dst="${CURSOR_HOME:-$HOME/.cursor}/rules"

  if [[ ! -f "$manifest" ]]; then
    warn "rules manifest missing: $manifest"
    return 0
  fi

  ensure_dir "$dst"

  if [[ "$DRY_RUN" == true ]]; then
    log "[dry-run] generate Cursor rules from $manifest -> $dst"
  fi

  python3 - "$manifest" "$rules_root" "$dst" "$DRY_RUN" <<'PY'
import sys, os

manifest, rules_root, dst, dry_run = sys.argv[1:5]
dry = dry_run.lower() == "true"

entries = []
entry = None
for raw in open(manifest, encoding="utf-8"):
    line = raw.strip()
    if not line or line.startswith("#"):
        continue
    if line == "rules:":
        continue
    if line.startswith("- source:"):
        if entry:
            entries.append(entry)
        entry = {"source": line.split(":", 1)[1].strip()}
        continue
    if entry is not None and ":" in line:
        key, val = line.split(":", 1)
        entry[key.strip()] = val.strip()
if entry:
    entries.append(entry)

for e in entries:
    src = os.path.join(rules_root, e["source"])
    if not os.path.isfile(src):
        print(f"[vibe-coding] WARN: rule source missing: {src}", file=sys.stderr)
        continue
    base = e["source"].replace("/", "-").removesuffix(".md")
    out = os.path.join(dst, f"{base}.mdc")
    body = open(src, encoding="utf-8").read()
    lines = ["---", f"description: {e.get('description', base)}"]
    if e.get("alwaysApply", "").lower() == "true":
        lines.append("alwaysApply: true")
    if "globs" in e:
        lines.append(f"globs: {e['globs']}")
    lines.append("---")
    lines.append("")
    content = "\n".join(lines) + body
    if dry:
        print(f"[vibe-coding] [dry-run] write {out}")
    else:
        with open(out, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[vibe-coding] wrote {out}")
PY
}
