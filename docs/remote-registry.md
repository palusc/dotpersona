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

- `404` (`text/plain`, not JSON — the error shape matches the success shape) if `owner/slug`
  doesn't exist, **or** if it exists but is `private`/`restricted` and the requester isn't allowed
  to see it (see **Visibility & tiers** below). Existence is never confirmed to a requester who
  can't view the persona.
- Increment the persona's download counter as a best-effort side effect of this request, after
  the body has been sent — a failed counter must never delay or fail the download itself.

### `GET /api/personas/:owner/:slug`

JSON metadata, for display before install (used by the website's detail page, and optionally by
the skill to show a confirmation line). Same existence-hiding `404` rule as `/raw` above.

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
  "updated_at": "2026-06-01T12:00:00Z",
  "visibility": "public",
  "shared_with": []
}
```

### `GET /api/personas?q=&tag=&sort=popular|new&cursor=`

List/search for the browse page. Returns an array of the same summary shape as above (no
`content`, `visibility`, or `shared_with` — keep list responses light and public-only; the search
RPC backing this only ever returns rows the requester is allowed to see).

### `POST /api/personas`

Submit or update a persona. Requires an authenticated session (GitHub OAuth recommended). The
signed-in user's handle becomes `owner`, always — never taken from the payload. The file's
frontmatter `author` must match that handle exactly; a mismatch is rejected with `403`, not
silently overwritten (identity can't be spoofed, and the registry doesn't silently repair
anything, per the validation rule below).

Body is the raw markdown file, or a JSON object `{"content": "...", "visibility": "...",
"shared_with": [...]}` for callers that also want to set visibility in the same request
(equivalently, an `x-visibility` / `x-shared-with` header alongside a raw-markdown body).
`visibility` defaults to `public` if omitted — see **Visibility & tiers**.

The server **must** validate before publishing — the local skill trusts registry content enough
to install it with only a light sanity check, so the registry is the real gate:

- required frontmatter keys: `persona`, `name`, `essence`, `version`, `author`
- required body sections, in this exact order: Identity, Operating Principles, Method,
  Skills I Wield, Definition of Done, How I Communicate, Summon Me When / Not

Reject with a specific list of what's missing or out of order. Never silently accept or
silently repair a malformed submission.

Free tier accounts are additionally capped at 3 published personas, and may not set
`visibility: private` or `restricted` (`403` — see **Visibility & tiers**).

## Visibility & tiers

A persona is published with one of four `visibility` values, set at submit time as above:

- `public` — listed in search/browse and installable by anyone.
- `unlisted` — installable by anyone with the exact `<owner>/<slug>` ID, omitted from search.
- `private` — installable only by the owner.
- `restricted` — installable by the owner and the GitHub handles listed in `shared_with`.

`private` and `restricted` are Pro features. A Free-tier submission requesting either is rejected
at publish time. If an owner's subscription later lapses, their existing `private`/`restricted`
personas lock for **everyone, including the owner** — `public`/`unlisted` are never gated by
tier. A locked-out request gets the same `404` as a nonexistent persona, never a `403` that would
confirm the `owner/slug` exists.

None of this reaches the client: `/persona remote <ID>` only ever calls `GET .../raw`, which
either returns the file or 404s. The client has no concept of tiers, ownership, or sharing.

## Attachments

An owner can attach reference files to their own persona — PDF, PNG, JPEG, or WEBP, sniffed by
magic bytes rather than trusted by the client's `Content-Type`. Free tier: 3 attachments per
persona, 5MB each. Pro: unlimited attachments, 25MB each. Attachments on a `private`/`restricted`
persona lock along with the persona itself if the owner's subscription lapses.

- `GET /api/personas/:owner/:slug/attachments` — list attachments; same visibility gate as the
  detail route.
- `POST /api/personas/:owner/:slug/attachments` — owner-only, `multipart/form-data` with a `file`
  field and an optional `label`. Rejects a file whose sniffed bytes don't match an allowed type,
  anything over the tier's size limit, and anything past the tier's count limit.
- `GET .../attachments/:id` — redirects to a signed, short-lived download URL.
- `DELETE .../attachments/:id` — owner-only.

This is a website-only feature today: `/persona remote` installs the persona file itself and
never fetches its attachments — there is no client-side use for them yet.

## Licensing note

The client (this repo) is MIT. The registry's content — the database of submitted personas,
download counts, curation — is not published as part of this repo and doesn't need to be under
the same license. Treat the registry as the proprietary half of an open-core split: the protocol
is open, the catalog behind it is not.
