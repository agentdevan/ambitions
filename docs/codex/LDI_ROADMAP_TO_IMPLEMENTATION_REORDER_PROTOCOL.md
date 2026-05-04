# LDI Roadmap To Implementation Reorder Protocol

<!-- markdownlint-disable MD013 -->

Status: Active integration protocol for queued SI, PD, AOS, and post-AOS LDI work.

## Default Rule

LDI01-LDI22 start after AOS30. Do not move LDI earlier unless the user explicitly requests it and a dependency review proves the earlier gate is safer.

## SI Hook Rule

Queued SI batches may add LDI-aware visual states, handling lane vocabulary, receipt/privacy/source/degraded states, and fixture matrices. SI does not implement LDI runtime.

## PD Hook Rule

Queued PD batches may add owned drill-down homes inside Today, Goals, Capture, Plan, or You. PD does not create a sixth destination and must stop when runtime/source/proof/privacy logic lacks AOS/LDI gates.

## AOS Hook Rule

Queued AOS batches may include LDI contracts inside existing kernels. AOS does not overrun its explicit boundary and must defer mismatched requirements to LDI.

## Completed History Rule

Do not rewrite completed batches as if they included LDI. Add forward hooks only to queued or future artifacts and record the integration point.

## Claim Rule

LDI integration may claim future source truth and governance only. Runtime behavior is claimed only by later implementation evidence.
