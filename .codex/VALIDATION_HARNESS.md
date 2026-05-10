<!-- markdownlint-disable MD013 -->

# Codex Validation Harness

Status: Active Codex execution-excellence validation router  
Date updated: 2026-05-10  
Authority: Subordinate to `docs/truth/*`, `.codex/OPERATING_SYSTEM.md`, and
`.codex/TOOLING_AND_VALIDATION.md`

This harness defines deterministic validation packs Codex can select before
and after a patch. It is not product truth, implementation proof, release
proof, hosted CI proof, device proof, accessibility conformance, performance
proof, or legal/privacy approval.

## 1. Core Rule

Codex must choose validation from the task type, touched files, and claim risk.
A command is evidence only when its command, scope, output summary, exit code,
and non-claims are recorded in the closeout or proof packet.

## 2. Pack Selector

| Task type | Required pack | Optional pack | Stop condition |
| --- | --- | --- | --- |
| Docs/control-plane | Docs pack, forbidden-claim pack | Link hygiene, closeout shape | Truth conflict or false proof claim |
| Source implementation | Source pack, forbidden-claim pack | Build/test pack, EFC pack | Source mutation outside allowed paths |
| UI/SwiftUI work | Source pack, UI pack, accessibility/motion pack | Visual proof, performance | Visual-only meaning or inaccessible primary action |
| Accessibility work | Accessibility/motion pack, source pack | Visual proof | Claiming conformance without raw evidence |
| Performance work | Performance pack, source pack | Visual proof if UI | Budget claim without measurement |
| Release/proof work | Release-claim pack, evidence packet pack | Archive/signing only if approved | Readiness claim without current proof |
| Skill/tooling work | Docs pack, forbidden-claim pack, tooling pack | MCP self-test | Tool gains unsafe write/network/signing scope |
| Archive/delete work | Archive safety pack, docs pack | Link check | Missing inbound refs or rollback |

## 3. Docs Pack

Use for docs, `.codex`, status, prompt, governance, and report work.

Minimum checks:

- `git diff --check`
- `scripts/run-doc-qa.sh` when safe
- `scripts/codex-forbidden-claim-scan.sh <changed paths>` after Phase 2 exists
- Repo MCP closeout-shape check when a closeout report is changed
- Inbound-reference `rg` before archive/delete decisions

Evidence required:

- changed paths
- command and exit code
- advisory findings separated from blockers
- hard claims not made

Docs pack does not prove app behavior, build success, tests, release status,
visual quality, accessibility conformance, or performance.

## 4. Source Pack

Use when app/runtime/source files are explicitly in scope.

Minimum checks:

- verify allowed paths from the active prompt or batch
- inspect owning `AGENTS.md` overlays
- run `git diff --check`
- run focused source scans relevant to the touched seam
- run focused tests/build commands required by `.codex/TOOLING_AND_VALIDATION.md`

Evidence required:

- exact source files changed
- tests/build commands and exit codes
- failures and repairs
- rollback path

Source pack is forbidden in docs-only governance passes unless the user
explicitly approves a tiny validation scaffold.

## 5. UI Pack

Use for SwiftUI surface changes.

Minimum checks:

- product/design truth object mapping
- SwiftUI primitive contract check
- screenshot or preview proof when visual behavior is claimed
- copy/terminology scan
- no generic card-stack/dashboard/chatbot drift

Evidence required:

- target surface
- primary object/state/action
- screenshots or explicit reason visual proof was not run
- accessibility/motion checks run or not run

UI pack does not prove public accessibility conformance or release readiness.

## 6. Accessibility And Motion Pack

Use when UI, copy, interaction, or state visibility changes.

Minimum checks:

- VoiceOver semantic grouping and labels
- Dynamic Type behavior
- Reduce Motion equivalent
- Increase Contrast / color-not-only state
- touch target and gesture alternative review
- non-shaming copy review

Evidence required:

- checked states and viewports
- manual or tool evidence
- unverified assistive-tech gaps

No public accessibility conformance claim is allowed without current,
scope-specific evidence and release-truth approval.

## 6A. Accessibility Gate Details

VoiceOver gate:

- primary object has one coherent summary
- primary action is reachable and labeled
- source/trust/proof state is exposed without visual-only dependency
- decorative atmosphere is hidden or demoted
- rotor/order does not trap the user in repeated metadata

Dynamic Type gate:

- primary action remains visible
- labels do not overlap or clip in the claimed size range
- controls reflow rather than shrink below readability
- dense metadata can wrap, collapse, or move behind a seam

Contrast and color gate:

- state is never carried by color alone
- low-contrast graphite-on-graphite controls are repaired or rejected
- Increase Contrast has a stronger boundary/state alternative when claimed

Touch and gesture gate:

- primary tap targets are at least 44 pt, 48 pt preferred
- custom gestures have visible alternatives
- destructive actions require clear affordance and rollback/receipt where
  appropriate

Copy and cognition gate:

- no shaming recovery language
- no fake certainty or opaque model language
- one primary question/action per surface
- explanation moves through Trust Seam or equivalent detail, not a prose wall

## 6B. Motion Gate Details

Motion may clarify:

- origin
- state transition
- relationship between objects
- proof/receipt creation
- reflow after change

Motion must not be:

- decorative particles, scans, bounce, or parallax gimmicks
- the only cue for state change
- required to understand before/after relationships
- continuous without meaningful live state

Reduce Motion requirement:

- provide static before/after or state-label equivalent
- preserve object origin and destination
- avoid replacing meaning with fade-only transitions
- record whether Reduce Motion was inspected, simulated, or not run

Motion proof must cite screenshots, recordings, simulator evidence, or a manual
inspection checklist before claiming motion-safe behavior.

## 7. Visual Proof Pack

Use when visual state, layout, motion, screenshots, or screenshots-as-evidence
are relevant.

Minimum checks:

- current build/simulator/preview source of screenshots
- baseline and after screenshots when comparing
- visual-proof ledger entry
- no overlapping text, clipped controls, or illegible state
- Dynamic Type and Reduce Motion variants when claimed

Evidence required:

- screenshot path
- commit/branch if tied to a proof claim
- viewport/device/simulator
- what the image proves and does not prove

## 8. Performance Pack

Use when performance, responsiveness, launch, memory, or scroll quality is
touched or claimed.

Minimum checks:

- performance budget selected from `docs/status/performance-budgets.md`
- measurement command/tool named before the claim
- fallback/no-claim wording if no measurement ran

Evidence required:

- measurement tool and configuration
- raw or summarized output
- pass/fail against budget
- device/simulator caveat

Performance pack does not prove production performance, memory safety, or
real-device performance unless current evidence explicitly supports that scope.

## 9. Release-Claim Pack

Use on every closeout and any release/proof/status file.

Minimum checks:

- `docs/truth/RELEASE_TRUTH.md`
- forbidden-claim scan
- evidence packet check
- explicit non-claims

Claims blocked without current raw proof:

- build success
- tests pass
- release readiness
- TestFlight or App Store readiness
- physical-device validation
- public accessibility conformance
- performance readiness
- legal/privacy approval
- hosted CI proof

## 10. Archive Safety Pack

Use before any move/delete/archive action.

Minimum checks:

- classify file
- search inbound references
- identify replacement authority
- preserve unique evidence or decisions
- record rollback
- obtain approval when useful history or active refs remain

Archive safety pack must stop on possible data loss, broken front door, or
missing rollback.

## 11. Tooling Pack

Use for scripts, MCPs, local validators, and automation.

Minimum checks:

- classify read/write/network/secret/signing/git behavior
- self-test when available
- confirm no hosted CI/dependency/provider activation
- update `.codex/TOOLING_AND_VALIDATION.md` if tool posture changes

## 12. Green / Yellow / Red

Green:

- required pack selected
- commands run or explicitly not run with reason
- evidence recorded
- no false claims
- no scope violation

Yellow:

- safe advisory findings remain
- validation could not run for environment/tool reason
- no destructive or release claim made
- owner, reason, retirement condition, and resume path recorded

Red:

- truth conflict
- source mutation outside scope
- false proof/release claim
- unsafe tool expansion
- archive/delete data-loss risk
- validation contradiction

## 13. Phase 1 Gate Result

Phase 1 result: Green.

Validation for this phase:

- docs/control-plane artifact only
- no app/source/runtime files touched
- no release, accessibility, performance, device, hosted CI, legal/privacy, or
  implementation-complete claim made
