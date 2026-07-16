# Visual Authority R1 Shell and Mapping Repair

Status: candidate/shadow; pending independent review and Gate B

## Result

The frozen R1 Figma candidate is now represented by an offline deterministic node snapshot and an updated shadow manifest. The records bind `49` live nodes on page `215:2`, including all `18` task-pack candidate targets, without activating visual authority.

The shell contract records:

- `14` root frames with exactly one root dock, one Search action, one Capture action, and `84` pt clearance (`96` pt for the accessibility-size Today frame);
- `7` drilldown frames with one Back affordance and no root dock, Search, or Capture action;
- `18` exact product viewport screenshots with current Figma node IDs and SHA-256 digests;
- `77` nodes created, `92` nodes mutated/read-bound, `0` nodes deleted, and `0` destructive actions in the bounded Figma write receipt.

The accessibility-size Today frame `270:1430` has one visible Search node (`359:243`) and one visible Capture node (`359:248`). Its hidden predecessor pairs and visible replacement pairs use matching geometry and fills. The unchanged render digest `311374645649f6bdd851b9e34783599847c94b76d6862d0dbb2d67a473260376` is therefore expected and is recorded as pixel-equivalent non-destructive replacement evidence.

## Deterministic records

- `docs/canon/migration/visual-authority-rebaseline.json`
- `docs/canon/migration/visual-authority-r1-node-snapshot.json`
- `docs/canon/schemas/visual-authority-rebaseline.schema.json`
- `docs/canon/schemas/visual-authority-r1-node-snapshot.schema.json`
- `docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-repair/RECEIPT.json`
- `docs/qa/evidence/2026-07-16-canon-visual-authority-r1-shell-repair/EVIDENCE_MANIFEST.json`

The compiler loads the R1 snapshot with the shadow manifest and fails closed if the candidate page, any live node binding, any product viewport digest, root/drilldown shell counts, candidate metadata, or the pixel-equivalent replacement proof drifts.

## TDD evidence

Observed focused RED:

```text
uv run --python 3.12 python -m unittest -v tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_node_snapshot_binds_live_targets_and_shell_contract_without_destruction
exit 1
FileNotFoundError: docs/canon/migration/visual-authority-r1-node-snapshot.json
Ran 1 test in 6.606s
```

Focused GREEN after the minimum snapshot, mapping, and validator implementation:

```text
uv run --python 3.12 python -m unittest -v tests.canon.test_visual_authority_rebaseline.VisualAuthorityRebaselineTests.test_r1_node_snapshot_binds_live_targets_and_shell_contract_without_destruction
exit 0
Ran 1 test in 6.410s
OK
```

## Covering validation

```text
git diff --check && uv run --python 3.12 python -m unittest -v tests.canon.test_visual_authority_rebaseline tests.canon.test_task_pack tests.canon.test_external_authority
exit 0
Ran 92 tests in 104.495s
OK

python3 scripts/ambitions-truth-path-vocabulary-audit.py
exit 0
GREEN

python3 scripts/ambitions-constitution-audit.py
exit 0
GREEN ambitions constitutional registry audit

python3 scripts/ambitions-remediation-governance-check.py
exit 0
GREEN remediation governance guard passed

bash scripts/canon-language-drift-scan.sh
exit 0
GREEN no changed-file canon language drift candidates
YELLOW existing backlog / guardrail hits follow
```

The pre-existing language-drift backlog is unchanged and did not produce a changed-file finding. Production Swift changed: `0`.

Both new/changed schemas passed Python JSON parsing. Draft 2020-12 validation through the optional `jsonschema` package was not run because that package is absent from the repository's Python environment; the attempted import exited `1` with `ModuleNotFoundError`. The standard-library compiler validator and the covering test set validate the exact runtime contract.

## Scope and non-claims

No production Swift, product law, AGENTS.md, CI, skill, Linear record, or authority state changed. No semantic evaluation was run or regenerated. Legacy and pre-R1 Figma material remains non-destructively retained.

Claim ceiling:

> Visual design authority candidate only for the exact Figma/canon mapping scope.

This repair does not claim source UI implemented, Runtime Green, rendered-app Visual Green, Accessibility Green, Device ready, privacy/legal approval, TestFlight readiness, App Store readiness, Release Green, or Gate B Green.
