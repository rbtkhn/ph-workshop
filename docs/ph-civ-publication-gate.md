# ph-civ Publication Gate

`ph-workshop` is the editorial workshop and source of truth. `ph-civ` is the public edition repo: it may contain the full publishable Predictive History text plus a smaller public context pack. Nothing should be copied, generated, or exported into `ph-civ` merely because it exists in this repository.

The publication gate exists to keep the public repo from hardening provisional editorial choices. Public text and context-pack routes become exportable only when they have passed public-facing review, rights boundaries, and validator coverage.

## Gate Status

Each route in [registries/ph-choreography.yaml](../registries/ph-choreography.yaml) declares `public_export_status`:

- `not_ready` - editorial route exists, but public export is paused.
- `candidate` - route is being prepared for public export review.
- `approved` - route has passed the publication gate and may be exported.
- `exported` - route has already been exported into the public context pack.

`museum_status` and `public_export_status` are separate. A `curated_draft` museum exhibit may be useful inside the workshop while still being blocked from public export.

The first named context-pack rehearsal batch lives in [registries/ph-civ-export-manifest.yaml](../registries/ph-civ-export-manifest.yaml). That manifest defines `pilot-001`, but batch membership does not approve export.

## Gate Requirements

A context-pack route should not become `approved` or `exported` unless it has:

- a stable chapter route in the choreography registry
- a public-safe civ-ph orientation card
- source transcript and commentary return paths
- limits language on the orientation card
- museum policy status, even when no museum exhibit is ready
- rights boundary language for any museum manifest
- claim boundary tags from [registries/ph-claim-boundaries.yaml](../registries/ph-claim-boundaries.yaml)
- validator coverage in the local publication gate

For `ph-apo`, any `candidate`, `approved`, or `exported` route must also keep date-sensitive, current-events, forecast, or pressure caution language visible before public use.

## Museum Boundary

`ph-mus` readiness requires an exhibit manifest and return paths. It does not require, authorize, or imply artifact binaries in Git.

The museum artifact archive remains outside Git in the local vault and shared cloud workspace. Git records public-safe manifest metadata, rights posture, and return paths only.

## Operating Rule

If a route is uncertain, mark it `not_ready` and explain the blocker in `readiness_note`. The validator should protect against accidental export while allowing honest editorial work to continue.

Before changing any route to `candidate`, run the pre-publication scaffold checks described in [ph-civ Pre-Publication Release](ph-civ-pre-publication-release.md).
