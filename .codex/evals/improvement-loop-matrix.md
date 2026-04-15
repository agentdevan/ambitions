# Improvement Loop Matrix

| Failure pattern | Should be caught by | Likely system update layer | Example Ambitions surface |
| --- | --- | --- | --- |
| wrong skill used | post-run review plus eval prompt | skill or operations docs | capture task misrouted as generic feature work |
| over-editing | eval prompt plus run review | skill, template, or AGENTS | planner change spills into unrelated UI |
| invented seam | stop-condition eval plus run review | skill, blocked-work template, or AGENTS | notification ingestion path that does not exist |
| weak validation | QA eval plus post-run review | `ios-qa-regression-checker` or validation templates | build claims made without Xcode tools |
| docs truth drift | docs truth eval plus run review | `repo-truth-enforcer` or operations docs | stale README after native cleanup |
| extension wiring miss | extension eval plus run review | `xcodegen-target-writer` or `ios-extension-builder` | Share extension missing plist or entitlement handling |
| domain overreach | planner eval plus run review | `planner-domain-safe-editor`, nested Domain AGENTS, or templates | rescheduling rewrite too broad |
| release miss | release eval plus run review | `release-hardening`, release templates, or operations docs | merge-readiness claim too strong |
