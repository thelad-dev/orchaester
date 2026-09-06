# /crew-knowledge

Pack: `vendor/firstmate-crew-knowledge`. Open at most one JSON (`task-classes` / `profiles` / `delegation`). Never slurp the tree into this pane.

Authority stays with Orchäster spawn, not with the pack.

1. Delegation-first — if a worker can do it, brief and `orch-spawn`. Do not analyze first.
2. Context class from `knowledge/delegation.json` (`VERY_LOW`…`VERY_HIGH`).
3. Microtask only with a complete context pack (`knowledge/context-pack.json`).
4. Match `knowledge/task-classes.json` → `profiles.json` → `{harness, model, effort}`.
5. If quota is close, prefer `quota-axi` (AXI) over inventing a second meter.
6. Hand concrete flags to `bin/orch-spawn.sh`. This skill does not spawn.

Symlink created by `orch-setup.sh`: `knowledge/firstmate-crew-knowledge` → `vendor/…`.
