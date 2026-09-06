# /dispatch

Show or temporarily override harness routing.

Default source: `config/dispatch.toml`.

- No args: print the current policy in four lines (primary / ship / scout / local).
- `/dispatch ship=grok` this turn only. Do not rewrite the file unless the captain says `persist`.
- `/dispatch persist` writes the in-turn overrides back to `config/dispatch.toml`.
- Refuse `ship=pi` and `primary=pi`. Pi stays on `local`.
- Refuse sending a `local` task to Grok or Cursor.
