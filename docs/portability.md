# Using a persona outside Claude Code

A persona is a markdown file. Nothing about the *mind* — the identity, the operating
principles, the method, the quality bar — depends on Claude Code. Only the *plumbing*
does: auto-routing from your open files, `/persona + auditor` stacking, and the skill
handoffs. Those are Claude Code features.

Everything else travels. `scripts/persona-export.sh` lifts a persona out of the repo and
reshapes it for wherever you actually work.

```bash
scripts/persona-export.sh --list        # who's on the roster
scripts/persona-export.sh auditor       # the system prompt, on stdout
```

Slugs resolve loosely: `auditor`, `the-auditor`, and anything in `custom-personas/` all work.

---

## What the export contains

The exported prompt is the persona's own file with the YAML frontmatter stripped and a
short preamble bolted on. The preamble does three things:

1. Names the identity — *"You are The Auditor."*
2. States the essence in one line.
3. Carries over the **graceful degradation contract**: where the persona names a Claude Code
   skill you don't have, do the work by hand from the method rather than asking the user
   to install anything.

That third point is what keeps a persona useful outside its home. `the-auditor` declares
`code-checkup`, `code-review`, and `security-review`. In Claude.ai none of those exist —
so it audits from its embedded method instead of stalling.

---

## Targets

### `prompt` (default) — Claude.ai, ChatGPT, anything with a system prompt box

```bash
scripts/persona-export.sh auditor | pbcopy      # macOS
scripts/persona-export.sh auditor | xclip -sel c # Linux
```

Paste it into a Claude Project's custom instructions, a ChatGPT custom GPT, or just the
first message of a conversation.

### `json` — the Messages API

```bash
scripts/persona-export.sh auditor --target json
# → {"slug": "the-auditor", "name": "The Auditor", "essence": "…", "system": "…"}
```

Feed `.system` straight into the `system` parameter:

```python
import json, subprocess, anthropic

persona = json.loads(subprocess.check_output(
    ["scripts/persona-export.sh", "auditor", "--target", "json"]))

anthropic.Anthropic().messages.create(
    model="claude-opus-4-8",
    max_tokens=4096,
    system=persona["system"],
    messages=[{"role": "user", "content": open("server.js").read()}],
)
```

`--all` returns an array instead of an object — useful for building a persona picker.

### `cursor` — Cursor rules

```bash
scripts/persona-export.sh --all --target cursor
# → .cursor/rules/the-auditor.mdc, the-dba.mdc, … (alwaysApply: false)
```

Each becomes a manually-invoked rule. In Cursor's chat, summon one with `@the-auditor`.

### `agents` — AGENTS.md

```bash
scripts/persona-export.sh --all --target agents
```

Writes a delimited block into `AGENTS.md`, the convention honored by Codex, Cursor, Zed,
Amp, and others. The block is fenced by `<!-- persona:start -->` and `<!-- persona:end -->`:
re-running replaces it in place rather than appending a second copy, and anything you wrote
outside the markers is left alone.

Each persona is folded into a `<details>` section so a ten-persona roster doesn't drown the
rest of your `AGENTS.md`.

---

## What you lose

Be honest about the trade. Exported personas are a **prompt**, not an engine.

| | Claude Code (`/persona`) | Exported |
|---|---|---|
| **Auto-routing** | Picks the expert from your open files and git diff | You pick |
| **Stacking** | `/persona + auditor` consults a second expert | One at a time |
| **Skill orchestration** | Calls `code-review`, `security-review`, … | Falls back to the embedded method |
| **Native tools** | Reads files, greps, runs the repro/test, verifies end-to-end | Describes what to run; you run it |
| **Switching** | `/persona off`, `/persona dba` mid-session | New conversation |
| **Updates** | `/persona update` | Re-run the export |

The mindset, the method, the quality bar, and the voice — the parts that actually change the
output — come along intact. **How much that's worth depends on the persona.** A judgment-first
role (The Strategist, The Product Manager, The Copywriter) exports at near-full strength: its
value is the thinking, and the thinking is text. A verification-first role (The Auditor, The
Tester, The Shipper, The DevOps Lead) loses the most: its method *depends* on running things —
executing a repro, tabbing through for accessibility, watching a deploy's health — and an
exported prompt can't run anything. In another tool it will hand you the exact test to run or
the exact request to fire, but you execute it, and its findings are PLAUSIBLE-until-you-run-them
rather than CONFIRMED. That's real degradation, not a rounding error — reach for the export when
you want the *judgment* travelled, and stay in Claude Code when you want the *verification* done.

---

## Keeping exports fresh

Exports are snapshots. When you `git pull` a sharpened persona, re-run the export. For a
project that lives on `AGENTS.md`, that's one idempotent command:

```bash
cd ~/.dotpersona && git pull --ff-only
cd ~/my-project && ~/.dotpersona/scripts/persona-export.sh --all --target agents
```

Every persona carries a SemVer `version:` in its frontmatter, and CI refuses a change that
doesn't bump it — so a diff in your `AGENTS.md` always corresponds to a real, versioned
change upstream.
