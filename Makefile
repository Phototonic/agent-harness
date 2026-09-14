.PHONY: help init new-plan new-history validate validate-project test

export PROJECT
export OWNER
export SLUG

help:
	@printf '%s\n' 'Targets:' '  init PROJECT=name OWNER=holder  Initialise project tokens, LICENSE, and drop bootstrap content' '  new-plan SLUG=name      Create an active execution plan' '  new-history SLUG=name   Create a monthly history record' '  validate                Validate harness shell scripts' '  validate-project        Run configured project checks, if any' '  test                   Run the dependency-free regression suite'

init:
	@./scripts/init-project.sh

new-plan:
	@./scripts/new-plan.sh

new-history:
	@./scripts/new-history.sh

validate:
	@bash -n scripts/*.sh
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck scripts/*.sh; \
	else \
		printf '%s\n' 'shellcheck not available; skipping'; \
	fi

test:
	@bash tests/run-tests.sh

ifneq ($(strip $(PROJECT_CHECKS)),)
validate-project:
	@$(PROJECT_CHECKS)
else
validate-project:
	@printf '%s\n' 'no project checks configured'
endif
