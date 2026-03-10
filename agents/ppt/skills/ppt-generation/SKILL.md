---
name: ppt-generation
description: Use for generating presentation structure, slide outlines, and message-first deck drafts from raw business or technical inputs.
---

# PPT Generation

Use this skill when the user needs a new deck from source material such as notes, documents, plans, metrics, or rough ideas.

## Goals

Generate a presentation structure that is decision-ready, audience-aware, and easy to turn into slides.

This skill owns blueprint generation rather than final rendering. When the task requires a rendered PPT, PPTX, SVG, or generated deck artifact, keep `slidemax-workflow` as the primary skill and use this skill to supply the structured content it needs.

## Inputs To Collect

Identify or infer:

- audience
- presentation objective
- desired decision or action
- time limit or slide budget
- presenter role
- final delivery destination
- source material confidence
- must-include facts or constraints

State assumptions explicitly when inputs are incomplete.
If the final delivery ecosystem is Feishu, treat the Feishu document as the required final destination and treat Feishu chat or group handoff as secondary.

## Progress Reporting

When generation takes multiple steps, provide progress checkpoints.
If this blueprinting work is being used to drive an actual PPT, PPTX, SVG, or rendered deck artifact workflow, maintain real-time progress updates during the generation handoff and any long-running preparation step.

Preferred checkpoints:

- requirements captured
- narrative shape selected
- message ladder drafted
- slide blueprint drafted
- SlideMax handoff package prepared
- generation handoff in progress
- delivery handoff prepared
- final recommendations prepared

Each progress update should state:

- what is complete
- what is in progress
- what will be done next
- whether any missing input blocks quality

For long-running generation preparation or handoff steps, send another progress update at least every 30 seconds until the step completes or becomes blocked.

## Generation Workflow

### 1. Define the narrative shape

Pick the lightest suitable structure:

- update
- proposal
- review
- pitch
- incident summary
- roadmap
- technical deep dive

### 2. Build the message ladder

Produce:

- one core takeaway
- three to five supporting arguments
- one explicit ask or next step

### 3. Draft the slide blueprint

For each slide include:

- slide number
- message-based title
- purpose
- content bullets
- recommended visual form
- optional speaker cue

### 4. Pressure test the draft

Check for:

- duplicate slides
- missing evidence
- unclear sequence
- weak ending
- too many concepts per slide

## Output Standard

Default output order:

1. executive summary
2. narrative arc
3. slide-by-slide blueprint
4. assumptions and risks
5. next actions
6. delivery target and handoff status

If the overall task still requires an actual deck artifact after this blueprint is ready, return control to `slidemax-workflow` for final generation and final document delivery.
