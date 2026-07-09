# Recommended skills — credit where it's due

Personas **reference** skills by name; this repo never bundles another author's skill code
(see *Skill provenance* in [`SKILL.md`](../SKILL.md)). A persona works with **none** of these
installed — its method carries the work — but these skills make it faster and sharper.

Two buckets:

- **Bundled** — ships with Claude Code; you already have it.
- **Community** — install separately from its own source. Credit and license belong to its author.

If an attribution here is wrong, missing, or a skill has moved, please
[open a PR](../CONTRIBUTING.md) — getting authors credited correctly matters to us.

## By persona

| Persona | Skills it wields | Bucket |
|---|---|---|
| The Architect | `senior-solution-architect`, `writing-plans`, `graphify` | community |
| The Designer | `premium-website`, `artifact-design`, `dataviz` | mixed |
| The Shipper | `executing-plans`, `verify`, `run`, `code-review` | bundled |
| The Auditor | `code-checkup`, `code-review`, `security-review` | mixed |
| The Researcher | `deep-research`, `webpage-reader`, `youtube-summarizer` | community |
| The Strategist | `mckinsey-strategist`, `storytelling-expert`, `brainstorming` | mixed |

## How to install a missing skill

Persona does not install skills for you and never copies them here. When a persona would benefit
from a skill you don't have, it tells you the skill's name and where it comes from. Install it from
its own source, typically by dropping its folder into `~/.claude/skills/<name>/`, then the persona
picks it up automatically on the next `/persona` invocation.

- **Bundled skills** are already present in a current Claude Code install — nothing to do.
- **Community skills** live in their authors' own repos. Search for the skill name and install from the
  original source.

## A note to skill authors

If one of your skills is referenced above and you'd like the credit link to point somewhere specific
(your repo, your handle, a sponsor page), open a PR editing this file. We'd rather over-credit than
under-credit. Personas are only as good as the skills the community builds.
