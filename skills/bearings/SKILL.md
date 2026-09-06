# /bearings

Write a four-section digest. Optionally persist it.

Sections:

1. **Fleet** — every non-done row in `data/fleet.md` plus live Herdr state
2. **Decisions** — captain-only questions, impact first
3. **Ships** — branches / worktrees still open
4. **Scouts** — reports in `data/reports/` from the last 7 days

If the captain said `file`, write `data/status-report-YYYY-MM-DD.md`.
Do not dump raw pane transcripts.
