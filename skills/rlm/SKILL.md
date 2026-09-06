# /rlm

Recursive Language Model is a **base feature** — always *ready*, not always *on*.

Use it when the corpus would not fit a clean window (repo-QA, log archaeology, multi-module audit). Skip it for a one-file fix: RLM's REPL + workers cost more than just doing that file.

When the ask is bigger than a window — whole repo Q&A, log archaeology, multi-file audit, "read everything then answer" — do not compact, do not dump, do not hope.

Pattern (Zhang / Kraska / Khattab):

1. Put the corpus **outside** the model: worktree + files + a REPL variable, not the prompt.
2. Root model (conductor-grade) writes code that slices the corpus.
3. Worker models (cheap, often Pi/local) read slices and return short facts.
4. Root synthesizes. Recurse if a slice is still too big.

Orchäster mapping:

- class stays `scout` (or `review` if the corpus is a ship branch)
- `config/quota.toml` `[route.infinite]`
- spawn a Cursor or Grok crewmate whose brief says: operate as RLM; do not load the tree into chat; use search/code against the lease; spawn local Pi workers via a second `orch-spawn --class local` if slice-work is bulk
- report lands in `data/reports/<id>.md`

Refuse to "just attach the repo" in the conductor pane. That is the anti-pattern RLM exists to kill.

If a dedicated `rlm` / `ypi` / `minrlm` binary exists on PATH, launch that as the scout harness for `infinite` instead of a vanilla agent.
