#!/usr/bin/env bash
# Attach or dump a pane. Prefer non-destructive capture when available.
# Usage: orch-peek.sh <pane-or-task-id>
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/orch-lib.sh"
require_herdr

target="${1:-}"
[[ -n "$target" ]] || { echo "usage: orch-peek.sh <pane-or-task-id>" >&2; exit 64; }

pane="$target"
if [[ "$target" == ship-* || "$target" == scout-* || "$target" == review-* || "$target" == local-* ]]; then
  pane="$(awk -F'|' -v id="$target" '$2 ~ id { gsub(/ /,"",$5); print $5; exit }' "$FLEET")"
  pane="${pane:-$target}"
fi

if herdr pane capture --help >/dev/null 2>&1; then
  herdr pane capture "$pane"
elif herdr agent get --help >/dev/null 2>&1; then
  herdr agent get "$pane"
else
  echo "orch-peek: attach manually with: herdr agent attach $pane" >&2
  exit 0
fi
