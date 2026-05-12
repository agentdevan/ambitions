#!/usr/bin/env python3
"""Materialize MRI01-MRI50 runner-compatible prompts from overlay JSON."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OVERLAY = ROOT / "docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json"
PROMPT_DIR = ROOT / "prompts/batches"
HEADER = """<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
"""

TRUTH_FILES = """- docs/truth/README.md
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/truth/PRODUCT_MOAT_TRUTH.md
- docs/truth/IMPLEMENTATION_TRUTH.md
- docs/truth/RELEASE_TRUTH.md
- docs/truth/CODEX_PROCESS_TRUTH.md
- docs/truth/HISTORICAL_POLICY.md
- AGENTS.md
- .codex/reports/current-run-state.md
- docs/codex/MOAT_RUNTIME_INTEGRATION_MASTER_PLAN.md
- docs/codex/MOAT_RUNTIME_LOOP_MATRIX.md
- docs/codex/MOAT_RUNTIME_ACCEPTANCE_CRITERIA.md
- docs/codex/MOAT_RUNTIME_GOLDEN_SCENARIOS.md
- docs/codex/MOAT_RUNTIME_BATCH_OVERLAY.json
"""


def slugify(text: str) -> str:
    keep = []
    for ch in text.upper():
        if ch.isalnum():
            keep.append(ch)
        elif ch in {" ", "/", "-", "_", "?"}:
            keep.append("-")
    slug = "".join(keep)
    while "--" in slug:
        slug = slug.replace("--", "-")
    return slug.strip("-")


def prompt_for(batch: dict) -> str:
    batch_id = batch["id"]
    full_id = Path(batch["prompt_file"]).stem
    report_name = f"docs/audits/{full_id.lower()}-report.md"
    no_claims = "\n".join(f"- {claim}" for claim in batch.get("no_claims", []))
    return f'''{HEADER}
# Batch ID

{full_id}

# Runner Command

```bash
make batch BATCH={full_id} PROMPT={batch['prompt_file']}
```

# Objective

{batch['allowed_scope_summary']}

Operating system: **{batch['operating_system']}**  
Product loop: **{batch['loop']}**

This batch must help close an end-to-end Ambitions loop, not merely add another disconnected component.

# Active Source Truth To Inspect

{TRUTH_FILES}

# Allowed Scope

{batch['allowed_scope_summary']}

The implementation pass may add or modify docs, prompts, fixtures, tests, or runtime source only if the batch-specific objective explicitly requires it and current truth files support it.

# Forbidden Scope

{batch['forbidden_scope_summary']}

Global hard exclusions unless this prompt explicitly narrows them with proof:

- no release automation
- no signing or entitlement changes
- no hosted personal-data backend
- no external/cloud LLM core runtime
- no Plan top-level restoration
- no sixth tab
- no generic task/calendar/dashboard/chatbot UI
- no unsupported readiness claims

# Validation Expectations

Use the minimum honest validation lane for the touched files:

```bash
git diff --check
python3 scripts/ambitions-state-advance-validate.py || true
python3 scripts/ambitions-unsupported-claim-scan.py <changed-files> 2>/dev/null || true
```

If Swift runtime source is touched, run focused owner tests. If visual runtime is touched, produce preview/screenshot or visual acceptance evidence when claiming visual behavior. Do not run broad full-suite Xcode validation unless this batch is a terminal proof gate.

Proof expectation: {batch['proof_expectation']}

# Hard Red Stop Conditions

- Required truth/source files cannot be inspected.
- Scope drifts outside the batch objective.
- A component is claimed complete without loop behavior or proof boundary.
- User-facing copy violates active product/moat vocabulary.
- The patch adds hosted personal-data, external/cloud LLM core behavior, or hidden recommendation logic.
- The patch restores Plan as top-level or adds a sixth tab.
- Release, device, accessibility, performance, privacy/legal, visual runtime, or global-completion claims are made without current proof.

# Rollback Expectations

Rollback only this batch's changed files. Preserve active SA/PK/global-train work. Do not delete historical evidence unless a dedicated RHC/historical-policy batch owns it.

# Final Report Requirements

Create or update:

```text
{report_name}
```

Report must include:

- status
- operating system
- product loop
- source truth inspected
- files changed
- validation commands and exit codes
- EFC applicability
- loop behavior added or still deferred
- claims not made
- rollback notes
- next handoff

# Claims Not Made

{no_claims}
'''


def main() -> int:
    parser = argparse.ArgumentParser(description="Materialize MRI prompt files from overlay JSON.")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    overlay = json.loads(OVERLAY.read_text(encoding="utf-8"))
    batches = overlay.get("batches", [])
    PROMPT_DIR.mkdir(parents=True, exist_ok=True)
    for batch in batches:
        path = ROOT / batch["prompt_file"]
        text = prompt_for(batch)
        if args.dry_run:
            print(f"DRY_RUN {path.relative_to(ROOT)}")
        else:
            path.write_text(text, encoding="utf-8")
            print(f"WROTE {path.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
