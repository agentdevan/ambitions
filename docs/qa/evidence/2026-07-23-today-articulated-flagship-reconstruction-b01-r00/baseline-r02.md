# R02 baseline record

R02 HEAD: `77e818823b58ee2911e68962dd8bd8115e1d26aa`

The complete R02 evidence family was inspected before B01 implementation:

- 16 native Simulator PNGs at 1206×2622;
- J01 30.255 seconds, J02 21.962 seconds, J03 27.738 seconds;
- screenshot and journey metadata;
- source, fixture, state, host, package tests, UI tests, validation, and known limitations;
- fresh package result: 30 tests, 0 failures.

The derived 16-frame board at `baseline/r02-complete-16-frame-board.png` has
SHA-256 `0127da85d99962df3fa61845836b8f80a90aea4d51a52588b4778930566568cf`.
It is a comparison aid generated from immutable R02 Foundry media, not a new
baseline or owner-accepted composite.

R02 package preview steady state was approximately 12 seconds across four
successful source-changing reloads; cached fixture-host build was 8.93 seconds.

Second-by-second recording inspection confirmed the preserved semantic stages
and also showed that direct host-state demo timing did not visually expose
every modal transition consistently. B01 will preserve the state model and
regenerate continuous evidence with explicit native transition verification.
