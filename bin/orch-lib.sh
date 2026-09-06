#!/usr/bin/env bash
# Shared helpers. Sourced by other bin/* scripts. Not executed directly.
set -euo pipefail

ORCH_HOME="${ORCH_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
FLEET="$ORCH_HOME/data/fleet.md"
DISPATCH="$ORCH_HOME/config/dispatch.toml"
BACKEND="$(tr -d '[:space:]' < "$ORCH_HOME/config/backend" 2>/dev/null || echo herdr)"

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "orch: missing dependency: $1" >&2; exit 127; }
}

require_herdr() {
  need herdr
  need jq
  if [[ "${BACKEND}" != "herdr" ]]; then
    echo "orch: backend is '${BACKEND}', expected herdr" >&2
    exit 2
  fi
  if [[ "${HERDR_ENV:-}" != "1" && -z "${HERDR_SOCKET_PATH:-}" ]]; then
    echo "orch: not inside a Herdr pane (HERDR_ENV/HERDR_SOCKET_PATH unset)." >&2
    echo "       start herdr, then run the primary as: grok --trust" >&2
    exit 2
  fi
}

next_id() {
  local class="$1"
  local prefix
  case "$class" in
    ship) prefix=ship ;;
    scout) prefix=scout ;;
    review) prefix=review ;;
    local) prefix=local ;;
    *) prefix=task ;;
  esac
  local n
  n="$(grep -oE "${prefix}-[0-9]+" "$FLEET" 2>/dev/null | sed "s/${prefix}-//" | sort -n | tail -1 || true)"
  n="${n:-0}"
  printf "%s-%03d" "$prefix" "$((10#$n + 1))"
}

toml_get() {
  # tiny section.key reader. good enough for our flat dispatch file.
  local section="$1" key="$2"
  awk -v s="[$section]" -v k="$key" '
    $0 == s { on=1; next }
    /^\[/ { on=0 }
    on && $0 ~ "^"k"[[:space:]]*=" {
      sub(/^[^=]+=[[:space:]]*/, "")
      gsub(/^"/, ""); gsub(/"$/, "")
      print; exit
    }
  ' "$DISPATCH"
}

harness_cmd() {
  local class="$1"
  toml_get "$class" launch
}

append_fleet() {
  local id="$1" class="$2" harness="$3" pane="$4" worktree="$5" status="$6" ask="$7"
  local safe_ask
  safe_ask="$(printf '%s' "$ask" | tr '|' '/' | tr '\n' ' ')"
  # replace the placeholder empty row if present
  if grep -q '| _empty_ ' "$FLEET"; then
    sed -i '/| _empty_ /d' "$FLEET"
  fi
  printf '| %s | %s | %s | %s | %s | %s | %s |\n' \
    "$id" "$class" "$harness" "$pane" "$worktree" "$status" "$safe_ask" >> "$FLEET"
}

log_event() {
  mkdir -p "$ORCH_HOME/data"
  {
    echo
    echo "## $(date -Iseconds 2>/dev/null || date)"
    echo "- $*"
  } >> "$ORCH_HOME/data/log.md"
}
