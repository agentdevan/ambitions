# AMB-1200 — Register Sync / Control Closeout

## Objective

Synchronize Linear status, `docs/qa/KNOWN_ISSUES.md`, evidence state, and project control-plane reporting so no runtime defect closes from source-only work.

## Covered Linear issues

- `AMB-1181`
- `AMB-1200`
- control-plane QA leaves attached to `AMB-1181`

## Covered repo issue IDs

- `AMB-ISSUE-0014`
- `AMB-ISSUE-0015`
- `AMB-ISSUE-0016`
- `AMB-ISSUE-0807`
- `AMB-ISSUE-0909`
- `AMB-ISSUE-1801`
- `AMB-ISSUE-1802`

## Product law

This is governance work. It does not fix runtime defects by itself and must not claim runtime or visual Green.

## Architecture law

The repo is the canonical source of remediation law and proof records. Linear is the execution tracker. The project source file is compact working memory. Evidence index is proof input, not implementation truth.

## Runtime honesty law

Do not close runtime defects without evidence. Do not let source-only work become closure. Keep AMB-1181, AMB-1282, the execution bundles, and `docs/qa/KNOWN_ISSUES.md` aligned.

## Visual law

No special visual redesign is introduced here. The visual requirement is truthful status communication and no false-release posture.

## Copy and iconography law

Control-plane copy must stay explicit about proof state, evidence links, and owner acceptance. Do not use optimistic Green language while P0s remain open.

## State model

- Linear issue status and repo status must remain synchronized
- proof state is tracked separately from source state
- project remains Off Track while runtime P0s remain open
- AMB-1282 remains owner-acceptance controlled and does not close runtime defects

## Required deletion / replacement

- delete contradictory proof-state language
- replace stale register mappings with current dossier/bundle mappings
- remove any source-only closure interpretation

## Required implementation

- synchronize Linear status and `docs/qa/KNOWN_ISSUES.md`
- ensure all touched issues have status, evidence, proof, and owner acceptance
- keep `AMB-1181` / QA control plane aligned
- post final project updates
- do not close runtime defects without evidence
- ensure no source-only closure

## Files likely in scope

Codex must inspect current source before editing. Likely areas include `docs/qa/KNOWN_ISSUES.md`, `docs/qa/remediation/**`, `docs/project-source/CHATGPT_AMBITIONS_PROJECT_SOURCE.md`, evidence indexes, and Linear project/update state. Unexpected files must be justified in closeout.

## Files forbidden unless explicitly justified

- app source implementation files
- runtime product behavior changes
- backend/network/R2 files

## Accessibility requirements

Accessibility requirement here is governance integrity: proof references must stay readable, inspectable, and linked from the control plane. No accessibility claim is allowed without recorded evidence.

## Testing / audit requirements

Validate issue/register synchronization, evidence links, bundle/dossier mapping, AMB-1181 evidence linkage, AMB-1282 owner-acceptance posture, and final project update accuracy.

## Screenshot / device proof requirements

This bundle does not create new runtime screenshots itself, but it must preserve links to the required screenshot/video proof for any issue claiming closure or candidate resolution.

## docs/qa/KNOWN_ISSUES.md update requirements

Keep bundle-to-dossier mappings current, preserve closure law, and reflect proof state separately from source state.

## Status ceiling

Control-plane closure does not imply app readiness. Open P0s still block Runtime Green, Visual Green, and Release Green.

## Closeout template

```text
Status:
Bundle:
Linear issues covered:
Repo issue IDs covered:
Files changed:
Product law implemented:
Architecture law implemented:
Runtime honesty proof:
Validation run:
Validation not run:
Screenshots/videos:
Accessibility proof:
docs/qa/KNOWN_ISSUES.md updates:
Status ceiling:
Known risks:
Rollback plan:
```
