# /local-pi

Run work against a local OpenAI-compatible API through Pi.

Use this when the captain says private, offline, LAN-only, cheap, or "use ollama/vllm/lmstudio".

1. Read `config/local-openai.toml`. Abort if nothing is `enabled = true`.
2. Confirm the endpoint is actually local or LAN (`127.0.0.1`, `localhost`, `10.x`, `192.168.x`, `172.16-31.x`). Refuse public URLs.
3. `bin/orch-spawn.sh --class local --ask "..."`
4. Do not pass cloud keys. Pi must use `env_key` from the toml.
5. Never route ship-of-record product work through Pi unless the captain overrode with `/dispatch` *and* acknowledged quality risk.

Pi is not a Firstmate primary here. It is a local inference adapter.
