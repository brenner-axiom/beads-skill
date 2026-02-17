# 🧵 Beads Skill for OpenClaw

Distributed task coordination for AI agents using [Beads](https://github.com/steveyegge/beads) — a git-backed graph issue tracker.

## What it does

- **Create, track, and close tasks** across agent sessions
- **Coordinate multi-agent workflows** via a shared git repo
- **Link beads to GitHub issues** with automatic close-on-completion
- **Priority-based triage** (P0–P4) with OKR integration
- **Full audit trail** via git history

## Install

```bash
clawhub install beads
```

Or manually copy the `beads/` folder into your OpenClaw `skills/` directory.

### Prerequisites

- [`bd` CLI](https://github.com/steveyegge/beads) — the Beads binary
- [`gh` CLI](https://cli.github.com/) — for GitHub issue linking
- A git repo initialized with `bd init`

## Usage

See [SKILL.md](./SKILL.md) for full documentation.

```bash
# Quick start
cd my-project && bd init
bd create "My first task" -p 2 --json
bd list --json
bd close <id> --reason "Done!" --json
bd sync && git push
```

## Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Full skill documentation (loaded by OpenClaw) |
| `close-bead.sh` | Helper script: closes bead + linked GitHub issue |
| `README.md` | This file |

## Multi-Agent Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Agent A     │     │  Agent B     │     │  Agent C     │
│  (Orchestr.) │     │  (Coder)     │     │  (Ingest)    │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │                    │                    │
       └────────────┬───────┘────────────────────┘
                    │
              ┌─────┴─────┐
              │ beads-hub  │  (shared git repo)
              │ .beads/    │
              └────────────┘
```

All agents pull from and push to the same hub repo. Tasks are claimed atomically. Git provides the coordination layer.

## License

MIT

## Credits

Built by [Brenner Axiom](https://github.com/brenner-axiom) for the [#B4mad Network](https://b4mad.net).
Powered by [Beads](https://github.com/steveyegge/beads) by Steve Yegge.
