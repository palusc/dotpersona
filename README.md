# 🎭 Persona for Claude Code

**Turn Claude Code into a team of senior specialists.** Summon the right expert for your workspace with a single command.

<div align="center">
  <img src="https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif" alt="Typing Cat" width="300" style="border-radius: 8px;" />
</div>

## Quick Install

Run this one-liner to link all experts into `~/.claude/skills`:

```bash
curl -fsSL https://raw.githubusercontent.com/palusc/dotpersona/main/install.sh | bash
```

Open Claude Code and type `/persona`.

---

## How to use

```bash
/persona                    # Auto-recommends and adopts the best expert for your current files
/persona list               # View the roster of available experts
/persona auditor            # Adopts a specific specialist (e.g. The Auditor)
/persona auditor index.js   # Adopt the Auditor and immediately review index.js
/persona + auditor          # Stack: consult the Auditor while keeping your primary expert
/persona off                # Return to default Claude
```

You can also switch naturally in chat: *"be a designer for this"*, *"put on your auditor hat"*.

---

## The Roster

Every persona holds a unique **mindset, method, quality bar, and voice** tailored to a specific developer role:

| Role | Essence |
|---|---|
| 🏛️ **[The Architect](skills/the-architect/SKILL.md)** | Designs systems that survive contact with reality. |
| 🎨 **[The Designer](skills/the-designer/SKILL.md)** | Understands the design system before touching a pixel; ships taste. |
| 🚀 **[The Shipper](skills/the-shipper/SKILL.md)** | Momentum over ceremony — small, verified steps to production. |
| 🔍 **[The Auditor](skills/the-auditor/SKILL.md)** | Assumes code is guilty until proven correct; hunts critical logic bugs. |
| 🗄️ **[The DBA](skills/the-dba/SKILL.md)** | Profiles queries, handles composite indexing, designs zero-downtime migrations. |
| 🧪 **[The Tester](skills/the-tester/SKILL.md)** | Hunts boundary edge-cases and writes robust test suites (Jest/Vitest/Playwright). |
| ✍️ **[The Wordsmith](skills/the-wordsmith/SKILL.md)** | Refines developer docs, UI copy, and logs to be punchy and active. |
| 📚 **[The Researcher](skills/the-researcher/SKILL.md)** | Chases evidence over vibes; separates what is known from guessed. |
| ♟️ **[The Strategist](skills/the-strategist/SKILL.md)** | Translates messy problems into a single decision and a reason to believe it. |

---

## Why Persona? (Comparison)

| Feature / Dimension | Plain Claude | Custom `CLAUDE.md` | Standalone Skills | 🎭 **Persona** |
|---|---|---|---|---|
| **Routability** | ❌ None | ❌ Manual copy-paste | ❌ None | **✅ Auto-routed** based on current workspace files |
| **Composition** | ❌ Mixed context | ❌ Manual stacking | ❌ None | **✅ Stackable** (`/persona + auditor`) and switchable |
| **Graceful Degradation** | ❌ N/A | ❌ N/A | ❌ Hard error if missing | **✅ Falls back** to manual process if skill is missing |
| **Validation & Schema** | ❌ None | ❌ None | ❌ None | **✅ Schema-enforced** (`docs/persona-schema.md`) structure |
| **Opinionated Mindsets** | ❌ Conversational | ❌ Vague generalists | ❌ Verbs only (tools) | **✅ High-judgment** senior specialist roles (minds) |

---

<details>
<summary>🛠️ <b>Build Your Own Expert</b></summary>

Persona includes a **Persona Forge** guided interview to let you draft your own update-safe custom personas:

```bash
/persona new
```

This interviews you and generates a custom persona markdown file under `custom-personas/` using a strict schema constraint. You can then link and submit your persona back to the community via a pull request.
</details>

<details>
<summary>🔄 <b>Self-Updates</b></summary>

The installer clones the repository to `~/.dotpersona`. Inside Claude Code, typing `/persona update` automatically pulls the latest improvements and symlinks any newly added community experts.
</details>

<details>
<summary>⚡ <b>Graceful Degradation</b></summary>

A persona *references* skills (verbs) but does not vendor them. If a referenced skill is missing from your system, the persona falls back to its embedded method to solve the task manually. It never breaks your session or requests you to install dependencies before helping.
</details>

<details>
<summary>📚 <b>Documentation Index</b></summary>

- 🧠 **[How it works](docs/how-it-works.md)** — The engine, lifecycle, and routing mechanics.
- 🧪 **[Before/After Proof](docs/before-after.md)** — See `/persona auditor` catch double-spends that default Claude misses.
- 📐 **[Schema Contract](docs/persona-schema.md)** — The strict markdown layout every persona follows.
- ✍️ **[Tutorial: Creating a Persona](docs/creating-a-persona.md)** — Step-by-step guide to authoring.
- 🤝 **[Contributing](CONTRIBUTING.md)** · 🗺️ **[Roadmap](ROADMAP.md)** · 📓 **[Changelog](CHANGELOG.md)**
</details>

---

## License

[MIT](LICENSE) © 2026 Paul Schirra and Persona contributors.
