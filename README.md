# Agent Harness Template

## What this is

A self-contained, agent-agnostic documentation and process scaffold for projects that use coding agents. Copy it into a project, then replace the seed material with the project's real knowledge and checks.

## Why

Agents are more reliable when they can read repository-local instructions, plans, and history instead of depending on chat-only context that may be incomplete or unavailable in later sessions.

## Quick Start

Bootstrap a new project by copying this `agent-harness` directory into its root, cloning it, or using GitHub's **Use this template** action:

```sh
cp -r /path/to/agent-harness/. /path/to/new-project/
```

Then run:

```sh
make init PROJECT=my-project
# or
scripts/init-project.sh my-project
```

Fill in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/QUALITY_AND_VALIDATION.md](docs/QUALITY_AND_VALIDATION.md) before substantial work begins.

## How Agents Use It

Every agent task starts by reading [AGENTS.md](AGENTS.md). That file routes the agent to the repository's instructions, plans, history, architecture, and validation rules.

## Agent Runtime

This template is runtime-agnostic: it makes no assumptions about which agent tool, model provider, or runtime you use. Keep runtime configuration (authentication, providers, model settings) out of the repository — it is environment-specific, not project knowledge. Document project-specific runtime notes in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

As an example, with [opencode](https://opencode.ai), global authentication and provider configuration already apply to every repository, so a project scaffolded from this template needs no runtime configuration at all.

## Folder Map

```text
.
├── .plans/
│   ├── active/
│   ├── completed/
│   └── templates/
├── docs/
│   ├── histories/
│   ├── ARCHITECTURE.md
│   ├── QUALITY_AND_VALIDATION.md
│   └── ...
├── scripts/
├── AGENTS.md
└── Makefile
```

## License

MIT.
