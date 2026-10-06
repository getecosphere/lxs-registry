# goldback-dcs-core

Core engine of the **Goldback DCS** protocol with its first economic profile
**DCSI**: investors acquire future product inventory through a **salam**
(advance purchase at a volume-tiered price); each unit sits in a **FIFO queue**;
when an end customer buys, units are consumed front-to-back, **HPP** (production
cost) is withheld by RWID, and the remaining **realized profit** is split
(50% RWID / 50% investor by default).

- **Profit is only realized on a verified end-customer sale.** No return from
  new-investor money; no guaranteed principal. The margin is **shared** — a loss
  is borne by both parties, not the investor alone.
- **Per-unit, auditable waterfall** — a **muḍārabah on the unit's margin**: the
  investor's `principal` (the salam price) is their cost basis, and
  `margin = retail − principal` is split — investor gets
  `principal + (1−pct)·margin`, the operator gets `pct·margin` (its *sales-side*
  share). Both always sum to `retail`. `HPP` is the internal cost the financed
  capital is spent on (must be ≤ `principal`); it is **not** subtracted a second
  time. The operator's *total* economics also include the manufacturing margin
  `principal − HPP`, reported separately so nothing is hidden.
- **No double-charging.** (0.4.0) The previous `profit = retail − HPP −
  principal` subtracted both the principal *and* the cost it financed, which
  pushed the investor's share of the real margin far below 50%; it is replaced
  by the margin-sharing model above.

## Configuration

| Env | Default | Notes |
|---|---|---|
| `SERVER_PORT` | — | managed port |
| `DATABASE_URL` | — | PostgreSQL |
| `JWT_SECRET` | — | verifies estate user tokens |
| `DCS_TENANT` | `rwid` | economy namespace |
| `DCS_RWID_SHARE_PCT` | `50` | RWID profit share |
| `DCS_INTERNAL_TOKEN` | — | enables `/api/sales` |
| `DCS_DEFAULT_HPP_UNIT` | `150` | seed HPP for `ecobook` |
| `DCS_DEFAULT_RETAIL_UNIT` | `1000` | seed retail for `ecobook` |

The first product `ecobook` and its tiers (800 / 750 / 700 per unit at
1 / 5.000 / 25.000 units) are seeded idempotently at startup.

## Tests

- Unit: `cargo test` (pure engine: waterfall balance, negative profit, tiers).
- Integration: `python3 tests/integration/run_dcs_integration.py` (one-shot
  local PostgreSQL; salam → sale → FIFO + HPP + 50/50 → reports).
