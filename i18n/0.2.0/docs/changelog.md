# Changelog

## 0.2.0

- **Estates can upload their own catalogs.** `PUT /api/i18n/catalog/:locale/:namespace` (header `x-i18n-token`,
  body = flat JSON object of strings) writes `CATALOG_DIR/{namespace}/{locale}.json` atomically. A new namespace no longer
  needs a change to this crate. Disabled unless `I18N_WRITE_TOKEN` is set; namespace and locale are limited to
  `[A-Za-z0-9_-]{1,32}`; bodies over 1 MB are rejected.
- New contract fields `CATALOG_DIR` (set it to a persistent path in production) and `I18N_WRITE_TOKEN` (secret).

## 0.1.3

- Add Arabic (`ar`) catalog to the getecosphere bootstrap namespace. Locale
  direction (LTR/RTL) is a client concern; catalogs carry text only.

## 0.1.2

- Add German (`de`) and French (`fr`) catalogs to the getecosphere bootstrap
  namespace (205 keys each).

## 0.1.1

- Refresh the getecosphere bootstrap catalog (en/id/ms): pricing, privacy and
  AI-credits pages added — 201 id / 202 ms keys.

## 0.1.0

- First release. Serves versioned message catalogs over HTTP:
  `GET /api/i18n/health`, `GET /api/i18n/locales`,
  `GET /api/i18n/catalog/:locale/:namespace`.
- Catalogs are keyed by the English source string; missing keys fall back to the
  source, so partial translations are safe.
- `ETag` + `Cache-Control` on catalogs; NDJSON logging per the platform contract.
- Bootstrap seed compiled in for the `getecosphere` namespace; a runtime
  `CATALOG_DIR/{namespace}/{locale}.json` overrides the seed.
