# The `PERSONA.md` schema

Every persona is a single Markdown file in `custom-personas/<slug>.md` (or `skills/<slug>/SKILL.md` for official ones). The consistency of this
schema is what makes the library feel like *one system* instead of a pile of prompts.
Match it exactly when you write a new persona.

## Frontmatter (YAML)

```yaml
---
persona: the-designer          # slug, kebab-case, matches the filename
name: the-designer             # official personas: must equal `persona:` — Claude Code's skill
                                # loader keys the skill by this field. Custom personas in
                                # `custom-personas/` aren't registered as skills and may use a
                                # free-form display name instead.
essence: >-                    # one line — the identity, shown in the roster
  Understands the system before touching a pixel; ships taste, not decoration.
version: 1.0.0                 # SemVer, MAJOR.MINOR.PATCH — CI enforces a bump on every change
author: persona                # or your GitHub handle
skills:                        # skills this persona orchestrates (SOFT dependencies)
  - premium-website
  - artifact-design
  - dataviz
consults:                      # other personas it naturally calls on (optional)
  - the-shipper
triggers:                      # words/contexts that suit this persona (for routing)
  - design
  - UI
  - UX
  - visual
  - brand
---
```

**Rules**

- `skills` are **soft dependencies**. A persona must be fully functional with *none* of them
  present — its Method carries the work; skills only accelerate it. Never list a skill the
  persona can't work without.
- `triggers` power `/persona` (no-arg) routing. Use plain words a user would type.
- `consults` names personas, not skills. It's the persona's "who I'd ask" list.
- `version` must be SemVer, and it must move whenever the file does. A persona's behavior is
  its contract: two people running *the-auditor 1.0.0* should get the same review.
  `scripts/check-version-bump.sh` fails a PR that changes a persona without bumping it, or
  that moves the version backwards. Patch for wording, minor for a new principle or method
  step, major for a persona that now draws a different line.

## Body (fixed section order)

The order is part of the contract — do not reorder or rename headings.

### `## Identity`
First person. Who this persona *is*, the stance it takes, what it cares about most.
2–4 sentences. This is the voice the reader should hear for the rest of the file.

### `## Operating Principles`
4–7 numbered, non-negotiable beliefs — the *taste*. Each is a short imperative with a
one-sentence "why". These are what the persona *refuses to violate*, not generic best practices.

### `## Method`
The repeatable process, in named phases (3–6). Each phase: what it does and how you know it's
finished. This is the persona's "how I actually work" — concrete, sequenced, checkable.

### `## Skills I Wield`
A table mapping each declared skill to **when** the persona reaches for it, plus a one-line
**fallback** describing what the persona does by hand if that skill is absent.

| Skill | When I reach for it | If it's missing |
|---|---|---|

### `## Definition of Done`
A checklist the persona holds work against before calling it finished. Phrased as things that
must be *true*. Include at least one thing the persona **refuses to ship**.

### `## How I Communicate`
Voice and output style: tone, length, format habits, what it never does (e.g. "no menus of
options — one recommendation").

### `## Summon Me When / Not`
Two short lists: the situations this persona is the right call, and the situations where
another persona fits better (name it). This makes the roster self-routing.

## Quality bar for a persona

A good persona is **opinionated**. If two personas would behave identically on a task, one of
them is redundant. Each persona must have at least one belief it holds that a generalist would
not — a line it draws that changes the outcome. Vague, agreeable personas are noise.
