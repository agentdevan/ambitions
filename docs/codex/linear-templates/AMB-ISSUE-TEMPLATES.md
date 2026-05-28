# Ambitions Linear Issue Templates

Status: Active workflow templates.
Scope: Linear issue bodies for Codex-executed Ambitions work.
Manifest: `docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml`

Use compact mode by default. Use expanded mode only when the issue touches product
law, cross-surface architecture, privacy/runtime behavior, release claims, major
SwiftUI shell work, or repeated Codex drift.

## Compact Header

Paste this header at the top of every generated Linear issue:

```text
Template: <AMB-BATCH|AMB-FIX|AMB-DESIGN|AMB-REVIEW|AMB-DOCS|AMB-SPIKE>@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Repo: agentdevan/ambitions
Authority inspected:
- <exact repo path>
- <exact repo path>
```

## Shared Hard Constraints

Use these constraints for every Codex-executed issue:

```text
Hard constraints:
- Work only on this Linear issue.
- Use one branch: linear/<ISSUE-ID>-<short-name>.
- Do not merge directly to main.
- Do not edit unrelated files for opportunistic cleanup.
- Do not create product law, architecture law, release claims, or train sequencing.
- Repo truth wins over Linear status, comments, and generated summaries.
- Stop and report Yellow/Red if scope expands or repo truth conflicts with the issue.
```

## AMB-BATCH

Use for normal scoped implementation.

```text
Template: AMB-BATCH@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Repo: agentdevan/ambitions
Authority inspected:
- docs/truth/README.md
- docs/codex/LINEAR_CONTROL_PLANE.md
- <relevant prompt/source/test/proof paths>

Intent
Implement <specific outcome> so Ambitions gains <specific product/runtime/repo value>.

Scope
Codex may modify:
- <allowed file/folder>
- <allowed file/folder>

Codex must not modify:
- Unrelated surfaces
- Top-level IA
- Canonical product language
- Privacy/local-first architecture
- Runner behavior
- Train order
- Release claims
- Generated artifacts not required by this issue

Requirements
1. <specific code/doc/test change>
2. <specific acceptance behavior>
3. <specific compatibility/migration/accessibility/proof requirement>

Validation
Run:
- git status --short
- <primary validation command>
- <narrow regression command if available>
- python3 scripts/ambitions-codex-os-validate.py || true

Proof
Produce or update:
- <proof path or report path>

Stop conditions
Stop and report Yellow/Red if:
- Required files do not exist
- The issue conflicts with repo truth
- The fix requires unrelated architecture changes
- Validation cannot be repaired within this scope

Final response required
Return:
- Summary
- Changed files
- Commands run
- Proof artifacts
- Green/Yellow/Red
- Risks
- Follow-up issue, if needed
```

## AMB-FIX

Use for validation failure repair, build/test repair, proof repair, or a narrow
regression.

```text
Template: AMB-FIX@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Repo: agentdevan/ambitions
Authority inspected:
- docs/codex/LINEAR_CONTROL_PLANE.md
- <failing command log/report>
- <source/test/proof paths involved>

Failure
Observed failure:
- <exact failing command>
- <exact error summary>
- <path to failing log/report if available>

Intent
Repair the failure with the smallest safe change that preserves Ambitions repo truth.

Scope
Codex may modify:
- <allowed source/test/proof files>

Codex must not modify:
- Unrelated files
- Product law
- Public claims
- Runner contracts unless the failure is explicitly in the runner contract

Requirements
1. Reproduce or inspect the failure evidence before changing files.
2. Apply the smallest safe fix.
3. Rerun the failing command exactly.
4. Run one narrow regression command if available.
5. Record before/after evidence in the final response.

Validation
Run:
- git status --short
- <failing command exactly>
- <narrow regression command if available>
- python3 scripts/ambitions-codex-os-validate.py || true

Proof
Produce or update:
- <before/after proof path if required>

Stop conditions
Stop and report Red if:
- The failure cannot be reproduced or inspected
- The fix requires broader architecture work
- A product-law/privacy/runtime conflict appears
- The repair causes a new known failure

Final response required
Return:
- Summary
- Root cause
- Changed files
- Commands run
- Before/after proof
- Green/Yellow/Red
- Remaining risks
```

## AMB-DESIGN

Use for SwiftUI surfaces, design system, visual QA, Dynamic Type, VoiceOver,
Reduce Motion, haptics, previews, screenshots, and flagship interface work.

```text
Template: AMB-DESIGN@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Repo: agentdevan/ambitions
Authority inspected:
- docs/truth/PRODUCT_DESIGN_TRUTH.md
- docs/codex/LINEAR_CONTROL_PLANE.md
- <surface/source/design-system paths>

Intent
Implement <surface/system outcome> while preserving Ambitions as a premium native
iPhone-first Personal Life OS.

Surface / system
- Surface: <Today|Goals|Capture|Time|You|shared system>
- Primary object: <Reality Meridian|Constellation Atlas|Atmosphere Composer|LifeShape Field|User System Profile|shared>
- User-facing language: <exact copy>

Scope
Codex may modify:
- <SwiftUI files>
- <design tokens/components/previews/tests>

Codex must not modify:
- Top-level IA
- Product object names
- Local-first/privacy architecture
- Unrelated surfaces
- Generic dashboard/card-stack/chatbot/calendar-clone patterns

Requirements
1. Preserve native SwiftUI structure and semantic design tokens.
2. Preserve Dynamic Type, VoiceOver order, Reduce Motion behavior, and touch target safety.
3. Add or update previews when practical.
4. Avoid generic cards, dashboard stacks, and web-app layout patterns.
5. Produce validation/proof evidence or report Yellow with the environment reason.

Validation
Run:
- git status --short
- xcodebuild -list || true
- <surface build/test/preview validation command if available>
- python3 scripts/ambitions-codex-os-validate.py || true

Proof
Produce or update:
- <preview/screenshot/accessibility/proof path if available>

Stop conditions
Stop and report Yellow/Red if:
- The required surface files are absent
- The change requires canon updates first
- Validation is blocked by local Xcode environment
- The work would introduce generic UI patterns or accessibility regression risk

Final response required
Return:
- Summary
- Changed files
- Commands run
- Preview/accessibility/proof artifacts
- Green/Yellow/Red
- Risks
```

## AMB-REVIEW

Use for no-mutation audit, merge-readiness review, proof review, or status check.

```text
Template: AMB-REVIEW@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Repo: agentdevan/ambitions
Authority inspected:
- <authority files>
- <diff/branch/PR/proof paths>

Intent
Review <scope> and determine whether it is Green, Yellow, or Red against repo truth.

No-mutation rule
Do not edit files. Inspect only.

Review scope
- <files/folders/PR/proof paths>

Review questions
1. Does the work preserve repo truth and product law?
2. Does the diff stay within scope?
3. Do validation outputs support the claim?
4. Are proof artifacts present and current?
5. Are there release/privacy/accessibility/performance claims without proof?

Validation
Run or inspect:
- git status --short
- <review command or report path>

Final response required
Return:
- Summary
- Evidence inspected
- Green/Yellow/Red
- Blocking issues
- Non-blocking risks
- Recommended follow-up issues
```

## AMB-DOCS

Use for documentation, governance, canon support notes, and process-only work.

```text
Template: AMB-DOCS@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Repo: agentdevan/ambitions
Authority inspected:
- docs/truth/README.md
- docs/codex/LINEAR_CONTROL_PLANE.md
- <docs being changed>

Intent
Update <documentation/process artifact> so <workflow/repo truth value> is clearer and safer.

Scope
Codex may modify:
- <docs paths>

Codex must not modify:
- App source
- Tests
- Runner behavior
- Product law unless this issue explicitly installs a truth-file decision

Requirements
1. Keep documentation subordinate to `docs/truth/*` unless editing truth files explicitly.
2. Include non-claims for build/test/release/accessibility/privacy where relevant.
3. Use exact repo paths instead of vague references.
4. Keep wording concise enough for future Linear reuse.

Validation
Run:
- git status --short
- python3 scripts/ambitions-codex-os-validate.py || true

Proof
Produce or update:
- <docs path>

Final response required
Return:
- Summary
- Changed files
- Commands run
- Green/Yellow/Red
- Non-claims preserved
- Follow-up issue, if needed
```

## AMB-SPIKE

Use for investigation only. No production mutation.

```text
Template: AMB-SPIKE@v1
Manifest: docs/codex/linear-templates/AMB-LINEAR-TEMPLATE-MANIFEST.yml
Repo: agentdevan/ambitions
Authority inspected:
- <authority/source/report paths>

Intent
Investigate <question> and return a bounded recommendation.

No-mutation rule
Do not edit files. Do not create implementation branches. Inspect only.

Questions to answer
1. <question>
2. <question>
3. <question>

Evidence to inspect
- <repo paths>
- <reports/logs>

Final response required
Return:
- Answer
- Evidence inspected
- Options considered
- Recommended next issue template
- Green/Yellow/Red confidence
- Risks and unknowns
```

## Expanded Product-Law Addendum

Attach this addendum only when compact reference is not enough:

```text
Product law addendum
- Ambitions is a premium native iPhone-first Personal Life OS, not a task app,
  habit tracker, chatbot, calendar clone, generic dashboard, or SaaS demo.
- Top-level IA is Today / Goals / Capture / Time / You unless repo truth changes.
- Primary objects are Reality Meridian, Constellation Atlas, Atmosphere Composer,
  LifeShape Field, and User System Profile.
- Preferred language: Start here, Recommended step, Start now, Open step, Step.
- Avoid: next best move, Begin Focus, generic task language, dashboard framing,
  chatbot framing, and calendar-clone framing.
- Core moat is the local-first Private Life Runtime that deterministically converts
  goals/intent into inspectable, capacity-aware daily steps and adapts through
  time reality, closure, proof, and recovery.
- External/cloud LLMs are not core architecture.
```
