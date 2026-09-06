#!/usr/bin/env bash
# Wait until a pane agent reaches a state.
# Usage: orch-wait.sh <pane-or-task-id> [done|blocked|idle] [timeout_sec]
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/orch-lib.sh"
require_herdr

target="${1:-}"
until="${2:-done}"
timeout="${3:-600}"
[[ -n "$target" ]] || { echo "usage: orch-wait.sh <pane-or-task-id> [done|blocked|idle] [timeout_sec]" >&2; exit 64; }

pane="$target"
if [[ "$target" == ship-* || "$target" == scout-* || "$target" == review-* || "$target" == local-* ]]; then
  pane="$(awk -F'|' -v id="$target" '$2 ~ id { gsub(/ /,"",$5); print $5; exit }' "$FLEET")"
  pane="${pane:-$target}"
fi

if herdr agent wait --help >/dev/null 2>&1; then
  herdr agent wait "$pane" --until "$until" --timeout-ms "$((timeout * 1000))"
else
  end=$((SECONDS + timeout))
  while (( SECONDS < end )); do
    state="$(herdr agent get "$pane" --json 2>/dev/null | jq -r '.status // .agent_status // empty' || true)"
    [[ "$state" == "$until" ]] && exit 0
    sleep 3
  done
  echo "orch-wait: timeout waiting for $pane -> $until" >&2
  exit 1
fi
