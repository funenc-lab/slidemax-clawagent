---
name: message-channel-delivery
description: Use when a finished presentation artifact or verified final link must be handed off to a chat, group, or message channel after final document delivery.
---

# Message Channel Delivery

Use this skill when the final artifact already exists, the final document destination is known or already updated, and the user also wants a handoff to a chat, group, or message channel.

## Goals

Turn a finished artifact or verified final link into a confirmed channel handoff.
For Feishu channel delivery where file delivery is expected, upload the file artifact rather than sending text alone.

## When To Use

Use this skill when:

- the user explicitly requests delivery to a chat, group, or message channel
- final document delivery is already complete or the final destination link is already verified
- the completion message must include channel handoff status

Do not use this skill when:

- the artifact does not exist yet
- final document delivery is still pending and no verified final link exists
- the user only asked for final document delivery without any channel handoff

## Inputs To Confirm

Confirm or collect:

- final artifact path
- channel type
- channel identifier, link, or destination name
- whether the channel supports direct file delivery
- whether authentication for the target channel is already available

## Workflow

### 1. Confirm artifact readiness

Verify the final artifact exists locally.
If the artifact is missing, return to the producing skill first.

### 2. Confirm final document state

Before channel handoff, confirm one of the following:

- the final document delivery already succeeded
- a verified final destination link already exists
- the user explicitly approved channel-only handoff

### 3. Select the handoff mechanism

Prefer the lightest valid mechanism:

- direct file upload when the channel supports file delivery
- verified final link plus concise status when file upload is unsupported or not expected

### 4. Apply channel-specific rules

- For Feishu chat or group delivery, upload the file artifact when file delivery is expected.
- Do not treat plain text-only Feishu handoff as complete file delivery.
- For other channels, send the artifact directly when supported; otherwise send the verified final link together with concise status.

### 5. Report the outcome

Always report:

- channel type
- channel destination reference
- whether the artifact file or verified final link was sent
- channel handoff status
- exact blocker and next manual step if the handoff did not complete
