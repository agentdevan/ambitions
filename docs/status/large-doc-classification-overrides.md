# Large Doc Classification Overrides

Status: Green for T05c safe override completion  
Date: 2026-05-09

## Authority

Active repo authority starts in `docs/truth/README.md`. If this file conflicts with `docs/truth/*`, the truth files win.

This file exists because several retained large historical/control-plane docs cannot be safely edited through the current GitHub connector: connector reads return truncated content, while `update_file` performs whole-file replacement.

These overrides are therefore the active classification labels for the files listed below until a local checkout or patch-capable tool can prepend equivalent headers directly to those files.

## Scope

Docs/control-plane classification only. No Swift source changes, app implementation changes, deletes, moves, archive operations, build/test/device validation, or release/readiness claims.

## Overrides

| Path | Classification | Active Rule |
| --- | --- | --- |
| `docs/codex/BATCH_REGISTRY.md` | Operational status registry / supporting Codex process context | Not product, implementation, release, or source-truth authority. Current authority begins in `docs/truth/` and `AGENTS.md`; registry entries are retained as operational batch history/status unless re-approved by `docs/truth/*`. |
| `MASTER_PRODUCT_SPEC.md` | Historical / supporting product-spec context | Not current product, implementation, release, or Codex process authority. Current authority begins in `docs/truth/`; any wording that implies current source truth is preserved historical context unless re-approved by `docs/truth/*`. |
| `docs/canon/Ambitions_3_0_Documentation_System_Index.md` | Historical / supporting documentation-system context | Not current product, implementation, release, or Codex process authority. Current authority begins in `docs/truth/`; older 3.0 documentation routing is preserved for traceability unless re-approved by `docs/truth/*`. |

## Intended Header Text For Future Local Patch

### `docs/codex/BATCH_REGISTRY.md`

```markdown
> T05c classification: Operational status registry / supporting Codex process context.
> This file is not product, implementation, release, or source-truth authority.
> Current authority begins in `docs/truth/` and `AGENTS.md`; registry entries below are retained as operational batch history/status unless re-approved by `docs/truth/*`.

```

### `MASTER_PRODUCT_SPEC.md`

```markdown
> T05c classification: Historical / supporting product-spec context.
> This file is not current product, implementation, release, or Codex process authority.
> Current authority begins in `docs/truth/`; if any wording below implies current source truth, treat it as preserved historical context unless re-approved by `docs/truth/*`.

```

### `docs/canon/Ambitions_3_0_Documentation_System_Index.md`

```markdown
> T05c classification: Historical / supporting documentation-system context.
> This file is not current product, implementation, release, or Codex process authority.
> Current authority begins in `docs/truth/`; older 3.0 documentation routing below is preserved for traceability unless re-approved by `docs/truth/*`.

```

## Validation

- The GitHub connector accepted creation of this override file.
- The three large target docs were not overwritten because full-file replacement from truncated reads would risk content loss.
- No Markdown/link checker, `xcodegen`, `xcodebuild`, unit test, UI test, archive, accessibility, performance, physical-device, TestFlight, or App Store validation was run.

## Next Optional Cleanup

When using a local checkout or patch-capable tool, prepend the intended headers above and then update this file to mark the overrides as physically applied.
