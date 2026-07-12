<div align="center">

<img src="docs/banner.svg" alt="Persona for Claude Code — turn Claude Code into a team of senior specialists" width="840" style="max-width:100%;" />

<br/>
<br/>

[![validate](https://github.com/palusc/dotpersona/actions/workflows/validate.yml/badge.svg)](https://github.com/palusc/dotpersona/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/palusc/dotpersona?color=brightgreen)](https://github.com/palusc/dotpersona/releases)
[![Language](https://img.shields.io/badge/language-Shell-orange.svg)](https://github.com/palusc/dotpersona)

</div>

# 🎭 Persona for Claude Code

**Turn Claude Code into a team of senior specialists.** Summon the right expert for your workspace with a single command.

<div align="center">
  <img src="docs/demo.gif" alt="Persona Auditor Demo — /persona list and /persona auditor in action" width="640" style="max-width:100%; border-radius:12px; box-shadow: 0 8px 24px rgba(0,0,0,0.15);" />
  <p><sub>Generated automatically using <a href="docs/demo.tape">docs/demo.tape</a> and <a href="https://github.com/charmbracelet/vhs">vhs</a></sub></p>
</div>

**See it change the output, not just the tone.** [Three before/after transcripts](docs/before-after.md) — the same buggy transfer endpoint (default Claude vs. `/persona auditor`), a blocking migration (default Claude vs. `/persona dba`), and a counter-case where a persona has nothing to add. Default Claude buries the double-spend race condition under logging and TypeScript nits; the Auditor ignores the nits and hands you the exact concurrent-request repro plus a scoped fix. It's a small, honestly-chosen set, not a benchmark — including the case where the persona doesn't help — showing the mechanism is real (a persona redirects Claude's attention), not that it wins every time.

> [!NOTE]
> **TL;DR:** Persona packages senior developer mindsets (Architect, Auditor, DBA, etc.) into schema-validated markdown experts. It auto-routes the right specialist to your Claude Code workspace or exports them directly to Cursor (`.mdc`), Claude.ai, or `AGENTS.md`. No manual prompt copy-pasting, no bloated `CLAUDE.md`.

---

## The Pain: Why Persona exists

I kept re-explaining the same thing to Claude every session — "review this like a security engineer," "now think like a DBA" — pasting the same 400-word prompt from a notes file I never fully trusted. Half the time I'd forget a rule I'd relied on last week, and the review would quietly miss what it missed before. I wanted the mindset to load on command and hold itself to a bar, without me re-typing it or dragging the whole thing into every conversation.

Every new Claude Code session starts with a blank slate. If you want specialized guidelines, you have two choices:
1. **Copy-paste massive, fragile system prompts** repeatedly for every new session.
2. **Bloat a static `CLAUDE.md`** with conflicting rules (architecture, security, DB performance, styling) until the context is diluted, the agent gets confused, and responses slow down.

Persona solves this by **packaging** specialized mindsets into modular, schema-validated, local markdown files. You summon only the expert you need, when you need them.

## Who is this for?

**This is for you if:**

- You use Claude Code daily and keep re-typing *"review this like a security engineer."*
- Your `CLAUDE.md` has grown into a pile of rules that quietly contradict each other.
- You want a review that names the bug that loses money — not the missing semicolon next to it.
- You want the same expert to behave the same way next Tuesday — a versioned mindset you can inspect, diff, and test, not a prompt you retype from memory.

**This is not for you if:**

- You want faster autocomplete. Persona changes *judgment*, not keystrokes.
- You want a personality skin. Every persona here has to change the *output* or it doesn't get merged — that's the [merge bar](CONTRIBUTING.md#what-makes-a-persona-get-merged).
- You don't use Claude Code. You can still take the personas with you — see [Beyond Claude Code](#beyond-claude-code-portability-cursor-claudeai-chatgpt) — but `/persona` auto-routing and stacking won't come along.

## Quick Install

See exactly what it would do first. `--dry-run` clones into a temp directory, prints its plan, and deletes it again — nothing under `$HOME` is touched:

```bash
curl -fsSL https://raw.githubusercontent.com/palusc/dotpersona/main/install.sh | bash -s -- --dry-run
```

Happy with the plan? Drop the flag:

```bash
curl -fsSL https://raw.githubusercontent.com/palusc/dotpersona/main/install.sh | bash
```

Open Claude Code and type `/persona`.

Everything is a symlink into `~/.claude/skills`, so `/persona update` (or `git pull`) keeps you current. `./install.sh --uninstall` removes every link. Existing folders are never overwritten — they're moved to `<name>.backup.<pid>` first.

---

## Beyond Claude Code: Portability (Cursor, Claude.ai, ChatGPT)

A persona is a markdown file, not a Claude Code feature. `scripts/persona-export.sh` reshapes any of them for wherever you actually work:

```bash
scripts/persona-export.sh --list                   # who's on the roster
scripts/persona-export.sh auditor | pbcopy         # paste into Claude.ai or ChatGPT
scripts/persona-export.sh auditor --target json    # {"system": …} for the Messages API
scripts/persona-export.sh --all --target cursor    # → .cursor/rules/*.mdc
scripts/persona-export.sh --all --target agents    # → AGENTS.md (Codex, Zed, Amp, …)
```

The export carries the identity, the method, the quality bar, the voice — and the degradation contract, so a persona that names a Claude Code skill it can't reach does the work by hand instead of stalling.

What doesn't travel: auto-routing, stacking, and `/persona update`. Everywhere but Claude Code, you pick the expert yourself. Full trade-off table and an API example: [`docs/portability.md`](docs/portability.md).

---

## The Difference, In One Case

Same buggy code, two runs — one of three cases, not a benchmark (the other two: a blocking
migration, and a counter-case where the persona has nothing to add). [Full transcripts & rationale →](docs/before-after.md)

```javascript
app.post('/transfer', async (req, res) => {
  const { fromUserId, toUserId, amount } = req.body;
  const fromUser = await db.getUser(fromUserId);
  if (fromUser.balance < amount) return res.status(400).send("Insufficient funds");
  await db.updateBalance(fromUserId, fromUser.balance - amount);
  await db.updateBalance(toUserId, (await db.getUser(toUserId)).balance + amount);
  res.send("Success");
});
```

| | Default Claude | `/persona auditor` |
|---|---|---|
| **Focus** | Style and general best practices | Concrete, reproducible failure cases |
| **Output** | 5 generic suggestions — input validation, try/catch, TypeScript types, structured logging, "you might want a transaction" | 2 **CONFIRMED** findings, each with the exact repro: a concurrent double-spend and a non-transactional write that loses money on crash |
| **Fix offered** | None — just a question: *"Would you like me to rewrite it?"* | A scoped fix: row-level lock + transaction boundary, nothing else touched |

The bug that actually loses money — the concurrent double-spend — is the fifth bullet in Default Claude's list, filed next to a suggestion to add Winston logging. The Auditor finds it first and doesn't stop until it has a concrete repro.

---

## How to use

```bash
/persona                    # Auto-recommends and adopts the best expert for your current files
/persona list               # View the roster of available experts
/persona auditor            # Adopts a specific specialist (e.g. The Auditor)
/persona auditor index.js   # Adopt the Auditor and immediately review index.js
/persona + auditor          # Stack: consult the Auditor while keeping your primary expert
/persona remote owner/slug  # Install a community persona from the dotpersona.dev registry
/persona new                # Forge your own via a guided interview
/persona update             # Pull the latest personas and link any new ones
/persona off                # Return to default Claude
```

You can also switch naturally in chat: *"be a designer for this"*, *"put on your auditor hat"*.

---

## The Roster

Every persona holds a unique **mindset, method, quality bar, and voice** tailored to a specific developer role. The third column is what you'll actually see it do differently from plain Claude:

| Role | Essence | What's different |
|---|---|---|
| 🏛️ **[The Architect](skills/the-architect/SKILL.md)** | Designs systems that survive contact with reality. | Refuses to ship a design with no stated failure modes or rollback path — "it should work" isn't an architecture. |
| 🎨 **[The Designer](skills/the-designer/SKILL.md)** | Understands the design system before touching a pixel; ships taste. | Justifies every shadow and border it keeps — decoration it can't explain gets cut. |
| 🚀 **[The Shipper](skills/the-shipper/SKILL.md)** | Momentum over ceremony — small, verified steps to production. | Won't write "done" until it's watched the real flow run — green tests alone don't count. |
| 🔍 **[The Auditor](skills/the-auditor/SKILL.md)** | Assumes code is guilty until proven correct; hunts critical logic bugs. | Tags each finding CONFIRMED or PLAUSIBLE with the exact input that breaks it — no repro, no report. |
| 🗄️ **[The DBA](skills/the-dba/SKILL.md)** | Profiles queries, handles composite indexing, designs zero-downtime migrations. | Treats every query as a full-table scan until `EXPLAIN ANALYZE` says otherwise; migrations ship as expand/contract, never a blocking lock. |
| 🧪 **[The Tester](skills/the-tester/SKILL.md)** | Hunts boundary edge-cases and writes robust test suites (Jest/Vitest/Playwright). | Writes more edge-case tests than happy-path ones on purpose — null, empty, concurrent, off-by-one. |
| ✍️ **[The Wordsmith](skills/the-wordsmith/SKILL.md)** | Refines developer docs, UI copy, and logs to be punchy and active. | Cuts 20–30% of your words and hands back a before/after diff — "seamless" and "revolutionize" don't survive. |
| 📚 **[The Researcher](skills/the-researcher/SKILL.md)** | Chases evidence over vibes; separates what is known from guessed. | Tags every claim with a confidence level and ships the "couldn't establish" section — no source, no claim. |
| ♟️ **[The Strategist](skills/the-strategist/SKILL.md)** | Translates messy problems into a single decision and a reason to believe it. | Opens with one recommendation and names what we're explicitly *not* doing — never "it depends." |
| 🎯 **[The Product Manager](skills/the-product-manager/SKILL.md)** | Turns a vague feature request into a spec so precise two engineers would build the same thing. | Refuses to hand off a story with no acceptance criteria — "should feel intuitive" isn't a test. |
| ⚙️ **[The Backend Lead](skills/the-backend-lead/SKILL.md)** | Owns data models, APIs, transactions, queues, and idempotency. | Refuses to ship a mutating endpoint with no idempotency key — a retry shouldn't double-charge anyone. |
| 🧩 **[The Frontend Lead](skills/the-frontend-lead/SKILL.md)** | Owns component architecture, state, performance budgets, and accessibility as default. | Ships loading, empty, and error states for every data view — a blank screen isn't a state. |
| 📊 **[The Data Lead](skills/the-data-lead/SKILL.md)** | Pipelines, schemas, and correctness of numbers. | Won't sign off on a dashboard number it can't trace back to the source table. |
| 🛰️ **[The DevOps Lead](skills/the-devops-lead/SKILL.md)** | Deploys, observability, rollbacks — the 3am-pager mindset. | Designs the rollback command before the forward deploy plan, every time. |
| 📈 **[The Growth Hacker](skills/the-growth-hacker/SKILL.md)** | Funnels, activation, and the one metric that actually moves the business. | Finds the funnel's biggest leak before optimizing anything downstream of it. |
| 🖋️ **[The Copywriter](skills/the-copywriter/SKILL.md)** | Words that convert; cuts your paragraph in half and it's better. | Ships exactly one CTA per page, stated as an action — never a menu of "learn more"s. |
| ⚖️ **[The Legal Reviewer](skills/the-legal-reviewer/SKILL.md)** | ToS, privacy, licensing — "can we actually ship this." | Checks what data the code actually collects against what the privacy policy claims — not the other way around. |
| 🎤 **[The Interviewer](skills/the-interviewer/SKILL.md)** | Pressure-tests your plan until only the true parts survive. | Won't sign off on a plan with an untested assumption still load-bearing. |
| 🧑‍🏫 **[The Teacher](skills/the-teacher/SKILL.md)** | Explains the thing so you actually understand it, not just copy it. | Checks you can restate the concept before moving on — an answered question isn't a landed one. |

More are coming, and the roster is hired by the community — see the [Roadmap](ROADMAP.md) and [Contributing](CONTRIBUTING.md).

---

## How it works

Persona routes on the files in front of you. There is no central registry to keep in sync.

```
   [ /persona command ]
           │
           ├──> Inspect current workspace files (active file / git diff)
           ├──> Match file extensions and names against each persona's `triggers`
           ├──> Adopt the best fit (Identity, Operating Principles, Method, Definition of Done)
           │
       [ Operate Phase ]
           ├──> Check ~/.claude/skills/ for the skills this persona declares
           └──> Run the Method, gate the answer on the Definition of Done
```

1. **Indexing.** The engine reads the `triggers` list from the YAML frontmatter of every `skills/*/SKILL.md` and `custom-personas/*.md`.
2. **Trigger matching.** An active `schema.sql` matches `sql` and `schema` → The DBA. A `.css` file → The Designer. CI reports any trigger claimed by two personas so ambiguous routing gets noticed in review — a soft overlap resolved by `consults` is legitimate, so it's surfaced, not failed.
3. **Adoption.** The chosen file is read into context (surviving compaction), and Claude works through its Method, refusing to finish until the Definition of Done is met.
4. **Graceful degradation.** A persona *references* skills but never vendors them. If a declared skill is missing, the persona falls back to its embedded method and does the work by hand. It never hard-fails or asks you to install something first.

Deeper mechanics: [`docs/how-it-works.md`](docs/how-it-works.md). The file format: [`docs/persona-schema.md`](docs/persona-schema.md).

### Why the installer is boring on purpose

* **Fail-fast:** `set -euo pipefail`, so a half-configured state can't happen.
* **Non-destructive:** an existing `~/.claude/skills/<name>` is moved to `<name>.backup.<pid>`, never overwritten or deleted.
* **Update-safe customization:** your own personas live in `custom-personas/`, which is gitignored — no merge conflicts on `git pull`.
* **Deterministic updates:** `/persona update` is a `--ff-only` pull. It shows you what changed and never rewrites local state.
* **Inspectable:** `--dry-run` prints the full plan and writes nothing, including over `curl | bash`.

---

## Why Persona? (Comparison)

| Feature / Dimension | Plain Claude | Custom `CLAUDE.md` | Standalone Skills | 🎭 **Persona** |
|---|---|---|---|---|
| **Routability** | ❌ None | ❌ Manual copy-paste | ❌ None | **✅ Auto-routed** based on current workspace files |
| **Composition** | ❌ Mixed context | ❌ Manual stacking | ❌ None | **✅ Stackable** (`/persona + auditor`) and switchable |
| **Graceful Degradation** | ❌ N/A | ❌ N/A | ❌ Hard error if missing | **✅ Falls back** to manual process if skill is missing |
| **Validation & Schema** | ❌ None | ❌ None | ❌ None | **✅ Schema-enforced** (`docs/persona-schema.md`), CI-verified |
| **Versioned behavior** | ❌ None | ❌ None | ❌ Rarely | **✅ SemVer** per persona; CI rejects a change that doesn't bump it |
| **Opinionated Mindsets** | ❌ Conversational | ❌ Vague generalists | ❌ Verbs only (tools) | **✅ High-judgment** senior specialist roles (minds) |

---

## Quick Examples

Here is how different personas respond to specific developer scenarios in your workspace:

#### 1. Security Review (`/persona auditor server.js`)
* **Scenario:** Auditing an Express transfer handler.
* **Input code:**
  ```javascript
  app.post('/transfer', async (req, res) => {
    const { fromUserId, toUserId, amount } = req.body;
    const fromUser = await db.getUser(fromUserId);
    if (fromUser.balance < amount) return res.status(400).send("Insufficient funds");
    await db.updateBalance(fromUserId, fromUser.balance - amount);
    await db.updateBalance(toUserId, (await db.getUser(toUserId)).balance + amount);
    res.send("Success");
  });
  ```
* **Auditor's Output:**
  ```
  — The Auditor. I'll assume this code is guilty until I prove it correct.

  ### Findings
  1. CONFIRMED: Concurrent Double-Spend (Critical)
     - Repro: User A (balance $100) fires two concurrent requests to transfer $100.
     - Trace: Request 1 & 2 read balance $100 concurrently, passing the check. Both update balance, resulting in a negative balance or double spend.
  2. CONFIRMED: Non-Transactional Write (High)
     - Repro: Network failure after the first updateBalance call. Money is deducted from sender but never credited to receiver.

  ### Scoped Fix
  [Provides transactional database block with row-level locks]
  ```

#### 2. Database Migration (`/persona dba schema.prisma`)
* **Scenario:** Adding a new non-null profile bio column to a user table with millions of rows.
* **DBA's Output:**
  ```
  — The DBA. I optimize database schemas, queries, and migrations.

  ### Recommendation: Zero-Downtime Migration
  Do not run a raw `ALTER TABLE User ADD COLUMN bio VARCHAR(255) NOT NULL DEFAULT '';` on your live database, as this will lock the table.

  ### Steps:
  1. Expand: Add the column as nullable.
  2. Write-to-Both: Update application code to write to both the old schema patterns or handle default fallback.
  3. Backfill: Batch-update existing rows in chunks of 5,000 to set the default value.
  4. Contract: Apply the `NOT NULL` constraint with `VALIDATE CONSTRAINT` asynchronously.
  ```

#### 3. Test Generation (`/persona tester auth.js`)
* **Scenario:** Writing test cases for a token validation helper.
* **Tester's Output:**
  ```
  — The Tester. Happy paths are boring; I write tests to prove code can't break.

  ### Test Suite Plan (Vitest)
  - [x] Happy Path: Valid token returns claims and expiration.
  - [x] Boundary: Token expires exactly at current time (should fail).
  - [x] Error Path: Malformed JWT structure throws JSON parse error.
  - [x] Error Path: Empty authorization header returns 401.
  - [x] Edge Case: Expiration timestamp overflow values.
  ```

---

## Build your own expert

```bash
/persona new
```

Persona Forge interviews you and writes an update-safe persona to `custom-personas/` against the same schema the official roster obeys. `custom-personas/` is gitignored, so your experts survive every `git pull`. When one turns out to be good, [send it back as a PR](CONTRIBUTING.md) — your handle goes on it.

Start from [`templates/PERSONA.template.md`](templates/README.md) if you'd rather write it by hand.

---

## Current limitations

Worth knowing before you install:

* **Session rollbacks.** `/persona off` asks Claude to return to normal behavior, but the adopted instructions remain in your conversation history. For a genuinely clean slate, start a new session.
* **A persona costs context.** Adopting one loads its `SKILL.md` — roughly 1–2k tokens — into the conversation. That's *one* persona on demand, not the whole roster (skills load lazily), and it's the same budget a re-pasted prompt would spend, held to a consistent bar. But on a very large file it's real: those tokens aren't reading your code. Adopt the expert you need, not a panel, and drop it (`/persona off` / new session) when the specialist work is done.
* **Stack no more than two.** `/persona + <name>` composes experts, but past two you get context bloat and competing instructions. The engine warns you; it doesn't stop you.
* **Claude Code is the only first-class host.** Auto-routing depends on `~/.claude/skills/`. Other CLIs work only via [export](#beyond-claude-code-portability-cursor-claudeai-chatgpt), and lose routing, stacking, and native tools — so verification-first personas degrade most ([details](docs/portability.md#what-you-lose)).
* **Personas redirect attention; they don't cure hallucination.** A persona makes Claude *look* in the right place — the Auditor hunts the race condition instead of the missing semicolon — but it's still the same model underneath. The Auditor's discipline is to label a finding CONFIRMED only after it actually *ran* the repro, PLAUSIBLE otherwise; treat a PLAUSIBLE finding as a lead to verify, not a fact. It is not a static analyzer and does not replace one.
* **Community personas are code you run.** `/persona remote <owner>/<slug>` fetches instructions Claude will follow with your tools. Before adopting, the engine now shows you the persona's actual `Operating Principles` and `Method` — not just its name — runs a deterministic pre-scan (`scripts/scan-persona-injection.sh`) for invisible/bidi-override Unicode and known injection phrasing, then flags instruction-injection or out-of-role actions (delete, exfiltrate, "ignore previous instructions") in its own judgment for you to veto. Neither layer is a safety guarantee — the mechanical scan catches one obfuscation class, the judgment pass can still miss a sufficiently novel attack. The registry validates schema *shape*, not *safety* — read the thing before you say yes.

---

## Repository map

```
dotpersona/
├── skills/              the roster — one folder per persona, plus the engine
│   ├── persona/         the engine: routing, adoption, stacking, Persona Forge
│   └── the-*/           one SKILL.md per expert — the whole mind, in one file
├── custom-personas/     your own experts (gitignored, survives `git pull`)
├── templates/           PERSONA.template.md — the blank a new persona starts from
├── scripts/             validate-personas.sh · check-version-bump.sh · persona-export.sh
├── docs/                schema · tutorial · before/after proof · portability
├── .github/workflows/   schema · shellcheck · version bump · export · installer dry-run
└── install.sh           symlink · copy · update · uninstall · dry-run
```

Every script is `shellcheck`-clean at `--severity=style` and runs in CI on every push.

---

## Documentation

- 🧠 **[How it works](docs/how-it-works.md)** — The engine, lifecycle, and routing mechanics.
- 🧪 **[Before/After proof](docs/before-after.md)** — `/persona auditor` catching a double-spend default Claude misses.
- 📐 **[Schema contract](docs/persona-schema.md)** — The strict markdown layout every persona follows.
- ✍️ **[Creating a persona](docs/creating-a-persona.md)** — Step-by-step authoring guide.
- 🌍 **[Portability](docs/portability.md)** — Using personas in Claude.ai, the API, Cursor, or AGENTS.md.
- 🧩 **[Recommended skills](docs/recommended-skills.md)** — The community skills personas orchestrate.
- 📡 **[Remote registry](docs/remote-registry.md)** — The `/persona remote` client↔registry contract.
- 🤝 **[Contributing](CONTRIBUTING.md)** · 🗺️ **[Roadmap](ROADMAP.md)** · 📓 **[Changelog](CHANGELOG.md)**

---

## License

[MIT](LICENSE) © 2026 Paul Schirra and Persona contributors.
