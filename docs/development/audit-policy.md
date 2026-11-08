# Audit policy

- Review each task before completion. Check acceptance criteria, changed behavior, compatibility, ownership, lifecycle, errors, test coverage and unintended changes. Keep the depth proportional to the task.
- Recommend a broader audit after roughly four to six completed feature tasks. Count feature tasks from the last broader audit and sample related systems for recurring defects, coupling and verification gaps.
- Review architecture at major milestones and before adopting changes with lasting cross-system impact. Compare the implementation with accepted ADRs and examine dependency direction, data ownership, migration and operational risks.

## Severity and disposition

| Severity | Criteria | Disposition |
| --- | --- | --- |
| Critical | Credible data loss, security exposure or widespread project failure | Stop affected work and contain or fix immediately. |
| High | Reproducible major regression, broken shared contract or blocker to acceptance | Resolve before completing the affected task. Escalate if the fix crosses an approval boundary. |
| Medium | Bounded correctness, maintainability or test risk with a credible impact | Fix within scope if practical. Otherwise record and prioritize it. |
| Low | Localized improvement with limited demonstrated impact | Defer unless the fix belongs in the current scope. |

Rate impact and likelihood using observed behavior, reproductions or concrete code paths. Avoid filing stylistic preferences as defects.

## Reporting and debt

For each actionable finding, record severity, file or symbol, evidence or reproduction, impact, proposed remediation and how to verify the fix. Summarize review scope, checks performed and gaps. Identify deferred findings explicitly.

Track significant deferred debt in the project's issue tracker or task backlog. Record the owner, rationale for deferral, the condition or milestone that should trigger reconsideration, and the link to the finding. Revisit open items during broader audits and milestone reviews.
