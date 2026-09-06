# Harnesses

## Grok Build — primary + scout + review

Install: `curl -fsSL https://x.ai/cli/install.sh | bash`

Primary launch inside Herdr, in this directory:

```
grok --trust
```

`--trust` loads project hooks once per clone. `/hooks-trust` inside Grok also works.

Why Grok is the conversation surface:

- Reads `AGENTS.md`, skills, hooks, MCP out of the box
- Plan mode for messy asks you have not classified yet
- Native worktrees and subagents — *crewmates* still own project writes; do not use Grok subagents as a way to bypass the fleet
- Headless `grok -p` is fine for scripts, not for the primary (Firstmate is right about this: the primary needs a live TUI)

Custom models in `~/.grok/config.toml` can point at OpenAI-compatible URLs. That is **not** a substitute for the Pi local path. If the captain asked for local-only, use Pi so the policy stays visible in `data/fleet.md`.

## Cursor Agent CLI — default ship

Herdr detects Cursor via screen manifest (`cursor.toml`). Start the CLI that your install provides:

```
agent
# or
cursor-agent
```

Set `config/dispatch.toml` `[ship].launch` to whichever binary exists.

Cursor is the ship path because that is where many captains already review diffs and apply cloud agents. Orchäster's job is to put a Cursor agent on an isolated worktree and keep the captain out of that pane.

Headless Cursor is acceptable for crewmates. The primary stays Grok.

## Pi — local OpenAI-compatible only

Install: `curl -fsSL https://pi.dev/install.sh | sh`

Pi talks to Anthropic, OpenAI, xAI, Ollama, and anything Chat-Completions shaped. In *this* distro that flexibility is restricted:

- Class `local` only
- Endpoint must be loopback or RFC1918 (`config/local-openai.toml`)
- No `ship=pi`, no `primary=pi`

That is the whole point versus Firstmate. Firstmate runs Pi as a co-primary with watcher extensions and `/calm`. Orchäster does not. If you want that life, use Firstmate.

Typical local stack:

```
# Ollama
export LOCAL_OPENAI_API_KEY=ollama
# config/local-openai.toml already points at :11434

# LM Studio
# base_url = "http://127.0.0.1:1234/v1"

# vLLM
# base_url = "http://192.168.1.20:8000/v1"
```

Then `/local-pi` or `bin/orch-spawn.sh --class local --ask "..."`.

## Fallback order

| Class | Try first | Then |
|---|---|---|
| primary | grok | — (do not silently switch) |
| ship | cursor (`agent`) | grok |
| scout | grok | cursor |
| review | grok | cursor (must differ from author if possible) |
| local | pi | refuse |

## Detection in Herdr

`herdr agent explain <pane>` shows which manifest fired. If Grok or Cursor comes up as idle while clearly working, fix the local override in `~/.config/herdr/agent-detection/` rather than patching Orchäster scripts.
