# /scout

Investigation, plan, or audit. No PR.

1. Resolve the workspace from `config/workspaces.toml`. Never scout in the captain checkout.
2. Spawn with `bin/orch-spawn.sh --class scout --repo <workspace-path> --ask "..."`.
3. Cursor on that leased worktree is the intelligence layer. Grok is fallback only.
4. Done definition is always: report at `data/reports/<id>.md`.
3. When the crewmate is idle/done, read that report and summarize it for the captain in under 15 lines.
4. Promoting a scout to a ship is a new task id, not a reuse of the scout pane.
