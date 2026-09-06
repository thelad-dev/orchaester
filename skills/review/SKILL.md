# /review

Adversarial read of a ship.

1. Need a ship id or a worktree/branch.
2. Pick a harness *other* than the author when `config/dispatch.toml` allows it.
3. `bin/orch-spawn.sh --class review --repo <path> --ask "review branch orch/<ship-id> …"`
4. Reviewer writes `data/reports/<review-id>.md`.
5. Only after a clean review may you tell the captain the ship is ready to PR / merge.
   Orchäster itself does not push or open the PR unless the captain explicitly orders that one-shot.
