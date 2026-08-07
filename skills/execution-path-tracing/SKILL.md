---
name: execution-path-tracing
description: Trace real runtime paths across requests, webhooks, events, queues, callbacks, database reads/writes, and UI updates. Use for debugging, feature scoping, contract impact, runtime documentation, validation planning, or field-authority analysis.
metadata:
  short-description: Trace execution paths
---

# Execution Path Tracing

Use when causal runtime understanding matters more than a file-by-file summary.

## Rules

- Start from an actual entrypoint or authoritative state origin, then follow one real hop at a time.
- Ground claims in code, contracts, observed payloads, or runtime evidence. Mark unknowns explicitly.
- Track important values end to end: authoring, validation, persistence, transformation, fallback, and consumption.
- Separate authoritative state from synchronized, cached, derived, and presentation state.
- Keep external APIs, queues, event buses, databases, caches, UI stores, and permission boundaries explicit.

## Workflow

1. Identify the goal, entrypoint, expected outcome, components, fields, and available evidence.
2. Read applicable guidance and inspect the entrypoint, registrations, call sites, contracts, tests, and persistence boundaries.
3. Build a numbered trace. For every hop record trigger, input/state, handler, side effect/state change, error or fallback behavior, and next handoff.
4. Identify authority changes, branch conditions, retries, partial success, and externally visible effects.
5. Extract invariants and verify where they are enforced; flag risks such as swallowed failure, duplicate side effect, stale cache, or misleading UI state.
6. Shape the result for the task: diagnosis, feature scope, documentation, or validation plan.

## Output

Return the relevant trace, authority map, affected boundaries, important branches and invariants, unknowns, and concrete validation steps. Do not invent hidden writes, payloads, or transitions.
