# Agent Skills

[![Agent Skills](https://img.shields.io/badge/Agent-Skills-6f42c1)](skills/)

Personal agent skills, shared for anyone to use.

| Skill | Purpose |
| --- | --- |
| [`better-docs`](skills/better-docs/SKILL.md) | Write technical documentation with direct, precise language. |
| [`say-what`](skills/say-what/SKILL.md) | Explain a previous response more simply when it did not land. |
| [`session-coordinator`](skills/session-coordinator/SKILL.md) | Coordinate delegated work through native sessions. |

## Install

Requirements: `make`, `ruby`, and a POSIX shell. Ruby is used only to validate
skill front matter.

From the repository root:

```sh
make check
make install
```

`make install` copies every skill to the default skill directories for Codex,
Copilot, Claude, and Antigravity. It creates a missing target directory and
replaces only a directory with the same name as a skill in this repository;
other installed skills are left alone.

| Agent | Default location | Override variable |
| --- | --- | --- |
| Codex | `~/.codex/skills` | `CODEX_SKILLS_DIR` |
| Copilot | `~/.copilot/skills` | `COPILOT_SKILLS_DIR` |
| Claude | `~/.claude/skills` | `CLAUDE_SKILLS_DIR` |
| Antigravity | `~/.gemini/skills` | `ANTIGRAVITY_SKILLS_DIR` |

To use custom or temporary locations, set the target variables when installing:

```sh
make install CODEX_SKILLS_DIR=/path/to/codex-skills \
  COPILOT_SKILLS_DIR=/path/to/copilot-skills \
  CLAUDE_SKILLS_DIR=/path/to/claude-skills \
  ANTIGRAVITY_SKILLS_DIR=/path/to/antigravity-skills
```

To install one skill instead:

```sh
make install SKILL=better-docs
```

## First steps

1. Install the collection, or start with one skill that matches a task you do
   often.
2. Give your coding agent a task that matches the skill's description. The
   agent uses that description to decide when the skill applies.
3. Read the selected `SKILL.md` to understand the workflow and its limits.
4. Run `make status` to see which skills are installed, or `make test` to run
   the repository's validator, evaluation, and installer tests without changing
   your real skill directories.

To remove one installed skill while keeping this source checkout:

```sh
make uninstall SKILL=better-docs
```

## Evaluations

Each skill has an adjacent `eval.yaml` with positive and negative loading
examples plus observable expectations for its behavior. `make evals` performs
structural checks on those files. The evaluation files are development material
and are not copied during installation; see [EVALS.md](EVALS.md) for the manual
evaluation process.

## License

[MIT](LICENSE).
