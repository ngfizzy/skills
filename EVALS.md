# Evaluations

Each skill carries an `eval.yaml` beside its `SKILL.md`. It states when the
skill should and should not load, and what a correct response must and must
not do.

They sit inside the skill directory so they move with it — a skill is copied
between repositories as a whole directory, and an evaluation kept somewhere
else is a second thing to remember. The installer strips `eval.yaml` before a
skill reaches an agent, because an evaluation is development material and its
assertions are phrased as instructions an agent could act on.

## What is checked automatically

`make evals` validates structure only, offline:

- every skill has an evaluation, and it names the skill it sits beside;
- triggers discriminate in both directions, with at least two cases each;
- every redirect in `instead` names a skill that exists here;
- `requires` matches the skill body in both directions — a declared dependency
  must be mentioned in `SKILL.md`, and a sibling skill mentioned in `SKILL.md`
  must be declared;
- every behavioral case states a scenario and at least one assertion.

This tells you the evaluations are well formed and current. It does not tell
you whether a skill triggers or behaves correctly — no agent runs. A reference
to a skill outside this repository cannot be detected here either; review
catches that.

## Running the behavioral cases

These need an agent, and they are read as a rubric rather than scored
automatically.

For a trigger case, start a fresh session with the skills installed, give the
agent the `situation` verbatim as the user turn, and record which skills it
loaded. A `should_load` case passes when the named skill loads. A
`should_not_load` case passes when it does not; if the case names `instead`,
that skill should load in its place.

For a behavioral case, give the agent the `given` scenario with the skill
available, then check the response against each `must` and `must_not`. A case
passes only when every assertion holds. Assertions are written to be decidable
by reading the response — if you find yourself debating one, it is too vague
and should be rewritten.

Use a fresh session per case. Skills loaded earlier in a session change what
gets loaded later, which is exactly what a trigger case is trying to measure.

## Format

```yaml
skill: <name of the skill directory this file sits in>

requires:            # sibling skills this skill references, may be empty
  - <skill-name>

triggers:
  should_load:
    - situation: <what the user says or asks for>
      because: <why this skill is the right one>
  should_not_load:
    - situation: <a nearby case this skill should decline>
      because: <why it is out of scope>
      instead: <skill that should handle it, optional>

behaviors:
  - name: <short label>
    given: <the scenario the agent is placed in>
    must:
      - <observable property of a correct response>
    must_not:                                    # optional
      - <observable property of an incorrect response>
```

## Writing cases that earn their place

Put the effort into `should_not_load`. Whether a skill fires on its obvious
case is rarely the problem; whether it fires on a neighbor's case is. The
useful cases sit on the boundary between two skills here, close enough that
either could plausibly claim them.

Write assertions about what the response does, not about its tone. "Retains
the field name `order_state`" can be checked. "Is well written" cannot.

When a skill changes, update its evaluation in the same change. An evaluation
describing the previous version is worse than none, because it will pass.
