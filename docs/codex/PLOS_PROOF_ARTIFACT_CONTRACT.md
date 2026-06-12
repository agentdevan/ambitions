# PLOS Proof Artifact Contract

Status: Active PLOS M00 governance contract
Issue: AMB-645 / PLOS-009
Parent: AMB-608 / PLOS-M00
Authority posture: Supporting artifact contract subordinate to `docs/codex-os/PROOF_ARTIFACT_STANDARD.md`
Runtime implementation proof: none

This contract defines the artifact paths PLOS issues use to bind claims to evidence. It extends existing repo conventions under `artifacts/personal-life-os/`, `artifacts/plos-runtime/`, and `artifacts/proof-ledger/`.

## Path Contract

Use these paths unless the active issue proves a stronger existing convention:

- Issue report: `artifacts/personal-life-os/reports/<issue-id>-report.md`
- Validation record: `artifacts/personal-life-os/validation/<issue-id>-validation.json`
- Search or inspection log: `artifacts/personal-life-os/validation/<issue-id>-search-log.txt`
- Screenshot proof: `artifacts/personal-life-os/screenshots/<issue-id>-<surface>-<state>.png`
- Screenshot manifest: `artifacts/personal-life-os/screenshots/<issue-id>-manifest.json`
- Accessibility proof: `artifacts/personal-life-os/accessibility/<issue-id>-a11y.md`
- Performance proof: `artifacts/personal-life-os/performance/<issue-id>-performance.md`
- Reviewer output: `artifacts/plos-runtime/reviewer-output/<issue-id>-<reviewer>.md`
- PLOS script output: `artifacts/plos-runtime/script-output/<command>-<timestamp>.log`
- Proof ledger: `artifacts/proof-ledger/PROOF_LEDGER.md`
- Proof index: `artifacts/proof-ledger/proof-index.json`

Existing UIQL proof may stay in `artifacts/ui-quality-lockdown/` when the active issue is UIQL-owned. PLOS issues should not move historical UIQL proof into PLOS folders.

## Required Artifact Fields

Every proof artifact must preserve the fields required by `docs/codex-os/PROOF_ARTIFACT_STANDARD.md`:

- claim
- commit or working-tree state
- touched files
- command
- exit code
- artifact path
- screenshot path if visual
- scope
- non-claims
- freshness
- responsible program
- related Linear issue
- Green/Yellow/Red evidence status

## Validation JSON Shape

When a PLOS issue creates validation JSON, use this shape:

```json
{
  "schema_version": 1,
  "program": "plos",
  "issue_id": "AMB-000",
  "plos_label": "PLOS-000",
  "parent_issue_id": "AMB-608",
  "commit": "<sha or working-tree>",
  "status": "Green|Yellow|Red",
  "commands": [
    {
      "command": "<command>",
      "exit_code": 0,
      "artifact": "<path>",
      "scope": "<what this proves>",
      "non_claims": ["<claim not made>"]
    }
  ],
  "unknown_commands": [
    {
      "lane": "<validation lane>",
      "owner": "M01|M26|AMB-###",
      "reason": "<why unknown is safe or blocking>"
    }
  ]
}
```

Do not create a validation JSON file with fabricated commands. If validation was only reported in a Markdown issue report, say so.

## Screenshot Proof

Screenshot artifacts must include:

- capture command or source
- surface and state
- device/simulator and OS when available
- commit or working-tree state
- visual evaluation summary
- accessibility boundary
- no-release/no-owner/no-device claim boundary unless separately proven

Screenshot paths alone are Yellow at best and cannot close visual Green.

## Accessibility Proof

Accessibility artifacts must distinguish:

- label/trait/source-level inspection
- Dynamic Type behavior
- Reduce Motion behavior
- Reduce Transparency / Increase Contrast behavior
- VoiceOver traversal
- tap targets and safe areas
- simulator versus physical device
- public accessibility conformance versus local proof

Do not claim accessibility verification from docs-only changes or screenshot paths.

## Performance Proof

Performance artifacts must include:

- budget source
- command
- target surface/runtime path
- measured result
- exit code
- degradation or fallback behavior
- accepted Yellow owner if budget is unmet

Do not claim performance proof from structural validators.

## Privacy / Safety / Source Proof

Privacy, safety, and source artifacts must include:

- data classification
- local/iCloud/R2 boundary
- source authority and freshness
- review/jurisdiction state where relevant
- failure or blocked mode
- receipt or rollback path
- no private user data in R2/public Source Atlas

High-risk domains require explicit source, jurisdiction, professional-boundary, crisis/safety, and blocked-mode proof before Green.

## Rollup Rules

Child artifacts roll up to AMB-608 only through:

- child report path
- proof ledger entry
- PLOS run-state update
- PLOS phase gate
- closeout validation
- pushed commit hash after push
- Linear comment/status update on actual `AMB-*` issue

Parent rollup cannot infer release, runtime, accessibility, privacy/legal, owner approval, device, or performance readiness from child governance artifacts.

## Non-Claims

AMB-645 does not create app runtime proof, source migration proof, screenshot proof, accessibility proof, performance proof, privacy/legal proof, release proof, owner approval, or PLOS-M01+ execution. It defines where future proof must be recorded.
