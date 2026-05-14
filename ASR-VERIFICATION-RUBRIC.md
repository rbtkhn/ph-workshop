# ASR Verification Rubric

Use this rubric to describe how deeply a transcript segment has been checked.

## Depth A: Structural Capture

- Captions were acquired and stored.
- Manifest metadata exists.
- No claim of quote-grade accuracy.
- Suitable for routing, rough search, and triage.

## Depth B: Targeted Review

- A bounded passage or recurring ASR issue was checked.
- Known safe replacements may be applied.
- Uncertain terms remain marked.
- Suitable for internal commentary support, not polished quotation unless the quoted line itself was verified.

## Depth C: Quote-Grade Review

- The passage was checked against video/audio or a reliable timestamped raw segment.
- Proper nouns, dates, and unclear words were resolved or explicitly marked.
- The wording preserves the lecturer's meaning and cadence.
- Suitable for `metadata/quotes.yaml`, chapter prose, or manuscript use.

Do not claim full proofreading unless the full relevant transcript has received depth-C review.
