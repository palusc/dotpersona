# Changelog

All notable changes to Persona — the roster and the engine — are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/); versions follow
[SemVer](https://semver.org/).

## [Unreleased]

### Added — Engine
- **Mechanical pre-scan for remote installs.** `scripts/scan-persona-injection.sh` deterministically
  checks a fetched community persona for invisible/bidi-override Unicode and known injection
  phrasing before `/persona remote` shows the payload for consent — catches the encoding-trick
  class of attack a visual or LLM-only read can miss on its own. Runs alongside, not instead of,
  the existing judgment-based scan; covered by `tests/test-scan-persona-injection.sh`.

### Added — Docs
- `docs/before-after.md` gained two more cases: The DBA catching a blocking migration on a
  multi-million-row table (a second role, a second bug class), and an honest counter-case where
  a persona and default Claude produce the same output because the task has no judgment call to
  make. Incremental progress on the ROADMAP's open evaluation gap — three transcripts instead of
  one — not the full eval suite, which is still open.

## [2.0.0] — 2026-07-12

Trust & rigor, not new experts: the roster earning the claims the README makes about it.
Behavior changes (stricter remote-install consent, pruned triggers) make this a major bump.

### Changed — Engine
- **Remote install shows the payload before adopting.** `/persona remote` now prints a fetched
  persona's actual `Operating Principles` and `Method` (not just name/essence) and scans the body
  for instruction-injection and out-of-role actions (delete, exfiltrate, "ignore previous
  instructions"), flagging them for the user to veto. A one-line label never revealed a prompt
  buried in the body; this closes the community-persona supply-chain gap at the point of adoption.
- **Trigger disambiguation.** Pruned the three colliding triggers the validator flagged —
  `component` (kept on The Frontend Lead, dropped from The Designer), `copy` (kept on The
  Copywriter, dropped from The Wordsmith), `deploy` (kept on The DevOps Lead, dropped from The
  Shipper) — and documented a routing tiebreak: an ambiguous request stacks or asks, never
  silently picks the wrong expert.

### Changed — Roster
- **The Auditor (1.1.0)** — `CONFIRMED` now means a repro that was actually executed and observed
  to fail; a sound-but-unexecuted trace is `PLAUSIBLE`, with the step that would settle it. Ties
  the persona's strongest label to an observation instead of its own asserted authority.
- **The Designer (1.0.1), The Wordsmith (1.0.1), The Shipper (1.0.1)** — trigger lists pruned per
  the disambiguation above; methods unchanged.

### Changed — Docs (honest-claims pass)
- `README.md` — the before/after is framed as one illustrative case, not a benchmark; a new
  limitation notes each persona's per-invocation token cost; the community-persona and
  hallucination caveats reflect the stricter Auditor and remote-install behavior.
- `docs/before-after.md` — labeled an existence proof, not a distribution claim, with the open
  evaluation work linked.
- `docs/portability.md` — a "Native tools" row and a note that verification-first personas
  degrade most when exported (they instruct, they can't execute).
- `CONTRIBUTING.md` — merge bar gains a durability criterion (encode method, not dated facts) and
  a non-colliding-triggers rule.
- `ROADMAP.md` — a v2.0 "trust & rigor" section and an explicit open "evaluation" gap.

### Changed — Registry docs
- `docs/remote-registry.md` documents the registry contract as shipped at dotpersona.dev:
  visibility tiers (`public`/`unlisted`/`private`/`restricted`), Free/Pro gating (3-persona cap,
  no private/restricted on Free, existing private personas lock if a Pro subscription lapses), and
  the attachments endpoints.

## [1.4.0] — 2026-07-10

The last five roles on the roadmap ship, and so does everything the engine roadmap promised.
Nothing left marked 🔭 in `ROADMAP.md` — what's next is hired by the community from here.

### Added — Roster
- **The Growth Hacker** — funnels, activation, and the one metric that actually moves the
  business; refuses to ship an experiment with no pre-declared sample size or stopping rule.
- **The Copywriter** — words that convert; ships exactly one CTA per page and cuts every draft
  at least once before calling it done.
- **The Legal Reviewer** — ToS, privacy, and licensing review scoped to "can we ship this";
  checks actual data flow against privacy-policy claims and flags, explicitly, where something
  needs a licensed attorney instead of a persona.
- **The Interviewer** — pressure-tests a plan one assumption at a time until only the load-bearing
  parts survive; the engine's `grill-me` skill made into a full persona.
- **The Teacher** — builds the mental model before the mechanism and checks understanding instead
  of assuming it; refuses to hand over working code with no explanation when the ask was to learn.

### Added — Engine
- **Team presets** (`/persona team <preset>`) — a named, ordered squad for a common project shape
  (`saas-launch`, `api-service`, `landing-page`, `data-pipeline`, `audit`), or an ad-hoc squad via
  `/persona team <a>+<b>+<c>`. Runs as a scripted sequence of ordinary one-line switches, not a
  new adoption mechanism — skip ahead or drop it like any switch.
- **Panel stack** (`/persona + <a> + <b> …`) — the deeper form of stacking: convene several
  consultants at once on one specific decision, each answering the same narrow question, with the
  primary synthesizing and still speaking in one voice.
- **Per-project personas** (`.persona/*.md`) — a team-committed, code-reviewed persona folder that
  lives in a user's own project, distinct from this plugin's personal, gitignored
  `custom-personas/`. Resolution order on a slug collision: official → per-project → personal.

## [1.3.0] — 2026-07-10

The domain leads join: role personas answer *how do I work*, domain leads answer *what do I know
deeply*.

### Added — Roster
- **The Backend Lead** — data models, APIs, transactions, queues, and idempotency; refuses to
  ship a mutating endpoint with no idempotency key.
- **The Frontend Lead** — component architecture, state, performance budgets, and accessibility
  as a default rather than a follow-up pass.
- **The Data Lead** — pipelines, schemas, and metric correctness; won't sign off on a dashboard
  number it can't trace to its source table.
- **The DevOps Lead** — deploys, observability, and rollbacks with the 3am-pager mindset; designs
  the rollback command before the forward deploy plan, every time.

## [1.2.0] — 2026-07-10

Personas leave home. A persona was always just markdown, but until now you needed Claude Code
to get anything out of one. This release makes that literal: export any persona as a system
prompt, a JSON payload for the Messages API, a Cursor rule, or an `AGENTS.md` block. The
mindset, method, and quality bar travel; the routing doesn't.

The other half of this release is about trusting what you install and what you contribute:
the installer can now show you its plan without touching a file, and CI stops a persona from
changing its behavior without changing its version.

### Added
- **`scripts/persona-export.sh`** — export any persona to `prompt` (stdout, for Claude.ai or
  ChatGPT), `json` (`.system` for the Messages API), `cursor` (`.cursor/rules/*.mdc`), or
  `agents` (an idempotent, marker-delimited block in `AGENTS.md`). `--all` does the whole
  roster; `--list` shows it. The export carries the graceful-degradation contract, so a persona
  that names a Claude Code skill it can't reach works from its embedded method instead of
  stalling. Trade-offs and an API example: `docs/portability.md`.
- **`install.sh --dry-run`** — prints exactly what would be created, moved, or deleted, and
  writes nothing. It composes with the other modes (`--dry-run --uninstall`). Piped through
  `curl`, it clones into a temp directory and deletes it again, so
  `curl -fsSL … | bash -s -- --dry-run` never writes outside `/tmp`.
- **`scripts/check-version-bump.sh`** — a persona's behavior is its contract. CI now fails a PR
  where a `SKILL.md` changed but its `version:` didn't, or where the version moved backwards.
  Brand-new personas pass. Answers the "every persona is pinned at 1.0.0 forever" problem.
- **`shellcheck` in CI** over `install.sh` and every script in `scripts/`, at `--severity=style`.
- **Two more CI guards**: the whole roster is exported to every portable target on every push
  (including an assertion that re-running the `agents` target replaces its block rather than
  duplicating it), and `install.sh --dry-run` is asserted to leave the filesystem untouched
  before a real install/uninstall round-trip runs.
- `scripts/validate-personas.sh` now rejects a non-SemVer `version:`, and checks that the
  version in `plugin.json` has a matching `## [x.y.z]` heading in `CHANGELOG.md` — a manifest
  bump can no longer ship without release notes.
- `/persona remote <owner>/<slug>` — install a persona from the community registry at
  dotpersona.dev, save it to `custom-personas/`, and adopt it. The client↔registry contract
  lives in `docs/remote-registry.md`. Before adoption, the engine now shows the fetched
  persona's name, essence, and owner and asks for a go-ahead — installed content becomes
  authoritative instructions Claude follows, and the registry only validates schema *shape*,
  not *safety*.
- `scripts/validate-personas.sh` now checks that `skills/persona/SKILL.md`'s own roster table
  lists every persona shipped on disk, the same class of check added for `plugin.json` in 1.1.1.
- `docs/portability.md`, a real `templates/README.md`, and a README that answers *who is this
  for* and *who is this not for* before it asks for an install.

### Changed
- The `validate` workflow lost its `paths:` filter. Its whole job is catching drift between
  files, and a path filter is precisely how such a guard silently stops running.
- README: architecture, graceful degradation, self-updates, limitations, and the docs index
  came out from behind `<details>` and are now visible on the page. Added a repository map
  and a **Who is this for?** section with an honest *not for you if* list.
- `install.sh --help` prints only the header block instead of every `#` comment in the file.

### Fixed
- `skills/persona/SKILL.md`'s roster table, `docs/recommended-skills.md`, and
  `docs/how-it-works.md`'s file tree had all gone stale the same way `docs/banner.svg` did in
  1.1.1 — The DBA, The Tester, The Wordsmith, and/or The Product Manager were missing from each,
  depending on the file. All four now match the shipped roster everywhere.
- `docs/persona-schema.md` documented `name:` as a free-form display name (`The Designer`), but
  every shipped persona actually sets it to the kebab-case slug — Claude Code's skill loader
  keys the skill by that field. Doc now matches the 10 real files.
- `scripts/validate-personas.sh` compared `plugin.json` against `ls skills/*/SKILL.md` under a
  locale-dependent `sort`, which `comm` can disagree with. Now uses `find` and `LC_ALL=C sort`.

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
