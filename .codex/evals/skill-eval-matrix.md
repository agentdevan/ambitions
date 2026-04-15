# Skill Eval Matrix

| Skill | Request shape that should trigger it | Likely repo areas | Common failure pattern | Should not touch by default |
| --- | --- | --- | --- | --- |
| `phase-executor` | roadmap phase or backlog item needing exact repo plan | `docs/`, `project.yml`, `Native/Ambitions/` | planning from generic iOS assumptions without repo inspection | unrelated UI polish files |
| `xcodegen-target-writer` | target, plist, entitlement, bundle, or scheme wiring | `project.yml`, plist, entitlements, target folders | hand-waving target config or skipping dependent files | unrelated domain logic |
| `ios-extension-builder` | widget, Live Activity, Share extension, App Intents | `project.yml`, extension targets, snapshots, routing docs | writing extension code that reaches into app-only internals | unrelated feature screens |
| `capture-flow-implementer` | capture model, service, routing, inbox, source typing | capture domain, services, persistence, captures feature | collapsing captures into a generic inbox or editing only one layer | planner-only files |
| `repo-truth-enforcer` | docs truth, stale copy, removed claims | `README.md`, `docs/`, previews, profile copy | inventing features or leaving historical claims unlabeled | unrelated target wiring |
| `ios-qa-regression-checker` | validation or regression check ask | validation docs, CI workflow, changed code paths | claiming tests/builds passed without running them | unrelated product copy |
| `design-system-guard` | premium UI polish or anti-drift review | `Native/Ambitions/Features/`, `Sources/`, `AppUI/Sources/` | random restyling or unrelated redesign | domain/persistence files |
| `planner-domain-safe-editor` | Today/planner/reschedule/feedback logic change | `Native/Ambitions/Domain/`, Today/Goals services, tests | broad rewrites with weak invariant tracking | unrelated docs cleanup |
| `release-hardening` | final preflight, merge prep, release sanity | docs, plist, entitlements, project config, validation docs | saying the branch is ready without real checks | unrelated new feature work |
