# Improvement Loops

Internal maintainer snapshot for Predictive History recursive quality loops.

Loop model: `validate -> audit -> queue -> deepen -> revalidate`
Status: warnings
Warning count: 50

| loop | status | warnings | next action |
| --- | --- | --- | --- |
| Structural Integrity Loop | clean | 0 | Repair manifest paths, missing routed files, invalid metadata, or validator failures. |
| Source Fidelity Loop | clean | 0 | Use explicit transcript-fidelity workflow before repairing curated transcript bodies. |
| Interpretive Constraint Loop | warnings | 50 | Work the highest-priority guardrail queue, then regenerate reports. |
| Orientation Coherence Loop | clean | 0 | Update civ-ph or orientation payloads only where alignment fails. |
| Cross-Surface Routing Loop | clean | 0 | Repair missing routing/report surfaces, then run cross-volume and media-pack validation. |

## Failure Boundaries

- **Structural Integrity Loop:** Broken paths, missing required files, invalid schema, or validator failures are hard failures.
- **Source Fidelity Loop:** Guardrail review must not mutate transcript bodies.
- **Interpretive Constraint Loop:** Review-depth gaps remain warnings; public terminology leakage and unsupported confidence must be corrected.
- **Orientation Coherence Loop:** civ-ph remains orientation, not transcript, source substitute, endorsement, or second commentary.
- **Cross-Surface Routing Loop:** Corridors and media packs orient study; they do not prove causal claims or override chapter source status.
