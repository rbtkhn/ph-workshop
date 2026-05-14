# Source Status Vocabulary

Use these labels so readers can see what is known, what is provisional, and what has been reviewed.

## Source Status

- `linked_only` - source URL recorded; no local source text imported.
- `metadata_checked` - title, URL, publication date, and source ID checked.
- `source_unavailable` - source link is missing, private, removed, or inaccessible.
- `source_disputed` - source identity, date, or canonical version needs review.

## Transcript Status

- `not_imported` - no transcript text in this repo.
- `machine_transcript_available` - machine transcript exists elsewhere but is not reviewed here.
- `machine_transcript_imported_pending_review` - machine transcript has been imported locally but still needs fidelity and curation review.
- `curated_transcript_pending_rights_review` - curated text exists but is not approved for public publication.
- `excerpted_with_review` - limited excerpts reviewed for public study use.
- `verified_transcript` - transcript checked against source and approved for public use under the repo's future source-text policy, with body fidelity meeting the exact-match benchmark.

## Transcript Fidelity

- `exact_body_match` - transcript body matches the source lecture body exactly after normalization; wrappers, frontmatter, and repository-specific headings are ignored.
- `normalized_exact_match` - same as `exact_body_match`; use when comparing files across formatting differences that do not change the transcript body.
- `needs_fidelity_review` - transcript body diverges from the source body and should be checked before public use.

## Transcript Fidelity vs. Interpretive Guardrails

Part I transcript bodies are fidelity-bearing artifacts. Guardrails for rhetoric, uncertainty, endorsement, contested claims, harmful wording, or present-day interpretation do not rewrite, soften, omit, or sanitize the verbatim transcript body.

Those guardrails apply to Part II commentary, PH-CIV placement entries, summaries, claims tables, limits sections, routing language, and public documentation. The repository preserves what was said in the transcript, then uses commentary and orientation surfaces to clarify status, uncertainty, evidence limits, and representation-not-endorsement.

## Annotation Status

- `not_started` - no public annotation yet.
- `drafted` - annotation exists but is not reviewed.
- `reviewed` - source anchors and basic interpretation checked.
- `needs_revision` - known problem remains.
- `public_ready` - suitable for student use.

## Review Status

- `unreviewed` - no maintainer review yet.
- `source_reviewed` - source identity and metadata checked.
- `quote_reviewed` - quotations or excerpts checked.
- `interpretation_reviewed` - summary and claims checked against source.
- `rights_review_required` - publication decision blocked on source-text rights.
