#!/usr/bin/env bash
# Parallel fetch across local workspaces. Does not merge your checkouts.
# Usage: orch-sync.sh [--ff-worktrees]
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/orch-lib.sh"
need git
need python3

ff=0
[[ "${1:-}" == "--ff-worktrees" ]] && ff=1

python3 - "$ORCH_HOME/config/workspaces.toml" "$ff" <<'PY'
import os, re, subprocess, sys
from concurrent.futures import ThreadPoolExecutor, as_completed

toml, ff = sys.argv[1], sys.argv[2] == "1"
blocks = open(toml).read().split("[[workspace]]")[1:]

def get(block, name, default=""):
    m = re.search(rf'^{name}\s*=\s*"(.*)"', block, re.M)
    if m: return m.group(1)
    m = re.search(rf'^{name}\s*=\s*\[(.*)\]', block, re.M)
    if m:
        return [x.strip().strip('"') for x in m.group(1).split(",") if x.strip()]
    return default

jobs = []
for b in blocks:
    path = get(b, "path")
    name = get(b, "name") or os.path.basename(path)
    remotes = get(b, "remotes") or ["origin"]
    if isinstance(remotes, str): remotes = [remotes]
    wt = get(b, "worktree_root") or (path + ".orch" if path else "")
    if path: jobs.append((name, path, remotes, wt))

def run(name, path, remotes, wt):
    if not os.path.isdir(path):
        return name, f"MISSING {path}"
    lines = [name]
    for r in remotes:
        p = subprocess.run(["git","-C",path,"fetch",r,"--prune"], capture_output=True, text=True)
        if p.returncode != 0:
            lines.append(f"  fetch {r}: FAIL {p.stderr.strip()[:120]}")
        else:
            lines.append(f"  fetch {r}: ok")
    st = subprocess.run(["git","-C",path,"status","-sb"], capture_output=True, text=True)
    lines.append("  workspace: " + (st.stdout.splitlines() or ["?"])[0])
    if ff and wt and os.path.isdir(wt):
        for d in sorted(os.listdir(wt)):
            tree = os.path.join(wt, d)
            if not os.path.isdir(os.path.join(tree, ".git")) and not os.path.isfile(os.path.join(tree, ".git")):
                continue
            dirty = subprocess.run(["git","-C",tree,"status","--porcelain"], capture_output=True, text=True)
            if dirty.stdout.strip():
                lines.append(f"  worktree {d}: dirty, skip ff")
                continue
            subprocess.run(["git","-C",tree,"merge","--ff-only"], capture_output=True, text=True)
            lines.append(f"  worktree {d}: ff attempted")
    return name, "\n".join(lines)

print("== orch-sync ==")
with ThreadPoolExecutor(max_workers=max(1, len(jobs))) as ex:
    futs = [ex.submit(run, *j) for j in jobs]
    for f in as_completed(futs):
        _, text = f.result()
        print(text)
        print()
PY
