# Architecture

Orchäster is a thin command layer on top of three things that already exist:

1. **Herdr** — persistent agent-aware terminals, pane state, `agent.prompt` / `agent.wait`
2. **Grok Build** — primary conversation + review fallback
3. **Cursor** — code intelligence + default ship/scout, always on a leased worktree
4. **Local workspaces** — captain checkouts in `config/workspaces.toml`, parallel-synced, never leased
5. **Pi** — local OpenAI-compatible APIs only

There is no daemon besides Herdr. Reconciliation is: read `data/fleet.md`, ask Herdr, update the file.

```
captain
   │  chat
   ▼
Grok Build  (primary pane, this repo, AGENTS.md)
   │  bin/orch-spawn.sh
   ▼
Herdr child workspace
   ├─ pane: Cursor   + git worktree   ship-*
   ├─ pane: Grok     + git worktree   scout-* / review-*
   └─ pane: Pi       + local API      local-*
```

## Why Herdr-native

Firstmate treats Herdr as one backend among several and still reasons about composer text, ghost placeholders, and process names. That matrix is how it stays portable. Orchäster drops portability on purpose.

Herdr already classifies `working` / `blocked` / `idle` for Grok CLI, Cursor Agent CLI, and Pi. The orchestrator should use that classification instead of scraping TUIs.

Implications:

- Spawn creates a Herdr workspace, not a tmux window.
- Steer uses `herdr agent prompt` (fallback: `pane send_input`).
- Liveness uses `herdr agent get` / `agent.wait`.
- Presentation: child workspaces with `--no-focus` so the captain pane does not jump.

If a Herdr verb is missing on an older build, the `bin/orch-*.sh` scripts degrade to list/get/send. Raise Herdr rather than adding tmux.

## Filesystem is the control plane

| Path | Role |
|---|---|
| `AGENTS.md` | Role + hard rules |
| `config/dispatch.toml` | Which harness owns which class |
| `config/local-openai.toml` | Pi endpoints |
| `data/fleet.md` | Source of truth for tasks |
| `data/briefs/<id>.md` | What the crewmate was told |
| `data/reports/<id>.md` | Scout/review output |
| `data/captain.md` | Standing preferences |
| `data/projects.md` | Repos Orchäster may dispatch into |

Conversation is not state. If Herdr restarts, Orchäster rereads these files and `herdr agent list`.

## Worktrees

`bin/orch-worktree.sh` creates `<repo-parent>/<repo>.orch/<task-id>` on branch `orch/<task-id>`.

Two ships on the same repo never share a checkout. Promoting scout → ship creates a new worktree from the scout's ref if the captain wants the investigation carried forward; it does not reuse the scout pane.

## Review gate

A `ship` is not "ready" when the author says so. A `review-*` task must write `data/reports/review-*.md` with either `CLEAN` or a finding list. Orchäster reports that to the captain. Push/PR stays a captain-approved one-shot (hard rule 1).

## What Orchäster is not

- Not a hosted Firstmate / Grok Bot factory
- Not a replacement for Herdr, Grok Build, or Cursor
- Not a general agent framework
- Not multi-host secondmates (add later if you need them; Herdr SSH attach is enough for v1)
