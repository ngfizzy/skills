# skills

Portable agent skills for technical work: tracing how software actually runs,
and writing about it accurately.

A skill is a directory containing a `SKILL.md` file. The front matter tells a
coding agent when to load it; the body tells the agent how to behave once it
does. Skills here are model- and vendor-neutral prose. They contain no code to
execute, no network calls, and no configuration for any particular repository.

## Skills

- **`execution-path-tracing`** — following a real runtime path across
  requests, events, queues, callbacks, storage reads and writes, and UI
  updates.
- **`cracked-debugging`** — diagnosing an unclear bug by finding the earliest
  point where the failing run diverges from the working one.
- **`document-runtime`** — writing documentation grounded in traced behavior
  rather than intended design.
- **`better-docs`** — making technical writing direct and precise without
  weakening what it claims.
- **`say-what`** — re-explaining something you just said, after the first
  explanation did not land.

They compose. `better-docs` and `document-runtime` both build on a trace
established by `execution-path-tracing`, so installing all four gives each one
the others it refers to.

## Install

```sh
make check
make install
```

`make install` copies every directory under `skills/` into the skill locations
for Codex, Copilot, Claude, and Antigravity. It replaces only directories whose
names match a skill in this repository, so built-in and third-party skills in
those locations are left alone.

The default install writes to all four locations, creating a location if it
does not already exist:

| Agent | Default location | Override |
| --- | --- | --- |
| Codex | `~/.codex/skills` | `CODEX_SKILLS_DIR` |
| Copilot | `~/.copilot/skills` | `COPILOT_SKILLS_DIR` |
| Claude | `~/.claude/skills` | `CLAUDE_SKILLS_DIR` |
| Antigravity | `~/.gemini/skills` | `ANTIGRAVITY_SKILLS_DIR` |

For example, use temporary or custom locations without touching the defaults:

```sh
make install CODEX_SKILLS_DIR=/path/to/codex-skills \
  COPILOT_SKILLS_DIR=/path/to/copilot-skills \
  CLAUDE_SKILLS_DIR=/path/to/claude-skills \
  ANTIGRAVITY_SKILLS_DIR=/path/to/antigravity-skills
```

Install a single skill:

```sh
make install SKILL=better-docs
```

Remove one from every agent, keeping the source here:

```sh
make uninstall SKILL=better-docs
```

`make status` shows what is currently installed. `make test` exercises the
validator, the evaluation runner, and the installer against temporary
directories, touching nothing real.

## Evaluations

Each skill carries an evaluation in its own directory stating when it should and
should not load, and what a correct response must and must not do. `make evals`
checks that those files are well formed and current; running the behavioral
cases needs an agent, and they are never installed. See [EVALS.md](EVALS.md).

Override any target location if your agent stores skills elsewhere:

```sh
make install CLAUDE_SKILLS_DIR=/path/to/skills
```

## Requirements

`make`, `ruby`, and a POSIX shell. Ruby is used only to validate front matter.

## Adapting a skill

If a skill is almost right but needs detail specific to your company, product,
or repository, do not fork it. Keep this version as the base and write a small
skill of your own that invokes it and adds only your delta. The base stays
upgradable, and your local knowledge stays where it belongs.

[AGENTS.md](AGENTS.md) describes what belongs in a skill here and what does
not.

## License

[MIT](LICENSE).
