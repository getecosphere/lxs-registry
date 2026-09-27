# ekoin

**ekoin** is the intrinsic currency wallet for a composition economy. One
instance serves one **economy (tenant)**: it owns the double-entry coin ledger,
per-user balances, campaign claims, top-up invoices and purchases — and posts
the corresponding company journal entries to the `accounting` LXS so revenue,
liability and P&L stay complete.

- **Ledger, not a balance column.** Balance is `SUM(postings.amount_delta)`; the
  journal is append-only and every entry balances to zero.
- **Mint only from treasury.** Top-ups, claims and rewards debit the system
  `treasury` account (which may go negative — it represents coins outstanding).
- **Idempotent by key.** Every mutation carries a unique `idempotency_key`
  (`(tenant, idempotency_key)` unique), so retries never double-spend.
- **Prices live server-side.** Clients send an `item_ref`; ekoin looks up the
  authoritative price in its catalog.

## Currency

`Rupiah to ekoin` is a fixed rate (`EKOIN_RATE_RUPIAH`, default 1000 →
Rp 1.000 = 1 ekoin). Amounts are integer `BIGINT`; 1 ekoin is the smallest unit.

## Configuration

| Env | Default | Notes |
|---|---|---|
| `SERVER_PORT` | — | managed port |
| `DATABASE_URL` | — | PostgreSQL (ledger) |
| `JWT_SECRET` | — | verifies estate user tokens |
| `EKOIN_TENANT` | `rwid` | economy namespace |
| `EKOIN_CURRENCY` | `<tenant>:ekoin` | display code |
| `EKOIN_RATE_RUPIAH` | `1000` | Rupiah per ekoin |
| `EKOIN_CAMPAIGN_NAME` | `welcome` | claim campaign id |
| `EKOIN_CAMPAIGN_PER_USER` | `50` | ekoin per claim |
| `EKOIN_CAMPAIGN_BUDGET` | `5000` | total budget |
| `EKOIN_CAMPAIGN_MAX_USERS` | `100` | max claims |
| `EKOIN_SERVICE_TOKEN` | — | enables `/api/internal/*` |
| `ACCOUNTING_BASE_URL` | — | company journal target |
| `ACCOUNTING_TOKEN` | — | optional bearer |

## Internal metering (service token)

With `EKOIN_SERVICE_TOKEN` set, a trusted peer domain can read any user's balance
(`GET /api/internal/balance?userId=`), grant credits, and charge a user
(`POST /api/internal/charge`, which refuses to overdraw with `409`). This is the
primitive a metered product (e.g. an AI gateway) uses to bill usage and cut off
automatically at zero. See `eco-server/docs/ai-token-gateway.md`.

## Quick start

```bash
SERVER_PORT=8080 JWT_SECRET=... DATABASE_URL=postgres://... cargo run
```

See `docs/api.md` for the REST surface.
