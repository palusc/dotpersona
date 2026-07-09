# Contributing a persona

The best rosters are hired by the community. Adding a persona is deliberately tiny:
**one persona = one file = one PR.**

## The 3-minute path

1. **Fork** [`palusc/dotpersona`](https://github.com/palusc/dotpersona) and clone your fork.
2. **Create** `skills/<slug>/SKILL.md` from [`templates/PERSONA.template.md`](templates/PERSONA.template.md) (or write it to `custom-personas/<slug>.md` via `/persona new` and move it).
   Match the schema exactly — see [`docs/persona-schema.md`](docs/persona-schema.md).
   (Fastest way: run `/persona new` in Claude Code and let Persona Forge write it, then refine.)
3. **Validate** locally: `bash scripts/validate-personas.sh` (CI runs the same check).
4. **Test** it on a real task: `/persona <slug> <something real>`. Does it behave differently from
   plain Claude? If not, sharpen it (see the opinionation test below).
5. **Log it**: add one line to `CHANGELOG.md` under `[Unreleased]`.
6. **Open a PR.** Your handle goes in the persona's `author:` field and the changelog.

## What makes a persona get merged

A persona must be **opinionated**. The bar: *if it behaves like a generalist on a task, it's noise.*

- **The opinionation test.** Each persona needs at least one belief a generalist wouldn't hold — a
  line it draws that changes the outcome.
  - ❌ Weak: *"Write clean, maintainable code."* (Everyone agrees; changes nothing.)
  - ✅ Strong: *"I refuse to say 'done' on a change I haven't seen actually run."* (Draws a line.)
- **Distinct.** It must not duplicate a shipped persona. Check the roster first. A new *angle*
  (a domain lead, a specialist) is welcome; a near-clone is not.
- **Skills as soft deps.** Every skill in the `skills:` table needs a real *"If it's missing"*
  fallback. A persona that breaks without a skill will be sent back.
- **Self-contained & standalone.** No vendored third-party skill code. Reference skills by name and,
  if they're community skills, add them to [`docs/recommended-skills.md`](docs/recommended-skills.md)
  with proper credit.
- **Schema-clean.** Correct frontmatter, exact section order. `validate-personas.sh` must pass.

## Improving an existing persona

Bump its `version:` (SemVer: patch for wording, minor for a sharper method/new principle) and note
it in `CHANGELOG.md`. Keep the persona's voice — read it first and match it.

## Improving the engine

Changes to `SKILL.md` (routing, adoption, stacking, Forge) are welcome. Keep adoption to one line,
never hard-fail on a missing skill, and update `docs/how-it-works.md` if behavior changes.

## Code of conduct

Be generous with credit, ruthless with vagueness. We over-credit skill authors on purpose.
