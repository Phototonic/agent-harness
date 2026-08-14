# Agent Instructions

Start every task by reading this file.

`agent-harness` keeps durable project knowledge in the repository. Treat markdown under `docs/` and `.plans/` as the system of record; prefer it over chat history.

## Routing

- Simple, small changes: make them carefully and validate them.
- Complex, risky, multi-session, or architectural work: write an execution plan first in `.plans/`; see [docs/PLANS_GUIDE.md](docs/PLANS_GUIDE.md).
- After any agent-made change: create a history entry; see [docs/HISTORY_GUIDE.md](docs/HISTORY_GUIDE.md).
- Validation is mandatory before claiming work is done; see [docs/QUALITY_AND_VALIDATION.md](docs/QUALITY_AND_VALIDATION.md).

## Read As Needed

- [Core beliefs](docs/CORE_BELIEFS.md)
- [Plans guide](docs/PLANS_GUIDE.md)
- [History guide](docs/HISTORY_GUIDE.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Quality and validation](docs/QUALITY_AND_VALIDATION.md)
