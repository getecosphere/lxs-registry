# i18n — translation catalogs as an LXS

A small service that stores and serves **message catalogs** so an estate can
show content in the visitor's language without rebuilding.

- English source strings are the **keys**; `{namespace}/{locale}.json` maps each
  key to its translation. A missing key falls back to the English source, so an
  incomplete catalog never breaks a page.
- Catalogs are served read-only with a stable `ETag` (cache-friendly).
- The **namespace** is the estate (e.g. `getecosphere`), so one LXS instance can
  hold several estates' catalogs.

## Two layers: negotiation (client) vs store (this LXS)

Locale **negotiation** runs inside the frontend render, per request (URL prefix →
cookie → `Accept-Language` → geo suggestion → default). It cannot be a remote
service because it needs request data during SSR. This LXS is only the catalog
**store**; a thin client library reads it and formats messages.

```
frontend (SSR)                          i18n LXS
  resolve locale ──┐                      │
  GET /api/i18n/catalog/:locale/:ns ─────►│ returns {namespace}/{locale}.json
  render t(key) ◄──┘ (cache by ETag)      │
```

## Catalog format

```json
{
  "Build software for less in the AI era": "Bangun perangkat lunak dengan biaya lebih rendah di era AI"
}
```

Keys are the English source text. This keeps untranslated strings legible and
lets the catalog grow one page at a time.

## v0.1 scope

Serves a **bootstrap seed** compiled into the binary (the getecosphere namespace)
plus any `CATALOG_DIR/{namespace}/{locale}.json` override. Authoring (drafts +
publish workflow + an Assistant editor) lands in a later version; see
`../eco-server/docs/i18n-multibahasa.md` for the platform design.
