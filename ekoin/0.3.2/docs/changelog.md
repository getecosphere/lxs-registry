# ekoin changelog

## 0.3.2
- **Internal balance read.** `GET /api/internal/balance?userId=...` (service
  token) lets a trusted peer domain (e.g. a metering AI gateway) pre-flight a
  user's balance before doing billable work. `POST /api/internal/charge` already
  refuses to overdraw (`409 insufficient balance`), so this closes the loop for
  post-paid metering with an atomic auto-cutoff.

## 0.3.1
- `DCS_INTERNAL_TOKEN` is now a configurable string (was secret) so it can be
  shared with the DCS core via ecompose `config` for the internal sale hook.

## 0.3.0
- **DCSI integration hook.** When `DCS_SALES_URL` is configured, a paid top-up
  (the end-customer ekoin sale) posts `POST {DCS_SALES_URL}/api/sales` so the
  Goldback DCS core consumes inventoried units (FIFO) and distributes realized
  profit. Best-effort: ekoin works unchanged when DCS is not configured.

## 0.2.0
- **Inventory tokens + redemption.** `POST /api/purchases` now mints an
  **inventory token** (`tokens`, status `HELD`) alongside ownership. New
  `POST /api/redeem { item_ref }` consumes a held token and issues a
  non-transferable **access credential** (`access_credentials`) that unlocks the
  product (e.g. an EcoBook). `GET /api/tokens` lists the caller's tokens. The
  catalog now reports `owned` (ownership) and `unlocked` (credential issued)
  separately, so a product can be owned but not yet opened. Generic: works for
  any catalog item.

## 0.1.0
- Initial release. Double-entry coin ledger (accounts / journal / postings,
  balance = SUM of postings), atomic idempotent campaign claim, top-up invoices
  with a simulated payment provider (paid / cancel / fail / expire), catalog +
  purchase (user → merchant), internal service-token endpoints, superadmin
  reports (revenue, coins outstanding, journal, invoices) and an accounting
  proxy. Posts the company journal to the `accounting` LXS on top-up, claim and
  purchase.
