# Local workspaces + Firstmate worktrees + Cursor intelligence

This is the part Firstmate gets half-right and Cursor gets the other half-right.

## The split

| Layer | Owner | Rule |
|---|---|---|
| Local workspace | you | The checkout you type in. Never leased. Always present. |
| Task worktree | Orchäster | Disposable sibling, like Firstmate/treehouse. One crewmate, one lease. |
| Cursor index | Cursor | Built **on the worktree**, so intelligence sees the task branch, not a dirty mix of two ships. |
| Remotes | `orch-sync` | Parallel fetch/push across the workspace set. Sync is not the work. |

You do not "clone for each task from GitHub". You already have the repos locally and keep several of them in lockstep. Crew work forks *beside* that, not instead of it.

```
~/src/app/                 ← workspace (yours, dirty is fine)
~/src/app.orch/ship-003/  ← lease (crew only, branch orch/ship-003)
~/src/api/                 ← sibling workspace
~/src/api.orch/ship-003/  ← same task id if the ship crosses repos
```

Same task id across siblings = one logical ship, two isolated trees. That is how parallel-sync products move without colliding.

## Why Cursor on the worktree, not the workspace

Cursor's value is the index, rules, semantic search, and the Grok model sitting on a coherent tree. If two agents edit the same workspace, the index lies.

So:

- Captain IDE may stay on `path` (the workspace).
- Ship/scout/review agents get `cursor` / `agent` launched with `--cwd` = worktree.
- Optional: `cursor <worktree>` so you can *look* at the intelligence surface without typing in the crew pane.
- `.cursor/rules`, `.cursor/hooks.json`, and repo `AGENTS.md` are copied or linked into the worktree at lease time if they exist on the workspace (git already carries tracked ones; untracked local rules get a symlink).

Scout that needs "where is X handled?" goes through Cursor on a *read-only* worktree at current HEAD — not through Grok grepping blind. That is the intelligence upgrade versus Firstmate.

## Parallel sync

`bin/orch-sync.sh` walks `config/workspaces.toml` and for each workspace, in parallel:

1. `git fetch --all --prune` on every listed remote
2. reports ahead/behind of the workspace branch vs its upstream
3. does **not** merge, rebase, stash, or reset the workspace
4. optionally fast-forwards a worktree only if it is clean and the captain passed `--ff-worktrees`

Workspace dirt stays yours. Sync is information plus fetch. Promote/land stays a captain one-shot.

## Lease lifecycle (Firstmate-shaped)

1. Resolve workspace by name or path from `workspaces.toml`.
2. Create `worktree_root/<task-id>` on `orch/<task-id>` from workspace HEAD (not from remote tip, unless `--from origin/main`).
3. Link local Cursor rules if missing in git.
4. Spawn Cursor agent in that tree.
5. On `done` + clean review: captain lands (merge/PR). Then `git worktree remove`.
6. On `dead`/`cancelled`: remove worktree, keep the branch until captain deletes it.

Never two live leases on the same `worktree_root/<id>`. Never a lease whose path equals `workspace.path`.
