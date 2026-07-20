# Native build and release

Generate the Xcode project from `project.yml` with `xcodegen generate`, then
confirm the generated project has no diff. For a no-sign build-for-testing run:

```bash
scripts/ambitions-xcode-build-for-testing.sh --batch local --scheme AmbitionsSmoke
```

Use `scripts/ambitions-xcode-test-focused.sh` for focused unit or integration
tests. Run UI, accessibility, migration, privacy/security, concurrency, or
performance lanes when the change touches those systems. Distribution builds
remain a separate platform operation; ordinary repository changes do not need
receipts, attestations, or approval artifacts.
