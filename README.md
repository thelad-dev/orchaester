# Orchäster

**Der Dirigent spricht mit dir. Grok Build und Cursor spielen.**

Ein Dirigent bash’t nicht die Violinstimme. Er weiß, dass die Musiker ihr Fach können — und hält den Takt.

Orchäster ist ein Agent-Distro — kein App, kein SaaS, kein zweites Firstmate.
Das geklonte Verzeichnis *ist* das Betriebssystem: `AGENTS.md`, Skills, dünne Scripts, Dateien als Control Plane.

Firstmate hat das Modell erfunden: ein First Mate, isolierte Worktrees, sichtbare Crew.
Grok Build und Cursor sind gleichberechtigte Dirigenten. Claude Code und Codex sind opt-in Stimmen. Außenwelt über AXI (Kun Chen). Kontext größer als ein Fenster = RLM. Quota in `config/quota.toml`. Crew-Wissen in `knowledge/crew/`. Pi bleibt lokal.

Orchäster darf in seinem Pane fast nichts tun außer verteilen. Grep, Patch, Test, Report, Repro — alles Crew. Unsicher = `/delegate`.

```
du  →  Orchäster (Grok Build in Herdr)  — nur Orchestrierung
         ├─ ship    → Cursor auf Lease-Worktree
         ├─ scout   → Cursor-Index auf Lease, Report statt PR
         ├─ review  → frischer Agent, nie der Autor
         └─ local   → Pi gegen 127.0.0.1 / LAN
```

## Warum nicht Firstmate forken

Firstmate ist tmux-referenziert, co-primary mit Claude/Pi, und trägt eine große Verifikationsmatrix.
Orchäster ist bewusst kleiner:

| | Firstmate | Orchäster |
|---|---|---|
| Default-Backend | tmux | **Herdr nativ** |
| Primär-Harness | Claude / Grok / Pi gleichrangig | **Grok Build** (Gespräch), **Cursor** (Ship) |
| Pi | vollwertiger Primary | **nur lokale OpenAI-APIs** |
| Orchestrierung | Composer-Scraping + viele Adapter | Herdr `agent.prompt` / `agent.wait` / `agent.list` |
| Scripts | großes `bin/`-Gürtel | wenige Wrapper |

Nimm Firstmate, wenn du die volle Flotte und Claude-Parity willst.
Nimm Orchäster, wenn dein Alltag Herdr + Grok Build + Cursor ist.

## Voraussetzungen

- [Herdr](https://herdr.dev) ≥ Protokoll 14 (`curl -fsSL https://herdr.dev/install.sh | sh`)
- [Grok Build](https://x.ai/build) (`curl -fsSL https://x.ai/cli/install.sh | bash`) — SuperGrok / X Premium Plus
- Cursor Agent CLI (`agent` oder `cursor-agent`, je nach Installation)
- Optional: [Pi](https://pi.dev) nur wenn lokale Modelle laufen
- `git`, `jq`

## Start — 2 · 3 · 4

```sh
cd orchaester
./bin/orch-setup.sh
# 2  Arbeitsordner
# 3  Dirigent (grok|cursor)
# 4  Satz

herdr
# Dirigent aus Schritt 3: grok --trust   oder   agent
```

Ab dann redest du nur mit Orchäster. `AGENTS.md` übernimmt.

Erster Prompt:

```
Lies AGENTS.md und docs/architecture.md. Dann /ahoy.
```

## Dispatch in einem Satz

- **Du** redest nur mit dem Primary (Grok Build).
- **Workspace**: dein lokaler Checkout in `config/workspaces.toml`. Wird nie verliehen. Sync nur `bin/orch-sync.sh`.
- **Ship / Scout**: Cursor auf Firstmate-Worktree *neben* dem Workspace, damit der Index die Task-Branch sieht.
- **Review**: immer ein *anderer* Agent als der Autor.
- **Local / privat / offline / billig**: Pi gegen die in `config/local-openai.toml` hinterlegte API.

Details: `config/dispatch.toml`, `docs/harnesses.md`.

## Dateien

```
AGENTS.md                 Supervisor-Vertrag (das Modell)
config/backend            immer "herdr"
config/dispatch.toml      wer welche Arbeit bekommt
config/workspaces.toml    lokale Checkouts + Worktree-Roots + Remotes
config/local-openai.toml  Pi-Ziele (Ollama, vLLM, …)
bin/                      herdr-native spawn / send / status / worktree
skills/                   slash-fähige Arbeitsweisen
data/                     persistenter Zustand der Flotte
docs/                     Architektur, Herdr, Harnesses
```

## Konventionen

- Orchäster schreibt **nicht** in fremde Projekt-Worktrees. Crewmates tun das.
- Jeder Task bekommt eine ID (`ship-042`, `scout-013`) und eine Zeile in `data/fleet.md`.
- Zustand lebt auf Disk. Herdr-Session darf sterben; die nächste reconcilen.
- Keine Secrets in Chats weiterreichen. Local-Pi bekommt Keys nur aus der Umgebung des Pi-Prozesses.

Lizenz: MIT. Architektur inspiriert von [firstmate](https://github.com/kunchenguid/firstmate) und [Herdr](https://herdr.dev), absichtlich nicht kompatibel.
