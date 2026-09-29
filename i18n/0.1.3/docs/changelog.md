# Changelog

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
