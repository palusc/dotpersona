# Contributing a persona

The best rosters are hired by the community. Adding a persona is deliberately tiny:
**one persona = one file = one PR.**

## The 3-minute path

1. **Fork** [`palusc/dotpersona`](https://github.com/palusc/dotpersona) and clone your fork.
2. **Create** `skills/<slug>/SKILL.md` from [`templates/PERSONA.template.md`](templates/PERSONA.template.md) (or write it to `custom-personas/<slug>.md` via `/persona new` and move it).
   Match the schema exactly — see [`docs/persona-schema.md`](docs/persona-schema.md).
   (Fastest way: run `/persona new` in Claude Code and let Persona Forge write it, then refine.)
3. **Validate** locally. CI runs exactly these, so a green run here is a green run there:
   ```bash
   bash scripts/validate-personas.sh    # frontmatter, section order, slug, SemVer, manifest sync
   bash scripts/check-version-bump.sh   # a changed persona must bump its version:
   shellcheck --severity=style --shell=bash install.sh scripts/*.sh
   ```
4. **Test** it on a real task: `/persona <slug> <something real>`. Does it behave differently from
   plain Claude? If not, sharpen it (see the opinionation test below).
5. **Log it**: add one line to `CHANGELOG.md` under `[Unreleased]`.
6. **Open a PR.** Your handle goes in the persona's `author:` field and the changelog.

## Branching & Git Workflow

To ensure a smooth contribution flow and keep the history clean, please follow these branching and commit rules:

1. **Do not submit PRs from your fork's `main` branch.** Always create a descriptive feature branch:
   ```bash
   git checkout -b feat/add-the-copywriter
   ```
2. **Make focused, semantic commits.** Try to group related changes together.
   ```bash
   git commit -m "feat: add the copywriter persona"
   ```
3. **Keep your branch updated** with the upstream repository:
   ```bash
   git remote add upstream https://github.com/palusc/dotpersona.git
   git fetch upstream
   git rebase upstream/main
   ```
4. **Push your branch and open a PR:**
   ```bash
   git push origin feat/add-the-copywriter
   ```

### Walkthrough: A Perfect Persona PR

If you're proposing a new official persona (e.g. *The Copywriter*), a complete pull request should make changes to the following files:

- **`[NEW]` `skills/the-copywriter/SKILL.md`**: The actual persona file following the schema.
- **`[MODIFY]` `plugin.json`**: Add the new skill path `"skills/the-copywriter/SKILL.md"` to the `"skills"` array so the installer knows to symlink it.
- **`[MODIFY]` `skills/persona/SKILL.md`**: Add the copywriter to the markdown roster table inside the `/persona` engine file.
- **`[MODIFY]` `CHANGELOG.md`**: Add an entry under `### Added` in the `[Unreleased]` section.

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
- **Portable.** A persona is markdown, not a Claude Code feature. CI exports the whole roster to
  every target in [`docs/portability.md`](docs/portability.md), so anything that breaks
  `scripts/persona-export.sh` fails the build.

## Improving an existing persona

**Bump its `version:`.** A persona's behavior is its contract — two people both running
"the-auditor 1.0.0" must get the same review. `scripts/check-version-bump.sh` fails the PR if a
`SKILL.md` changed and its version didn't, or if the version moved backwards.

- **patch** — wording, typos, a sharper example.
- **minor** — a new operating principle, a changed method step, a new declared skill.
- **major** — the persona now draws a different line. Rare; say why in the PR.

Note it in `CHANGELOG.md` under `[Unreleased]`, and keep the persona's voice — read it first
and match it.

## Improving the engine

Changes to `SKILL.md` (routing, adoption, stacking, Forge) are welcome. Keep adoption to one line,
never hard-fail on a missing skill, and update `docs/how-it-works.md` if behavior changes.

## Improving the scripts

`install.sh` and everything in `scripts/` must be `shellcheck`-clean at `--severity=style`, and
any new filesystem write has to honor `install.sh --dry-run`. The installer's promise is that a
dry run touches nothing — CI asserts it.

## Code of conduct

Be generous with credit, ruthless with vagueness. We over-credit skill authors on purpose.
