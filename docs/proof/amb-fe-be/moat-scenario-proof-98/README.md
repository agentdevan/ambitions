# AMB-FE-BE-MOAT-SCENARIO-PROOF-98

Result: GREEN

Scenario summary
- Same health-consistency intent, two local contexts, two different Start Here / Reality Meridian recommendations.
- Context A keeps the open window visible and recommends the health step.
- Context B keeps protected recovery time intact and recommends a smaller recovery-aware step.

Exact command run

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionsMoatScenarioProof98Tests test CODE_SIGNING_ALLOWED=NO | tee docs/proof/amb-fe-be/moat-scenario-proof-98/test-output.log
```

Evidence index
- `same-intent-context-a.json`
- `same-intent-context-b.json`
- `diff-summary.json`
- `replay-output.json`
- `privacy-boundary.log`
- `test-output.log`

Limitations
- `swift test` is not the primary proof lane for the iOS target; the focused Xcode test is the executable proof path.
- The proof pack stays local and inspectable; it does not claim device, App Store, or hosted release proof.