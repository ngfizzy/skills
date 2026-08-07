# AGENTS.md

This repository holds portable agent skills. Each direct child of `skills/` is
one installable skill and must contain `SKILL.md`. Use the Makefile for
validation and installation; do not add or remove installed copies by hand.

## Content boundary

A skill here must be useful to someone with no knowledge of the person or
organization that wrote it. Nothing in this repository may contain:

- names, usernames, contact details, machine paths, or session-state locations;
- company, client, project, repository, service, team, ticket, or environment
  identifiers;
- internal URLs, credentials, customer data, or proprietary payloads;
- procedures that only make sense inside one organization's tooling.

Technology is not the boundary — specificity is. Naming a test runner, a
framework, a transport, a queue, or a deployment pattern is fine when the
guidance holds for anyone using it. Naming *your* service, *your* pipeline, or
*your* review process is not.

This repository is public. Anything committed here is disclosed permanently,
including through the commit history, and may be copied or archived beyond your
control. Review a diff against this boundary before proposing it, not after.

## Writing a skill

A skill changes how an agent behaves. It is not a reference manual.

1. State when the skill applies and when it does not. The `description` front
   matter is what an agent matches against, so it must describe the triggering
   situation, not just the topic.
2. Give the agent decisions to make and an order to make them in. Prefer a
   short workflow, a classification, or a set of criteria over prose that
   restates good intentions.
3. Keep guardrails, sequencing, and validation steps explicit. These are the
   parts most likely to be dropped during editing and the most costly to lose.
4. Say what the finished output must demonstrate. An agent needs a way to
   check its own work.
5. Prefer the shortest version that still produces the behavior. Length costs
   context and dilutes the instructions that matter.

Cross-references between skills in this repository are allowed and encouraged.
Do not reference a skill that does not exist here.

## Adapting rather than forking

When a skill is nearly right but needs detail specific to an organization,
product, or repository, keep this version as the base and write a separate
skill that invokes it and supplies only the local delta. Do not copy the
workflow into the adaptation; an adaptation that restates its base will drift
from it.

Name the full chain in the adaptation so a reader knows what runs first, and
keep the chain shallow. Every additional layer is another file an agent must
load, and another description competing to trigger on the same request.

## Changing an existing skill

Skills are installed and relied upon. Before proposing a change:

1. Identify the behavior, guardrails, and decision points the current version
   produces.
2. Make the change without weakening a necessary safety, sequencing, or
   validation instruction. Removing verbosity is welcome; removing a
   distinction is not.
3. Consider how an agent already following the current version would behave
   differently, and say so in the change description.
4. Run `make check` and `make test`.

Renaming a skill changes its installed path and silently strands the old copy
on every machine that installed it. Treat a rename as a breaking change and say
so.

## Keep changes focused

One skill or one coherent concern per change. Do not add generated install
artifacts, editor configuration, credentials, or unrelated documentation.
