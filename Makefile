SHELL := /bin/sh

CODEX_SKILLS_DIR ?= $(HOME)/.codex/skills
COPILOT_SKILLS_DIR ?= $(HOME)/.copilot/skills
CLAUDE_SKILLS_DIR ?= $(HOME)/.claude/skills
ANTIGRAVITY_SKILLS_DIR ?= $(HOME)/.gemini/skills
RUBY ?= ruby
COPY ?= cp

AVAILABLE_SKILLS := $(sort $(notdir $(wildcard skills/*)))
SKILL ?=
SELECTED_SKILLS := $(if $(SKILL),$(SKILL),$(AVAILABLE_SKILLS))
TARGETS := $(CODEX_SKILLS_DIR) $(COPILOT_SKILLS_DIR) $(CLAUDE_SKILLS_DIR) $(ANTIGRAVITY_SKILLS_DIR)

.DEFAULT_GOAL := help
.PHONY: help check evals evals-list test install uninstall status install-all-targets install-target validate-installed-skills

help:
	@printf '%s\n' \
	  'make check                  Validate the skill layout in this repository.' \
	  'make evals                  Validate every skill'"'"'s eval.yaml.' \
	  'make evals-list             Print evaluation cases as a manual checklist.' \
	  'make evals-list SKILL=<n>   Print one skill'"'"'s evaluation cases.' \
	  'make test                   Run the validator, evaluation, and installer tests.' \
	  'make install                Install every skill for all supported agents.' \
	  'make install SKILL=<name>   Install one skill for all supported agents.' \
	  'make uninstall SKILL=<name> Remove one skill from all supported agents.' \
	  'make status                 Show which skills are currently installed.'

check:
	@set -eu; \
	for skill in $(SELECTED_SKILLS); do \
	  case "$$skill" in ''|*[!a-z0-9-]*) printf '%s\n' "Unsafe skill name: $$skill" >&2; exit 1;; esac; \
	  test -d "skills/$$skill" || { printf '%s\n' "Unknown skill: $$skill" >&2; exit 1; }; \
	  test -f "skills/$$skill/SKILL.md" || { printf '%s\n' "skills/$$skill is missing SKILL.md" >&2; exit 1; }; \
	  test "$$(sed -n '1p' "skills/$$skill/SKILL.md")" = '---' || { printf '%s\n' "skills/$$skill/SKILL.md has no YAML front matter" >&2; exit 1; }; \
	done
	@$(RUBY) scripts/validate-skills.rb $(addprefix skills/,$(SELECTED_SKILLS))
	@printf 'Validated %s skill(s).\n' "$$(printf '%s\n' $(SELECTED_SKILLS) | wc -l | tr -d ' ')"

evals:
	@$(RUBY) scripts/run-evals.rb

evals-list:
	@$(RUBY) scripts/list-evals.rb $(if $(SKILL),--skill $(SKILL))

test:
	@$(RUBY) tests/validate-skills-test.rb
	@$(RUBY) tests/run-evals-test.rb
	@$(RUBY) tests/list-evals-test.rb
	@$(RUBY) tests/install-test.rb
	@$(MAKE) --no-print-directory evals

install: check
	@$(MAKE) --no-print-directory install-all-targets SELECTED_SKILLS="$(SELECTED_SKILLS)"
	@$(MAKE) --no-print-directory validate-installed-skills SELECTED_SKILLS="$(SELECTED_SKILLS)"

install-all-targets:
	@$(MAKE) --no-print-directory install-target TARGET="$(CODEX_SKILLS_DIR)" AGENT=Codex SELECTED_SKILLS="$(SELECTED_SKILLS)"
	@$(MAKE) --no-print-directory install-target TARGET="$(COPILOT_SKILLS_DIR)" AGENT=Copilot SELECTED_SKILLS="$(SELECTED_SKILLS)"
	@$(MAKE) --no-print-directory install-target TARGET="$(CLAUDE_SKILLS_DIR)" AGENT=Claude SELECTED_SKILLS="$(SELECTED_SKILLS)"
	@$(MAKE) --no-print-directory install-target TARGET="$(ANTIGRAVITY_SKILLS_DIR)" AGENT=Antigravity SELECTED_SKILLS="$(SELECTED_SKILLS)"

# Each skill is copied into a staging directory and swapped into place only
# after the copy succeeds, so a failed install never leaves a partial skill
# behind and never disturbs unrelated entries in the target directory.
#
# eval.yaml is removed from the staging copy before the swap. Evaluations live
# beside their skill so they move with it, but they are development material,
# not runtime material: their assertions are phrased as instructions and an
# agent reading the installed directory could act on them.
install-target:
	@set -eu; \
	install_target="$(TARGET)"; \
	mkdir -p "$$install_target"; \
	for skill in $(SELECTED_SKILLS); do \
	  staging="$$install_target/.skills-staging-$$skill.$$$$"; \
	  rm -rf "$$staging"; \
	  mkdir -p "$$staging"; \
	  if ! $(COPY) -R "skills/$$skill/." "$$staging/"; then rm -rf "$$staging"; exit 1; fi; \
	  rm -f "$$staging/eval.yaml"; \
	  rm -rf "$$install_target/$$skill"; \
	  mv "$$staging" "$$install_target/$$skill"; \
	done; \
	printf 'Installed %s skill(s) for %s.\n' "$$(printf '%s\n' $(SELECTED_SKILLS) | wc -l | tr -d ' ')" "$(AGENT)"

validate-installed-skills:
	@set -eu; \
	for target in $(TARGETS); do \
	  for skill in $(SELECTED_SKILLS); do \
	    test -f "$$target/$$skill/SKILL.md" || { printf '%s\n' "Missing installed skill: $$target/$$skill" >&2; exit 1; }; \
	    $(RUBY) scripts/validate-skills.rb "$$target/$$skill"; \
	  done; \
	done
	@echo "Validated every installed skill for every target."

uninstall:
	@if test -z "$(SKILL)"; then \
	  printf '%s\n' 'Usage: make uninstall SKILL=<name>' >&2; \
	  exit 1; \
	fi
	@$(MAKE) --no-print-directory check SKILL="$(SKILL)"
	@set -eu; \
	for target in $(TARGETS); do \
	  rm -rf "$$target/$(SKILL)"; \
	done; \
	printf 'Uninstalled %s from every supported agent. The source remains in this repository.\n' "$(SKILL)"

status:
	@set -eu; \
	for target in $(TARGETS); do \
	  printf '%s:\n' "$$target"; \
	  for skill in $(AVAILABLE_SKILLS); do \
	    if test -d "$$target/$$skill" && test -f "$$target/$$skill/SKILL.md"; then \
	      printf '  installed  %s\n' "$$skill"; \
	    else \
	      printf '  missing    %s\n' "$$skill"; \
	    fi; \
	  done; \
	done
