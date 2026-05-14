# Predictive History YouTube Channel Cache

This directory holds the local metadata and raw-caption cache for Predictive History channel transcript work.

Tracked files:

- `index.json`: lightweight channel/video index.
- `transcript_manifest.json`: caption acquisition metadata.
- `CHANNEL-VIDEO-INDEX.md`: human-readable index.
- `transcripts/README.md`: raw-cache rules.

Raw caption files under `transcripts/*.txt`, `transcripts/*.vtt`, and `transcripts/*.srt` are ignored by default. They are acquisition artifacts, not quote-grade text.
