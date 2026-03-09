---
name: final-document-delivery
description: Use when a final PPT artifact, review package, speaker notes package, or document-ready result must be delivered to a final destination such as a Judao final document or a Feishu document.
---

# Final Document Delivery

Use this skill when the task is not complete until the final artifact or document-ready package has been sent or published to the requested final delivery document.

## Goals

Turn a finished local artifact into a confirmed final delivery outcome.
A task that requires external delivery is only complete when one of the following is true:

- the artifact has been published to the requested final delivery document
- the artifact has been sent to the requested final delivery document
- a concrete delivery blocker has been verified and reported together with the exact next manual step

## When To Use

Use this skill when:

- the user asked for a final deliverable rather than a draft only
- the output must be sent to a Judao final document, Feishu document, or another named final document destination
- a local artifact already exists under `outputs/` and now must be delivered externally
- the final reply must include delivery confirmation or a delivery blocker

Do not use this skill when:

- the user explicitly requested a local-only draft
- the task is still at the outline or blueprint stage and the final artifact does not exist yet
- the destination document is intentionally deferred by the user

## Inputs To Confirm

Confirm or collect:

- final artifact path
- final delivery destination type
- final delivery destination link, identifier, or access path
- delivery format expected by the destination
- whether browser login or document tool authentication is already available

If the destination document is required but missing, ask for it before claiming completion.

## Progress Reporting

For multi-step delivery, report concise checkpoints:

- delivery target confirmed
- artifact prepared for delivery
- publish or send action attempted
- delivery verified or blocked

Each update should include:

- completed delivery stage
- current action
- next action
- blocker, if any

## Workflow

### 1. Confirm the final artifact exists

Verify the final artifact or document-ready package exists locally before any delivery attempt.
If the artifact is missing, return to the producing skill first.

### 2. Confirm the final destination

Preferred destinations include:

- Judao final document
- Feishu document
- another user-specified final document destination

Do not treat `outputs/` as the final destination.
It is only the staging area.

### 3. Select the delivery mechanism

Prefer the lightest valid mechanism:

- document-capable tool when the destination supports direct document writing
- browser-capable tool when delivery requires web interaction such as Feishu document editing
- an existing project or platform integration when one is already available

If no suitable delivery tool is available, stop after producing the final local package and report the blocker.

### 4. Perform the delivery

Deliver the final artifact or document-ready content to the requested destination.
Preserve the final document structure expected by the user.
Do not silently downgrade to a local-only result.

### 5. Verify the destination state

After delivery, verify at least one of the following:
After the delivery outcome is known, run `scripts/check_final_delivery_gate.sh` with the artifact path, delivery status, destination details, verification evidence, blocker metadata when applicable, and local-only approval evidence when applicable before claiming completion. The CLI of that script is the canonical runtime completion contract.


- the destination document was updated
- the destination link is reachable and contains the expected content
- the send or publish action returned an explicit success signal

If verification cannot be completed, report the delivery as blocked or unverified instead of complete.

## Final Report

Always report:

- final artifact path
- final destination type
- final destination link or identifier when available
- delivery status
- exact blocker and next manual step if delivery did not complete
