# Token budget

Firstmate is correct about isolation and wrong about context.
A firstmate primary often pulls AGENTS.md + architecture + harness-adapters +
verification notes + a live pane dump. That is the opposite of AXI.

Orchäster treats tokens like rehearsal time: the conductor does not play
every part just to stay informed.

## Hard caps (this pane)

| Thing | Cap |
|---|---|
| Reply to captain | 15 lines unless they asked for a report |
| Scout/review summary | 15 lines + path to `data/reports/<id>.md` |
| Brief to a crewmate | ≤ 60 lines (`data/briefs/<id>.md`). Corpus stays on disk |
| Files the conductor may *read* per turn | `AGENTS.md`, `data/fleet.md`, `data/quota.md`, `config/quota.toml`, one skill, at most **one** JSON from crew-knowledge |
| Vendor pack | never slurp the tree. Open `task-classes.json` **or** `profiles.json` **or** `delegation.json` |
| Pane peek | last screen only. No full scrollback into this chat |
| GitHub | `gh-axi` / AXI TOON. Not `gh` JSON. Not MCP schemas |

If you need a second file from the pack, you already should have spawned.

## RLM vs stuffing vs compacting

```
small ask, known files     → cheap crewmate, no RLM
module / one feature       → Cursor on a lease (index is the memory)
bigger than a window       → RLM: corpus in REPL/files, cheap workers on slices
"summarize the repo first" → forbidden compact. That loses the middle.
```

RLM is always *available*. It is not always *cheaper*.
A rename does not need a REPL and three subcalls.
A 400-file audit does not belong in anyone's context window —
not the conductor's, not Cursor's, not Grok's.

Default for `infinite` / `VERY_HIGH` context: RLM.
Default for `VERY_LOW` / `LOW`: one cheap crewmate, tiny brief.
Never: paste the repo into this pane "so I have context".

## Why this beats Firstmate on tokens

1. Conductor tools are `orch-status`, `orch-send`, AXI. No composer scraping, no adapter novels.
2. Skills are pull, not preload. `/rlm` and `/axi` stay closed until the class needs them.
3. Crew-knowledge is tables, not prose in the system prompt.
4. Durable state is short markdown rows, not session transcripts.
5. Workers see a lease + a 60-line brief. They do not inherit the captain thread.
6. Quota bands pick *small* models for trivial work on purpose.
