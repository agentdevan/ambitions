# CS06 Failed-Taxonomy Retirement Risk Map

Status: CS06A risk map.

## Risk Ratings

| Seam group | Risk | Reason | CS06A decision | Next owner |
|---|---:|---|---|---|
| Command execution `.failed` status | Red if touched now | Real technical status and test dependency | Must preserve | CS06B proof |
| External action `.failed` outcome | Red if touched now | External route/action compatibility surface | Must preserve | CS06B proof |
| Async UI `.failed(String)` state | Red if touched now | Shared feature load/error state across app | Must preserve | CS06B proof |
| Bootstrap `.failed(String)` state | Red if touched now | Launch failure representation | Must preserve | CS06B/CS06C only if touched |
| `failedSafely` / `safeFailure` raw values | Red if touched now | Receipt/persistence/import/export trust semantics | Must preserve | CS06B proof, CS08-style import/export proof if changed |
| Smart Attachment `unavailable_failed` / `failed_safely` raw values | Red if touched now | Raw payload compatibility plus existing tests | Must preserve | CS06B proof |
| User-facing "failed/failure" copy candidates | Yellow | Canon discourages visible blame language, but exact UI exposure and behavior coupling must be proven | Defer to CS06C after proof | CS06B/CS06C |
| Accessibility labels/hints using failure language | Yellow/Red depending on identifier impact | Assistive copy may need humane wording, but identifiers are compatibility surfaces | Inventory only | CS06B/CS06C |
| Accessibility identifiers containing legacy terms | Red if touched now | UI automation compatibility surface | Preserve | CS06B/CS06C only with alias/deprecation proof |
| Tests asserting failure behavior | Red if weakened | Failure-path tests are compatibility proof | Preserve | CS06B can add/refine, not weaken |
| Historical docs/logs | Red if rewritten | Historical truth cannot be altered for copy cleanup | Preserve | None |
| Tooling/checklist failed/failure semantics | Yellow | Tooling pass/fail language is technical, but broad docs QA flags may remain | Preserve | Future tooling batch if needed |

## Backout Plan

CS06A changes are docs-only. Backout is a targeted revert of the CS06A ledgers, CS06 prompt repair, and status-doc updates. No app behavior, raw values, tests, persistence, or identifiers need rollback because none are touched.

CS06B backout must revert only focused tests/proof docs unless the ledger justifies a test fixture edit. CS06C backout must preserve compatibility shims and technical states; any retired seam must have a named rollback test.

## CS06A Recommendation

Proceed to CS06B focused proof. Do not execute CS06C until proof identifies a specific user-facing copy or dead seam that is safe to retire.
