---
name: better-docs
description: Write, rewrite, review, or explain technical documentation with direct, precise, runtime-grounded language. Use for RFCs, tickets, handoffs, notes, architecture explanations, or inline clarification; create or edit a file only when the user explicitly asks for an artifact.
---

# Better Docs

Make technical writing easy to parse without weakening its meaning.

## Output mode

Respond inline when the user asks to explain, clarify, or rewrite text. Create or edit a document only when they explicitly request a file, note, knowledge-base entry, or documentation update.

Use `document-runtime` for a durable runtime explainer, deep dive, or walkthrough. Do not invoke it merely because the user asks for clearer prose.

## Voice

- Lead with the real problem, decision, or observed behavior.
- Use concrete subjects and active claims. Name the owning boundary and what stays unchanged.
- Keep code identifiers, field names, state names, API values, and technical terms when they carry contract meaning.
- Separate facts, decisions, assumptions, risks, validation, and open questions.
- Prefer short paragraphs, tables for contracts or state, numbered steps for flows, and bullets for requirements or risks.

Avoid vague labels such as “handling,” “support,” or “integration” unless the text defines the exact behavior. Do not replace precise terms with friendlier but incorrect language.

## Editing discipline

Simplify syntax, not semantics. Before changing text, classify the problem:

- **unclear:** actor, behavior, owner, or consequence is missing
- **ambiguous:** multiple technical readings are possible
- **overcompressed:** concise wording hides runtime meaning
- **verbose:** wording repeats or cushions meaning
- **precise enough:** technical but accurate and scannable
- **meaning at risk:** further simplification would remove a necessary distinction

When rewriting, identify the real subject and action, retain necessary terms, split dense qualifiers into a second sentence when useful, and state the consequence plainly.

## Technical tickets and handoffs

- Make the outcome, owner, scope, non-goals, and acceptance criteria explicit.
- Describe concrete change points only when they improve implementation clarity; do not turn a ticket into a full design document.
- Make acceptance criteria prove outcomes rather than repeat implementation bullets.
- Do not include private paths, agent workflow history, or irrelevant process notes in human-facing artifacts.

Before returning, review once for vague ownership, duplicated requirements, false certainty, and simplifications that damaged technical meaning.
