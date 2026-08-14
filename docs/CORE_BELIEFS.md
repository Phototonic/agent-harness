# Core Beliefs

- **Humans steer; agents execute.** Humans set outcomes, constraints, and trade-offs. Agents should make the work observable and ask only when a meaningful decision remains.
- **Repository-local knowledge beats private context.** Decisions that affect future work belong in files that any contributor or agent can read, review, and update.
- **Repeated agent failure is a scaffolding problem.** Fix the instruction, plan, check, or missing context that allowed the failure instead of repeatedly correcting the same symptom.
- **Short, stable entry points beat giant prompts.** Keep the entry instruction small and route readers to focused documents rather than maintaining a monolithic prompt.
- **Mechanical checks beat soft conventions.** A command, test, linter, or schema check is more reliable than asking agents to remember an unwritten rule.
- **Plans make risky work resumable.** Record goals, constraints, decisions, and binary validation so work can move safely between people and sessions.
- **History preserves design intent.** A concise record of what changed, why, and how it was verified prevents future contributors from reconstructing it from diffs alone.
- **Continuous cleanup keeps the harness trustworthy.** Remove stale guidance, replace seeds with facts, and tighten checks when failures expose gaps.
