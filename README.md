# Agent Harness Template

[![License: MIT](https://img.shields.io/badge/License-MIT-3A3A3A?style=flat&labelColor=3A3A3A&color=6C9E4F)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-3A3A3A?style=flat&labelColor=3A3A3A&color=E8A33D)](issues)

**Repo-local instructions, plans, and history that make coding agents more reliable.**

A self-contained, runtime-agnostic scaffold for projects that use coding agents. Copy it into a repository and every agent gets a stable place to read instructions, plan risky work, and record what it changed — instead of depending on chat-only context that later sessions may not have.

[What it does](#what-it-does) • [Quick start](#quick-start) • [How agents use it](#how-agents-use-it) • [Agent runtime](#agent-runtime) • [Documentation](#documentation) • [License](#license)

---

## What it does

| Piece | What it gives you |
| --- | --- |
| **AGENTS.md routing** | One short entry point every agent reads before working. |
| **Execution plans** | `.plans/` with a template, milestones, and binary validation criteria. |
| **History records** | One file per change: what changed, design intent, how it was verified. |
| **Validation guidance** | Stack-specific quality gates plus an agent checklist to pass before claiming done. |
| **Runtime-agnostic** | No assumptions about agent tool, model provider, or runtime. |
| **Zero dependencies** | Plain bash scripts and a Makefile — no external CLI, no install step. |

---

## Quick start

Bootstrap a new project by copying this directory into its root, cloning it, or using GitHub's **Use this template** action:

```bash
cp -r /path/to/agent-harness/. /path/to/new-project/
```

Then initialise the project name and read the two seeds:

```bash
make init PROJECT=my-project   # or: scripts/init-project.sh my-project
```

Replace the seed content in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and fill in the quality gates in [docs/QUALITY_AND_VALIDATION.md](docs/QUALITY_AND_VALIDATION.md) before substantial work begins.

---

## How agents use it

Every agent task starts by reading [AGENTS.md](AGENTS.md). That file routes the agent:

- **Simple, small changes** — make them carefully and validate them.
- **Complex, risky, or architectural work** — write an execution plan first in `.plans/` (see [docs/PLANS_GUIDE.md](docs/PLANS_GUIDE.md)).
- **After any change** — record a history entry (see [docs/HISTORY_GUIDE.md](docs/HISTORY_GUIDE.md)).
- **Before claiming done** — pass the validation checklist (see [docs/QUALITY_AND_VALIDATION.md](docs/QUALITY_AND_VALIDATION.md)).

Repository-local knowledge beats private context: decisions that affect future work live in files that any contributor or agent can read, review, and update.

---

## Agent runtime

This template is runtime-agnostic: it makes no assumptions about which agent tool, model provider, or runtime you use, and ships no runtime configuration. Keep authentication, provider, and model settings out of the repository — they are environment-specific, not project knowledge. Document project-specific runtime notes in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

As an example, with [opencode](https://opencode.ai), global authentication and provider configuration already apply to every repository, so a project scaffolded from this template needs no runtime configuration at all.

---

## Documentation

| Doc | What it's for |
| --- | --- |
| [AGENTS.md](AGENTS.md) | The routing entry point every agent reads first. |
| [Core beliefs](docs/CORE_BELIEFS.md) | The operating principles behind the harness. |
| [Plans guide](docs/PLANS_GUIDE.md) | When to plan, and how to run a plan through its lifecycle. |
| [History guide](docs/HISTORY_GUIDE.md) | When and how to record a change for future agents. |
| [Architecture](docs/ARCHITECTURE.md) | Seed for the project's real structure — replace it. |
| [Quality and validation](docs/QUALITY_AND_VALIDATION.md) | Quality gates and the agent validation checklist. |

### Folder map

```text
.
├── AGENTS.md               # entry point every agent reads
├── Makefile                # init / new-plan / new-history / validate / help
├── .plans/                 # execution plans
│   ├── active/             # plans currently in progress
│   ├── completed/          # finished plans
│   └── templates/          # execution-plan template
├── docs/
│   ├── histories/          # one record per agent change
│   └── *.md                # guides and seeds (see table above)
└── scripts/                # plain-bash helpers behind the Makefile
```

---

## License

MIT — see [LICENSE](LICENSE).