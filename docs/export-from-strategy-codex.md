# Export From Strategy-Codex

This public repository is not a mirror of the private working corpus.

Strategy-Codex is the private forge: it may contain raw intake, operator notes, drafts, backlog, experiments, and internal workflow language. This repo is the public instrument: it should contain only source-labeled, audience-readable material that is useful outside Strategy-Codex.

Predictive History may be populated from Strategy-Codex by curated migration, but this public repo does not write back into Strategy-Codex.

For transcript-backed chapters, Part I is the fidelity-bearing artifact and must match the source lecture body exactly after normalization.

Interpretive guardrails do not apply by editing the Part I transcript body. If a transcript contains difficult, mistaken, offensive, speculative, or high-risk wording, the export rule is to preserve the transferred wording for fidelity and handle the risk in Part II commentary, PH-CIV placement, limits sections, and public routing language.

## Export Rule

Material may enter this public repo only when it is:

- source-labeled
- readable by Jiang students without private context
- status-labeled
- free of private operator notes
- free of internal governance jargon
- useful as a public study artifact
- transcript bodies must meet the exact-body-match fidelity benchmark against the source lecture before being promoted into the public chapter file
- interpretive guardrails must be expressed outside the verbatim transcript body, in commentary and orientation surfaces

## Do Not Export

- private operator notes
- internal workbench backlog
- raw Strategy-Codex process files
- Record, Voice, gate, or companion-system artifacts
- unreviewed long transcript blocks
- machine-generated candidates without human review

## Export Metadata

Future public items should include:

- `source_id`
- `canonical_url`
- `publication_date`
- `source_reviewed_at`
- `exported_from_strategy_codex_at`
- source/transcript/annotation/review status fields

## Initial Process

1. Bootstrap standards only.
2. Manually select a tiny Geo-Strategy pilot.
3. Convert each selected item into the public annotation template.
4. Review source status, quote length, rights risk, timestamp anchors, and transcript fidelity.
   - Use [scripts/validate-transcript-fidelity.ps1](../scripts/validate-transcript-fidelity.ps1) to compare the source lecture body against the Part I transcript body.
5. Batch the update and record it in `CHANGELOG.md`.

Automation may come later, after the manual pilot proves the public shape.
