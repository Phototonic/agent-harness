# Agent Harness Template

[![License: MIT](https://img.shields.io/badge/License-MIT-3A3A3A?style=flat&labelColor=3A3A3A&color=6C9E4F)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-3A3A3A?style=flat&labelColor=3A3A3A&color=E8A33D)](https://github.com/Phototonic/agent-harness/issues)

**Repo-local instructions, plans, and history that make coding agents more reliable.**

A self-contained, runtime-agnostic scaffold for projects that use coding agents. Copy it into a repository and every agent gets a stable place to read instructions, plan risky work, and record what it changed — instead of depending on chat-only context that later sessions may not have.

[What it does](#what-it-does) • [Install with an agent](#install-with-an-agent) • [Manual quick start](#manual-quick-start) • [Upgrades](#upgrades) • [How agents use it](#how-agents-use-it) • [Agent runtime](#agent-runtime) • [Documentation](#documentation) • [License](#license)

---

## What it does

| Piece | What it gives you |
| --- | --- |
| **AGENTS.md routing** | One short entry point every agent reads before working. |
| **Execution plans** | `.plans/` with a template, milestones, and binary validation criteria. |
| **History records** | One file per change: what changed, design intent, how it was verified. |
| **Validation guidance** | Stack-specific quality gates plus an agent checklist to pass before claiming done. |
| **Runtime-agnostic** | No assumptions about agent tool, model provider, or runtime. |
| **Requirements** | Bash ≥ 3.2, Make, and standard host utilities (`grep`, `sed`, `awk`, `date`, `cp`, `mv`, `rm`, `mktemp`); GNU and BSD userlands both work; nothing to install. |

---

## Install with an agent (recommended)

Strongly recommended: let a coding agent install this for you. The bootstrap involves copying the template, choosing a project name, deciding what goes into the docs, picking a license, and running the init scripts — an agent reads the full guide, asks you the setup questions once, and applies everything consistently.

Paste this prompt into Claude Code, AmpCode, Cursor, opencode, or any agent:

```text
Install and configure the agent-harness template for a new project by following the instructions here:
https://raw.githubusercontent.com/Phototonic/agent-harness/v0.1.0/docs/AGENT_QUICKSTART.md

Ask me the setup questions the guide lists (project name, license, docs, and so on), apply my answers, run the scripts, and verify before you finish.
```

**For LLM agents** — fetch the full guide and follow it step by step:

```bash
curl -fsSL https://raw.githubusercontent.com/Phototonic/agent-harness/v0.1.0/docs/AGENT_QUICKSTART.md
```

The guide covers: bootstrap methods (copy, clone, or GitHub template), project-naming rules, the setup interview (project name, license, doc depth, quality gates, git history), running `make init` / `make new-plan` / `make new-history` / `make validate`, applying your answers to the README, LICENSE, and seeds, and verifying the scaffold. Don't summarise it — read it end to end and execute. The same guide ships in the repo at [docs/AGENT_QUICKSTART.md](docs/AGENT_QUICKSTART.md); both it and this section are removed by `make init` once you scaffold.

The `main` branch is unstable; prompts should use the latest tagged release. This example is pinned to `v0.1.0`.

---

## Manual quick start

### Fresh repository

Bootstrap a new project by cloning this template, using GitHub's **Use this template** action, or copying its contents into an empty directory. When copying, include hidden files and directories; the dotfiles are part of the scaffold. This flow is for a fresh repository only.

### Existing repository

Do not copy the template over an existing working tree. From this checkout, install only the harness-owned manifest into the target:

```bash
scripts/install-existing.sh /path/to/existing-project
```

The installer leaves differing files in place and reports collisions. It generates `<code>agent&#45;harness.mk</code>` inside the target; add `<code>include agent&#45;harness.mk</code>` to the target's Makefile as the one manual integration step — resolve any reported collisions first. It never replaces the target's README, LICENSE, Makefile, `.gitignore`, or `.git` directory.

### Initialise a fresh repository

Initialise the project name (and the license holder) and read the two seeds:

```bash
make init PROJECT=my-project OWNER="Your Name"   # or: scripts/init-project.sh my-project "Your Name"
```

Replace the seed content in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and fill in the quality gates in [docs/QUALITY_AND_VALIDATION.md](docs/QUALITY_AND_VALIDATION.md) before substantial work begins.

`make init` is a partial bootstrap for fresh template checkouts. It replaces the template name in `README.md` and `AGENTS.md`, removes the bootstrap-only **Install with an agent** section from this README and `docs/AGENT_QUICKSTART.md`, and sets the `LICENSE` copyright holder — from `OWNER` when given, otherwise a `<YOUR NAME>` placeholder you fill in. The title, tagline, and other README prose remain yours to edit; the agent-assisted flow applies the full setup interview.

Re-running it is safe: cleanup uses an explicit manifest for bundled history records rather than deleting whole history directories, and a template-marker guard makes a second run a true no-op. User history records and the history template are preserved.

## Upgrades

Upgrades are manual: check the upstream template's releases wherever you copied this harness from, compare your `HARNESS_VERSION` with the release version, diff the harness-owned files, and apply the changes selectively. No migration scripts are shipped.

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

This template is runtime-agnostic. Any runtime that reads `AGENTS.md` at session start, or can be configured or prompted to do so through its rules or context mechanism, works with it. If a runtime has no such mechanism, point it at `AGENTS.md` manually at the start of a session. No provider configuration is shipped; keep authentication, provider, and model settings out of the repository because they are environment-specific, not project knowledge. Document project-specific runtime notes in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

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
├── HARNESS_VERSION         # installed harness release marker
├── Makefile                # init / new-plan / new-history / validate / validate-project / test / help
├── .plans/                 # execution plans
│   ├── active/             # plans currently in progress
│   ├── completed/          # finished plans
│   └── templates/          # execution-plan template
├── docs/
│   ├── histories/          # one record per agent change
│   └── *.md                # guides and seeds (see table above)
├── tests/                  # dependency-free regression tests
└── scripts/                # plain-bash helpers behind the Makefile
```

The installer generates `<code>agent&#45;harness.mk</code>` inside existing targets; it is not shipped at this repository's root.

---

## License

MIT — see [LICENSE](LICENSE).
