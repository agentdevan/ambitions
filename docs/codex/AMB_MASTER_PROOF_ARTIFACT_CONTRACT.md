# Ambitions Master Build Proof Artifact Contract

Status: Active artifact contract for `amb-master`
Authority posture: Supporting contract subordinate to `docs/codex-os/PROOF_ARTIFACT_STANDARD.md`

## Path Contract

Use these paths unless the active issue proves a stronger existing convention:

- Issue report: `artifacts/ambitions-master-build/reports/<issue-id>-<slug>.md`
- Validation record: `artifacts/ambitions-master-build/validation/<issue-id>-validation.json`
- Search or inspection log: `artifacts/ambitions-master-build/validation/<issue-id>-search-log.txt`
- Reviewer output: `artifacts/ambitions-master-build/reviewer-output/<issue-id>-<reviewer>.md`
- Script output: `artifacts/ambitions-master-build/script-output/<command>-<timestamp>.log`
- Screenshot proof: `artifacts/ambitions-master-build/screenshots/<issue-id>-<surface>-<state>.png`
- Screenshot manifest: `artifacts/ambitions-master-build/screenshots/<issue-id>-manifest.json`
- Accessibility proof: `artifacts/ambitions-master-build/accessibility/<issue-id>-a11y.md`
- Performance proof: `artifacts/ambitions-master-build/performance/<issue-id>-performance.md`
- Proof ledger: `artifacts/proof-ledger/PROOF_LEDGER.md`
- Proof index: `artifacts/proof-ledger/proof-index.json`

Existing UIQL, source-atlas, release, privacy, or runtime proof may stay in established folders when those systems own the artifact. Do not move historical proof just to satisfy this path contract.

## Required Fields

Every proof artifact must state:

- claim
- commit or working-tree state
- touched files
- command
- exit code
- artifact path
- scope
- non-claims
- freshness
- responsible program
- related Linear issue
- Green/Yellow/Red evidence status

## Screenshot / Accessibility / Performance Proof

Screenshot paths alone are not proof. Visual proof requires current capture, visual evaluation, device/simulator context, accessibility boundary, and no-release/no-device claim boundary unless separately proven.

Accessibility proof must distinguish source-level checks, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, VoiceOver traversal, tap targets, safe areas, simulator proof, physical-device proof, and public accessibility certification.

Performance proof must include command, target surface/runtime path, budget source, measured result, exit code, degradation/fallback behavior, and accepted Yellow owner if unmet.

## Privacy / Safety / Source Proof

Privacy, safety, and source artifacts must include data classification, local/iCloud/R2 boundary, source authority/freshness/revocation where relevant, failure or blocked mode, receipt or rollback path, and no private user data in public/R2 paths.
