<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01 - Ambitions Codex OS Flagship Autonomy Upgrade Installer

## Batch ID

AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01

## Runner command

```bash
scripts/ambitions-codex-train.sh AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01 prompts/batches/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md
```

## Execution model

This is an installer prompt. It must upgrade the existing Ambitions Codex OS so future batches behave more like an autonomous senior product/design/iOS/backend/QA/privacy/release department. It must not replace the existing repo OS. Inspect, reuse, and extend.

## Objective

Install Codex OS upgrades that make future Ambitions work safer, more autonomous, more repo-aware, more proof-driven, more visually rigorous, less likely to duplicate authority, less likely to produce doc-only Green, less likely to ship v1-feeling UI, and more capable of building a flagship local-first Personal Life Operating System.

Create or update skills, tools, policies, report templates, validation gates, and review boards inside the existing repo OS.

## Required inspection

Inspect before changes:

- `README.md`
- `Makefile`
- `docs/codex/`
- `docs/codex/batches/`
- `docs/codex/batch-trains/`
- `docs/codex/reports/`
- `docs/codex/review-boards/`
- `docs/canon/`
- `.codex/`
- `.codex/skills/`
- `scripts/`
- `build/reports/`

Search for:

```text
Repo Doctor
Codex OS
batch train
runner
review board
skill
validation
visual QA
SwiftUI
privacy
release
authority
canon
obsolete
archive
```

Do not create a second OS. Do not overwrite existing skills without preserving intent. If an equivalent skill exists, upgrade it instead of duplicating it.

## Required installed artifacts

Use active repo paths if different. Suggested locations:

- `docs/codex/os/`
- `docs/codex/os/AMB-CODEX-OS-FLAGSHIP-UPGRADE-MANIFEST.md`
- `docs/codex/os/AMB-CODEX-OS-AUTHORITY-RESOLVER.md`
- `docs/codex/os/AMB-CODEX-OS-GREEN-YELLOW-RED-STANDARD.md`
- `docs/codex/os/AMB-CODEX-OS-NO-SPRAWL-GUARD.md`
- `docs/codex/os/AMB-CODEX-OS-PROOF-LEDGER.md`
- `docs/codex/os/AMB-CODEX-OS-VISUAL-QA-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-PRIVACY-CLAIM-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-APPLE-CONTINUITY-GATE.md`
- `docs/codex/os/AMB-CODEX-OS-LAUNCH-BELIEVABILITY-GATE.md`
- `docs/codex/reports/AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01.md`
- `.codex/skills/ambitions/`

Suggested skills:

- `.codex/skills/ambitions/authority-resolver.md`
- `.codex/skills/ambitions/batch-train-composer.md`
- `.codex/skills/ambitions/no-sprawl-guard.md`
- `.codex/skills/ambitions/source-truth-classifier.md`
- `.codex/skills/ambitions/swiftui-flagship-ui-reviewer.md`
- `.codex/skills/ambitions/backend-local-first-reviewer.md`
- `.codex/skills/ambitions/apple-continuity-reviewer.md`
- `.codex/skills/ambitions/privacy-claim-verifier.md`
- `.codex/skills/ambitions/proof-ledger-writer.md`
- `.codex/skills/ambitions/accessibility-native-ios-reviewer.md`
- `.codex/skills/ambitions/release-believability-reviewer.md`
- `.codex/skills/ambitions/red-team-reviewer.md`

Optional scripts if repo convention supports them:

- `scripts/ambitions-proof-ledger-validate.py`
- `scripts/ambitions-no-sprawl-scan.py`
- `scripts/ambitions-visual-qa-checklist.py`
- `scripts/ambitions-privacy-claim-scan.py`
- `scripts/ambitions-launch-believability-scan.py`

Do not add brittle scripts if the repo OS has a better convention.

## Operating concepts to install

### Authority Resolver

Force Codex to answer: what active truth did I inspect, which source outranks which, am I about to create duplicate authority, is this active/supporting/historical/obsolete, and where should this change live?

### No-Sprawl Guard

Prevent duplicate canon trees, duplicate design systems, duplicate backend modules, orphan prompts, unregistered docs, second implementation plans, top-level concept drift, and `.codex/runs` pollution.

### Proof Ledger

Every batch must record claim, evidence, file path, validation command, status, known gaps, and proof type: source, test, visual, doc, or report. No proof means no Green.

### Visual QA Gate

UI work requires preview/screenshot proof, supported iPhone size consideration, Dynamic Type, Reduce Motion, empty/normal/dense/error/recovery states, one-primary-object rule, and anti-dashboard check.

### Privacy Claim Gate

Privacy/local-first/iCloud/security/export/delete claims must map to source code, entitlement, privacy manifest, user-facing copy, and test/report evidence. No claim may outrun code.

### Apple Continuity Gate

iCloud/CloudKit/continuity changes must answer what syncs, what remains local, offline behavior, new iPhone behavior, iCloud disabled behavior, conflict handling, privacy copy, and app group/widget/share implications.

### Launch Believability Gate

Before release, Codex must judge whether the app feels flagship, local-first, trustworthy, category-creating, free of v1 seams, and credible to skeptical users.

### Red Team Reviewer

Mandatory final review persona for major trains. It looks for false claims, fake proof, generic UI, hidden server assumptions, data loss risk, privacy mismatch, duplicate authority, untested migrations, accessibility regressions, and promising-but-early feel.

## Required generated batch prompts

Install smaller Codex OS implementation prompts, each with the required runner header:

1. `OS-FLAGSHIP-01-AUTHORITY-RESOLVER`
2. `OS-FLAGSHIP-02-NO-SPRAWL-GUARD`
3. `OS-FLAGSHIP-03-PROOF-LEDGER`
4. `OS-FLAGSHIP-04-VISUAL-QA-GATE`
5. `OS-FLAGSHIP-05-PRIVACY-APPLE-CONTINUITY-GATES`
6. `OS-FLAGSHIP-06-LAUNCH-BELIEVABILITY-REVIEW`
7. `OS-FLAGSHIP-07-SKILL-REGISTRY-AND-RUNNER-INTEGRATION`

## Skill details

Install or upgrade the requested skills with these requirements:

- `authority-resolver.md`: source hierarchy, active/supporting/historical/obsolete classification, conflict rules, path discovery, duplicate authority refusal, final report checklist.
- `batch-train-composer.md`: splitting mega-work into bounded batches, dependencies, Green/Yellow/Red standards, implementation vs installer distinction, prompt requirements.
- `no-sprawl-guard.md`: duplicate design system/backend/canon detection, orphan docs, stale prompt detection, authority-path mapping.
- `source-truth-classifier.md`: active, supporting, historical, obsolete, archive-candidate, delete-candidate, unknown.
- `swiftui-flagship-ui-reviewer.md`: one-primary-object, native iPhone-first, anti-dashboard, anti-card-stack, typography/material/spacing, motion/haptics, preview/screenshot proof, accessibility proof.
- `backend-local-first-reviewer.md`: local-first invariants, no custom server dependency, no AI/backend/analytics SDK checks, deterministic recommendation proof, data durability proof, proof/receipt persistence proof, view-layer computation rejection.
- `apple-continuity-reviewer.md`: iCloud/CloudKit, app group/widget/share implications, offline/new-device states, conflict artifacts, Trust Console projection, false sync claim rejection.
- `privacy-claim-verifier.md`: privacy manifest, entitlements, App Store copy, onboarding claim, export/delete claim, local-first claim.
- `proof-ledger-writer.md`: recording evidence, proof quality levels, unsupported claim format, no-Green-without-proof rule.
- `accessibility-native-ios-reviewer.md`: Dynamic Type, VoiceOver order, hit targets, contrast, reduced motion, status announcements, native sheet/navigation behavior.
- `release-believability-reviewer.md`: flagship rubric, Personal Life OS category rubric, trust rubric, launch blockers, closed beta trust questions.
- `red-team-reviewer.md`: skeptical checklist, would users call this early, would this damage trust, what is fake, what is generic.

## Validation expectations

Discover available commands first:

```bash
make help
make doctor
make validate
make test
python3 scripts/ambitions-codex-os-validate.py --help
```

Run safe repo OS validation if available. If new scripts are created, they must have help output, no destructive behavior, clear exit codes, and documented scope. Do not invent passing validation.

## Forbidden scope

Do not rewrite app source, change product IA, add backend dependencies, analytics, AI SDKs, server code, stage `.codex/runs` artifacts unless policy requires it, delete existing skills without mapping/replacement, or create a duplicate repo OS root.

## Hard Red stops

Stop if the existing repo OS cannot be identified, skill location cannot be safely determined, generated skills would duplicate active skills, validation cannot be discovered and no honest report can be produced, changes would overwrite unrelated dirty files, the upgrade would weaken runner-required execution, no-sprawl policy cannot be installed without conflict, or visual/privacy/continuity gates cannot be registered or reported.

## Final response format

Return:

```md
# AMB-CODEX-OS-FLAGSHIP-UPGRADE-INSTALL-01 Result

## Status

GREEN / YELLOW / RED

## Summary

## Existing repo OS discovered

## Installed Codex OS upgrades

## Skills created or modified

## Scripts created or modified

## Review boards / gates installed

## Validation

## Risks

## Worktree hygiene

## Rollback

## Recommended next command
```

## Success definition

Future Ambitions Codex batches must become materially better at finding active truth, avoiding duplicate authority, requiring proof, building premium UI, protecting privacy claims, handling Apple continuity honestly, avoiding generic product patterns, refusing fake Green status, and shipping toward flagship believability.
