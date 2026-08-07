---
name: document-runtime
description: Write documentation grounded in real execution paths. Use for runtime overviews, explainers, deep dives, walkthroughs, field-authority notes, and Mermaid-backed diagrams; not for future implementation specs, diff summaries, trivial file lists, or marketing copy.
metadata:
  short-description: Runtime-grounded docs
---

# Document Runtime

Trace first, document second. Use `execution-path-tracing` to establish the path and `cracked-debugging` when the goal is diagnosis rather than explanation.

## Grounding rules

- Read applicable repository guidance, target docs, contracts, and code before writing.
- Every important claim must come from a trace, contract, observed payload, or prior grounded investigation.
- Do not turn architectural intention into runtime fact. Mark unknowns explicitly.
- Distinguish authoritative state from synchronized, cached, derived, and presentation state.
- Write to the repository's established docs location, a user-provided path, or ask when the destination is material and unclear.

## Choose the narrowest useful form

- **Overview:** purpose, components, top-level path, boundaries, caveats.
- **Explainer:** behavior, main path, important modules, state/contracts, common variations.
- **Deep dive:** entrypoint, numbered trace, field flow, authority, branches, unknowns.
- **Walkthrough:** prerequisites, starting state, actions, observations, troubleshooting tied to real evidence.
- **Field note:** meaning, source of truth, transformations, consumers, common confusion.
- **Diagram-backed document:** use a Mermaid sequence, flow, or component diagram only when it clarifies the runtime.

## Workflow

1. Infer audience, question, depth, systems, fields/state, and target location.
2. Trace from the entrypoint or state origin, one hop at a time; record field flow, branches, and authority boundaries.
3. Extract the narrative spine and omit details that do not help that audience without breaking causality.
4. Use code references, tables, diagrams, and troubleshooting cues only when they improve understanding.
5. Verify the finished document against the traced path.

The result must clearly explain what happens, where it happens, which state is authoritative, which branches matter, what remains unknown, and how a reader can verify it.
