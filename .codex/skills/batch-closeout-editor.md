# Batch Closeout Editor Skill

Status: Active speed skill  
Purpose: Produce honest batch closeout reports quickly without adding new tests or inflating claims.

## Use when

Use at the end of every autonomous-train batch, whether Green, Accepted Yellow, or Red.

## Fast command

```bash
python3 scripts/ambitions-batch-closeout-accelerator.py --batch <BATCH_ID> --status "<STATUS>" --hbi "<HBI_APPLICABILITY>" --mri "<MRI_APPLICABILITY>" --print-path
```

Then run the existing final-report gate when applicable:

```bash
python3 scripts/ambitions-final-report-gate.py <REPORT_PATH> --strict || true
```

## Report must include

```text
batch ID
status
files changed
validation commands and true exit codes
HBI applicability
MRI applicability
defects repaired
defects deferred
Accepted Yellow rationale, if any
claims made
claims not made
rollback notes
next eligible batch
```

## Rules

- Use actual command output only.
- Do not claim a validation command ran if it did not run.
- Do not turn Red into Yellow for speed.
- Do not turn Yellow into Green for presentation.
- Do not claim release, device, App Store, TestFlight, accessibility, privacy/legal, or commercial readiness unless active proof exists.
- Do not add new tests or test frameworks.

## Claim boundary

This skill speeds documentation. It does not validate implementation, prove correctness, or authorize release claims.
