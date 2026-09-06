# /ship

Turn the current ask into a `ship` task.

1. Confirm repo (from `data/projects.md` or the path the captain named).
2. Confirm done-definition in one sentence. If missing, ask once.
3. `bin/orch-spawn.sh --class ship --repo <path> --ask "<ask + done-definition>"`
4. Tell the captain the task id, pane, branch `orch/<id>`, and that review still stands unless waived.

Cursor is the default ship harness. If spawn reports the binary missing, retry with `--harness grok`.
Never mark a ship `done` until tests in the worktree have been run by the crewmate.
