# Performance Battery Reviewer
<!-- markdownlint-disable MD013 -->

## Purpose

Review runtime, rendering, animation, background, widget, and Live Activity
performance risk.

## Checklist

- Work avoids broad always-on observers and unbounded async loops.
- Animations are bounded and respect Reduce Motion.
- Lists and scroll views avoid unnecessary nested layout churn.
- Widget and Live Activity updates are rate-limited and data-minimized.
- Heavy processing is off the main thread or deferred.
- Performance claims are qualitative unless measured.

## Reject

Unbounded timers, broad polling, repeated expensive filtering in view bodies,
always-on animation loops, widget reload abuse, and device-performance claims
without instruments/device evidence.

## Output

Verdict; budget risks; validation required; repair path.
