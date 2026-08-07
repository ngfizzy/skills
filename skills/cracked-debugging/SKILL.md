---
name: cracked-debugging
description: Diagnose unclear bugs by tracing normal and failing runtime paths to the earliest divergence and smallest viable fix point. Use for cross-component, timing, async-state, webhook, queue, SDK-callback, or authority-versus-UI failures before implementation.
metadata:
  short-description: Runtime-first debugging
---

# Cracked Debugging

This is `execution-path-tracing` focused on causal diagnosis. Do not implement changes until the user asks after diagnosis.

## Grounding

- Read applicable repository guidance, runtime docs, and relevant contracts.
- Gather or infer the symptom, expected behavior, reproduction, entrypoint, fields/state, components, and available evidence.
- Ground claims in code paths, contracts, payloads, logs, or screenshots. Mark unknowns rather than guessing.
- Treat rendered state, documentation, labels, and queue names as non-authoritative until code or contracts prove otherwise.

## Workflow

1. Trace from the actual entrypoint one hop at a time, including requests, callbacks, events, queues, state updates, reads/writes, and renders.
2. For each hop record component, trigger, input/state, handler, effect/state change, and next handoff.
3. Trace relevant fields from authoring through transformation and consumption; classify each as authoritative, synchronized, cached, derived, or presentation-only.
4. Compare the normal and failing paths to identify the earliest divergence.
5. Classify the divergence: data, timing, state ownership, event wiring, policy/configuration, or an external boundary.
6. Identify the narrowest safe fix point and the adjacent layers that should remain unchanged.
7. State unknowns, evidence needed to resolve them, and the highest-value regression or manual checks after a fix.

## Output

Return a causal summary, numbered trace, authority map, normal-vs-failing comparison, earliest divergence, smallest viable fix point, unknowns, and suggested tests.
