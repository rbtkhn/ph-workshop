---
name: ph-audit
description: Use for Predictive History repository health checks, including spine validation, transcript fidelity checks, civ-ph health, cross-volume links, high-risk review queue, and next-actions reports.
---

# PH Audit

Use this skill for read/check/report work across the repo. Default posture is diagnostic: run validators, inspect reports, summarize risk, and avoid content rewrites unless separately requested.

## Operating Rules

- Prefer `scripts/validate-all.ps1` for full repo health.
- Use family validators for focused checks: Civilization spine, Great Books spine, civ-ph, orientation payloads, cross-volume links, transcript skill, and transcript substrate.
- Use audit scripts for maintainer reports: spine health, civ-ph health, high-risk review queue, and next actions.
- Treat warnings as review queues unless a validator marks them as hard failures.
- Do not edit transcript bodies, commentary, civ-ph entries, or reports while performing an audit unless the user asks for remediation.

## Validation

Run `scripts/validate-all.ps1 -StrategyRoot C:\dev\strategy-codex\codex\predictive-history` when the transfer authority is available. Summaries should distinguish hard failures, expected warnings, and existing dirty working-tree changes.
