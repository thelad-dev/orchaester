#!/usr/bin/env bash
# Lease inside the workspace: <workspace>/orch/<task-id>
# Usage: orch-worktree.sh <workspace-path-or-name> <task-id> [ref]
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/orch-lib.sh"

want="${1:-}"
task_id="${2:-}"
ref="${3:-}"

if [[ -z "$want" || -z "$task_id" ]]; then
  echo "usage: orch-worktree.sh <workspace-path-or-name> <task-id> [ref]" >&2
  exit 64
fi

toml="$ORCH_HOME/config/workspaces.toml"
repo=""
wt_root=""

if [[ -d "$want/.git" || -f "$want/.git" ]]; then
  repo="$(cd "$want" && pwd)"
fi

if [[ -z "$repo" && -f "$toml" ]]; then
  mapped="$(python3 - "$toml" "$want" <<'PY'
import sys, re
toml, key = sys.argv[1], sys.argv[2]
text = open(toml).read().split("[[workspace]]")
for block in text[1:]:
    def get(name):
        m = re.search(rf'^{name}\s*=\s*"(.*)"', block, re.M)
        return m.group(1) if m else ""
    if get("name") == key or get("path") == key:
        print(get("path") + "\t" + get("worktree_root"))
        break
PY
)"
  repo="${mapped%%$'\t'*}"
  wt_root="${mapped#*$'\t'}"
fi

if [[ -z "$repo" || ! -e "$repo/.git" ]]; then
  echo "orch: not a registered workspace or git repo: $want" >&2
  exit 2
fi

root="$(cd "$repo" && git rev-parse --show-toplevel)"
if [[ -z "$wt_root" ]]; then
  wt_root="${root}/orch"
fi
# never lease the workspace root itself
mkdir -p "$wt_root"
if [[ ! -f "$root/.gitignore" ]] || ! grep -qx 'orch/' "$root/.gitignore" 2>/dev/null; then
  printf '\n# Orchäster leases\norch/\n' >> "$root/.gitignore" || true
fi
dest="${wt_root}/${task_id}"
branch="orch/${task_id}"
base="${ref:-HEAD}"

if [[ "$dest" == "$root" ]]; then
  echo "orch: worktree must not be the workspace path" >&2
  exit 2
fi

mkdir -p "$wt_root"
if [[ -d "$dest" ]]; then
  echo "$dest"
  exit 0
fi

git -C "$root" worktree add -B "$branch" "$dest" "$base"

for rel in .cursor/rules .cursor/hooks.json .cursorrules; do
  src="$root/$rel"
  dst="$dest/$rel"
  if [[ -e "$src" && ! -e "$dst" ]]; then
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst" 2>/dev/null || cp -a "$src" "$dst"
  fi
done

echo "$dest"
