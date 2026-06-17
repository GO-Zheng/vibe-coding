#!/usr/bin/env bash
# Archive Cursor agent-transcript JSONL to Markdown (plain + with-tools).
#
# Usage:
#   archive-cursor-session.sh REPO STEP SLUG [--session-id UUID] [--project ID]
#
# Examples:
#   archive-cursor-session.sh aidb 01 engine
#   archive-cursor-session.sh aidb 01 engine --session-id 992353ef-7ecc-47ce-8d74-2f8ad1b253d6
#   archive-cursor-session.sh aikv 03 protocol --project root-code-database
#
# Output (under database/REPO/archive/):
#   {STEP}-{SLUG}.md
#   tools/{STEP}-{SLUG}-with-tools.md
#   {STEP}-{SLUG}.meta.json   (session id, paths, timestamp)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATABASE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONVERTER="$SCRIPT_DIR/cursor-transcript-to-md.py"
PROJECT_ID="${CURSOR_PROJECT_ID:-root-code-database}"
TRANSCRIPTS_ROOT="${CURSOR_TRANSCRIPTS_ROOT:-$HOME/.cursor/projects/$PROJECT_ID/agent-transcripts}"

usage() {
  sed -n '3,15p' "$0" | sed 's/^# \?//'
  exit "${1:-0}"
}

if [[ $# -lt 3 ]]; then
  usage 1
fi

REPO="$1"
STEP="$2"
SLUG="$3"
shift 3

SESSION_ID=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --session-id)
      SESSION_ID="$2"
      shift 2
      ;;
    --project)
      PROJECT_ID="$2"
      TRANSCRIPTS_ROOT="$HOME/.cursor/projects/$PROJECT_ID/agent-transcripts"
      shift 2
      ;;
    -h|--help)
      usage 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage 1
      ;;
  esac
done

case "$REPO" in
  aidb|aikv) ;;
  *)
    echo "error: REPO must be aidb or aikv, got: $REPO" >&2
    exit 1
    ;;
esac

STEP="$(printf '%02d' "$((10#$STEP))")"
REPO_ROOT="$DATABASE_ROOT/$REPO"
ARCHIVE_DIR="$REPO_ROOT/archive"
TOOLS_DIR="$ARCHIVE_DIR/tools"

if [[ ! -d "$REPO_ROOT" ]]; then
  echo "error: repo not found: $REPO_ROOT" >&2
  exit 1
fi

if [[ ! -x "$CONVERTER" && ! -f "$CONVERTER" ]]; then
  echo "error: converter not found: $CONVERTER" >&2
  exit 1
fi

find_jsonl() {
  if [[ -n "$SESSION_ID" ]]; then
    local path="$TRANSCRIPTS_ROOT/$SESSION_ID/$SESSION_ID.jsonl"
    if [[ -f "$path" ]]; then
      echo "$path"
      return 0
    fi
    echo "error: transcript not found for session $SESSION_ID" >&2
    echo "  expected: $path" >&2
    return 1
  fi

  local latest
  latest="$(find "$TRANSCRIPTS_ROOT" -name '*.jsonl' ! -path '*/subagents/*' -printf '%T@ %p\n' 2>/dev/null \
    | sort -rn | head -1 | cut -d' ' -f2-)"
  if [[ -z "$latest" ]]; then
    echo "error: no jsonl under $TRANSCRIPTS_ROOT" >&2
    return 1
  fi
  echo "$latest"
}

JSONL="$(find_jsonl)"
SESSION_ID="${SESSION_ID:-$(basename "$(dirname "$JSONL")")}"

PLAIN_OUT="$ARCHIVE_DIR/${STEP}-${SLUG}.md"
TOOLS_OUT="$TOOLS_DIR/${STEP}-${SLUG}-with-tools.md"
META_OUT="$ARCHIVE_DIR/${STEP}-${SLUG}.meta.json"

mkdir -p "$ARCHIVE_DIR" "$TOOLS_DIR"

python3 "$CONVERTER" "$JSONL" -o "$PLAIN_OUT"
python3 "$CONVERTER" "$JSONL" -o "$TOOLS_OUT" --tools

EXPORTED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
cat > "$META_OUT" <<EOF
{
  "sessionId": "$SESSION_ID",
  "projectId": "$PROJECT_ID",
  "progressStep": "$STEP",
  "slug": "$SLUG",
  "repo": "$REPO",
  "jsonl": "$JSONL",
  "plainMd": "$PLAIN_OUT",
  "toolsMd": "$TOOLS_OUT",
  "exportedAt": "$EXPORTED_AT"
}
EOF

echo "archived session $SESSION_ID"
echo "  plain: $PLAIN_OUT"
echo "  tools: $TOOLS_OUT"
echo "  meta:  $META_OUT"
