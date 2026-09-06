#!/usr/bin/env bash
# Print fleet table plus live Herdr agent states.
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/orch-lib.sh"
require_herdr

echo "== fleet (disk) =="
sed -n '1,80p' "$FLEET"
echo
echo "== herdr agents (live) =="
if herdr agent list --json >/dev/null 2>&1; then
  herdr agent list --json | jq -r '
    def row: "\(.agent // "-")\t\(.status // .agent_status // "-")\t\(.pane_id // .pane // "-")\t\(.workspace_id // .workspace // "-")";
    if type=="array" then .[] | row
    elif .agents then .agents[] | row
    else row end
  ' 2>/dev/null || herdr agent list
else
  herdr agent list
fi
