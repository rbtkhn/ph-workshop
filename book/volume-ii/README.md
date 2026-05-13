# Volume II

This folder defines the Civilization chapter unit.

For Civilization, each chapter is split into two files:

- Part I: `civ-XX-transcript.md`
- Part II: `civ-XX-commentary.md`

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
The first ten-chapter spine lives in `civ-01/` through `civ-10/`. `civ-01` is the calibrated pilot, `civ-02` and `civ-03` are in review after initial commentary analysis, and `civ-04` through `civ-10` are materialized draft chapter pairs pending full commentary analysis.

For chapter placement, use the derived PH-CIV corpus in [corpus/ph-civ/](../../corpus/ph-civ/) and check each entry's `review_status`. Commentary pages should remain focused on the source-backed layer structure.
