#!/usr/bin/env bash
# Spawn a crewmate in Herdr.
# Usage:
#   orch-spawn.sh --class ship|scout|review|local \
#                  --ask "..." \
#                  [--repo /path] [--ref HEAD] [--harness grok|cursor|pi]
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/orch-lib.sh"
require_herdr

class=""
ask=""
repo=""
ref="HEAD"
harness_override=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --class) class="$2"; shift 2 ;;
    --ask) ask="$2"; shift 2 ;;
    --repo) repo="$2"; shift 2 ;;
    --ref) ref="$2"; shift 2 ;;
    --harness) harness_override="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
    *) echo "unknown arg: $1" >&2; exit 64 ;;
  esac
done

[[ -n "$class" && -n "$ask" ]] || { echo "orch-spawn: --class and --ask required" >&2; exit 64; }

case "$class" in
  ship|scout|review|local) ;;
  *) echo "orch-spawn: class must be ship|scout|review|local" >&2; exit 64 ;;
esac

if [[ "$class" == "local" ]]; then
  if ! grep -q 'enabled = true' "$ORCH_HOME/config/local-openai.toml"; then
    echo "orch-spawn: no enabled local endpoint in config/local-openai.toml" >&2
    exit 2
  fi
fi

id="$(next_id "$class")"
harness="${harness_override:-$(toml_get "$class" harness)}"
launch="$(toml_get "$class" launch)"
need_wt="$(toml_get "$class" worktree)"
worktree="—"

if [[ "${need_wt}" == "true" ]]; then
  if [[ -z "$repo" ]]; then
    echo "orch-spawn: class $class requires --repo" >&2
    exit 64
  fi
  worktree="$("$ORCH_HOME/bin/orch-worktree.sh" "$repo" "$id" "$ref")"
fi

ws_name="orch-${id}"
# Isolated child workspace; --no-focus keeps the captain pane.
if herdr workspace create --help 2>/dev/null | grep -q -- '--no-focus'; then
  herdr workspace create "$ws_name" --no-focus >/dev/null
else
  herdr workspace create "$ws_name" >/dev/null || true
fi

# Resolve a pane in the new workspace. Herdr labels vary by version;
# we create a tab/pane by running the harness there.
run_dir="$ORCH_HOME"
if [[ "$worktree" != "—" ]]; then
  run_dir="$worktree"
fi

# Start the harness in a new pane of the child workspace.
# `herdr pane run` is the portable "do this in a pane" verb.
pane_json="$(herdr pane run --workspace "$ws_name" --cwd "$run_dir" -- "$launch" 2>/dev/null || true)"
pane_id="$(printf '%s' "$pane_json" | jq -r '.pane_id // .id // empty' 2>/dev/null || true)"
if [[ -z "$pane_id" ]]; then
  # Fallback: list agents/panes and pick the newest in this workspace.
  pane_id="$(herdr pane list --json 2>/dev/null | jq -r --arg ws "$ws_name" '
    [.[] | select((.workspace // .workspace_id // .workspace_name // "") | tostring | test($ws))]
    | last | .pane_id // .id // empty
  ' || true)"
fi
pane_id="${pane_id:-$ws_name}"

brief_file="$ORCH_HOME/data/briefs/${id}.md"
mkdir -p "$ORCH_HOME/data/briefs" "$ORCH_HOME/data/reports"
cat > "$brief_file" <<EOF
# ${id}

You are a Orchäster crewmate. You report to Orchäster, not to the captain.
Task id: ${id}
Class: ${class}
Harness: ${harness}
Worktree: ${worktree}

## Ask
${ask}

## Done when
- ${class} = scout: write data/reports/${id}.md in the Orchäster home and stop. Do not change project code.
- ${class} = ship: implement in this worktree, tests green, do not open a PR.
- ${class} = review: write data/reports/${id}.md with findings; do not push.
- ${class} = local: stay on the local OpenAI-compatible endpoint only.

When finished, say: ORCH_DONE ${id}
If blocked on a captain decision, say: ORCH_BLOCKED ${id}: <one question>
EOF

# Give the TUI a moment to come up, then prompt.
sleep 1
if herdr agent prompt --help >/dev/null 2>&1; then
  herdr agent prompt "$pane_id" --input "$(cat "$brief_file")" >/dev/null 2>&1 || \
    herdr pane send_input "$pane_id" "$(cat "$brief_file")" >/dev/null 2>&1 || true
else
  herdr pane send_input "$pane_id" "$(cat "$brief_file")" >/dev/null 2>&1 || true
fi

append_fleet "$id" "$class" "$harness" "$pane_id" "$worktree" "running" "$ask"
log_event "spawned ${id} class=${class} harness=${harness} pane=${pane_id} worktree=${worktree}"

printf 'id=%s\nclass=%s\nharness=%s\npane=%s\nworktree=%s\nbrief=%s\n' \
  "$id" "$class" "$harness" "$pane_id" "$worktree" "$brief_file"
