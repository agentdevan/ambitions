# Raw Content Review Replay Addendum

This addendum makes the byte-valid raw Content review payloads independently auditable from a clean checkout. Each tracked attachment below was copied without change from the stated SDD replay source.

| Phase | SDD replay source | Tracked attachment | SHA-256 | Direct lifecycle result |
| --- | --- | --- | --- | --- |
| Research revision 3 | `.superpowers/sdd/2026-08-02-ambitions-product-development-lifecycle/task-10-chatgpt-research-revision-3-content-review-replay.json` | `raw-content-reviews/research-revision-3.json` | `e6c0ba7ddfcd46ee4e3eb459fd29cb568bddf24f8fa729e0717aeb9b2045949f` | `REV-CONTENT-RESEARCH-003` PASS, state commit `306d11ab62a0f268e7577f7646ca885fbdf05546` |
| Scope revision 1 | `.superpowers/sdd/2026-08-02-ambitions-product-development-lifecycle/task-10-chatgpt-scope-content-review-replay.json` | `raw-content-reviews/scope.json` | `f5f504f40b6d50880cedb28eef51bd269c672e1ac5ff9633b887a3ba83ab9193` | `REV-CONTENT-SCOPE-001` PASS, state commit `2682578881e1f6f820c5913241eb03b2a08d3866` |
| Design revision 1 | `.superpowers/sdd/2026-08-02-ambitions-product-development-lifecycle/task-10-chatgpt-design-content-review-replay.json` | `raw-content-reviews/design.json` | `af159b291988325b0017d6235a898897300822b6542d8d619403c97808aab01f` | `REV-CONTENT-DESIGN-001` NEEDS REVISION, state commit `7daafb3f1b96adb5b4a8417acd3c00864da5bc6d` |
| Design revision 2 | `.superpowers/sdd/2026-08-02-ambitions-product-development-lifecycle/task-10-chatgpt-design-revision-2-content-review.json` | `raw-content-reviews/design-revision-2.json` | `4073fdf31b721882326c709eaaa9563ced1659bb8e16e0bcfe5f79f2dfc0f6c6` | Strict unchanged JSON `REV-CONTENT-DESIGN-002` PASS, direct Content state commit `afaaea2d75cd87efabf742664fb7d4f2e1be54a3` |

The current durable Codex Consumer review IDs are `REV-CONSUMER-RESEARCH-003` and `REV-CONSUMER-SCOPE-001`. Their fresh local payload hashes are respectively `6febdfeaf23e1d32164a864f33ea7dcf875680d1b1c770f6985e211d84b29410` and `62b0040c7c208a2bd3dcf179266c695e2b5fdfa7bb7911c906bd363c69895e9c`; their state commits are `f2efdc2090b1760693a1001472927e1f01d2ea59` and `4145fcc6d6bd18b1088023ae4fb375f9f33f1813`.

The Design revision-1 attachment directly records `needs-revision`. Its preceding normalized Content and Consumer PASS records are historical and non-current: their active state was non-rewriting reverted before the direct raw revision-1 import at `7daafb3f1b96adb5b4a8417acd3c00864da5bc6d`.

Current Design is revision `2`, produced at `a575d66d1fb12f1c160693e9c4b50f02de1333fe`, sealed at `fcfe3761a284de5c3397cf6a91edc4937bbd426a`, and passed at `908295b8eb721793764b4d0be03085bb9dc21132` with contract `sha256:30b689731623644dc2a19873418f25fa425b56c28930e3a67af52661a8257224`. Its Codex Consumer record is durable ID `REV-CONSUMER-DESIGN-002`, payload SHA-256 `1d3a315c3211090a28be60d5d40790fd2910689f317b7d645f6b277c1816bbcf`, and exactly one accepted nonmaterial assessment of current Scope drift. A new standalone consume remains a drift detector and therefore still requires a fresh Scope assessment; it is not claimed as PASS after the recorded review.
