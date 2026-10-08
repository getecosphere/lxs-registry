# referrals API

Base `/api`.

## GET /api/health
## GET /api/referrers/:code        — `{code,label,kind,claimed}`
## POST /api/attribute             — (auth) `{code?,source?,medium?,campaign?}` → attribute caller (idempotent; default RWID)
`{"code":"haryo","referrerLabel":"Haryo","source":"threads","already":false}`
UTM fields are optional and normalized to slugs (`source` = the platform, e.g.
`threads`, `facebook`); empty/unknown code falls back to the RWID code.
## POST /api/claim                 — (auth) `{code}` → claim an unclaimed code
## POST /api/affiliate             — (auth) ensure caller's personal affiliate code → `/me` payload
`{"userId":"…","affiliate":{"code":"budi","label":"@budi","kind":"affiliate","claimed":true,…},
  "attribution":{…}|null,"ownedReferrers":[…],"referrals":{"total":2,"bySource":{"threads":1,"direct":1},
  "recent":[{"name":"Ana","code":"budi","source":"threads","at":"…"}]}}`
## GET /api/me                     — (auth) my attribution + `affiliate` + owned codes + `referrals` (+ `bySource`)
## GET /api/me/stream              — (auth) SSE of my referral events, private per owner
`data: {"type":"referral","name":"Ana","code":"budi","source":"threads","at":1790786761}`
## GET /api/resolve/:user_id       — the referral code for a user (sales attribution; `default:true` when unattributed)
## Admin (superadmin)
- `GET /api/admin/referrers` — all referrers + attributed counts; each carries
  `sources` (`{source: count}`, `direct` when untagged) for per-referral ranking
- `GET /api/admin/report` — totals + by-kind + `bySource` (UTM sign-ups estate-wide)
- `POST /api/admin/seed` — `{referrers:[{code,label,kind,rate_bps,capital_idr}]}`

## POST /api/internal/affiliate  (x-referrals-token)
Ensure + return a user's personal affiliate code, for a trusted peer domain
(e.g. a reward email that embeds each member's referral link).
Body `{ "userId": "…", "username": "…" }` → `{ "userId": "…", "code": "budi" }`.
Guarded by `REFERRALS_SERVICE_TOKEN` sent as the `x-referrals-token` header;
disabled (403) when unset.
