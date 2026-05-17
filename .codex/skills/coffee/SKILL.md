---
name: coffee
description: Compatibility opening alias for Predictive History workshop chats; route coffee to ph-open instead of a generic greeting.
---

# Coffee

Use this skill when the operator says `coffee` in `ph-workshop`.

This is a compatibility alias, not the Strategy-Codex coffee menu. Do not emit a generic coffee greeting.

## Route

- Use `ph-open`.
- Run `scripts/ph-civ-open.ps1` when the chat is about `ph-civ` population, bridge readiness, candidate review, or public export.
- Summarize the current repo identity: `ph-workshop` is the Predictive History editorial workshop; `ph-civ` is the existing public repository and public surface.
- Report whether population is blocked or eligible.
- Treat `candidate` as review-only. Only `approved` or `exported` routes are population-eligible.

## Boundary

Do not copy transcripts, commentary bodies, private notes, museum binaries, or workshop-private material into `ph-civ` during coffee/opening.
