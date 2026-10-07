# geo changelog

## 0.2.0
- `/api/whereami` and `/api/lookup` now also return **`region`** (province/state)
  — from the MaxMind DB `subdivisions` or ip-api `regionName`. Existing fields
  are unchanged (additive).

## 0.1.1 (2026-09-30)
- Declare `API_BASE_PATH: /api` in the contract so peers (auth) resolve the
  direct-call base as `/api` rather than the default `/api/geo`.

## 0.1.0 (2026-09-30)
- Initial release: reusable **IP → location** capability.
  `GET /api/lookup?ip=` (explicit IP) and `GET /api/whereami` (the caller's IP
  from `cf-connecting-ip` / `X-Forwarded-For` / `X-Real-IP`) return
  `{ip, country, city, lat, lng}`. Offline MaxMind-DB via `GEO_DB`, HTTP
  fallback via `GEO_URL` (default `ip-api.com`); 24h in-process cache;
  private/loopback IPs return `null`.
