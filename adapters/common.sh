#!/usr/bin/env bash
# vibe-coding 适配器: 共享 helper

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

# 复制 src 到 dst, 替换现有文件, 目录或符号链接.
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

# 向后兼容的别名.
link_path() {
  copy_path "$@"
}

# 将 src_dir 中包含 SKILL.md 的 skill 目录复制到 dst_parent, 使用扁平结构.
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

# 向后兼容的别名.
link_skill_dirs() {
  copy_skill_dirs "$@"
}

# 将 rules 目录扁平复制到 dst_rules_dir, 所有 .md 规则文件直接放入目标目录.
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

# 同步 rules/ 到 dst_rules 并保留子目录结构, 用于 Claude Code 和 Xcode Agent.
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

# 为 Claude Code 写入 CLAUDE.md 桥接文件, 因为它原生不读取 AGENTS.md.
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

# 根据 rules/manifest.yaml 和纯 Markdown 源文件生成 Cursor .mdc 文件.
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

# 展开 AGENTS.md 中的 @ 引用, 并为 Antigravity 自动包含 alwaysApply 规则.
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

# 同时检查 manifest.yaml 中 alwaysApply: true 的规则.
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

