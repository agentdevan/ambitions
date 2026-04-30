# Ambitions 3.0 — Local Toolchain Readiness Matrix

Status: Active developer experience canon

## Purpose

Codex should know which local tools are required, adopted, advisory, later, or
avoided before starting work. Missing required tools block validation. Missing
advisory tools reduce evidence quality but do not prove app failure.

## Matrix

| Tool | Class | Purpose | Install | Verify | Impact | Status | Use |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Xcode | Required | Build/test/archive native app | App Store/Apple developer | `xcodebuild -version` | Blocks native validation | Blocking | All native work |
| xcode-select | Required | Select developer directory | Xcode CLT | `xcode-select -p` | Blocks Xcode tools | Blocking | Preflight |
| XcodeGen | Required | Generate project from `project.yml` | `brew install xcodegen` | `xcodegen --version` | Blocks project generation | Blocking | Build/test |
| SwiftPM | Required | Resolve packages | Xcode | `swift --version` | Blocks package resolution | Blocking | Build/test |
| git | Required | Repo truth | Xcode/Homebrew | `git --version` | Blocks source control | Blocking | Every run |
| zsh/bash | Required | Scripts | macOS | `zsh --version` | Blocks scripts | Blocking | Every run |
| ripgrep | Required | Fast scans | `brew install ripgrep` | `rg --version` | Slower scans if absent | Blocking for Codex scans | Search |
| iPhone simulator runtime | Required | Local app validation | Xcode Components | `xcrun simctl list devices available` | Blocks simulator proof | Blocking for UI/build destination | Native validation |
| gh | Adopted developer tool | GitHub inspection | `brew install gh` | `gh --version` | Local GitHub automation reduced | Advisory credentials | PR/CI inspection |
| jq | Adopted developer tool | JSON parsing | `brew install jq` | `jq --version` | Parsing less reliable | Advisory | simctl/gh output |
| xcbeautify | Adopted developer tool | Readable Xcode logs | `brew install xcbeautify` | `xcbeautify --version` | Logs noisier | Advisory | wrappers |
| markdownlint-cli2 | Adopted docs QA | Markdown lint | `brew install markdownlint-cli2` | `markdownlint-cli2 --version` | Docs lint unavailable | Advisory | docs QA |
| lychee | Adopted docs QA | Link checking | `brew install lychee` | `lychee --version` | Link audit unavailable | Advisory | docs QA |
| shellcheck | Recommended next | Shell script lint | `brew install shellcheck` | `shellcheck --version` | Shell issues caught later | Docs only | Script hardening |
| shfmt | Recommended next | Shell formatting | `brew install shfmt` | `shfmt --version` | Formatting manual | Docs only | Script hardening |
| yq | Recommended next | YAML parsing | `brew install yq` | `yq --version` | YAML parsing manual | Docs only | project/workflow audits |
| fd | Recommended next | Fast file search | `brew install fd` | `fd --version` | Use `find` fallback | Docs only | local exploration |
| tree | Recommended next | Directory snapshots | `brew install tree` | `tree --version` | Use `find` fallback | Docs only | reports |
| xcparse | Recommended next | xcresult extraction | `brew install chargepoint/xcparse/xcparse` | `xcparse version` | Use Xcode tools fallback | Docs only | test evidence |
| SwiftLint | Advisory staged | Swift style lint | `Brewfile.optional-later` | `swiftlint version` | Not active | Optional Brewfile | later lint gate |
| SwiftFormat | Advisory staged | Swift formatting | `Brewfile.optional-later` | `swift-format --version` | Not active | Optional Brewfile | later formatting |
| Fastlane | Later | Signing/TestFlight automation | `Brewfile.optional-later` | `fastlane --version` | Not active | Optional Brewfile | future release automation |
| Tuist | Avoid | Project generation alternative | N/A | N/A | Conflicts with XcodeGen | Avoid | Never without canon reset |
| SwiftGen | Avoid | Code generation | N/A | N/A | Unneeded complexity | Avoid | Not now |
| Sourcery | Avoid | Code generation | N/A | N/A | Unneeded complexity | Avoid | Not now |
| Danger | Avoid | CI review automation | N/A | N/A | CI/process overhead | Avoid | Not now |
| Analytics SDKs | Avoid | Tracking | N/A | N/A | Privacy/runtime risk | Forbidden without policy | Not now |
| Backend SDKs | Avoid | Remote services | N/A | N/A | Local-first risk | Forbidden without policy | Not now |
| AI SDKs | Avoid | Model integration | N/A | N/A | AI-wrapper risk | Forbidden without policy | Not now |
| Paid QA services | Avoid | Hosted QA | N/A | N/A | Cost/process risk | Avoid | Not now |

## Validation

Use:

```bash
brew bundle check || true
scripts/validate-dev-tools.sh || true
scripts/build-local.sh || true
```

## Brewfile Placement

- `Brewfile`: XcodeGen, ripgrep, `gh`, `jq`, `xcbeautify`, `markdownlint-cli2`, and `lychee` as adopted local developer tools. Xcode, `xcode-select`, SwiftPM, git, zsh, and simulator runtimes are system/Xcode requirements rather than Homebrew-only dependencies.
- `Brewfile.optional-later`: SwiftLint, SwiftFormat, and Fastlane only. They are staged/advisory and must not become blocking until promoted by the Dependency Promotion Ladder.
- Docs only: `shellcheck`, `shfmt`, `yq`, `fd`, `tree`, and `xcparse` until a future tooling batch promotes them.
- Avoid: Tuist, SwiftGen, Sourcery, Danger, analytics SDKs, backend SDKs, AI SDKs, and paid QA services unless a future human-approved canon change explicitly reverses the posture.
