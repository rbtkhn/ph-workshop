# Internal Audit Substrate

This internal substrate helps maintainers and agents inspect the completed Civilization spine and PH-CIV layer without changing transcript or reader-facing prose.

The workflow is:

```text
validate -> audit -> queue -> deepen -> revalidate
```

## Commands

- `.\scripts\validate-all.ps1 -StrategyRoot C:\dev\strategy-codex\codex\predictive-history`
- `.\scripts\audit-civilization-spine.ps1`
- `.\scripts\audit-ph-civ.ps1`
- `.\scripts\audit-review-queue.ps1`

`validate-all.ps1` is the default maintainer command. It runs the spine, PH-CIV, and orientation validators, regenerates tracked reports, scans public surfaces, checks stale placeholder-like language, and runs `git diff --check`.

## Reports

Tracked reports live in `reports/`:

- `civilization-spine-health.md` and `.json`
- `ph-civ-health.md` and `.json`
- `high-risk-review-queue.md` and `.json`
- `next-actions.md` and `.json`

Markdown reports are for maintainers. JSON reports are for future CLI or agent tooling. They are internal health snapshots, not polished reader-facing material.

## Guardrails

- Transcript bodies remain fidelity-bearing and must not be rewritten by audit guardrails.
- Public PH-CIV entries remain the reader-facing orientation layer.
- Neutral orientation payloads remain the active internal payload contract where routed.
- Warnings identify review work; hard failures are reserved for broken paths, invalid schema, validator failures, or public terminology leakage.
