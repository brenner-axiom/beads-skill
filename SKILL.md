---
name: beads
description: "Cross-agent task coordination using Beads (bd CLI). Create, claim, track, and sync distributed tasks across agents and sessions via a git-backed graph issue tracker."
version: "1.0.0"
metadata:
  openclaw:
    emoji: "🧵"
    requires:
      bins: ["bd", "gh"]
    install:
      - id: beads
        kind: binary
        label: "Install bd CLI from github.com/steveyegge/beads"
---

# Beads — Distributed Task Coordination

Beads is a git-backed, distributed issue tracker designed for multi-agent workflows. Every task (a "bead") lives in a git repo and syncs automatically — no central server, no database, just git.

**Why Beads?**
- Tasks survive session restarts — they're files in a repo
- Multiple agents can coordinate without shared memory
- Full audit trail via git history
- Works offline, syncs when connected

## Prerequisites

- **`bd`** — the Beads CLI ([github.com/steveyegge/beads](https://github.com/steveyegge/beads))
- **`gh`** — GitHub CLI (for linked issue management)
- A git repo initialized with `bd init`

## Quick Start

```bash
# Initialize beads in any git repo
cd my-project && bd init

# Or use a shared hub repo for cross-project coordination
git clone https://github.com/your-org/beads-hub
cd beads-hub && bd init
```

## Core Commands

### List & Query

```bash
bd list --json                    # All beads
bd ready --json                   # Open beads ready for work
bd show <id> --json               # Single bead details
```

### Create

```bash
bd create "Title" -p <0-4> --json
bd create "Title" -p 1 --description "Details..." --json
bd create "Sub-task" --parent <epic-id> -p 2 --json
```

### Update

```bash
bd update <id> --status in_progress --json
bd update <id> --claim --json               # Atomic claim (prevents conflicts)
bd update <id> --notes "Progress update"
bd update <id> -p 0                          # Re-prioritize
```

### Close

```bash
bd close <id> --reason "Completed: summary" --json
```

### Dependencies

```bash
bd dep add <child-id> <parent-id>   # child blocked until parent closes
```

### Sync (CRITICAL — always do after changes)

```bash
bd sync && git push
```

> **Never skip `git push`!** Beads are git-backed. Unpushed changes are invisible to other agents and sessions.

## Closing Beads with Linked GitHub Issues

When a bead title contains `GH#<number>` or notes contain a GitHub issue URL, closing the bead should also close the linked issue:

```bash
# Using the helper script
bash skills/beads/close-bead.sh <bead-id> "Completed: summary"

# Or manually
bd close <id> --reason "summary" --json
gh issue comment <number> --repo <owner/repo> \
  --body "✅ Closed via bead <id>. Summary: <reason>"
gh issue close <number> --repo <owner/repo> --reason completed
bd sync && git push
```

The `close-bead.sh` script automates this: it extracts the issue number, comments, closes, syncs, and pushes.

## Priority Guide

| Priority | Label | When to use |
|----------|-------|-------------|
| **P0** | 🔴 Critical | Production down, blocking everything |
| **P1** | 🟠 High | Important, do today |
| **P2** | 🟡 Normal | Standard work items |
| **P3** | 🔵 Low | Nice to have, backlog |
| **P4** | ⚪ Someday | Ideas, maybe later |

## Multi-Agent Patterns

### Hub & Spoke

Use a shared "beads-hub" repo for cross-project coordination. Each agent pulls from the hub, claims work, and pushes results.

```bash
# Agent session start
cd ~/beads-hub && git pull -q && bd sync
bd ready --json   # What can I work on?
```

### Delegating Work

Create a bead assigned to a specific agent:

```bash
bd create "Refactor auth module" -p 2 --assign codemonkey --json
```

The assigned agent picks it up on its next session or heartbeat.

### Epics with Sub-tasks

Break large work into trackable pieces:

```bash
bd create "Deploy new service" -p 1 --json
# Returns id: hub-abc
bd create "Write Dockerfile" --parent hub-abc -p 2 --json
bd create "Set up CI pipeline" --parent hub-abc -p 2 --json
bd create "Configure DNS" --parent hub-abc -p 2 --json
```

### Linking to OKRs

Add OKR references in bead notes for traceability:

```bash
bd update <id> --notes "OKR: KR 2.3 (integrate additional data source)"
```

## Session Workflow

**Every session start:**
1. `cd ~/beads-hub && git pull -q && bd sync`
2. `bd ready --json` — check what's available
3. Pick highest-priority bead you can make progress on

**While working:**
4. `bd update <id> --status in_progress`
5. Do the work
6. If blocked, ask for input — don't skip forever

**When done:**
7. Close the bead (use `close-bead.sh` if GitHub-linked)
8. `bd sync && git push` — always!
9. Pick next bead — never stop

## Conventions

- **Always `--json`** for machine-readable output
- **Always `bd sync && git push`** after changes
- **Claim before working** — prevents duplicate effort
- **Include bead ID in git commits:** `git commit -m "Fix auth bug (hub-abc)"`
- **One bead per work order** — every task goern assigns gets a bead
- **Close what you finish** — including linked GitHub issues
