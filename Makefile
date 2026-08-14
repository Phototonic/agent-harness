.PHONY: help init new-plan new-history validate

help:
	@printf '%s\n' 'Targets:' '  init PROJECT=name OWNER=holder  Initialise project tokens, LICENSE, and drop bootstrap content' '  new-plan SLUG=name      Create an active execution plan' '  new-history SLUG=name   Create a monthly history record' '  validate                Validate shell scripts and JSON files'

init:
	@./scripts/init-project.sh $(PROJECT) $(OWNER)

new-plan:
	@./scripts/new-plan.sh $(SLUG)

new-history:
	@./scripts/new-history.sh $(SLUG)

# Extend with checks for your project's real config files (e.g. jq for JSON).
validate:
	@bash -n scripts/init-project.sh scripts/new-plan.sh scripts/new-history.sh
