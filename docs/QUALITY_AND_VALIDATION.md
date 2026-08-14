# Quality And Validation

## Quality Gates You Must Add

This template cannot know your stack. Replace the commands below with the project's real checks and keep them runnable locally and in automation.

| Gate | Command (to fill in) | Fails when |
| --- | --- | --- |
| Lint | > ⚠️ REPLACE: `make lint` | Style, formatting, or static-analysis violations are reported. |
| Type-check | > ⚠️ REPLACE: `make typecheck` | Types cannot be resolved or type contracts are violated. |
| Tests | > ⚠️ REPLACE: `make test` | A test fails, errors, or an expected test suite does not run. |
| Build | > ⚠️ REPLACE: `make build` | The production artefact cannot be produced. |

## Agent Validation Checklist

Before claiming work is done:

1. Run every configured project quality gate that applies to the change.
2. Run language diagnostics on each changed source file and resolve new errors.
3. For changed shell scripts, run `bash -n script.sh`; run `shellcheck script.sh` when ShellCheck is available.
4. For changed JSON, run `jq empty file.json` or an equivalent parser check.
5. Perform manual QA by using the real surface: `curl` the endpoint, run the CLI with representative input, or open and exercise the page.
6. Record the commands, manual actions, and observed results in the history entry.

A passing build alone is not evidence that a user-visible path works. Validate the behaviour the change was intended to deliver.
