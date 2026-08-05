# Verification

## Exact automated and build checks

```bash
python3 .agents/skills/ambitions-product-development-lifecycle/scripts/ambitions_product_docs.py check linear-realtime-lifecycle-control
npm --prefix tools/linear-control ci
npm --prefix tools/linear-control run format:check
npm --prefix tools/linear-control run lint
npm --prefix tools/linear-control run typecheck
npm --prefix tools/linear-control test
npm --prefix tools/linear-control run cf-types
npm --prefix tools/linear-control run deploy:dry-run
python3 scripts/ambitions-canon.py check
git diff --check
```

## Required evidence

- Automated: raw-byte hashes, complete/incomplete lifecycle admission, stable
  DAG ordering, cycles, shared-path conflicts, WIP, state/proof transitions,
  health thresholds, templates/views/taxonomy, deletion safety, idempotency,
  reordered events, API backoff, and convergence.
- Build: strict TypeScript, lint, generated Worker binding types, configuration
  schema validation, package tests, deployment dry run, and Code Quality.
- Runtime: production health response, signed synthetic Linear/GitHub events,
  Queue processing, D1 receipts, scheduled check, kill switch, retry, DLQ, and
  replay evidence followed by two no-drift full reads.
- Accessibility: deterministic human text and JSON CLI output plus semantic
  review of all shared Linear views/templates. Native/device accessibility is
  N/A because no app UI changes.
- Privacy/security: invalid, missing, stale, and replayed signatures reject;
  secrets and document bodies are absent from logs; bounded-body limits pass;
  gitleaks and private-data-field canaries pass.
- Migration: empty D1 creation, ordered migration apply, repeated migration
  no-op, partial reconciliation resume, mapping replacement, and DLQ replay.
- Performance: webhook acknowledgement remains bounded by signature validation
  and enqueue; queue batches avoid unbounded memory/API calls; freshness is
  under 15 minutes outside a declared provider outage.
- Device: N/A; hosted engineering control plane only.

## Live acceptance

The final live audit must establish one repository folder per active Project,
one primary Initiative, exact M0–M6, exact document hashes, one Issue per Plan
task, correct dependencies/sub-issues, controlled states/labels, proof-gated
Done, a two-Project active group, one active task per Project, current/next
cycles, correct health/progress, current views/templates, zero unexplained drift,
and no orphaned work. PASS is forbidden while any required mutation, deployment,
installation, synchronization, or verification defect remains.
