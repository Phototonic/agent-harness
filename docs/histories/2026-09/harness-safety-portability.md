# History Record

> Never record secrets, credentials, tokens, or private data in a history entry.

## Date

2026-09-14

## Agent

opencode orchestrator (glm-5.3), planner/fixer/oracle subagents

## User Request

Audit the harness for needed updates given its general-purpose intent, then implement all approved improvements: safe idempotent init, injection/overwrite-safe scripts, two install modes, version marker with manual upgrades, test suite + CI, honest docs, validation boundary, reduced ceremony.

## What Changed

- `scripts/init-project.sh`: non-destructive init (exact bundled-history manifest removal, empty-only `rmdir`), dedicated `.agent-harness-template` marker guard with README/AGENTS/LICENSE preflight, env `PROJECT`/`OWNER` interface, OWNER newline/CR rejection, portable mktemp-based in-place edits replacing GNU-only `sed -i`.
- `scripts/new-plan.sh`, `scripts/new-history.sh`: slug validation (`^[a-z0-9]+([_-][a-z0-9]+)*$`), parent-symlink component rejection, atomic exclusive creation (noclobber), no-overwrite refusal, env `SLUG` interface.
- `Makefile`: env-export interface (no user input in recipe shell lines), `validate` (bash -n + optional shellcheck), new `validate-project` (`PROJECT_CHECKS` variable), `test` target, honest help text.
- `scripts/install-existing.sh` (new): existing-repo install mode — explicit manifest copy, collision report (identical skip / differs report), symlink-component guards, generated `agent-harness.mk` fragment, never touches `.git` or user files.
- `HARNESS_VERSION` (new): `0.1.0` release marker, survives init, ships in both install modes.
- `tests/run-tests.sh` (new) + `.github/workflows/ci.yml` (new): 14-case template-mode / 5-case scaffold-mode dependency-free suite; CI runs validate + test.
- Docs: README badge fix, honest requirements, pinned `v0.1.0` bootstrap URLs (main = unstable), fresh/existing install split, partial-bootstrap honesty, Upgrades section, runtime compatibility contract; quickstart rewritten to two modes; QUALITY_AND_VALIDATION split into harness vs project checks with conditional manual QA; history ceremony thresholds lowered (mandatory for decision-bearing/risky/multi-file/user-visible only); no-secrets warning in history template and guide; plan-template front matter made valid YAML; `.gitignore` neutralized; stale 2026-08 verification contradiction corrected with a dated note.

## Design Intent

- Settled with the user: version marker + manual upgrades only (no migration machinery); two install modes; runtime-agnostic; portable shell; no new dependencies.
- Init safety comes from an explicit removal manifest plus a dedicated marker file rather than textual inference — a review-driven deviation from the plan's original textual-marker wording, chosen because any README mention of the harness must never authorize a LICENSE rewrite.
- Accepted review hardening: mktemp temp files, symlink-component rejection, exclusive creation. Rejected as disproportionate: installer TOCTOU/concurrent-attacker hardening (local tool threat model).
- `PROJECT_CHECKS` is executable by design and documented as trusted project configuration.
- Decision-complete source: `.slim/plans/harness-safety-portability.md`; per-task detail: `docs/histories/2026-09/harness-safety-portability-task-5.md`.

## Files Touched

- `scripts/init-project.sh`, `scripts/new-plan.sh`, `scripts/new-history.sh`, `scripts/install-existing.sh` — safety core and installer.
- `Makefile`, `HARNESS_VERSION`, `.agent-harness-template` — interface, version marker, distribution marker.
- `tests/run-tests.sh`, `.github/workflows/ci.yml` — regression cover and CI.
- `README.md`, `AGENTS.md`, `docs/AGENT_QUICKSTART.md`, `docs/QUALITY_AND_VALIDATION.md`, `docs/HISTORY_GUIDE.md`, `docs/histories/template.md`, `.plans/templates/execution-plan.md`, `.gitignore` — docs honesty and ceremony.
- `.plans/active/2026-09-14-harness-safety-portability.md` → `.plans/completed/` — execution-plan lifecycle.

## Verification

- `bash -n scripts/*.sh` — all parse.
- `make validate` — exit 0 (shellcheck absent, optional skip).
- `make test` — template mode: 14 passed, 0 failed; scaffold-mode copy: 5 passed, 0 failed; legacy-script sensitivity check (git-restored vulnerable scripts) fails by name as expected.
- Post-init simulation (`/tmp/opencode/final-sim`, `make init PROJECT=demo OWNER='Jane Doe & Sons'`): `.agent-harness-template` and `docs/AGENT_QUICKSTART.md` removed, `HARNESS_VERSION` and `docs/histories/template.md` retained, user-planted file intact, LICENSE reads `Copyright (c) 2026 Jane Doe & Sons` (ampersand preserved — injection regression).
- Make-level injection attempt (`OWNER='x; touch pwned; #'`) — no file created, usage error only; covered as a named test case.
- Existing-repo install covered by in-suite case: user files byte-unchanged, `.git` untouched, collisions reported, `agent-harness.mk` generated, second run safe.
- Doc sweeps: `grep -rn 'Zero dependencies\|](issues)' README.md docs` and `grep -n 'cp -r' README.md` — no matches.

## Open Questions

- ~~Maintainer release step pending~~ — resolved 2026-09-15: committed (`4a100de` + shellcheck SC2295 quoting fix `e46a20a`), tagged `v0.1.0`, pushed; CI green on the tagged commit; pinned quickstart URL returns 200.
