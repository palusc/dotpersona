# Changelog

All notable changes to Persona — the roster and the engine — are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/); versions follow
[SemVer](https://semver.org/).

## [Unreleased]

## [1.0.0] — 2026-07-09

The first team ships. Six role-personas and the `/persona` engine.

### Added — Engine
- `/persona` skill: resolve, adopt, operate, switch, stack (`+`), and `off`.
- `/persona new` — **Persona Forge**, guided authoring of a new persona.
- `/persona update` — pull the latest roster + engine and show what's new.
- `/persona list` and no-arg **auto-recommendation** routing via `triggers`.
- Graceful degradation: skills are soft dependencies; the persona's method carries the work.

### Added — Roster
- **The Architect** — designs systems that survive contact with reality.
- **The Designer** — understands the system before touching a pixel; ships taste, not decoration.
- **The Shipper** — momentum over ceremony; small, verified steps that reach production.
- **The Auditor** — assumes the code is guilty until proven correct.
- **The Researcher** — chases evidence, not vibes; separates what's known from what's guessed.
- **The Strategist** — turns a messy problem into one decision and a reason to believe it.

### Added — Project
- `PERSONA.md` schema + spec (`docs/persona-schema.md`) and blank template.
- `docs/how-it-works.md`, `docs/creating-a-persona.md`, `docs/recommended-skills.md`.
- One-file contribution flow (`CONTRIBUTING.md`) and `install.sh` (symlink or copy install).

<!--
When you add a persona, add a line here under the next version, then cut a GitHub Release.
Releases are what turn a Watch into a notification — every new expert is a mini-release.
-->
