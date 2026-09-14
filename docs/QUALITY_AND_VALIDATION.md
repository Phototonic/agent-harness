# Quality And Validation

## Harness checks (always)

Run the harness checks in every checkout:

- `make validate` syntax-checks all shipped shell scripts and runs ShellCheck when it is available. ShellCheck is optional; it is not a required dependency.
- `make test` runs the dependency-free regression suite. It uses the full suite in the template checkout and the portable subset in a scaffolded project.

## Project checks (per stack)

This template cannot know your stack. Replace the commands below with the project's real checks and keep them runnable locally and in automation.

Set `PROJECT_CHECKS` to the project commands, then run `make validate-project`. If it is unset, the target prints `no project checks configured` and exits successfully. `PROJECT_CHECKS` is executable by design — treat it as trusted project configuration, checked in and reviewed like code.

Delete rows that don't apply to your stack; replace the remaining commands with the real checks.

| Gate | Command (to fill in) | Fails when |
| --- | --- | --- |
| Lint | > ⚠️ REPLACE: `make lint` | Style, formatting, or static-analysis violations are reported. |
| Type-check | > ⚠️ REPLACE: `make typecheck` | Types cannot be resolved or type contracts are violated. |
| Tests | > ⚠️ REPLACE: `make test` | A test fails, errors, or an expected test suite does not run. |
| Build | > ⚠️ REPLACE: `make build` | The production artefact cannot be produced. |

## Agent Validation Checklist

Before claiming work is done:

1. Run `make validate` and `make test`.
2. Run `make validate-project` when project checks are configured and apply the gates that matter to the change.
3. Run language diagnostics on each changed source file and resolve new errors.
4. For changed JSON, run `jq empty file.json` or an equivalent parser check.
5. When the change has a real executable or user-visible surface, perform manual QA: `curl` the endpoint, run the CLI with representative input, or open and exercise the page. Manual QA is not required for docs-only or internal process changes.
6. When a history entry is created, record the commands, manual actions, and observed results in it.

A passing build alone is not evidence that a user-visible path works. Validate the behaviour the change was intended to deliver.
