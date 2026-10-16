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

## `PUT /api/i18n/catalog/:locale/:namespace` (≥ 0.2.0)

Replace one runtime catalog. Header `x-i18n-token: <I18N_WRITE_TOKEN>`; body is a flat JSON object of string → string
(English source → translation). `200 {"ok":true,"keys":N}`, `400` invalid body or id, `401` bad token, `403` writes
disabled (no `I18N_WRITE_TOKEN`). The file lands in `CATALOG_DIR/{namespace}/{locale}.json` and wins over the compiled seed.

## Notes

- Catalog overrides are files under `CATALOG_DIR/{namespace}/{locale}.json` (upload them with the `PUT` above).
- Locale negotiation is intentionally **not** server-side: it runs in the SSR
  client, which has the request's `Accept-Language`, cookie and country.
