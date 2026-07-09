<div align="center">

# 🎭 Persona

### Don't give your AI tools. Give it a team.

**Persona turns Claude into a roster of senior specialists** — each with a mindset, a method,
a quality bar, and the skills to deliver. Summon the right expert for the job with one command.

[![Validate](https://github.com/palusc/dotpersona/actions/workflows/validate.yml/badge.svg)](https://github.com/palusc/dotpersona/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

```
  /persona designer   →  — The Designer. I'll understand the design system before I touch a pixel.
  /persona architect  →  — The Architect. Let me map the forces in tension before I draw a box.
  /persona auditor    →  — The Auditor. I'll assume this code is guilty until I prove it correct.
```

## The idea

A **skill** is a *verb* — `brainstorm`, `graphify`, `dataviz`. A single tool that does one thing.

A **persona** is a *noun* — *The Architect*, *The Designer* — a whole professional identity that
**wields many skills with judgment**. It doesn't just "use the design tool"; it *understands the
design system first*, has taste with reasons, holds a quality bar, and knows which tool to reach
for and when.

> **The persona's mind lives in its `SKILL.md`. Skills are its hands.**
> If a skill isn't installed, the persona still thinks correctly and does the work by hand —
> it degrades gracefully, it never breaks.

That's the difference between handing someone a toolbox and hiring someone who knows the craft.

### Why not just use a system prompt?
While you can type these instructions into a system prompt by hand, it is hard to scale, share, and maintain. Persona solves this through **packaging**: it provides a versioned, routable, schema-validated repertoire of opinionated prompts that your team doesn't have to re-type, copy-paste, or construct from scratch for every new session.

## The roster

| | Persona | Essence |
|---|---|---|
| 🏛️ | **[The Architect](skills/the-architect/SKILL.md)** | Designs systems that survive contact with reality. |
| 🎨 | **[The Designer](skills/the-designer/SKILL.md)** | Understands the system before touching a pixel; ships taste, not decoration. |
| 🚀 | **[The Shipper](skills/the-shipper/SKILL.md)** | Momentum over ceremony — small, verified steps that reach production. |
| 🔍 | **[The Auditor](skills/the-auditor/SKILL.md)** | Assumes the code is guilty until proven correct; hunts the input that breaks it. |
| 📚 | **[The Researcher](skills/the-researcher/SKILL.md)** | Chases evidence, not vibes; separates what's known from what's guessed. |
| ♟️ | **[The Strategist](skills/the-strategist/SKILL.md)** | Turns a messy problem into one decision and a reason to believe it. |

**More experts are hiring →** see the [Roadmap](ROADMAP.md). Domain leads (Backend, Frontend, Data),
specialists (Growth, Copy, Legal) and more are on the way.

## Install

```bash
git clone https://github.com/palusc/dotpersona.git
cd dotpersona
./install.sh          # links each expert as a first-class skill into ~/.claude/skills
```

That's it. Open Claude Code and type `/persona`.

<sub>Prefer a copy over a symlink? `./install.sh --copy`. Remove it later with `./install.sh --uninstall`.</sub>

## Use it

```
/persona                    # recommends the best expert for what you're doing, and adopts it
/persona designer           # summon a specific persona
/persona architect design the billing schema   # summon AND start the task in-character
/persona list               # see the whole roster
/persona + auditor          # stack: keep your primary, consult The Auditor on security
/persona new                # forge your own expert (guided)
/persona update             # pull the latest roster and see what's new
/persona off                # back to plain Claude
```

You can also just say it: *"be a designer for this"*, *"put on your architect hat"*.

A persona is a **mode, not a costume** — it changes *how Claude decides and what it refuses to
ship*, not just the tone.

## Keeping your team current

Persona is a **team that keeps hiring**. Inside Claude Code, `/persona update` runs `./install.sh --update` to pull the latest engine improvements, new experts, and versioned updates, then displays the changes.

## Build your own expert

The best rosters are hired by the community. Creating a custom persona is one file:

```bash
/persona new     # Persona Forge interviews you and writes custom-personas/<slug>.md
```

…or copy [`templates/PERSONA.template.md`](templates/PERSONA.template.md) by hand. The only rule
that matters: **be opinionated.** A persona must hold at least one belief a generalist wouldn't —
a line it draws that changes the outcome. If it behaves like plain Claude, it's noise.

Then [open a PR](CONTRIBUTING.md) — your name goes on the persona, and it joins everyone's team.

## We reference skills — we don't steal them

A persona *names* the skills it likes to orchestrate; it never bundles another author's code.
Declaring `dataviz` is like a résumé saying "proficient in Figma" — it names the tool without
shipping it. Skill authors are credited in [`docs/recommended-skills.md`](docs/recommended-skills.md),
and every persona works with **none** of them installed. Standalone, MIT, yours.

## Learn more

- 🧠 [How it works](docs/how-it-works.md) — the architecture and mental model
- 🧪 [Before/After transcript](docs/before-after.md) — see how /persona auditor catches bugs default Claude misses
- 📐 [The `PERSONA.md` schema](docs/persona-schema.md) — the contract every persona follows
- ✍️ [Creating a persona](docs/creating-a-persona.md) — a hands-on tutorial
- 🗺️ [Roadmap](ROADMAP.md) · 📓 [Changelog](CHANGELOG.md) · 🤝 [Contributing](CONTRIBUTING.md)

## License

[MIT](LICENSE) © 2026 Paul Schirra and Persona contributors. Referenced skills belong to their
authors under their own licenses.

<div align="center"><sub>Built with Claude Code. Hire an expert, not a tool.</sub></div>
