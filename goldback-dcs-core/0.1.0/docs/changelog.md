# goldback-dcs-core changelog

## 0.5.0
- **The sale path now actually runs the documented waterfall.** `post_sale`
  previously ignored `split_unit` and split the **retail** 50/50 under a "cap"
  (`capital × (1+rate)`, i.e. a target return), writing `principal = 0` and
  `hpp = rwid_cut` (both mislabeled). It now calls
  `split_unit(retail, hpp, principal, rwid_pct)` — a **mudārabah on the unit's
  margin** (`margin = retail − principal`), **no cap and no target return**, with
  a negative margin shared by both parties. `distributions` now stores the true
  `principal`, `hpp`, `profit` (= margin), `investor_share`, `rwid_share`, so the
  public summary reconciles with the paper's §4 formula. `/api/me` drops the
  obsolete `capEcoin` / `remainingCapEcoin`.

## 0.4.2
- **`principal = HPP` (no hidden spread).** The salam price now equals the
  product's HPP, so the investor finances exactly the per-sale cost and the
  operator's product margin (`principal − HPP`) is **zero** — the operator earns
  only its share of the sale margin. `ecobook` HPP is set to a real per-sale
  content/token cost (default **Rp20,000**, ≈US$1); retail default Rp25,000.
  The seed is now upsert (config changes apply) and the price tiers are flat
  (= HPP). Historical orders/distributions keep their recorded values.

## 0.4.1
- **Clearer public `/api/public/summary`.** Report `realized.{investorShare,
  rwidShare, margin}` (margin = the two shares summed) instead of the confusing
  `profit`; add `salamCurrency: "IDR"` and `historicalCurrency: "Ekoin"` so the
  mixed units are explicit; and include per-product `hppUnit` / `retailUnit` so a
  reader can check the operator's spread (`principal − HPP`) instead of it being
  hidden.

## 0.4.0
- **Fair margin-sharing waterfall (breaking).** `split_unit` now treats the
  investor's `principal` (salam price) as the cost basis and shares the
  **margin** `retail − principal`: investor = `principal + (1−pct)·margin`,
  operator = `pct·margin`. The old `profit = retail − HPP − principal`
  subtracted both the principal and the cost it financed, so the investor's
  share of the real margin was always far below 50%; a loss is now shared by
  **both** parties. `hpp` is retained for reporting as the operator's internal
  cost (≤ principal) and is no longer double-counted. Seed/`DCS_DEFAULT_HPP_UNIT`
  should equal the financed per-unit cost.

## 0.3.1
- **Exit (sell inventory at cost)** + **referral lanes** on sales, on top of the
  0.3.0 sale-notification webhook. See 0.2.4 notes for detail.

## 0.3.0
- **Sale notification (opt-in).** Set `DCS_SALE_NOTIFY_URL` (e.g. the estate's
  telegram LXS `/api/telegram/send`) and each recorded sale POSTs
  `{"key","text"}` there, with the key from `DCS_SALE_NOTIFY_KEY` (default
  `sales`). Best-effort and fire-and-forget: a notify failure never blocks or
  fails the sale. Unset = no behaviour change.

## 0.2.3
- Historical summary adds `remainingCapitalEcoin` = sum over positions of
  `max(0, capital - realized)` (only capital NOT yet returned; completed
  positions contribute 0, no cross-position netting) and
  `obligationRemainingEcoin` = that remaining x (1 + per-position rate).

## 0.2.2
- Historical import now stores the **per-position profit rate** (`profit_rate_raw`
  -> bps). Reconcile and `/api/global` expose `obligationEcoin` = sum of
  `capital x (1 + per-position rate)` — accumulated per position, **no global
  rate assumption**.

## 0.2.1
- `GET /api/admin/historical` (superadmin) lists every imported historical
  position; `/api/global` now includes a `historical` summary block.

## 0.2.0
- **NEW revenue-share-until-cap model.** Each sale is split RWID/investor (50/50
  by default); the holder's half accumulates until `cap = capital x (1 + rate)`,
  after which 100% goes to RWID. `HPP == RWID's share` (not deducted first).
  Realized-only, no guarantee. `profit_rate_bps` on salam orders (default 50%).
- **Historical (legacy) import** from the pre-ecoin DCSI spreadsheet:
  `POST /api/admin/import/historical` + `GET /api/admin/historical/reconcile` +
  `GET /api/me/history` (money -> ekoin at the locked rate; old rule preserved,
  no HPP).
- Seed economics updated: retail 2.500 ekoin/unit, salam tiers 1.900/1.800/1.700.

## 0.1.2
- **Generic products.** `POST /api/admin/products` registers/updates any product
  and its price tiers, so DCSI is not hardcoded to EcoBook. Integration test now
  covers a second product end-to-end.

## 0.1.1
- `DCS_INTERNAL_TOKEN` is now a configurable string (was secret) so it can be
  shared with ekoin via ecompose `config`.

## 0.1.0
- Initial release: salam acquisition with volume price tiers, FIFO inventory-unit
  queue, per-unit HPP withholding, 50/50 realized-profit waterfall, investor and
  global reports, admin listings, and a service/admin sale endpoint. Includes
  unit tests and a one-shot local integration test.
