# Ambitions iOS Development Toolkit Readiness Snapshot
**Timestamp:** 2026-06-23 08:44 EDT  
**Auditor Posture:** Senior QA / Release Engineer  
**Status Verdict:** Ready with Caveats  
**Artifact Path:** [toolkit-snapshot-20260623-0844.md](file:///Users/devan/Documents/GitHub/ambitions/docs/dev/toolkit-snapshots/toolkit-snapshot-20260623-0844.md)  
**Local Helper Script:** [toolkit-snapshot.sh](file:///Users/devan/Documents/GitHub/ambitions/scripts/dev/toolkit-snapshot.sh)

---

## 1. Executive Summary

A comprehensive readiness audit of the local macOS development environment was performed on `main` at commit `79e044178afd4aa8de4a0b6cd969c0416e1cdcdc`.

Overall, the machine is highly capable, and the core iOS compilation toolchain works perfectly. The project generated and compiled successfully in **2m 19s** for the iOS 26.5 Simulator. However, the environment is **Ready with Caveats** due to two main issues:
1. **Broken Quality Gate Tooling:** The python validation script `scripts/ambitions-quality-gate.py` crashes because it depends on `scripts/ambitions-architecture-inventory.py`, which is looking for a deleted header (`## 17. Final Architecture Tree`) in `docs/canon/migration/legacy-semantic-migration.json`. This is a blocking tool bug that must be repaired before starting `AMB-1191` to ensure correct local audits can run.
2. **Missing SF Symbols Application:** SF Symbols is not installed in `/Applications`. This is required for visual token mapping and native iOS glyph registry inspection.

---

## 2. Machine / OS / VM Snapshot

* **macOS Version:** macOS 26.5.1 (Build 25F80)
* **Hardware Model / CPU:** Intel(R) Core(TM) i5-9600K CPU @ 3.70GHz (x86_64)
* **RAM:** 8.00 GB (8,589,934,592 bytes)
* **Free Disk Space:** 21 GiB available of 200 GiB (36% capacity) on `/`
* **Current Shell:** `/bin/zsh` (User), `/bin/bash` (Script context)
* **User:** `devan`
* **Repo Path:** `/Users/devan/Documents/GitHub/ambitions` (Mounted on main macOS volume `/dev/disk1s4s1`)

---

## 3. Xcode / Apple Toolchain

* **Selected Developer Path:** `/Applications/Xcode.app/Contents/Developer`
* **Xcode Version:** 26.6 (Build version 17F113)
* **Command Line Tools:** Installed (`com.apple.pkg.CLTools_Executables` version `26.6.0.0.1780393157`)
* **Available SDKs:**
  * iOS 26.5 (iphonesimulator26.5 and iphoneos26.5)
  * macOS 26.5
  * tvOS 26.5
  * visionOS 26.5
  * watchOS 26.5
  * DriverKit 25.5
* **iOS Simulator Runtimes:**
  * iOS 26.3 (26.3.1 - 23D8133)
  * iOS 26.5 (26.5 - 23F77)
* **Installed Simulator Devices:** iPhone 17 (iOS 26.3, 26.5), iPhone 17 Pro Max (iOS 26.5), iPhone 17e (iOS 26.5), iPhone Air (iOS 26.5)
* **Compilation Status:** **Success**. Local compilation via `xcodebuild` targeting `iPhone 17 Pro Max` simulator succeeded in **2 minutes, 19 seconds** (excluding dependencies resolution).
* **Workspace / Project / Scheme Discovery:** Working.
  * Project `Ambitions` target schema is parsed correctly.
  * Target schemes found: `Ambitions`, `AmbitionsDesignSystem`, `AmbitionsExperienceKernel`, `AmbitionsWidgetUI`.

---

## 4. Apple Developer Apps / Resources

* **SF Symbols:** **Missing** (Not present in `/Applications`)
* **Icon Composer:** **Present** (`/Applications/Icon Composer.app`)
* **Reality Composer:** **Missing / Not in Applications**
* **Accessibility Inspector:** **Present** (Via Xcode -> Developer Tools)
* **Instruments / xctrace:** **Present** (`/Applications/Xcode.app/Contents/Developer/usr/bin/xctrace`)
* **Xcode Side-by-Side:** No beta/alternative Xcode installed.

---

## 5. Swift & CLI Developer Tools

| Tool | Status | Version | Path / Executable |
|---|---|---|---|
| **Swift Compiler** | Ready | 6.3.3 | `/usr/bin/swift` |
| **SwiftPM** | Ready | Swift 6.3.3 | `/usr/bin/swift` |
| **Homebrew** | Ready | 6.0.2 | `/usr/local/bin/brew` |
| **XcodeGen** | Ready | 2.45.4 | `/usr/local/bin/xcodegen` |
| **SwiftFormat** | Ready | 0.61.0 | `/usr/local/bin/swiftformat` |
| **swift-format** | Missing | - | - |
| **SwiftLint** | Ready | 0.63.2 | `/usr/local/bin/swiftlint` |
| **xcbeautify** | Ready | 3.2.1 | `/usr/local/bin/xcbeautify` |
| **xcpretty** | Missing | - | - |
| **xcparse** | Ready | 2.3.2 | `/usr/local/bin/xcparse` |
| **periphery** | Ready | 3.7.4 | `/usr/local/bin/periphery` |
| **sourcery** | Ready | 2.3.0 | `/usr/local/bin/sourcery` |
| **fastlane** | Ready | 2.232.2 | `/usr/local/bin/fastlane` |
| **git-lfs** | Ready | 3.7.1 | `/usr/local/bin/git-lfs` |
| **Ruby** | Ready | 2.6.10p210 / 3.2.6p353 | `/usr/bin/ruby` |
| **Bundler** | Ready | 1.17.2 | `/usr/bin/bundle` |
| **Python 3** | Ready | 3.14.5 | `/usr/local/bin/python3` |
| **Node.js** | Ready | v26.3.0 | `/usr/local/bin/node` |
| **npm** | Ready | 11.16.0 | `/usr/local/bin/npm` |
| **pnpm** | Ready | 11.6.0 | `/usr/local/bin/pnpm` |
| **yarn** | Missing | - | - |

---

## 6. Repo Structure / Build Setup

* **Current Branch:** `main` (clean working tree, tracking `origin/main`)
* **Commit SHA:** `79e044178afd4aa8de4a0b6cd969c0416e1cdcdc`
* **Remotes:** `origin https://github.com/agentdevan/ambitions.git`
* **Configuration Files:**
  * `project.yml` is present (defines app structure and targets).
  * `Package.swift` is present (defines the `AmbitionsDesignSystem` package).
  * `Packages/AmbitionsExperienceKernel/Package.swift` is present.
  * `Ambitions.xcodeproj` is present (generated locally, correctly ignored/regenerated).
* **Package Dependencies:** Resolved correctly.
* **Scripts Directory:** Structurally intact containing 40 validation and build scripts.

---

## 7. Existing Ambitions Validation/Audit Capability

* **Hard-coded Color Audit:** Checked via python gate and `RAW_DESIGN_LITERAL_PATTERNS`.
* **Forbidden Language Audit:** Covered by `ForbiddenLanguageAudit.swift` and `ForbiddenTopLevelTerms.swift`.
* **Safe Area Audit:** Covered by `SafeAreaAudit.swift` and python gate patterns.
* **Shell Chrome Audit:** Covered by `ShellChromeAudit.swift` and python gate patterns.
* **Dynamic Type Audit:** Covered by `DynamicTypeAudit.swift`.
* **Motion Reduction Audit:** Covered by `MotionReductionAudit.swift`.
* **Visual Regression Harness:** `VisualRegressionHarness.swift` exists.
* **Screenshot Generation:** `ambitions-run-ui-screenshot-matrix.sh` exists.
* **Accessibility Proof:** `AccessibilityAudit.swift` and `AFEP021AccessibilityCertificationProgram.swift` exist.
* **Known-Issues Sync:** `lifeshape-linear-control-plane-check.py` exists.
* **Build/Test Helpers:** `build-local.sh`, `test-local.sh`, and `Makefile` present.

---

## 8. Codex / Agent / MCP Setup

* **Codex Manifest:** `.codex/manifest.json` is present.
* **Agent configuration:** `.agents/` contains 9 active skills (`ambitions-ios-quality-gate`, `ambitions-architecture-tree-enforcement`, etc.).
* **AGENTS.md:** Present in root, active repo contract.
* **XcodeBuildMCP:** References found in docs and `AGENTS.md`; `.xcodebuildmcp` exists.
* **xcparse integration:** CLI tool version 2.3.2 is ready.

---

## 9. Apple Quality Readiness Assessment

| Category | Status | Evidence | Gap | Recommended Action |
| :--- | :--- | :--- | :--- | :--- |
| **Xcode Stable Toolchain** | Ready | Xcode 26.6 | None | None |
| **iOS Simulator Runtime** | Ready | iOS 26.5 & 26.3 | None | None |
| **Real-Device Proof Path** | Present but unverified | Entitlements and configuration exist | No active local profile verified | Configure local development profile when ready to sign |
| **Swift Compiler/Build** | Ready | Build Succeeded in 2m 19s | None | None |
| **XcodeGen/Project Gen** | Ready | Version 2.45.4 | None | None |
| **Formatting** | Ready | swiftformat 0.61.0 | swift-format is missing | Use swiftformat (already configured) |
| **Linting** | Ready | swiftlint 0.63.2 | None | None |
| **Test Execution** | Present but unverified | Schemes parsed | Test runner not yet executed | Run `make test-local` to verify tests compile and pass |
| **Result Parsing** | Ready | xcparse 2.3.2 | None | None |
| **Screenshot Extraction** | Present but unverified | `run-ui-screenshot-matrix.sh` present | Not run during audit | Run screenshot runner to test simulator screen capture |
| **Visual Regression** | Present but unverified | `VisualRegressionHarness.swift` exists | Not run during audit | Validate visual diff harness runs locally |
| **Accessibility Validation** | Present but unverified | `AccessibilityAudit.swift` present | Quality gate script crashes | Fix quality gate script parser crash |
| **Dynamic Type Validation** | Present but unverified | `DynamicTypeAudit.swift` present | Quality gate script crashes | Fix quality gate script parser crash |
| **Reduce Motion Validation** | Present but unverified | `MotionReductionAudit.swift` present | Quality gate script crashes | Fix quality gate script parser crash |
| **Hard-Coded Color Audit** | Present but unverified | `ambitions-quality-gate.py` has literals check | Quality gate script crashes | Fix quality gate script parser crash |
| **Forbidden Language Audit** | Present but unverified | `ForbiddenLanguageAudit.swift` present | Quality gate script crashes | Fix quality gate script parser crash |
| **Safe-Area/Shell Audit** | Present but unverified | `SafeAreaAudit.swift` present | Quality gate script crashes | Fix quality gate script parser crash |
| **Repo AGENTS Quality** | Ready | `AGENTS.md` and 9 skills present | None | None |
| **Remediation Dossier Avail**| Ready | `AMB-1191-theme-design-system.md` present| None | None |
| **Known-Issues Register Avail**| Ready | `docs/qa/KNOWN_ISSUES.md` present | None | None |
| **Linear/GitHub Proof** | Present but unverified | Python status scripts present | Not run during audit | Run `lifeshape-linear-control-plane-check.py` |
| **Apple Design Resources** | Missing | Not found in `/Applications` | Missing UI kits | Download Apple HIG iOS Design resources |
| **SF Symbols Availability** | Missing | Not found in `/Applications` | SF Symbols app missing | Download SF Symbols 6 |
| **Icon Composer Avail** | Ready | `/Applications/Icon Composer.app` | None | None |

---

## 10. Missing / Optional Installs

1. **SF Symbols 6 (Critical):** Highly recommended for design system work.
2. **Apple Design Resources / UI Kits (Optional):** Highly recommended for HIG alignment.
3. **swift-format (Optional):** Not needed as `swiftformat` is configured.
4. **xcpretty (Optional):** Not needed as `xcbeautify` is installed.

---

## 11. Verification Plan & Commands Executed

All checks were run in read-only mode to prevent system changes:
1. `sw_vers && uname -a && sysctl -n machdep.cpu.brand_string && sysctl -n hw.memsize && df -h / && whoami && pwd` (Machine info)
2. `ls -1 /Applications` (App detection)
3. `xcodebuild -version && xcodebuild -showsdks && xcrun simctl list runtimes` (Toolchain & SDKs)
4. `xcrun simctl list devices available` (Simulators inventory)
5. `swift --version && which brew && brew --version && which xcodegen && xcodegen --version && which swiftformat && swiftformat --version && which swiftlint && swiftlint version && which xcbeautify && xcbeautify --version && which xcparse && xcparse version && which periphery && periphery version && which sourcery && sourcery --version && which fastlane && fastlane --version && which ruby && ruby -v && which python3 && python3 --version && which node && node --version && which pnpm && pnpm --version && which git-lfs && git-lfs version` (CLI tools detection)
6. `git status --short --branch && git rev-parse HEAD && git remote -v` (Git snapshot)
7. `xcodebuild -list` (Workspace & Scheme parsing)
8. `python3 scripts/ambitions-quality-gate.py` (Local audit scan - *Failed due to parser error*)
9. `bash scripts/build-local.sh` (Local simulator build test - *Succeeded*)

### Commands Intentionally Not Run and Why
* `make test-local` or direct test executions were not run to prevent long CPU runs and focus only on tool presence/readiness.
* Global write settings (`defaults write`) were not run to keep system configuration pristine.
* `npm install`, `brew install`, or other installers were not run in compliance with the "do not install anything" constraint.

---

## 12. Sensitive Data Redaction Note

In compliance with repo security guidelines:
* All private network domains, access tokens, SSH credentials, and email addresses in command output logs were redacted.
* Repository URL credentials were redacted using `sed` streaming rules.

---

## 13. Final Recommendation

**Ready with Caveats**

The environment is ready to compile and build Ambitions, but the following issues should be resolved before proceeding with `AMB-1191`:
1. **Fix the Quality Gate Parser:** Modify `scripts/ambitions-architecture-inventory.py` to either dynamically adapt to the new `PRODUCT_DESIGN_TRUTH.md` layout, or bypass the missing header check so that `ambitions-quality-gate.py` can run successfully.
2. **Download SF Symbols 6:** Download the SF Symbols app from Apple Developer to enable previewing and auditing glyph assets.

---

## 14. Validation Repair Train Closeout (2026-06-23 09:23)

A bounded validation repair train was executed on `main` before starting `AMB-1191`:
1. **Restored the Canonical Final Architecture Tree:** Section `## 17. Final Architecture Tree` was merged back into `docs/canon/migration/legacy-semantic-migration.json` without losing any of the 2026-06-22 remediation canon. This successfully resolved the `ambitions-architecture-inventory.py` parser mismatch (returning `GREEN final-tree parity achieved`).
2. **Excluded Policy/Audit Definition Files from Quality Gate Scans:** A narrow allowlist (`POLICY_AUDIT_FILES`) was added to `scripts/ambitions-quality-gate.py` containing `ForbiddenTopLevelTerms.swift`, `ForbiddenLanguageAudit.swift`, `LifeShapeFakePrecisionAudit.swift`, and `UserLanguageCategoryAudit.swift`. This prevents forbidden-language false positives on the definitions/audits themselves.
3. **Successful Execution:** The quality gate command `python3 scripts/ambitions-quality-gate.py` now completes successfully with `GREEN all strict quality gates passed`. The local build `bash scripts/build-local.sh` compiles cleanly without error.

