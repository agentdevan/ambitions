# AQOS Tools, Skills, And Scripts Prompt
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
