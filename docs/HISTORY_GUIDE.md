# History Guide

History entries are mandatory for decision-bearing, risky, multi-file, or user-visible changes. For other small, low-risk changes, a one-line entry is optional.

When recording a change, create one file at `docs/histories/YYYY-MM/<slug>.md`, using [docs/histories/template.md](histories/template.md) or `make new-history SLUG=short-description`.

Never record secrets, credentials, tokens, or private data in a history entry.

A full record captures the user request, what changed, design intent, files touched, verification evidence, and any open questions. It is written for future agents and humans: it explains what changed, why the change was made, and how it was verified.
