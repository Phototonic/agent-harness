# History Record

## Date

2026-08-14

## Agent

Sisyphus (deepseek-v4-flash-free) in opencode

## User Request

Make the template repo agent-first friendly by adding a quick-start link / raw doc designed for agents — a paste-into-agent prompt so new users can have their agent copy the template, set it up locally, ask the user setup questions (project name, docs, licence, etc.), and run the scripts. Model it on the oh-my-openagent README's install-prompt pattern.

## What Changed

- Added `docs/AGENT_QUICKSTART.md`: a dual-audience guide. Humans get a one-shot prompt to paste into any agent; agents get a fetchable, step-by-step setup guide (bootstrap methods, setup interview with defaults, running `make init` / `make new-plan` / `make new-history` / `make validate`, applying answers to README/LICENSE/seeds, verification checklist, reporting).
- Updated `README.md`: added an "Install with an agent (recommended)" section with the paste prompt and a `curl` line for agents (raw URL), added it to the TOC, and renamed the old "Quick start" section to "Manual quick start".
- The guide instructs the scaffolding agent to remove the bootstrap-only install section from the scaffolded README, because `make init` rewrites every `agent-harness` token — including the raw URL — with the project name, which would break it. The manual quick-start section notes the same.
- Follow-up: `scripts/init-project.sh` now also removes the bootstrap-only **Install with an agent** section (and its TOC entry) from README.md, deletes `docs/AGENT_QUICKSTART.md`, removes the template's own history records, and sets the LICENSE copyright holder from an optional second argument (`make init PROJECT=x OWNER="Name"`, defaulting to a `<YOUR NAME>` placeholder). The copyright line is matched structurally (year + trailing text), so no author name is hardcoded in the script and forks work unchanged. The Makefile passes `OWNER` through and its help text was updated. Scaffolded projects no longer contain the author's username or template-repo URLs.

## Design Intent

Follow the oh-my-openagent pattern: keep the human-facing prompt short and point it at a single raw-doc URL that agents fetch and execute end to end, instead of duplicating setup instructions across the repo. The guide encodes the template's real behaviour (slug validation regex, token replacement scope, idempotent init, hidden-file copying) so agents act correctly without trial and error. Runtime-agnosticism is preserved — no provider/model/config instructions were added.

One design trap surfaced during QA: `init-project.sh` sed-replaces every `agent-harness` occurrence in README.md, so the new section's raw URL became `Phototonic/<project>/...` in scaffolded projects. The install section is bootstrap-only content, so the fix is to strip it — and the other owner-specific content (the quick-start doc, the template's own history records, the LICENSE copyright line) — inside `init-project.sh` itself, so manual users and agents both get a neutral scaffold without manual cleanup.

## Files Touched

- `docs/AGENT_QUICKSTART.md` — new agent quick-start guide (also referenced by raw URL)
- `README.md` — new install section, TOC update, quick-start section renamed
- `scripts/init-project.sh` — extended: OWNER arg, LICENSE holder, bootstrap-content removal
- `Makefile` — `init` target passes OWNER; help text updated
- `docs/histories/2026-08/agent-quickstart-guide.md` — this record

## Verification

- Follow-up verification (init-based cleanup): a fresh scaffold run with `make init PROJECT=my-project OWNER="Jane Doe"` left zero `Phototonic` references anywhere in the tree (including the script — the copyright line is matched structurally, not by author name), removed the install section and its TOC entry, deleted `docs/AGENT_QUICKSTART.md` and the template history records, and set `LICENSE` to `Copyright (c) 2026 Jane Doe`; a run without OWNER set the `<YOUR NAME>` placeholder; a simulated fork (LICENSE already under a different name) was rewritten to `Acme Corp` with zero `Phototonic` left. The only remaining `agent-harness` strings in a scaffold are the search patterns inside `init-project.sh`, which the script needs to do its job. `make validate` passed, exit codes are correct (1 on missing/invalid args, 0 on success), and the second init run was a full no-op.
- End-to-end simulation of the guide's flow in a scratch directory: copy-from-checkout bootstrap (hidden files included, `.codegraph/` excluded per the guide's note), `make init PROJECT=my-project` replaced tokens in README.md and AGENTS.md, second init run was a no-op, `grep -rn 'agent-harness' README.md AGENTS.md` found no leftover tokens, `make new-plan SLUG=smoke` and `make new-history SLUG=smoke` created the expected files, smoke files removed.
- Reproduced the token-replacement trap: `make init` rewrites the raw URL to `Phototonic/<project>/main/...`. Verified the fix: after removing the bootstrap section (guide Step 4), the scaffolded README contains no raw URLs and its headings are clean (`# My Project`).
- Follow-up verification (init-based cleanup): a fresh scaffold run with `make init PROJECT=my-project OWNER="Jane Doe"` left zero `Phototonic` and zero `agent-harness` references in the tree, removed the install section and its TOC entry, deleted `docs/AGENT_QUICKSTART.md` and the template history records, and set `LICENSE` to `Copyright (c) 2026 Jane Doe`; a run without OWNER set the `<YOUR NAME>` placeholder. `make validate` passed and the second init run was a no-op.
- Raw URL `https://raw.githubusercontent.com/Phototonic/agent-harness/main/docs/AGENT_QUICKSTART.md` is reachable (returns 404 until these changes are pushed to main, as expected).
- `git clone https://github.com/Phototonic/agent-harness.git` succeeds, confirming the template URL used in the guide is valid.

## Open Questions

None.
