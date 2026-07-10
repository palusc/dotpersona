# Remote persona registry (dotpersona.dev)

This repo is the **client**: the `persona` skill knows how to install a persona by ID from a
public registry. The registry itself — browsing, search, submissions, storage, curation —
lives outside this repo, at dotpersona.dev. This document is the contract between the two, so
either side can be rebuilt independently as long as it honors this.

## What stays where

- This repo ships the **shipped roster** (`skills/*/SKILL.md`) and the **client logic**
  (`skills/persona/SKILL.md`, including `/persona remote <ID>`) — MIT, free, forkable.
- The registry (the database of community personas, the browse/submit UI, download counts,
  auth, curation) lives at dotpersona.dev and is **not** part of this repo. Forking this repo
  gets you a working client with an empty `custom-personas/` — not the catalog behind it.

## ID scheme

A persona's public ID is `<owner>/<slug>`:

- `owner` — the submitting author's handle (GitHub handle recommended, so identity is
  trust-derived from OAuth rather than free-typed)
- `slug` — the persona's `persona:` frontmatter value, kebab-case (see `docs/persona-schema.md`)

Example: `paulschirra/the-negotiator`

Namespacing by owner means two authors can use the same slug without collision — this mirrors
`owner/repo` on GitHub, a mental model users already have, and avoids needing a global slug
registry or auto-suffixing on submit.

## Endpoints the registry must expose

### `GET /api/personas/:owner/:slug/raw`

Returns the **exact** persona file — frontmatter + body, matching `docs/persona-schema.md` —
as `text/markdown; charset=utf-8`. This is fetched verbatim by `/persona remote <ID>` and
written to `custom-personas/<slug>.md` with no transformation. The response body IS the file;
do not wrap it in JSON.

- `404` if `owner/slug` doesn't exist.
- Increment the persona's download counter as a best-effort side effect of this request.

### `GET /api/personas/:owner/:slug`

JSON metadata, for display before install (used by the website's detail page, and optionally by
the skill to show a confirmation line):

```json
{
  "owner": "paulschirra",
  "slug": "the-negotiator",
  "name": "The Negotiator",
  "essence": "Turns adversarial standoffs into structured trades.",
  "version": "1.0.0",
  "author": "paulschirra",
  "triggers": ["negotiation", "pricing", "contract"],
  "downloads": 482,
  "updated_at": "2026-06-01T12:00:00Z"
}
```

### `GET /api/personas?q=&tag=&sort=popular|new&cursor=`

List/search for the browse page. Returns an array of the same summary shape as above (no
`content` field — keep list responses light).

### `POST /api/personas`

Submit or update a persona. Requires an authenticated session (GitHub OAuth recommended — the
server sets `owner` and should overwrite/ignore any `author` the client sends, so identity can't
be spoofed). Body is the raw markdown file.

The server **must** validate before publishing — the local skill trusts registry content enough
to install it with only a light sanity check, so the registry is the real gate:

- required frontmatter keys: `persona`, `name`, `essence`, `version`, `author`
- required body sections, in this exact order: Identity, Operating Principles, Method,
  Skills I Wield, Definition of Done, How I Communicate, Summon Me When / Not

Reject with a specific list of what's missing or out of order. Never silently accept or
silently repair a malformed submission.

## Licensing note

The client (this repo) is MIT. The registry's content — the database of submitted personas,
download counts, curation — is not published as part of this repo and doesn't need to be under
the same license. Treat the registry as the proprietary half of an open-core split: the protocol
is open, the catalog behind it is not.
