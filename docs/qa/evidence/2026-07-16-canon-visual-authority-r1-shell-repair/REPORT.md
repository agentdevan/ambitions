# Visual Authority R1 Shell and Mapping Repair

Status: candidate/shadow; pending exact-range independent re-review and Gate B

## Result

The frozen R1 Figma candidate is represented by an offline deterministic node snapshot and shadow manifest. The bounded review repair closes the four accepted finding classes without activating visual authority:

- `VA-P4-A11Y-CLASS-003` carries the exact Trust requirement and screen-state mappings as an accessibility support overlay.
- `VA-P4-A11Y-CLASS-005` carries `32` lifecycle requirement IDs, `10` screen mappings, `35` displayed current commands, and no stale GAP command-contract copy.
- The journey consequence row is no longer clipped; Today and Goals preserve `84` pt of dock clearance; Goals and You expose all four root glyphs.
- Every nested snapshot record is closed against unknown fields, and the accessibility-size Today replacement is independently reproducible from normalized Figma node records and distinct retained before/after render files.

The records bind `49` live nodes on page `215:2`, including all `18` task-pack candidate targets. They retain `14` root frames, `7` drilldown frames, and `18` exact product viewport screenshots. The cumulative Figma receipt is `79` nodes created, `105` nodes mutated/read-bound, `0` nodes deleted, and `0` destructive actions.

The first bundled repair attempt failed atomically because a child could not be inserted into an instance; Figma debug UUID `fba516e2-f956-4ca1-9563-a52d7e73597b` identifies that no-change failure. Two later bounded writes succeeded. The legacy Goals and You dock instances remain hidden and retained at `354:2562` and `354:2733`; their visible replacements are `368:2746` and `367:2746`.

## Deterministic records

- `docs/canon/migration/visual-authority-rebaseline.json`
- `docs/canon/migration/visual-authority-r1-node-snapshot.json`
- `docs/canon/schemas/visual-authority-rebaseline.schema.json`
- `docs/canon/schemas/visual-authority-r1-node-snapshot.schema.json`
- `docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-repair/RECEIPT.json`
- `docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-repair/EVIDENCE_MANIFEST.json`

The compiler loads the R1 snapshot with the shadow manifest and fails closed if the candidate page, live node binding, product viewport digest, root/drilldown shell contract, candidate metadata, support-overlay mapping, command-registry binding, presentation repair, nested record shape, or pixel-equivalence proof drifts.

## Pixel-equivalence proof

The hidden predecessor node IDs `354:2517`, `354:2518`, `354:2522`, and `354:2523` and visible replacement IDs `359:242`, `359:243`, `359:247`, and `359:248` normalize to identical circle geometry, paint, component, vector, and stroke records. Their canonical normalized digest is:

```text
f096dbcc63c65a9ef0f6e3b826a91749836b57aec7afe4222d80a921dac6a5b1
```

The retained before and after files have distinct paths, are byte-identical, and both have SHA-256:

```text
311374645649f6bdd851b9e34783599847c94b76d6862d0dbb2d67a473260376
```

This is evidence of a non-destructive pixel-equivalent replacement, not evidence that the replacement failed.

## TDD evidence

Observed focused RED:

```text
/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 -m unittest tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_accessibility_classes_are_registry_bound_without_stale_gap_copy tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_presentation_repairs_are_durable_and_task_pack_exact tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_snapshot_rejects_unknown_fields_at_every_nested_record tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_pixel_equivalence_is_independently_reproducible
exit 1
Ran 4 tests in 11.619s
FAILED with 1 expected assertion failure and 3 expected missing-contract errors
```

Focused GREEN after the bounded implementation:

```text
/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 -m unittest tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_accessibility_classes_are_registry_bound_without_stale_gap_copy tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_presentation_repairs_are_durable_and_task_pack_exact tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_snapshot_rejects_unknown_fields_at_every_nested_record tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_pixel_equivalence_is_independently_reproducible
exit 0
Ran 4 tests in 6.871s
OK
```

## Covering validation

```text
git diff --check && /Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 -m unittest -v tests.canon.test_visual_authority_rebaseline tests.canon.test_task_pack tests.canon.test_external_authority
exit 0
Ran 96 tests in 114.387s
OK

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-truth-path-vocabulary-audit.py
exit 0
GREEN: truth paths resolve or are explicitly planned/internal, and active stale terms are quarantined

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-constitution-audit.py
exit 0
GREEN ambitions constitutional registry audit
opportunities=118 p0=18 p1=100
laws=124 source_maps=34 test_maps=34
scenarios=16 budgets=9 classifications=6

/Users/devan/.local/share/uv/python/cpython-3.12-macos-x86_64-none/bin/python3.12 scripts/ambitions-remediation-governance-check.py
exit 0
GREEN remediation governance guard passed
changed_paths=15
production Swift changed=0

bash scripts/canon-language-drift-scan.sh
exit 0
GREEN no changed-file canon language drift candidates
YELLOW existing backlog / guardrail hits follow

git diff --check
exit 0
no output
```

The language-drift Yellow is the unchanged pre-existing backlog printed after the changed-file Green result. It is not a new finding in this candidate.

The exact Python 3.12 environment does not include the optional `jsonschema` package; its import exited `1` with `ModuleNotFoundError`. Both schema files parse as JSON, and the standard-library compiler validator plus the `96`-test covering set validate the exact runtime contract. No result from the accidentally started system-Python duplicate processes is claimed because their terminal output was not recoverable.

## Review posture

This proof-only update records the completed repair candidate. One exact-range independent re-review is still required after the repair commit. It must return a consolidated Critical, Important, and Minor docket; no authority state may advance while any Critical or Important finding remains.

## Scope and non-claims

No production Swift, product law, AGENTS.md, CI, skill, Linear record, or authority state changed. No semantic evaluation was run or regenerated. Legacy and pre-R1 Figma material remains non-destructively retained.

Claim ceiling:

> Visual design authority candidate only for the exact Figma/canon mapping scope.

This repair does not claim source UI implemented, Runtime Green, rendered-app Visual Green, Accessibility Green, Device ready, privacy/legal approval, TestFlight readiness, App Store readiness, Release Green, or Gate B Green.
