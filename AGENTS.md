# Repository AGENTS

This repository is the source-of-truth for the PPT OpenClaw agent package and its installation runbook.

## Project Role

- `docs/openclaw-install.md` is the canonical install/update entry prompt.
- `docs/openclaw-install-fresh.md` is the fresh-install runbook.
- `docs/openclaw-update.md` is the update and repair runbook.
- `agents/ppt/` contains the final OpenClaw agent files that are installed into the target OpenClaw workspace.
- Repository-root files describe the repository, the installation flow, and source-level validation only.

## Directory Boundaries

- `agents/ppt/` is the shipped agent content boundary.
- `docs/` is for repository-level installation and update documentation.
- `scripts/` is for repository-level validation or installation helpers.
- `tests/` is for repository-level validation tests.

Do not move repository installation helpers into `agents/ppt/` unless they are intended to ship as part of the final installed agent.

## Editing Rules

- Treat `agents/ppt/` as installable agent payload, not as a scratch area for repository-only tooling.
- Prefer changing `docs/openclaw-install.md` when the task is about installation or update flow.
- Prefer changing repository-root `scripts/` and `tests/` when the task is about source checkout validation.
- Change files under `agents/ppt/` only when the shipped agent behavior, prompt files, or packaged skills actually need to change.

## Current Install Model

The repository keeps the agent package in `agents/ppt/` and the installation flow in `docs/`.
The entry prompt is responsible for detecting the current scenario and routing to one runbook.
The install/update runbooks are responsible for acquiring dependencies, selecting target paths, copying the managed agent files, preserving local runtime state, and reporting validation plus registration results.
