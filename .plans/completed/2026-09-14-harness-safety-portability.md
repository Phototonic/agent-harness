---
Title: "Harness safety, honesty, and portability hardening"
Status: "completed"
Created: "2026-09-14"
Updated: "2026-09-14"
Owner: "Fixer"
---

## Goal

Deliver the safety, honesty, and portability improvements described by the decision-complete source plan at `.slim/plans/harness-safety-portability.md`, including safer initialization and installation, portable scripts, honest documentation, and proportionate validation.

## Scope

- In: Non-destructive initialization, injection and traversal fixes, fresh-repo and existing-repo installation modes, the `HARNESS_VERSION` marker, neutral repository defaults, documentation corrections, validation-boundary updates, tests, CI, and convention-compliant plan/history closure.
- Out: Migration or upgrade automation, provider/runtime configuration, README title rewriting, force or dry-run flags, and tool-local ignore entries.

The `.slim/plans/harness-safety-portability.md` file is the decision-complete source for this execution plan.

## Context

The repository is a reusable agent-harness template. The authoritative source plan records the approved design decisions, implementation order, risks, and final verification requirements for hardening its safety and portability.

## Risks & Mitigations

| Risk | Mitigation |
| --- | --- |
| Initialization could remove adopter-owned files or rewrite a foreign tree. | Restrict cleanup to an explicit bundled manifest and guard structural rewrites with template markers. |
| Shell and documentation changes could drift from the settled contract. | Keep the `.slim` plan authoritative and run the named syntax, YAML, and repository validation checks. |

## Milestones

- [x] Phase 1: Script safety core and the `HARNESS_VERSION` marker are implemented.
- [x] Phase 2: Existing-repository installation is manifest-based and collision-safe.
- [x] Phase 3: Dependency-free tests and minimal CI provide regression coverage.
- [x] Phase 4: Documentation, template, gitignore, and ceremony updates match behavior.
- [x] Phase 5: Final verification passes and the completed plan/history record is closed.

## Validation

1. The front matter of this plan and `.plans/templates/execution-plan.md` parses as a YAML mapping of strings.
2. `cat HARNESS_VERSION` prints `0.1.0`.
3. The final validation commands and acceptance criteria in `.slim/plans/harness-safety-portability.md` pass before closure.

## Progress Log

- 2026-09-14 - Created execution plan; Phase 1 is in flight while the approved safety and portability changes are implemented.
- 2026-09-14 - Phases 1-3 landed (script safety core, installer, tests + CI); oracle review of the safety core accepted findings hardening (dedicated `.agent-harness-template` marker replacing textual inference, mktemp temp files, symlink rejection + exclusive creation) and rejected installer TOCTOU hardening as disproportionate. Docs phase landed after behavior freeze.
- 2026-09-14 - Phase 5 final verification passed (14/14 template-mode, 5/5 scaffold-mode, post-init and existing-repo simulations clean); history record `docs/histories/2026-09/harness-safety-portability.md` created; plan moved to completed. Pending maintainer step: tag `v0.1.0` after commit so pinned bootstrap URLs resolve.

## Decision Log

- 2026-09-14 - Followed `.slim/plans/harness-safety-portability.md` as the decision-complete source; this file tracks execution state only.
