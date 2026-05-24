# Champion Selection Gate

Status: Active Codex gate.

Future batches are not allowed to create new implementation owners unless:

1. no existing owner exists, or
2. the batch explicitly supersedes an owner, or
3. the batch creates a scoped helper under a canonical owner.

Existing code champion coverage is mandatory. Future implementation work may not proceed until every existing Swift file/type is classified and every product/runtime concept has a canonical owner or explicit owner-review boundary.

Any replacement must:

- update `docs/audits/intelligence-consolidation/SUPERSESSION_LEDGER.md`
- update `docs/audits/intelligence-consolidation/BEST_CODE_RESCUE_LEDGER.md` if useful old behavior exists
- update `docs/audits/intelligence-consolidation/CANONICAL_OWNER_MAP.md`
- update `docs/codex/canonical-owner-map.yml`
- preserve tests/proof or add replacements
- avoid broad implementation claims until proof passes

No batch may create a new canonical owner just to bypass the parallel implementation guard.

Concepts listed in `docs/codex/concept-lock-registry.yml` are blocked for ordinary feature/runtime/product trains until their Champion Merge queue item is closed Green or accepted Yellow with owner boundary. Source-changing work on locked concepts must be a Champion Merge or owner-review resolution batch.
