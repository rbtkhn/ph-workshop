# Weekly Review Sprint

Internal maintainer sprint selected from the high-risk review queue.

Sprint model: `validate -> audit -> select sprint -> deepen selected items -> revalidate`
Selected items: 5
Queue count: 50
Improvement loop status: warnings

## Sprint Items

| source_id | priority | flags | next action |
| --- | --- | --- | --- |
| `civ-24` | high | seeded-known-risk, religious-formation | manual guardrail and external-review triage |
| `civ-25` | high | seeded-known-risk, religious-formation | manual guardrail and external-review triage |
| `civ-31` | high | seeded-known-risk, live-current-or-war-prediction, political-analogy-or-date-sensitive | manual guardrail and external-review triage |
| `civ-32` | high | seeded-known-risk, live-current-or-war-prediction, violence-or-state-terror, political-analogy-or-date-sensitive | manual guardrail and external-review triage |
| `civ-43` | high | seeded-known-risk, religious-formation, political-analogy-or-date-sensitive | manual guardrail and external-review triage |

## Allowed Action

For each selected item, deepen limits, clarify counter-readings, and add uncertainty or source-status notes in commentary or civ-ph. Do not edit transcript bodies as part of sprint work.

## Validation Return Path

After sprint work, rerun `.\scripts\audit-review-queue.ps1`, `.\scripts\audit-improvement-loops.ps1`, `.\scripts\audit-review-sprint.ps1`, and `.\scripts\validate-all.ps1`.
