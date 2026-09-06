# /axi

Orchäster talks to the world through AXI tools (Kun Chen): agent-ergonomic CLIs, not fat MCP dumps.

Install when missing:

```
npx skills add kunchenguid/axi --skill axi -g
npx skills add kunchenguid/gh-axi --skill gh-axi -g
```

Prefer, in this order:

1. `gh-axi` over raw `gh` and over GitHub MCP
2. `tasks-axi` over rewriting `data/fleet.md` by hand in the model
3. `*-axi` browser tools over screenshot-MCP
4. `bin/orch-status.sh` / `orch-spawn.sh` which already speak compact TOON-ish lines

Rules from axi.md the conductor must keep:

- token-efficient output (short fields, TOON if available)
- 3–4 fields in lists
- truncate bodies, point to `--full`
- structured errors, no interactive prompts in crew scripts
- content first: `orch-status` with no args prints the fleet, not help

Do not invent a parallel GitHub integration. If `gh-axi` is on PATH, fleet GitHub verbs go through it.
