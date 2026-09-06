# Herdr

Orchäster assumes it is running *inside* Herdr.

Injected into every pane (Herdr 0.7.5+):

- `HERDR_ENV=1`
- `HERDR_PANE_ID`
- `HERDR_WORKSPACE_ID`
- `HERDR_TAB_ID`
- `HERDR_SESSION`
- `HERDR_SOCKET_PATH`

`bin/orch-lib.sh` refuses to spawn if those are missing. Start `herdr` first, then `grok --trust` in the pane.

## Verbs Orchäster uses

```
herdr workspace create <name> --no-focus
herdr pane run --workspace <name> --cwd <dir> -- <cmd>
herdr pane list --json
herdr agent list [--json]
herdr agent get <pane>
herdr agent prompt <pane> --input "..."
herdr agent wait <pane> --until done|blocked|idle
herdr pane send_input <pane> "..."     # fallback
herdr agent attach <pane>              # captain only, rare
herdr agent explain <pane>             # detection debug
```

Exact flags drift across Herdr minors. Scripts probe `--help` and degrade.

Protocol floor: 14 (see Firstmate's verification notes). Presentation spaces / `--no-focus` need a current Herdr (0.8+ is comfortable).

## Layout convention

- Captain / Orchäster primary: the workspace you launched in. Do not recycle it for crew.
- Each task: workspace `orch-<task-id>`, one agent pane, optional scratch pane later.
- Never `herdr server stop` as a cleanup step.

## Integrations worth installing

```
herdr integration install grok      # if offered
herdr integration install cursor
herdr integration install pi
```

Hooks beat screen manifests when both exist. Orchäster does not ship Herdr plugins in v1; add one only if `agent.prompt` is not enough.
