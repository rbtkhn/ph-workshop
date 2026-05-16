# Volume II

This folder defines the Civilization chapter unit.

For Civilization, each source item is represented by two main files:

- Source transcript: `civ-XX-transcript.md`
- Commentary: `civ-XX-commentary.md`

The source transcript is fidelity-bearing. Its transcript body should preserve the transferred source wording exactly after normalization, even when the wording is contested, high-risk, speculative, or uncomfortable. Do not use interpretive guardrails to rewrite the transcript body.

The commentary is interpretation-bearing. Apply guardrails there: status labels, neutral summaries, source-backed claims, counter-readings, limits, representation-not-endorsement, and explicit handling of uncertainty or live-current risk.

The commentary file uses the versioned multi-layer scaffold in `civ-XX-commentary.md`:

- Layer 0 - Metadata & Quick Reference
- Layer 1 - Neutral Summary
- Layer 2 - Source-Backed Claims & Concepts
- Layer 3 - Predictions & Falsifiers
- Layer 4 - Counter-Readings & Alternative Interpretations
- Layer 5 - Synthesis & Cross-Volume Links
- Layer 6 - Open Issues & Future Research

Template rules:

- Civilization only; do not retrofit Geo files to this structure.
- Keep the layer order stable so parsers and reviewers can rely on it.
- Use line-level transcript references in Layer 2.
- Keep Layer 1 paraphrased and neutral.
- Keep Layer 6 internal and review-oriented.
- Use `draft`, `in-review`, or `complete` in the completeness state fields.

The transcript companion path is recorded in the commentary frontmatter.
The first sixty-chapter spine lives in `civ-01/` through `civ-60/`. `civ-01` is the calibrated pilot, and `civ-02` through `civ-60` are in review after initial commentary analysis.

For civ-ph placement, use the derived civ-ph corpus in [corpus/civ-ph/](../../corpus/civ-ph/) and check each entry's `review_status`. Commentary pages should remain focused on the source-backed layer structure.
