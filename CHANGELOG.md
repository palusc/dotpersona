# Changelog

All notable changes to Persona — the roster and the engine — are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/); versions follow
[SemVer](https://semver.org/).

## [Unreleased]

### Added
- `/persona remote <owner>/<slug>` — install a persona from the community registry at
  dotpersona.dev, save it to `custom-personas/`, and adopt it. The client↔registry contract
  lives in `docs/remote-registry.md`. Before adoption, the engine now shows the fetched
  persona's name, essence, and owner and asks for a go-ahead — installed content becomes
  authoritative instructions Claude follows, and the registry only validates schema *shape*,
  not *safety*.
- `scripts/validate-personas.sh` now checks that `skills/persona/SKILL.md`'s own roster table
  lists every persona shipped on disk, the same class of check added for `plugin.json` in 1.1.1.

### Fixed
- `skills/persona/SKILL.md`'s roster table, `docs/recommended-skills.md`, and
  `docs/how-it-works.md`'s file tree had all gone stale the same way `docs/banner.svg` did in
  1.1.1 — The DBA, The Tester, The Wordsmith, and/or The Product Manager were missing from each,
  depending on the file. All four now match the shipped roster everywhere.
- `docs/persona-schema.md` documented `name:` as a free-form display name (`The Designer`), but
  every shipped persona actually sets it to the kebab-case slug — Claude Code's skill loader
  keys the skill by that field. Doc now matches the 10 real files.

## [1.1.1] — 2026-07-10

### Fixed
- `docs/banner.svg` still listed the original 9 roles — The Product Manager was missing from the hero banner's roster strip.

### Added
- CI now diffs `plugin.json`'s skills array against `skills/*/SKILL.md` on disk and fails on drift in either direction — the automated guard that would have caught the 1.1.0 manifest bug. `plugin.json` added to `validate.yml`'s trigger paths so an edit to the manifest alone still runs it.
- `templates/README.md` clarifying that folder is for persona authors, not end users.

## [1.1.0] — 2026-07-10

Four more experts join the team, and the plugin manifest catches up to the actual roster.

### Added — Roster
- **The DBA** — profiles queries, handles composite indexing, designs zero-downtime migrations.
- **The Tester** — hunts boundary edge-cases and writes robust unit, integration, and E2E tests.
- **The Wordsmith** — refines developer docs, UI copy, and logs to be punchy and active.
- **The Product Manager** — turns a vague feature request into a spec so precise two engineers would build the same thing.

### Fixed
- `plugin.json` only listed 7 of the 10 shipped skills — installs via the plugin marketplace path were silently missing The DBA, The Tester, and The Wordsmith. All 10 are now listed.
- `docs/before-after.md` used a ` ```carousel ` fence GitHub doesn't render; replaced with plain sections so the comparison actually displays.

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
