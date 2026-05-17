# Predictive History Museum

The Predictive History Museum is the public artifact-exhibit layer for the project. The target end state is one curated exhibit per chapter across **Predictive History: Civilization** and **Predictive History: Apocalypse**.

The internal repo path can remain `corpus/media-packs/` for compatibility, but the source of curatorial work is not a flat spreadsheet. The source of curatorial work is a chapter exhibit with stored artifacts, metadata, wall labels, room placement, and rights status.

## Non-Negotiable Storage Rule

URL-only artifacts are not acceptable. A source URL is provenance, not storage.

Every museum artifact must be stored in both:

- a local museum vault
- a shared document cloud workspace such as Google Drive, Dropbox, SharePoint, or another approved shared service

GitHub should not store large binary artifacts. GitHub stores lightweight manifests, generated exhibit pages, validators, schemas, and pointers to the local/cloud artifact IDs.

## Chapter Folder Contract

Each chapter exhibit should have one folder in the local vault and the shared cloud workspace:

```text
Predictive History Museum/
  civilization/
    civ-053-dostoevsky-and-the-soul-of-russia/
      index.md
      exhibit.yaml
      artifacts/
        001-russian-orthodox-chant/
          metadata.yaml
          original/
          derivatives/
          notes/
        002-dostoevsky-manuscript-page/
          metadata.yaml
          original/
          derivatives/
          notes/

  apocalypse/
    gt-021-live-crisis-pressure/
      index.md
      exhibit.yaml
      artifacts/
```

Use zero-padded artifact folders so ordering is stable. Use short, lowercase, hyphenated slugs.

## Artifact Folder Contract

Each artifact folder contains:

```text
metadata.yaml
original/
derivatives/
notes/
```

For images:

```text
001-achilles-ajax-amphora/
  metadata.yaml
  original/
    achilles-ajax-amphora.jpg
  derivatives/
    thumb.webp
    display.webp
  notes/
    curator-note.md
```

For music or audio:

```text
001-russian-orthodox-chant/
  metadata.yaml
  original/
    source-audio.ext
  derivatives/
    preview.mp3
    waveform.webp
  notes/
    curator-note.md
```

For texts or documents:

```text
001-code-napoleon/
  metadata.yaml
  original/
    code-napoleon.pdf
  derivatives/
    thumb.webp
    excerpt.txt
  notes/
    curator-note.md
```

## Exhibit Manifest

Each chapter folder has an `exhibit.yaml`:

```yaml
chapter_id: civ-53
museum_part: civilization
title: "Civilization #53: Dostoevsky and the Soul of Russia"
status: curated_draft
local_exhibit_path: "Predictive History Museum/civilization/civ-053-dostoevsky-and-the-soul-of-russia"
cloud_exhibit_path: "Predictive History Museum/civilization/civ-053-dostoevsky-and-the-soul-of-russia"
artifact_count: 5
rooms:
  entrance_artifact:
    - civ-053-001
  context_room:
    - civ-053-002
  primary_artifacts_and_texts:
    - civ-053-003
  comparison_artifacts:
    - civ-053-004
  pressure_systems:
    - civ-053-005
return_paths:
  civ_ph_path: corpus/civ-ph/civ-53.md
  transcript_path: book/volume-ii/civ-53/civ-53-transcript.md
  commentary_path: book/volume-ii/civ-53/civ-53-commentary.md
```

## Artifact Metadata

Each artifact has `metadata.yaml`:

```yaml
artifact_id: civ-053-001
chapter_id: civ-53
museum_part: civilization
room: entrance_artifact
title: "Russian Orthodox chant"
item_type: music
local_original_path: original/source-audio.ext
cloud_original_path: "Predictive History Museum/civilization/civ-053-dostoevsky-and-the-soul-of-russia/artifacts/001-russian-orthodox-chant/original/source-audio.ext"
source_url: "https://..."
source_name: "..."
rights_status: needs_review
storage_status: local_and_cloud
checksum_sha256: "..."
what_to_notice: "..."
lecture_connection: "..."
what_this_cannot_prove: "..."
curator_note: "..."
```

## Rooms

- `entrance_artifact`: the one artifact that opens the chapter's world
- `context_room`: maps, places, institutions, timelines, or background artifacts
- `primary_artifacts_and_texts`: objects, documents, texts, recordings, or artifacts closest to the lecture's subject
- `comparison_artifacts`: artifacts that show contrast, reception, memory, or alternative framing
- `pressure_systems`: diagrams, infrastructure, weapons, finance, geography, institutions, or pressure fields
- `caution_room`: artifacts that are powerful but easy to overread

## Artifact Types

Use the narrowest useful `item_type`:

- `artwork`
- `artifact`
- `object`
- `text`
- `manuscript`
- `map`
- `place`
- `portrait`
- `chart`
- `diagram`
- `music`
- `speech`
- `document`
- `performance`
- `architecture`
- `institution`
- `pressure_system`
- `symbolic_artifact`

## Rights Status

Use one of:

- `public_domain`
- `open_license`
- `external_link_only`
- `needs_review`
- `unavailable`

Even when an artifact is stored locally and in cloud storage, the source URL remains required for provenance. Rights status controls publication, mirroring, derivatives, and public display.

## Bounty Acceptance Standard

A bidder has not completed the museum by submitting a flat table of artifact rows.

A complete submission must provide:

- chapter folders, not just rows
- one finished exhibit per claimed chapter
- 5-15 artifacts per exhibit
- local artifact files
- shared-cloud artifact files
- `exhibit.yaml` per chapter
- `metadata.yaml` per artifact
- room placement for every artifact
- rights status for every artifact
- wall labels with what to notice and what this cannot prove
- checksums for stored files
- return paths to civ-ph, transcript, and commentary

Rows may be useful as exports generated from exhibits. Rows are not the source of truth.

## Human Curator Responsibilities

Human curators must:

- choose the entrance artifact
- approve, replace, or remove agent-suggested artifacts
- find non-obvious artifacts such as music, ritual objects, local documents, tools, performances, maps, or architecture
- check sacred, traumatic, political, ethnic, religious, colonial, or otherwise sensitive material
- balance elite, imperial, state, ordinary, local, sonic, textual, and counter-perspective artifacts
- verify source quality
- set rights status
- calibrate emotional distance
- approve wall labels
- give final exhibit sign-off
