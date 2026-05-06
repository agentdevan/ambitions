# HPS10 AI Governance Evaluation Assurance Lab Prompt
<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow on 2026-05-06.
Train: HPS01-HPS12 Human Progress Systems Upgrade.
Type: Docs/evaluation/governance architecture.

## Purpose

Run HPS10 to define the AI Governance and Evaluation Assurance Lab contract.
The contract covers AOS golden scenarios, LDI red-team expansion,
recommendation regression oracle, privacy leak scenarios, minor/student-data
scenarios, career false-certainty scenarios, source-stale scenarios,
professional-boundary scenarios, unsafe dream scenarios, memory hallucination
scenarios, open-loop recovery scenarios, ADHD overload, new-baby overload,
claim truth tests, AI risk register, and continuous assurance ledger.

HPS10 is docs-only. It does not implement tests, fixtures, runtime evaluation,
model evaluation, CI gates, telemetry, analytics, AOS runtime, LDI runtime, UI,
professional advice, legal/privacy signoff, or release claims.

## Locked HPS10 Decisions

- Intelligence cannot close by vibes.
- Every high-risk behavior needs an expected safe outcome.
- Every unsafe or professional-boundary case needs a safe failure posture.
- Every Yellow needs an owner and repair/evidence path.
- Claim-truth tests block unsupported platform, launch, professional, safety,
  privacy, and intelligence claims.
- Assurance ledgers must not store user personal data.

## Allowed Files

- `docs/canon/Ambitions_AI_Governance_Evaluation_Assurance_Lab_Architecture.md`
- `docs/codex/batches/HPS10_AI_Governance_Evaluation_Assurance_Lab_Prompt.md`
- `docs/audits/hps10-ai-governance-evaluation-assurance-lab-report.md`
- HPS train/global order/registry/context/run-state docs

## Forbidden Files

- Production Swift files.
- Test implementation files.
- CI/workflow files.
- Runtime AOS/LDI/model/telemetry/analytics files.
- Route/raw-value, persistence/schema, sync/cloud/account/backend files.
- External-surface behavior files.
- Legal/release/App Store/TestFlight claim files.

## Acceptance

- Assurance object families, required fields, golden scenarios, LDI red-team
  expansion, recommendation regression oracle, privacy leak scenarios,
  source/professional-boundary scenarios, claim truth tests, AI risk register,
  continuous assurance ledger, API contract families, and regression oracle are
  defined.
- No runtime, tests, fixtures, CI, telemetry, analytics, model behavior, UI,
  legal/privacy signoff, or release claim is introduced.

## Validation

- `git status --short`
- `git diff --check`
- HPS assurance architecture scan
- relevant CQS scans
- HPS advisory scripts checked for presence
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Next Batch

HPS11 Vertical Expansion + Revenue Architecture.
