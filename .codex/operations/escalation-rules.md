# Escalation Rules

Stop, downgrade, or switch workflows when:

- the request would require inventing a repo seam
- the diff is expanding beyond the asked scope
- the environment cannot support the needed validation
- the primary skill is wrong
- the remaining work needs a different environment, such as local macOS/Xcode signing or simulator runtime checks

## Preferred Actions

- downgrade to a truthful bounded slice
- switch to the narrower skill or execution mode
- recommend the needed environment explicitly
- ask for user direction only when the remaining path has materially different tradeoffs
