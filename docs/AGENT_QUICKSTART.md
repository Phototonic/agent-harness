# Agent Quick Start

Install and configure the `agent-harness` template into a new or existing project with a coding agent. The fresh-repo flow is automated; existing-repo installation has one manual Makefile include step. The agent asks you the setup questions, applies your answers, runs the scripts, and verifies the result.

Two audiences:

- **Humans** — paste the short prompt below into Claude Code, Cursor, AmpCode, opencode, or any coding agent.
- **Coding agents** — fetch this file and follow the [Setup guide](#setup-guide-for-agents) end to end. Do not summarise it; execute it.

---

## Quick install (for humans)

Paste this prompt into your agent:

```text
Install and configure the agent-harness template for a new or existing project by following the instructions here:
https://raw.githubusercontent.com/Phototonic/agent-harness/v0.1.0/docs/AGENT_QUICKSTART.md

Ask me the setup questions the guide lists (project name, license, docs, and so on), apply my answers, run the scripts, and verify before you finish.
```

The agent will: choose the fresh-repo clone/copy or existing-repo manifest installer, walk you through the setup questions, run the applicable harness scripts, apply fresh-repo choices to the README, LICENSE, and seeds, preserve existing-repo files, and verify before reporting back.

## For LLM agents

Fetch the full guide and follow it step by step:

```bash
curl -fsSL https://raw.githubusercontent.com/Phototonic/agent-harness/v0.1.0/docs/AGENT_QUICKSTART.md
```

Read it end to end before acting. The guide covers: bootstrap methods, the setup interview, running the harness scripts, applying answers, verification, and reporting.

---

## Setup guide (for agents)

### Goal

Deliver a working scaffold of this template in the user's target project. For fresh repos, replace the project token and apply setup answers to the README / LICENSE / seeds; for existing repos, install the harness manifest without overwriting user files. Run the applicable scripts, verify the result, and record a history entry when required.

### Step 0 — Orient (read first)

1. If this file was fetched from the raw URL, the template lives at `https://github.com/Phototonic/agent-harness`. If you are reading it inside a checkout, that checkout *is* the template.
2. Read `AGENTS.md` — it is the template's routing entry point.
3. Read `README.md`, `Makefile`, and the files under `docs/` so you know the layout and the available targets.
4. Identify the target project directory. If it is not obvious, ask the user.

### Step 1 — Bootstrap the template into the target

Pick the method that fits the situation:

| Situation | Action |
| --- | --- |
| User wants a brand-new project directory | `git clone https://github.com/Phototonic/agent-harness.git <dir>` (or `cp -r <template>/. <dir>/`). For a clean project history, remove the template's `.git` afterward — ask first. |
| User has an existing project directory | From the template checkout, run `scripts/install-existing.sh <project>`. It copies only the harness manifest, never blanket-copies or clobbers user files, reports differing collisions, and prints the one manual `include agent-harness.mk` step. |
| User already created the repo on GitHub with **Use this template** | The files are already in place; skip the copy and continue from Step 2. |

For the fresh-copy flow, include hidden files: `.gitignore`, `.plans/`, and `docs/` must come along (a plain `cp template/ project/` without `/.` silently drops dotfiles). When copying from a local checkout, skip tool-local directories that are not part of the template (for example `.codegraph/` and `.omo/`). Existing repos use the installer above instead of a blanket copy.

### Step 2 — Ask the setup questions

Ask the user once, then apply the answers. If the user says "just do it", apply the defaults without asking.

| # | Question | Default | Notes |
| --- | --- | --- | --- |
| 1 | Project name (slug) | Sanitised target directory name | Must match `^[a-z0-9]+([_-][a-z0-9]+)*$` (lowercase letters, digits, hyphens, underscores). Sanitise: lowercase, spaces to hyphens, drop other characters. |
| 2 | Scaffold target | Existing directory / new directory | See Step 1. |
| 3 | Fresh git history? | Fresh (strip the template `.git`, then `git init`) | Ask before removing the template's `.git`. |
| 4 | License | MIT (keep as-is) | If changed: replace `LICENSE`, the badge in `README.md`, and the License section. For non-standard licenses, ask the user to paste the text — never fabricate license terms. |
| 5 | Doc depth | Keep all guides | "Minimal" trims to `AGENTS.md`, core beliefs, plans guide, history guide, and quality & validation. |
| 6 | Stack and quality gates | Leave as `REPLACE` markers | Needed only to fill the gates table in `docs/QUALITY_AND_VALIDATION.md` (lint / typecheck / test / build). If the user tells you the stack, fill the real commands; otherwise leave the markers and note it in the history. |
| 7 | Architecture seed | Leave as seed | Fill `docs/ARCHITECTURE.md` from the user's description now, or leave the `REPLACE ME` seed for later. |
| 8 | First commit | `git init` + initial commit | Only for fresh repositories. |
| 9 | License copyright holder | Passed as `OWNER` to init, else a `<YOUR NAME>` placeholder | Sets the `Copyright (c)` line in `LICENSE` during init. Ask for the name or organisation to put on the license. |

### Step 3 — Run the harness scripts

1. `make init PROJECT=<slug> OWNER=<name>` (or `scripts/init-project.sh <slug> [<owner>]`) in a fresh template checkout. It replaces every `agent-harness` token in `README.md` and `AGENTS.md` with the project name, sets the `LICENSE` copyright holder from `OWNER` (or a `<YOUR NAME>` placeholder when omitted), removes the bootstrap-only **Install with an agent** section from `README.md` (and its TOC entry), removes `docs/AGENT_QUICKSTART.md`, and removes only the known bundled history record. The manifest-based removal preserves user history records and `docs/histories/template.md`; a template-marker guard makes non-template trees a true no-op, and repeating init is a true no-op.
2. `make validate` — syntax-checks all shell scripts and runs ShellCheck when available. It must exit 0.
3. Recommended: `make new-history SLUG=project-bootstrap` to create the first history record, then fill it (Step 4). This demonstrates the harness's own workflow.
4. Optional: `make new-plan SLUG=<first-task>` if the user wants an execution plan for the first substantial piece of work.

### Step 4 — Apply the answers

For a fresh scaffold, apply the answers as follows. In an existing repo, leave user-owned files such as `README.md` and `LICENSE` unchanged; review the installer's collision report before making any changes.

- `README.md`: title line, license badge (if changed), tagline, and the quick-start references. Relative links stay as they are. The bootstrap-only **Install with an agent** section and its TOC entry were already removed by `make init`.
- `LICENSE`: replace with the chosen license (if changed). The copyright holder was set by init from your answer to question 9, or is a `<YOUR NAME>` placeholder — fill it in.
- `docs/ARCHITECTURE.md`: replace the seed with the user's description of topology, package boundaries, data flow, observability, and local development workflow — or leave the seed.
- `docs/QUALITY_AND_VALIDATION.md`: fill the gates table with real commands when the stack is known; keep the agent validation checklist.
- Trim docs per the doc-depth answer.
- Fill the created `docs/histories/YYYY-MM/project-bootstrap.md` record: date, agent, the user's request, what changed, design intent, files touched, and the verification commands you actually ran (from Step 5).
- Fresh repository: `git init`, stage, and make the initial commit if the user wants one.

### Step 5 — Verify before claiming done

Follow the checklist in `docs/QUALITY_AND_VALIDATION.md`:

1. `make validate` exits 0.
2. No leftover template or owner tokens anywhere in the scaffolded tree: `grep -rn -e 'agent-harness' -e 'Phototonic' README.md AGENTS.md LICENSE docs` returns nothing.
3. `LICENSE` matches the chosen license and the README badge agrees.
4. The targets work: `make help` lists them, `make init PROJECT=<slug>` runs, and smoke-test `make new-plan SLUG=smoke` and `make new-history SLUG=smoke` — then remove the smoke files again.
5. Manual QA: exercise the real surface. Show the user the resulting layout (`find . -path ./.git -prune -o -maxdepth 2 -print | sort`), the replaced title, and the output of the commands you ran.
6. Report the local `HARNESS_VERSION` and record the commands and their results in the history entry.

### Step 6 — Report

Summarise: where the scaffold landed, the questions asked and the answers, the commands run and their output, and anything left open (for example, `REPLACE` quality-gate markers because the stack is not known yet).

---

## Notes

- The raw-URL examples use the tagged release `v0.1.0`; `main` is unstable, and prompts must reference the latest tagged release.
- The template is runtime-agnostic: do not add provider, model, authentication, or API configuration. Keep that out of the repository.
- Guardrails: never delete user files without confirmation, never fabricate license text or quality-gate commands, and never run `make init` with an invalid slug — sanitise it first (Step 2, question 1).
