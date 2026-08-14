# Plans Guide

Write an execution plan for large, risky, multi-session, architectural, or migration work, and for work shared between multiple agents or contributors. Small, contained changes do not need a plan.

## Lifecycle

1. Copy `.plans/templates/execution-plan.md` to `.plans/active/` with a descriptive filename, or run `make new-plan SLUG=short-description`.
2. Update its progress and decisions while work proceeds.
3. When complete, add a final status note and move it to `.plans/completed/`.

## Template Sections

| Section | Purpose |
| --- | --- |
| Goal | State the observable outcome, not the activity. |
| Scope | Define what is included and explicitly excluded. |
| Context | Capture facts, links, constraints, and relevant prior decisions. |
| Risks & Mitigations | Record credible failure modes and the planned response. |
| Milestones | Break the work into observable checkpoints. |
| Validation | List the exact evidence required before completion. |
| Progress Log | Record dated status changes, discoveries, and blockers. |
| Decision Log | Record dated choices and their rationale. |

Validation entries are binary pass/fail criteria, not aspirations. Write `GET /health returns 200 and the body matches the documented schema`, not `health endpoint should work`.
