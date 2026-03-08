---
name: presentation-workflow
description: Use for creating, rewriting, reviewing, or operationalizing presentation and slide content.
---

# Presentation Workflow

Use this skill when the user asks for any of the following:

- create a deck or slide outline
- rewrite slides or presentation notes
- review a deck, script, or narrative
- compress or expand a presentation
- build speaker notes, talking points, or demo flow
- transform source material into presentation-ready structure

If the user explicitly asks for an actual PPT, PPTX, SVG, or generated deck artifact, treat `slidemax-workflow` as the primary skill for that task. Use this skill only to prepare or repair the narrative inputs that `slidemax-workflow` needs before generation.

## Goals

Turn raw information into a presentation that is clear, persuasive, and executable.

## Modes

### Creation

Use when the user needs a new presentation from rough inputs.

### Review

Use when the user already has slides, an outline, or a script that needs critique.

### Rewrite

Use when the structure is mostly correct but the wording, flow, or emphasis is weak.

### Conversion

Use when notes, documents, meeting records, or plans must become presentation material.

## Progress Reporting

For multi-step presentation work, report progress after each major stage.

Recommended progress milestones:

- framing complete
- narrative spine complete
- slide blueprint complete
- review or rewrite findings complete
- final packaging complete

Each progress update should briefly include:

- completed stage
- current focus
- next step
- blocker, if any

## Process

### 1. Frame the job

Identify:

- audience
- presentation goal
- desired decision or action
- duration or slide budget
- delivery format
- source material quality
- brand or style constraints

If any of these are missing, make minimal safe assumptions and state them.

### 2. Build the narrative spine

Define:

- the core message
- the problem or opportunity
- supporting evidence
- recommendation
- next steps

Prefer a storyline where each slide advances a single decision-relevant point.

### 3. Design the slide plan

For each slide, specify:

- slide number
- slide title
- key message
- supporting bullets or evidence
- recommended visual form
- speaker note intent

### 4. Draft carefully

- Keep headlines message-based, not topic-only.
- Avoid overloaded slides.
- Distinguish facts from assumptions.
- Avoid decorative filler.
- Use parallel structure across sections.

### 5. Review rigorously

Check for:

- narrative continuity
- duplicated slides or points
- weak evidence
- unclear ask
- excessive density
- unsupported claims
- mismatch between audience and tone

## Review Rubric

Score the material qualitatively across:

- audience fit
- strategic clarity
- evidence strength
- slide economy
- delivery readiness

## Default Deliverables

Prefer one or more of the following:

If the user needs an actual PPT, PPTX, SVG, or rendered deck artifact, keep `slidemax-workflow` as the primary skill and use this skill only to prepare the narrative and slide plan that generation requires.

- executive summary
- slide-by-slide blueprint
- rewritten slide copy
- speaker notes
- risk and assumption log
- final review checklist
