# Agent Harness Template

[![License: MIT](https://img.shields.io/badge/License-MIT-3A3A3A?style=flat&labelColor=3A3A3A&color=6C9E4F)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-3A3A3A?style=flat&labelColor=3A3A3A&color=E8A33D)](issues)

**Repo-local instructions, plans, and history that make coding agents more reliable.**

A self-contained, runtime-agnostic scaffold for projects that use coding agents. Copy it into a repository and every agent gets a stable place to read instructions, plan risky work, and record what it changed — instead of depending on chat-only context that later sessions may not have.

[What it does](#what-it-does) • [Install with an agent](#install-with-an-agent) • [Manual quick start](#manual-quick-start) • [How agents use it](#how-agents-use-it) • [Agent runtime](#agent-runtime) • [Documentation](#documentation) • [License](#license)

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

## Install with an agent (recommended)

Strongly recommended: let a coding agent install this for you. The bootstrap involves copying the template, choosing a project name, deciding what goes into the docs, picking a license, and running the init scripts — an agent reads the full guide, asks you the setup questions once, and applies everything consistently.

Paste this prompt into Claude Code, AmpCode, Cursor, opencode, or any agent:

```text
Install and configure the agent-harness template for a new project by following the instructions here:
https://raw.githubusercontent.com/Phototonic/agent-harness/main/docs/AGENT_QUICKSTART.md

Ask me the setup questions the guide lists (project name, license, docs, and so on), apply my answers, run the scripts, and verify before you finish.
```

**For LLM agents** — fetch the full guide and follow it step by step:

```bash
curl -fsSL https://raw.githubusercontent.com/Phototonic/agent-harness/main/docs/AGENT_QUICKSTART.md
```

The guide covers: bootstrap methods (copy, clone, or GitHub template), project-naming rules, the setup interview (project name, license, doc depth, quality gates, git history), running `make init` / `make new-plan` / `make new-history` / `make validate`, applying your answers to the README, LICENSE, and seeds, and verifying the scaffold. Don't summarise it — read it end to end and execute. The same guide ships in the repo at [docs/AGENT_QUICKSTART.md](docs/AGENT_QUICKSTART.md); both it and this section are removed by `make init` once you scaffold.

---

## Manual quick start

Bootstrap a new project by copying this directory into its root, cloning it, or using GitHub's **Use this template** action:

```bash
cp -r /path/to/agent-harness/. /path/to/new-project/
```

Then initialise the project name (and the license holder) and read the two seeds:

```bash
make init PROJECT=my-project OWNER="Your Name"   # or: scripts/init-project.sh my-project "Your Name"
```

Replace the seed content in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and fill in the quality gates in [docs/QUALITY_AND_VALIDATION.md](docs/QUALITY_AND_VALIDATION.md) before substantial work begins.

`make init` also makes the scaffold fully neutral: it removes the bootstrap-only **Install with an agent** section from this README, removes `docs/AGENT_QUICKSTART.md`, and sets the `LICENSE` copyright holder — from `OWNER` when given, otherwise a `<YOUR NAME>` placeholder you fill in. Re-running it is safe.

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