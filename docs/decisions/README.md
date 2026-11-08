# Architecture decision records

Use an ADR for a significant choice with lasting consequences, such as a cross-system boundary, foundational dependency or persistent data contract. Use the task proposal for routine implementation choices.

Create `NNNN-short-title.md` with the next available number. Start it as **Proposed**, link the design task and request approval where required by [AGENTS.md](../../AGENTS.md). Mark it **Accepted** after approval and record the decision date. If a later accepted ADR replaces it, mark the original **Superseded** and link both records. Preserve the original rationale.

## Template

~~~markdown
# NNNN — Decision title

Status — Proposed | Accepted | Superseded
Date — YYYY-MM-DD
Related task or ADR — link

## Context and problem
What must be decided, and under what constraints?

## Alternatives
Which viable options were considered, and how did they compare?

## Decision and rationale
What was chosen, and why?

## Consequences and trade-offs
What becomes easier or harder? What needs migration, verification or follow-up?
~~~
