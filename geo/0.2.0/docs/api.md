# geo API

Base path: `/api`. No auth (a location for an IP is coarse, public data).
In an estate the browser prefix is `/api/geo/*` (the gateway strips it to
`/api/*`).

## GET /api/health
Liveness. `200 {"status":"UP"}`.

## GET /api/whereami
Geo of the **calling client**, from the edge-reported IP
(`cf-connecting-ip` → first hop of `X-Forwarded-For` → `X-Real-IP`).

```json
{ "ip": "103.28.14.2", "country": "Indonesia", "region": "Daerah Istimewa Yogyakarta", "city": "Yogyakarta", "lat": -7.78, "lng": 110.36 }
```

When the IP is private/loopback or unknown:

```json
{ "ip": null, "country": null, "region": null, "city": null, "lat": null, "lng": null }
```

## GET /api/lookup?ip=<ip>
Geo of an explicit IP (same shape). `400` when `ip` is missing.

## Notes
- Results are cached in-process for 24h.
- Private/loopback/link-local IPs are never looked up (return `null`).
- With `GEO_DB` set, lookups are offline; otherwise `GEO_URL` (ip-api) is used.
