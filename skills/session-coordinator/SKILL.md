---
name: session-coordinator
description: Coordinate explicitly delegated work through native sessions while owning boundaries, lifecycle, evidence, replacement, and final reporting.
metadata:
  short-description: Coordinate delegated native sessions
---

# Session Coordinator

Use this skill when a coordinator should delegate execution but remain
accountable for the objective, sequencing, evidence, quality gate, and final
report. A worker owns task-specific execution; the coordinator owns
orchestration.

Do not activate this skill for an implicit match. If the user has not
explicitly invoked the coordinator or requested delegation, decline coordinator
behavior and leave the task to the normal workflow.

## Invocation contract

An explicit invocation with a task or configuration always enters delegation
mode. When a healthy native session can be created or reused, native-session
delegation is mandatory: the coordinator delegates every requested research,
implementation, writing, testing, and review action to that session and does
not perform those actions itself. There is no simple-task exception. The sole
exception is the consent-gated native-unavailable path below: after explicit
user approval, the coordinator may use only the specifically recommended
alternative, including direct execution, a native subagent, an external
worker, or a CLI worker, within the approved boundary. No fallback is silent or
inferred.

A bare invocation with no task or configuration only acknowledges coordinator
mode. It asks no question, starts or reuses no worker, and performs no task
investigation.

For a non-bare invocation:

1. Discover the harness's documented native session/thread and model
   capabilities. Do not infer a capability, command, or model identifier.
2. Validate the model and reasoning selection against the discovered
   capabilities.
3. Create or reuse a related healthy native session before any task-specific
   investigation. Do not inspect task sources, reproduce behavior, design a
   solution, write artifacts, run tests, or review the task before that session
   is ready.
4. Assign the complete task boundary and required evidence to that session.

If native session creation or reuse is unavailable, stop and report that
task execution cannot continue through the preferred path. Identify the
closest available alternative that best preserves the requested delegation
outcome, such as a native subagent, external worker, CLI worker, or direct
execution when appropriate. State the material differences and limitations,
including context, permissions, observability, and cost where relevant, then
ask the user for explicit permission to use the named alternative. No
alternative may start before that approval. If the user refuses or does not
respond, leave the task stopped and report it as blocked. After approval, use
only the approved alternative within the approved boundary and report the
degradation honestly; do not broaden the fallback.

## Model and reasoning selection

When the invocation supplies no model or reasoning override, use
`gpt-5.6-luna` with `high` reasoning. Use `max` only for unusually complex or
high-risk coordination. `low` reasoning is forbidden, including
`gpt-5.6-luna` with `low`; if the default pair is not exposed, report the
limitation rather than substituting another pair.

A model or reasoning override is per-invocation only. Resolve an omitted field
to the default, then validate the complete pair against the harness
capabilities before delegation. Reject an unsupported combination without
substitution or worker execution. Never persist an override; an invocation
that omits it returns to `gpt-5.6-luna` with `high`.

If a validated override applies to ongoing work and the active native session
cannot change model or reasoning in place, create a replacement native session
with a context-preserving handoff. Preserve verified facts, artifacts,
acceptance criteria, validation, risks, and incomplete work; retire or
supersede the old session through its recorded native identity rather than
restarting from scratch.

## Coordinator responsibilities

The coordinator owns:

- the objective, acceptance criteria, boundaries, and sequencing;
- native session creation, reuse, lifecycle, and replacement;
- bounded checkpoints and required status reports;
- delegation of independent verification, testing, and review;
- evidence judgment against the acceptance criteria; and
- the final report, including uncertainty and the next precise action.

On the native path, the coordinator does not own worker execution. It may
inspect orchestration reports and produced artifacts for evidence, but
task-specific investigation, implementation, writing, testing, and review
remain delegated. On the consented fallback path, it remains accountable for
the approved boundary and may use only the approved alternative.

## Delegation lifecycle

Give each worker one owner-sized boundary with:

- objective, acceptance criteria, and relevant authoritative context;
- constraints, non-goals, and allowed side effects;
- expected files, artifacts, or result shape;
- validation commands or evidence expected; and
- checkpoint timing and a completion-report contract.

At bounded checkpoints, require:

```text
Status: queued | running | blocked | completed
Scope: what this worker owns
Progress: what changed since the last checkpoint
Artifacts: files, links, or result identifiers
Validation: checks run and their outcomes
Risks: open questions, failures, or unverified claims
Next action: the precise next step or handoff needed
```

Reuse a related healthy native session when its goal, authority, artifacts,
permissions, and boundary still match. Delegate independent verification to a
separate native session when it is useful; do not treat the implementation
worker's report as proof without checking its evidence against the
requirements.

Treat repeated context loss, contradictory claims, missed acceptance criteria,
or lack of progress as degradation. Preserve the last verified state and use a
context-preserving replacement handoff rather than discarding the work.

On normal completion, independently judge the evidence against every acceptance
criterion. The final report must separate verified evidence from worker claims,
list unresolved items or uncertainty, and state the precise next action; a
worker's completion claim alone is not completion evidence.

## Context-preserving handoff

Use this structure when replacing an active session:

```text
Handoff reason: <stale context | contradiction | blocked capability | no progress | model change>
User objective: <original outcome>
Constraints and non-goals: <must preserve>
Selected model/reasoning: <validated pair for this invocation>
Delegation path: <native session>
Verified facts: <evidence, commands, and decisions>
Current artifacts: <files, links, identifiers, and ownership>
Incomplete work: <remaining acceptance criteria>
Validation: <checks passed, failed, or not run>
Risks and open questions: <unresolved items>
Exact next action: <one concrete step for the replacement worker>
```

## Approval and safety gates

Preserve approval gates for commits, pushes, pull requests, external writes,
destructive operations, and billable work. A worker may act only within the
permissions explicitly granted for its boundary; neither the coordinator nor a
worker may infer approval.

Keep secrets, tokens, private identifiers, and unnecessary source material out
of prompts, handoffs, stored configuration, and reports. Do not discard
unrelated changes or claim to have observed work, validation, or future events
that were not actually inspected.
