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
The first pilot chapter lives in [civ-01/](civ-01/) and follows this scaffold in a dedicated chapter folder.

For CIV-MEM calibration units, the commentary file can render a top-level `## CIV-MEM Context` block from a chapter-local YAML payload sidecar. The shared doctrine lives in [docs/civ-mem.md](../../docs/civ-mem.md).
