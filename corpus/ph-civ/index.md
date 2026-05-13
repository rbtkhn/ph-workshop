# PH-CIV Index

This index is the human entry point for PH-CIV placements. Use it when you want a chapter's larger historical placement before moving into transcript or commentary detail.

PH-CIV is an orientation layer. The source chapter remains canonical; the PH-CIV entry helps readers decide what to notice, how much weight to give the frame, and how to return later.

## How To Use

1. Start with a PH-CIV entry when entering a chapter cold.
2. Move from the entry to the source transcript for what was said.
3. Use the companion commentary for source-backed claims, concepts, predictions, and counter-readings.

Machine and tool routing should use `ph_civ_path` in [chapter-manifest.yaml](../../chapter-manifest.yaml).

PH-CIV work follows this operating pipeline:

```text
map -> orient -> constrain -> validate -> route
```

The pipeline keeps the corpus compact: choose eligible chapters, write placement entries, control overreach, validate the contract, and route readers or tools to the result.

## Entries

| source_id | placement_weight | review_status | source_series | entry |
| --- | --- | --- | --- | --- |
| `civ-01` | strong | calibration_seed | civilization | [civ-01.md](civ-01.md) |
| `civ-02` | strong | in_review | civilization | [civ-02.md](civ-02.md) |
| `civ-03` | strong | in_review | civilization | [civ-03.md](civ-03.md) |
| `civ-04` | medium | in_review | civilization | [civ-04.md](civ-04.md) |
| `civ-05` | strong | in_review | civilization | [civ-05.md](civ-05.md) |
| `civ-06` | strong | in_review | civilization | [civ-06.md](civ-06.md) |
| `civ-07` | medium | in_review | civilization | [civ-07.md](civ-07.md) |
| `civ-08` | medium | in_review | civilization | [civ-08.md](civ-08.md) |
| `civ-09` | medium | in_review | civilization | [civ-09.md](civ-09.md) |
| `civ-10` | medium | in_review | civilization | [civ-10.md](civ-10.md) |
| `geo-05` | light | calibration_seed | geo-strategy | [geo-05.md](geo-05.md) |
| `geo-07` | medium | calibration_seed | geo-strategy | [geo-07.md](geo-07.md) |
| `geo-12` | medium | calibration_seed | geo-strategy | [geo-12.md](geo-12.md) |
