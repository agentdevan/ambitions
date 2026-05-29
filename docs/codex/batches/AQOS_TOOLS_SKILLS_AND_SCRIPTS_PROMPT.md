# AQOS Tools, Skills, And Scripts Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-29087703, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_surface_multiple_active_batches-13212827

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- markdownlint-disable MD013 -->

Status: Copyable Codex prompt for materializing AQOS executable tooling locally.
Date: 2026-05-05

```markdown
You are operating in the Ambitions repo as the AQOS tooling implementer.

Mission:
Materialize the AQOS script/tool layer from docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md, integrate it with Codex OS, and run it in advisory mode without disrupting the active global train.

Do not edit production Swift.
Do not change routes/raw values.
Do not change persistence/schema.
Do not change signing/workflows/entitlements unless an AQOS tool batch explicitly permits it.
Do not add third-party dependencies without PFC dependency approval.

Read:
- docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM.md
- docs/codex/quality/AQOS_SCRIPT_AND_TOOL_MAP.md
- docs/codex/quality/AQOS_TOOL_DEPENDENCIES.md
- docs/codex/quality/AQOS_REPORT_TEMPLATE.md
- docs/codex/quality/AQOS_REQUIRED_EVIDENCE_MATRIX.md
- docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md
- docs/codex/quality/AQOS_DOMAIN_QUALITY_GATES.md
- docs/codex/GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md
- .codex/skills/autonomous-quality-operating-system-reviewer.md
- .codex/skills/evidence-gated-quality-reviewer.md
- .codex/skills/accessibility-privacy-performance-quality-reviewer.md
- .codex/skills/founder-vision-and-handoff-reviewer.md

Create missing scripts under scripts/:
- aqos-impact-classifier.sh
- aqos-required-evidence-check.sh
- aqos-claim-truth-scan.sh
- aqos-copy-internal-term-scan.sh
- aqos-visual-card-stack-scan.sh
- aqos-architecture-fitness-scan.sh
- aqos-privacy-exposure-scan.sh
- aqos-screenshot-freshness-check.sh
- aqos-evidence-folder-check.sh
- aqos-state-coverage-check.sh
- aqos-evidence-maturity-ledger-check.sh
- aqos-run-all-advisory.sh

Script requirements:
- Bash-first.
- Non-mutating by default.
- Advisory by default.
- `AQOS_STRICT=1` enables non-zero exits for relevant findings.
- Use standard macOS tools and Python 3 standard library only.
- Clear output.
- No secrets.
- No network calls.
- No paid tools.

Also update or add:
- AQOS script registry/map references if repo has a script map.
- Batch report template references if repo has a canonical report template.
- Codex context/registry references where safe.

Validation:
```bash
git status --short
git diff --check
bash scripts/aqos-run-all-advisory.sh || true
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

Write report:
`docs/audits/aqos-tools-skills-and-scripts-report.md`

Report must include:
- scripts created;
- skills read;
- dependencies used;
- advisory findings;
- strict-mode readiness;
- files changed;
- validation run;
- no-claim boundary;
- next eligible batch.

Commit if Green or accepted Yellow with no Hard Red.
```

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
