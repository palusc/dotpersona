# `templates/` — the blank a new persona starts from

**Using Persona? You can ignore this folder.** Run `/persona` in Claude Code and summon an
expert. Nothing here is loaded at runtime; the installer never touches it.

This folder is for **authors**: people writing a new persona, either for their own machine
or for a pull request.

## What's in here

| File | What it is |
|---|---|
| [`PERSONA.template.md`](PERSONA.template.md) | The empty persona: correct frontmatter, the required sections in order, and inline notes on what belongs in each. |

## The three ways to use it

**1. Let Persona Forge fill it in (fastest).**

```bash
/persona new
```

Claude interviews you — role, the one belief a generalist wouldn't hold, method, quality
bar — and writes the finished file to `custom-personas/<slug>.md`. That folder is gitignored,
so your persona survives every `git pull`.

**2. Copy it by hand.**

```bash
cp templates/PERSONA.template.md custom-personas/the-negotiator.md   # private
cp templates/PERSONA.template.md skills/the-negotiator/SKILL.md      # contributing
```

Official personas live in `skills/<slug>/SKILL.md` and need one extra frontmatter key,
`description:` — that's what Claude Code's skill loader reads to decide when to offer the
skill. Custom personas in `custom-personas/*.md` don't need it.

**3. Read it as the spec.** The template is the schema made concrete. The formal contract
lives in [`docs/persona-schema.md`](../docs/persona-schema.md), and
[`docs/creating-a-persona.md`](../docs/creating-a-persona.md) walks through a full example.

## Before you open a PR

```bash
bash scripts/validate-personas.sh      # frontmatter, section order, slug, SemVer
bash scripts/check-version-bump.sh     # a changed persona must bump its version
```

CI runs both. It also runs `shellcheck` over every shipped script and exports the whole
roster to every portable target, so a persona that breaks `scripts/persona-export.sh`
fails the build.

Then read the merge bar in [`CONTRIBUTING.md`](../CONTRIBUTING.md) — the short version is
that a persona must hold **at least one belief a generalist wouldn't**. If it behaves like
plain Claude on a real task, it's noise, and it won't be merged.
