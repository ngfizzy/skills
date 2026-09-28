---
name: session-coordinator
description: Coordinate explicitly delegated work through native sessions while owning boundaries, lifecycle, evidence, replacement, and final reporting.
metadata:
  short-description: Coordinate delegated native sessions
---

# Session Coordinator

Use this skill only when the user explicitly invokes it or requests delegation.
If the user invokes this skill without a task, settings, or question,
acknowledge coordinator mode without asking questions, creating a worker, or
investigating a task.

The coordinator owns scope, sequencing, worker lifecycle, approvals, evidence
judgment, and the final report. For any task size, delegate requested research,
implementation, writing, testing, and review to a native session. Do not do
that work locally. The coordinator may inspect worker reports and artifacts to
judge their evidence.

## Host feature examples

These documented features are examples, not proof that a tool is enabled in the
current host. Discover callable tools before choosing a delegation path. A UI
that shows parallel sessions does not by itself let an agent create or address
another session.

| Surface | Documented feature |
| ------- | ------------------ |
| [Codex desktop](https://learn.chatgpt.com/docs/environments/git-worktrees) | Parallel chats in worktrees; background threads are documented in the [changelog](https://learn.chatgpt.com/docs/changelog). |
| [Codex CLI](https://learn.chatgpt.com/docs/agent-configuration/subagents) | Subagent threads, inspectable with `/agent`. |
| [Copilot in VS Code](https://docs.github.com/en/copilot/how-tos/chat-with-copilot/chat-in-ide) | `runSubagent` creates an isolated child within the chat. |
| [Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli/work-with-multiple-sessions) | Multiple CLI sessions; [`task` and `/fleet`](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-command-reference) run subagents. |
| [Copilot app](https://docs.github.com/en/copilot/how-tos/github-copilot-app/agent-sessions) | Parallel isolated sessions. |
| [Claude Code desktop](https://code.claude.com/docs/en/desktop) | Parallel Code-tab sessions, cross-session messaging, and in-session subagents. |
| [Claude Code CLI](https://code.claude.com/docs/en/sub-agents) | Subagents and conversation forks within a session. |
| [OpenCode TUI](https://opencode.ai/docs/agents) | Subagents create navigable child sessions. |

## Start and assign

1. Discover the host's callable session, model, and reasoning capabilities.
   Select and validate the model as described below before task investigation.
2. Create or reuse a healthy native session before inspecting task sources or
   running task commands. Give it a specific assignment: objective,
   acceptance criteria, constraints, permitted side effects, expected artifacts,
   validation, and checkpoint timing.
3. Reuse a session only for the same user objective, owning repository or
   artifact set, deliverables, required approvals, and lifecycle. Health,
   idleness, familiarity, or configuration alone does not justify reuse.
   Start a new session for unrelated work, including after the old objective
   completes.

If no native session can be created or reused, stop. Name the closest available
alternative, explain material differences in context, permissions,
observability, or cost, and request explicit permission. Use only that approved
alternative within its approved scope and permissions; refusal or silence
leaves the task blocked. Alternatives may include a subagent, external or CLI
worker, or direct execution when appropriate. No fallback is implicit.

## Keep work owned

Before any task-specific action and after each worker checkpoint, ensure a
healthy worker owns the next unfinished acceptance criterion. An idle or
completed worker is not an owner. Delegate the next assignment or a replacement
handoff before task work continues. If the host's session tool is unavailable,
request explicit permission as described above. End delegation only after
every criterion has been independently verified.

Require checkpoints with status, scope, progress, artifacts, validation, risks,
and the next action. Treat repeated context loss, contradictions, missed
criteria, or lack of progress as degradation. Replace the worker through its
recorded identity, preserving the handoff reason, objective, constraints,
selected model and path, verified facts, artifacts, unfinished criteria,
validation, risks, and one precise next action.

## Select model and reasoning

If the host exposes no usable worker models, report that delegation cannot
start. Do not ask the user to choose from an empty list or create a worker.

When the user first assigns work through this skill, ask them to choose a model
from the host's available models, unless they already supplied one. Validate
the choice before creating a worker; do not guess or substitute a model. The
chosen model remains the session default until the user changes it.

When the host allows reasoning selection, choose its level for each assignment
based on that assignment's complexity. Otherwise use the host's available
setting without claiming to control it. Validate the complete model and
reasoning pair before delegation.

The user may change the session's model or reasoning choice mid-session. Apply
the change to subsequent assignments, with user-selected reasoning taking
precedence over complexity-based selection until changed. A task-specific
override affects only that worker unless the user says to change the session
default. If an active worker cannot adopt a validated change, replace it with
the context-preserving handoff above.

Keep model and reasoning choices within the current coordinator session. Do not
save them in durable memory or carry them into a later session.

## Verify and report

Judge worker evidence against each acceptance criterion; delegate independent
verification when useful. Separate verified facts from worker claims,
uncertainty, unresolved work, and the next action in the final report. A
worker's completion claim alone is not proof.

Preserve approval gates for commits, pushes, pull requests, external writes,
destructive actions, and billable work. Neither coordinator nor worker may
expand the assigned scope or permissions by inference. Exclude secrets, private
identifiers, and unnecessary source material from prompts and handoffs;
preserve unrelated changes and report only work actually observed.
