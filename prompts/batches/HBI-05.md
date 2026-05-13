<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# HBI-05 - Files/PDF/Resume

## Batch ID

HBI-05

## Runner command

```bash
scripts/ambitions-codex-train.sh HBI-05 prompts/batches/HBI-05.md
```

Equivalent:

```bash
make batch BATCH=HBI-05 PROMPT=prompts/batches/HBI-05.md
```

## Objective

Implement user-selected Files/PDF/Resume import for Historical Baseline using repo-approved UIDocumentPicker and PDFKit boundaries, producing evidence, source records, receipts, and tests without file crawling.

## Active source truth to inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_OVERLAY.md`
- `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json`
- `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`
- `prompts/batches/HBI-04.md`
- existing file import, Source Atlas, privacy, and storage code/tests

## Allowed scope

- User-selected file/document import boundary.
- PDFKit text extraction for selected PDFs and resume-like files where supported by current architecture.
- Source records, evidence drafts/items, import preview, run receipts, and fixture tests.
- Local-only parsing and deterministic classification hooks.

## Forbidden scope

- File crawling or silent indexing.
- Broad device scan.
- Cloud parsing or cloud storage.
- Creating active goals directly from imported documents.
- Release/readiness claims.

## Validation expectations

Run focused file/PDF/resume import tests and relevant source/privacy/storage tests. Prove imports require user-selected files, produce receipts, and remain review-gated.

## Visual proof expectations

Required only if user-facing import UI is touched. Otherwise no visual proof required.

## Hard Red stop conditions

Stop if files can be scanned without user selection, if imported content creates active goals directly, if cloud storage/parsing is introduced, or if evidence cannot be deleted/exported by later policy.

## Rollback expectations

Revert only HBI-05-owned importer, fixture, test, and report files.

## Final report expectations

Create `docs/audits/hbi-05-batch-closeout-report.md` with validation evidence, no-crawling confirmation, no-active-goal confirmation, and next eligible batch.
