---
name: message-channel-delivery
description: Use when a finished presentation artifact or verified final link must be handed off to a chat, group, or message channel after final document delivery.
---

# Message Channel Delivery

Use this skill when the final artifact already exists, the final document destination is known or already updated, and the user also wants a handoff to a chat, group, or message channel.

## Goals

Turn a finished artifact reference or verified final link into a confirmed channel handoff.
For Feishu channel delivery, the Feishu document upload must already be complete or the Feishu document link must already be verified.
Do not use this skill to replace final delivery to a Feishu document.

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
- final verified document link when one exists
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

If the channel is Feishu, require a completed or verified Feishu document destination before proceeding.

### 3. Select the handoff mechanism

Prefer the lightest valid mechanism:

- Feishu online document link message when the channel is Feishu
- direct file upload when the channel supports file delivery and Feishu-specific link rules do not apply
- verified final link plus concise status when file upload is unsupported or not expected

### 4. Apply channel-specific rules

- For Feishu chat or group delivery, send a concise message that contains the verified Feishu online document link.
- Do not treat a Feishu file upload without the Feishu online document link message as the final requested handoff.
- Do not treat a Feishu chat or group handoff as the final PPT delivery destination.
- For other channels, send the artifact directly when supported; otherwise send the verified final link together with concise status.

### 5. Report the outcome

Always report:

- channel type
- channel destination reference
- whether a file artifact was sent when the channel required one
- whether the verified Feishu online document link message or other required handoff payload was sent
- channel handoff status
- exact blocker and next manual step if the handoff did not complete

When this handoff is part of the final completion path, write the channel metadata into the task-local `delivery-manifest.json` and set `requireChannelHandoff=true`. Then validate with `scripts/check_final_delivery_gate.sh --manifest /absolute/path/to/delivery-manifest.json` so the canonical completion gate cannot pass without the requested message-channel result.
