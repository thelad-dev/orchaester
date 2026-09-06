#!/usr/bin/env bash
# Send text to a crewmate pane.
# Usage: orch-send.sh <pane-or-task-id> <text>
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/orch-lib.sh"
require_herdr

target="${1:-}"
shift || true
text="${*:-}"
[[ -n "$target" && -n "$text" ]] || { echo "usage: orch-send.sh <pane-or-task-id> <text>" >&2; exit 64; }

pane="$target"
if [[ "$target" == ship-* || "$target" == scout-* || "$target" == review-* || "$target" == local-* ]]; then
  pane="$(awk -F'|' -v id="$target" '$2 ~ id { gsub(/ /,"",$5); print $5; exit }' "$FLEET")"
  pane="${pane:-$target}"
fi

if herdr agent prompt --help >/dev/null 2>&1; then
  herdr agent prompt "$pane" --input "$text"
else
  herdr pane send_input "$pane" "$text"
fi
log_event "send $pane :: ${text:0:120}"
