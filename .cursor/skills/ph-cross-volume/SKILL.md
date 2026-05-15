---
name: ph-cross-volume
description: Use for adding or auditing Predictive History cross-volume corridors in corpus/cross-volume/ and registries/cross-volume-links.yaml with typed, source-grounded, non-causal edges.
---

# PH Cross-Volume

Use this skill for guided routes across Predictive History volumes.

## Operating Rules

- Add reader-facing corridors under `corpus/cross-volume/` and machine-readable edges in `registries/cross-volume-links.yaml`.
- Every edge must resolve to existing `chapter-manifest.yaml` endpoints.
- Use allowed relation types already established by the registry, such as `scale_shift`, `inheritance`, `revision`, `transmutation`, and `return`.
- Treat corridors as guided study paths, not causal proof. Keep guardrails explicit.
- Keep civ-ph entries orientation-first; corridor links should be compact pointers, not duplicate commentary.

## Validation

Run `scripts/validate-cross-volume-links.ps1` and `scripts/validate-all.ps1`. Manually inspect the corridor page to ensure it reads as a guided path and not a claim of sole historical causation.
