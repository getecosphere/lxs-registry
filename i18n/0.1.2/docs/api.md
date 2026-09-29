# i18n API

Base path: `/api/i18n`.

## `GET /api/i18n/health`

`200 ok` — liveness probe.

## `GET /api/i18n/locales`

```json
{ "default": "en", "locales": ["en", "id", "ms"] }
```

From `DEFAULT_LOCALE` and `LOCALES`.

## `GET /api/i18n/catalog/:locale/:namespace`

Returns the catalog JSON for the namespace + locale.

- `200` — `application/json; charset=utf-8`, with `ETag` and
  `Cache-Control: public, max-age=300`.
- `404` — unknown namespace or locale.

```json
{
  "Pricing": "Harga",
  "Build software for less in the AI era": "Bangun perangkat lunak dengan biaya lebih rendah di era AI"
}
```

Clients cache by `ETag`; a changed catalog yields a new `ETag` (derived from the
body), so revalidation is cheap.

## Notes

- The service is read-only in v0.1. Catalog overrides are files under
  `CATALOG_DIR/{namespace}/{locale}.json`.
- Locale negotiation is intentionally **not** server-side: it runs in the SSR
  client, which has the request's `Accept-Language`, cookie and country.
