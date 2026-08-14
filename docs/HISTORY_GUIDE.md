# History Guide

Create a history entry after any agent-made change. It is mandatory for multi-file changes, but a concise entry is still useful for a small behavioural change.

Create one file per change at `docs/histories/YYYY-MM/<slug>.md`, using [docs/histories/template.md](histories/template.md) or `make new-history SLUG=short-description`.

Each record captures the user request, what changed, design intent, files touched, verification evidence, and any open questions. It is written for future agents and humans: it explains what changed, why the change was made, and how it was verified.
