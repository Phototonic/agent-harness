# History Record

## Date

2026-09-14

## Agent

Fixer, gpt-5.6-luna, OpenCode

## User Request

Implement Task 5 from `.slim/plans/harness-safety-portability.md`: add a safe existing-repository installer with an explicit harness manifest, collision reporting, and generated `agent-harness.mk` support.

## What Changed

- Added `scripts/install-existing.sh` with target validation, template-root protection, manifest-only copying, byte-identical skip handling, collision reporting, and generated Make targets.
- Added this history record for the decision-bearing implementation change.

## Design Intent

Existing repositories receive only harness-owned files and the generated Make fragment. User files, including repositories' control files and `.git`, remain untouched; differing destination files are reported rather than overwritten. The fragment exports `SLUG` and invokes the shipped scripts without positional arguments, preserving the environment-based interface.

## Files Touched

- `scripts/install-existing.sh` — new existing-repository installer.
- `docs/histories/2026-09/harness-safety-portability-task-5.md` — implementation history.

## Verification

- `bash -n scripts/install-existing.sh` — passed.
- Simulated installation in `/tmp/opencode` with user README, LICENSE, Makefile, `.gitignore`, `.git`, and a differing `docs/HISTORY_GUIDE.md` — passed; user files and `.git` marker were byte-unchanged, the collision was reported, all manifest files and `agent-harness.mk` were present, and a second run re-reported only the collision while remaining successful.

## Open Questions

None.
