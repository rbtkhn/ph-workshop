# Cross-Volume Index

Cross-volume corridors expose guided routes across routed chapters without replacing the chapter manifest, civ-ph placements, or source commentary.

Homer to Tolstoy is the Volume I literary spine exposed through this routing layer. The Tolstoy Question is downstream: it turns the spine's terminal problem into a causation corridor.

| Corridor | Structural Role | Sequence | Status | Reader Path |
| --- | --- | --- | --- | --- |
| Homer to Dante | First literary segment | `civ-07 -> gb-02 -> gb-05 -> gb-07 -> civ-17 -> gb-08 -> civ-29 -> civ-30 -> civ-41 -> gb-09 -> gb-10` | In review | [homer-to-dante.md](homer-to-dante.md) |
| Homer to Tolstoy | Volume I literary spine | `Homer -> Virgil -> Dante -> Shakespeare -> Dostoevsky -> Tolstoy`; typed extension `gb-10 -> civ-51 -> civ-53 -> sh-16` | In review | [homer-to-tolstoy.md](homer-to-tolstoy.md) |
| The Tolstoy Question | Downstream causation corridor | `civ-07 -> gb-02 -> gb-05 -> civ-15 -> civ-16 -> civ-25 -> civ-48 -> civ-53 -> sh-16 -> civ-59 -> gt-21 -> gt-22` | Routed draft | [tolstoy-question.md](tolstoy-question.md) |

For tooling, use [registries/cross-volume-links.yaml](../../registries/cross-volume-links.yaml). Each edge resolves to a manifest chapter and its civ-ph placement. Use [registries/causation-lenses.yaml](../../registries/causation-lenses.yaml) for actor-pressure pairs behind the Tolstoy question.
