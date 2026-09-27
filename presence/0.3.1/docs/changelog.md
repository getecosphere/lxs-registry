# presence changelog

## 0.3.1 (2026-09-27)
- **No-signup offline geo path.** `scripts/fetch-geo-db.sh` downloads a free
  DB-IP Lite ip→city `.mmdb` (no account; MaxMind-DB format, same reader).
  GeoLite2 remains a drop-in alternative (free MaxMind signup + license key).
- Contract: expose `PRESENCE_GEO_DB`, `PRESENCE_GEO_URL`, `PRESENCE_DATA_DIR`
  as config fields, and route `/api/presence/replay`.

## 0.3.0 (2026-09-27)
- **Offline GeoLite2 geo.** If `PRESENCE_GEO_DB` points to a MaxMind
  GeoLite2-City `.mmdb`, IP→city is resolved locally (no external call);
  otherwise it falls back to `PRESENCE_GEO_URL` (default `ip-api.com`).
- **Daily replay.** Every pulse is appended to
  `<PRESENCE_DATA_DIR>/<UTC-date>.ndjson`; `GET /api/replay` returns today's
  pulses so the globe can run a time-lapse on first paint.

## 0.2.0 (2026-09-27)
- **IP → city fallback.** When a pulse arrives without coords (geolocation
  declined), the city/country/coords are resolved from the client IP (first
  `X-Forwarded-For` hop, else `X-Real-IP`) via a geo lookup
  (`PRESENCE_GEO_URL`, default `ip-api.com`), cached for 24h. Private/loopback
  addresses are skipped. This fills the "location decline" case.

## 0.1.0 (2026-09-27)
- Initial release: realtime fan-out hub for the Living Globe. `POST /api/event`
  records a first-name-only pulse with city/coords; `GET /api/stream` streams
  them over SSE; `GET /api/stats` exposes counters (`signups`, `signins`,
  `online`, `total`, `latest`).
