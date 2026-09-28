---
name: work-in-flight
description: Help the user catch up on work in flight by summarizing requests, linked artifacts, remaining work, and lifecycle statuses.
---

# Work in Flight

When the user asks what they left unfinished or wants to catch up,
reconstruct the relevant work from conversations and project records.

Check the current artifacts and statuses where possible, then present a concise
table. For example, with hypothetical projects:

| Request | Artifacts | What remains | Status |
| ------- | --------- | ------------ | ------ |
| Add reminders to a to-do app | [Task T-12](https://example.com/tasks/T-12) | Implement and test reminders | `ready` (recorded) |
| Add WIP limits to a Kanban board | [PR #8](https://example.com/pulls/8) | Resolve review comments | `in_review` (inferred) |

Keep each row concise. Separate deliverables when they have different
statuses or remaining actions.

Use statuses from the user's project-management tools or records when available.
Otherwise, infer from current evidence using `draft`, `backlog`, `ready`,
`in_progress`, `in_review`, `blocked`, `done`, `cancelled`, or `archived`.
Mark inferred statuses as such; use `untracked` when the status is unclear.
Passing tests does not mean work is merged or delivered.

Link docs, specs, tickets, PRs, and results directly using absolute local
paths or verified URLs.
Clearly identify work that exists only locally.

Summarize the work without changing it or starting new tasks.
