# Roadmap — the experts coming to your team

Persona grows like a team that keeps hiring. New experts ship regularly — every persona is a mini-release.

This roadmap is a promise *and* an invitation: if you want one of these sooner, build it with
`/persona new` and [open a PR](CONTRIBUTING.md). Your name goes on the persona.

## Shipped — v1.0

- ✅ The Architect · The Designer · The Shipper · The Auditor · The Researcher · The Strategist

## Shipped — v1.1

- ✅ The DBA · The Tester · The Wordsmith · The Product Manager

## Shipped — v1.2 (personas leave home)

- ✅ **Portable export** — `scripts/persona-export.sh` reshapes any persona for Claude.ai, the
  Messages API, Cursor rules, or `AGENTS.md`. Trade-offs: [`docs/portability.md`](docs/portability.md).
- ✅ **`install.sh --dry-run`** — read the installer's plan before you run it, even over `curl`.
- ✅ **Versioned behavior** — CI rejects a persona change that doesn't bump its SemVer `version:`.

## Shipped — v1.3 (the domain leads)

Role personas answer *how do I work*. Domain leads answer *what do I know deeply*.

- ✅ **The Backend Lead** — data models, APIs, transactions, queues, idempotency, the boring reliability.
- ✅ **The Frontend Lead** — component architecture, state, performance budgets, accessibility as default.
- ✅ **The Data Lead** — pipelines, schemas, correctness of numbers, "is this metric even right".
- ✅ **The DevOps Lead** — deploys, observability, rollbacks, the 3am-pager mindset.

## Shipped — v1.4 (the specialists)

- ✅ **The Growth Hacker** — funnels, activation, the one metric that matters.
- ✅ **The Copywriter** — words that convert; cuts your paragraph in half and it's better.
- ✅ **The Legal Reviewer** — ToS, privacy, licensing, "can we actually ship this".
- ✅ **The Interviewer** — pressure-tests your plan until only the true parts survive.
- ✅ **The Teacher** — explains the thing so you actually understand it, not just copy it.

## Engine roadmap

- ✅ **Team presets** — summon a named squad for a project (`/persona team saas-launch`).
- ✅ **Deeper stacking** — a primary persona convening a short panel of consultants on one decision.
- ✅ **Per-project personas** — a `.persona/` folder in your own repo with project-specific experts.
- ✅ **Persona registry** — `/persona remote <owner>/<slug>` installs a community persona from
  the registry at dotpersona.dev (client contract: `docs/remote-registry.md`). The registry's
  browse/search UI itself lives outside this repo.

## Shipped — v2.0 (trust & rigor)

Not new experts — the roster earning the claims the README makes about it.

- ✅ **Remote-install shows the payload.** `/persona remote` now surfaces the actual
  `Operating Principles` + `Method` a fetched persona would run, and scans the body for
  instruction-injection, before it can be adopted — a name/essence line was never enough to
  catch a prompt buried in the body.
- ✅ **The Auditor executes its repros.** CONFIRMED now means a repro that was actually run and
  observed to fail, not one traced in the model's head; an unexecuted-but-sound trace is
  PLAUSIBLE. The strongest label is tied to an observation, not to the persona's own authority.
- ✅ **Trigger disambiguation.** Resolved the three colliding triggers (`component`, `copy`,
  `deploy`) by specificity and documented a routing tiebreak, so an ambiguous request stacks or
  asks instead of silently picking the wrong expert.

## Open — evaluation (the honest gap)

The evidence for "a persona improves the output" is currently **one transcript**
([`docs/before-after.md`](docs/before-after.md)) — an existence proof, not a distribution claim.
The open work is a real evaluation: a set of tasks run default-vs-persona and scored, including
the **counter-cases** (where a persona over-focuses, or the default is already the pragmatic
answer). `skill-creator` already provides eval/variance tooling to build this. Until it exists,
the README and launch copy say "inspect," "example," and "mechanism" — never "proven."

## Later — v1.5+ (open floor)

Every named expert and engine feature on this roadmap has shipped. What's next is hired by the
community, not planned in advance — see the opinionation test in `CONTRIBUTING.md` before
proposing one.

Have an expert you wish existed? [Open an issue](https://github.com/palusc/dotpersona/issues/new?template=new-persona.md)
or just build it. The best rosters are hired by the community.
