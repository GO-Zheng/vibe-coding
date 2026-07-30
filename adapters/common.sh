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

# Copy src -> dst (replaces existing file/dir or symlink).
copy_path() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    warn "source missing, skip: $src"
    return 0
  fi

  ensure_dir "$(dirname "$dst")"

  if [[ "$DRY_RUN" == true ]]; then
    log "[dry-run] copy $src -> $dst"
    return 0
  fi

  if [[ -L "$dst" ]]; then
    rm -f "$dst"
  fi

  if [[ -d "$src" ]]; then
    rm -rf "$dst"
    cp -r "$src" "$dst"
    log "copied dir: $src -> $dst"
  else
    cp "$src" "$dst"
    log "copied file: $src -> $dst"
  fi
}

# Alias for backward compatibility
link_path() {
  copy_path "$@"
}

# Copy each skill directory (containing SKILL.md) in src_dir into dst_parent (flat structure)
copy_skill_dirs() {
  local src_dir="$1"
  local dst_parent="$2"

  ensure_dir "$dst_parent"

  if [[ ! -d "$src_dir" ]]; then
    warn "skills dir missing: $src_dir"
    return 0
  fi

  local found=false
  while IFS= read -r -d '' skill_file; do
    found=true
    local skill_dir
    skill_dir="$(dirname "$skill_file")"
    local name
    name="$(basename "$skill_dir")"
    copy_path "$skill_dir" "${dst_parent%/}/$name"
  done < <(find "$src_dir" -type f -name 'SKILL.md' -print0 | sort -z)

  if [[ "$found" == false ]]; then
    log "no skills with SKILL.md found in $src_dir"
  fi
}

# Alias for backward compatibility
link_skill_dirs() {
  copy_skill_dirs "$@"
}

# Copy rules directory flatly to dst_rules_dir (all .md rule files placed directly in dst_rules_dir)
copy_rules_dir() {
  local dst_rules="$1"
  local src_rules="$VIBE_CODING_ROOT/rules"

  if [[ ! -d "$src_rules" ]]; then
    warn "rules dir missing: $src_rules"
    return 0
  fi

  ensure_dir "$dst_rules"

  while IFS= read -r -d '' file; do
    local base
    base="$(basename "$file")"
    copy_path "$file" "${dst_rules%/}/$base"
  done < <(find "$src_rules" -type f -name '*.md' -not -path "$src_rules/README.md" -print0 | sort -z)

  log "rules deployed flatly -> $dst_rules"
}

# Sync rules/ to dst_rules preserving subdirectory structure (for Claude Code & Xcode Agent)
sync_claude_rules() {
  local dst_rules="${1:-${CLAUDE_HOME:-$HOME/.claude}/rules}"
  local src_rules="$VIBE_CODING_ROOT/rules"

  if [[ ! -d "$src_rules" ]]; then
    warn "rules dir missing: $src_rules"
    return 0
  fi

  ensure_dir "$dst_rules"

  while IFS= read -r -d '' file; do
    local rel="${file#$src_rules/}"
    copy_path "$file" "$dst_rules/$rel"
  done < <(find "$src_rules" -type f -name '*.md' -not -path "$src_rules/README.md" -print0 | sort -z)

  log "rules synced with directory structure -> $dst_rules"
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

# Expand @references in AGENTS.md and auto-include alwaysApply rules for Antigravity
expand_antigravity_agents() {
  local src_agents="$VIBE_CODING_ROOT/AGENTS.md"
  local manifest="$VIBE_CODING_ROOT/rules/manifest.yaml"
  local rules_root="$VIBE_CODING_ROOT/rules"
  local dst_agents="${1:-$HOME/.gemini/config/AGENTS.md}"

  if [[ ! -f "$src_agents" ]]; then
    warn "src AGENTS.md missing: $src_agents"
    return 0
  fi

  ensure_dir "$(dirname "$dst_agents")"

  if [[ "$DRY_RUN" == true ]]; then
    log "[dry-run] expand $src_agents -> $dst_agents"
    return 0
  fi

  python3 - "$src_agents" "$manifest" "$rules_root" "$dst_agents" <<'PY'
import sys, os, re

src_agents, manifest, rules_root, dst_agents = sys.argv[1:5]
root_dir = os.path.dirname(os.path.abspath(src_agents))

def find_rule_file(ref_path):
    candidate = os.path.join(root_dir, ref_path)
    if os.path.isfile(candidate):
        return candidate
    candidate = os.path.join(rules_root, ref_path)
    if os.path.isfile(candidate):
        return candidate
    basename = os.path.basename(ref_path)
    if os.path.isdir(rules_root):
        for r, _, files in os.walk(rules_root):
            if basename in files:
                return os.path.join(r, basename)
    return None

expanded_files = set()
out_lines = []

with open(src_agents, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for line in lines:
    stripped = line.strip()
    if stripped.startswith('@'):
        ref = stripped[1:].strip()
        found = find_rule_file(ref)
        if found:
            expanded_files.add(os.path.abspath(found))
            with open(found, 'r', encoding='utf-8') as rf:
                out_lines.append(f"<!-- Expanded from {ref} -->\n")
                out_lines.append(rf.read().rstrip() + "\n\n")
            continue
        else:
            print(f"[vibe-coding] WARN: @ reference not found: {ref}", file=sys.stderr)
    out_lines.append(line)

# Also check manifest.yaml for alwaysApply: true rules
if os.path.isfile(manifest):
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
        if e.get("alwaysApply", "").lower() == "true":
            src = os.path.join(rules_root, e["source"])
            abs_src = os.path.abspath(src)
            if abs_src not in expanded_files and os.path.isfile(abs_src):
                expanded_files.add(abs_src)
                with open(abs_src, 'r', encoding='utf-8') as rf:
                    out_lines.append(f"\n<!-- Auto-included alwaysApply rule: {e['source']} -->\n")
                    out_lines.append(rf.read().rstrip() + "\n\n")

with open(dst_agents, 'w', encoding='utf-8') as f:
    f.writelines(out_lines)

print(f"[vibe-coding] expanded AGENTS.md -> {dst_agents}")
PY
}

