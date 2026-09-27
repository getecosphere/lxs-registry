# ekoin API

Base path `/api`. User endpoints authenticate with `Authorization: Bearer <jwt>`.
Internal endpoints authenticate with `X-Ekoin-Token`. Admin endpoints require a
superadmin JWT.

## GET /api/health
`{"status":"UP","service":"ekoin"}`

## GET /api/balance
`{"balance":50,"currency":"rwid:ekoin","tenant":"rwid"}`

## GET /api/transactions?limit=&offset=
`{"transactions":[{"id":"<uuid>","kind":"grant","ref":"claim:...","memo":"Bonus...","amount":50,"amountDelta":50,"createdAt":"..."}]}`

## GET /api/campaign
Campaign state + whether the caller already claimed.
`{"campaign":{"id":"welcome","name":"...","perUser":50,"budget":5000,"maxUsers":100,"remaining":4950,"claimed":1,"active":true},"claimedByMe":false,"myGrant":null,"balance":0,"currency":"rwid:ekoin"}`

## POST /api/claim
Auto-approving claim (no requirements). Idempotent per user.
`{"granted":true,"alreadyClaimed":false,"amount":50,"balance":50,"remaining":4950,"journalId":"..."}`
- already claimed → `{"granted":false,"alreadyClaimed":true,...}`
- budget exhausted / inactive → 409

## POST /api/topups  { "amount": <ekoin> }
Creates a **pending** invoice (simulated provider). `amount` 1..100000.
Returns the invoice:
`{"id":"<uuid>","amount":50,"rupiah":50000,"status":"pending","provider":"simulated","expiresAt":"...","paidAt":null}`

## GET /api/topups?limit=&offset=
## GET /api/topups/:id

## POST /api/topups/:id/simulate  { "outcome": "paid|cancel|fail|expire" }
Simulated Midtrans callback. On `paid`: marks the invoice paid, mints ekoin to
the user (treasury → user) and posts the company journal (Cash / Coin liability).
`{"status":"paid","balance":100,"amount":50,"journalId":"..."}`

## GET /api/catalog
`{"items":[{"itemRef":"blackbox","title":"...","amount":5,"merchantRef":"rwid-store","description":"...","coverUrl":"...","owned":false,"unlocked":false}],"currency":"rwid:ekoin"}`
- `owned` = the caller holds an inventory token for the item.
- `unlocked` = the caller has redeemed it (access credential issued).

## POST /api/purchases  { "item_ref": "blackbox" }
Charges the caller at the authoritative catalog price, records an entitlement
and an **inventory token** (`HELD`), and moves ekoin user → merchant. 409 when
the balance is insufficient or the item is already owned.
`{"ok":true,"itemRef":"blackbox","amount":5,"balance":95,"journalId":"..."}`

## GET /api/tokens
The caller's inventory tokens.
`{"tokens":[{"id":"<uuid>","itemRef":"blackbox","status":"HELD","source":"purchase","acquiredAt":"...","redeemedAt":null}]}`

## POST /api/redeem  { "item_ref": "blackbox" }
Consumes a held token and issues a non-transferable **access credential** that
unlocks the product (generic; first use is EcoBook).
`{"ok":true,"alreadyUnlocked":false,"itemRef":"blackbox","tokenId":"<uuid>"}`
- not owned → 403; nothing to redeem → 409; already unlocked → `alreadyUnlocked: true`.

## POST /api/internal/charge  (X-Ekoin-Token)
Body `{"merchant":"rwid-store","userId":"...","amount":5,"itemRef":"...","idempotencyKey":"..."}`.
Seller is derived from `merchant`, never from the client.

## POST /api/internal/grant  (X-Ekoin-Token)
Body `{"userId":"...","amount":100,"reason":"...","idempotencyKey":"..."}`.

## GET /api/internal/balance?userId=...  (X-Ekoin-Token)
Reads any user's wallet balance for a trusted peer domain (metering pre-flight).
`{"userId":"...","balance":95,"currency":"eco:ai","tenant":"getecosphere"}`

## Admin (superadmin JWT)
- `GET /api/admin/summary` → `{revenueRupiah, coinsSold, coinsSpent, coinsGranted, coinsOutstanding, invoicesPending, walletUsers, rateRupiah, tenant, currency}`
- `GET /api/admin/accounts` → all accounts with balances
- `GET /api/admin/ledger?limit=&offset=` → journal entries with postings
- `GET /api/admin/invoices?limit=&offset=` → all invoices
- `GET /api/admin/accounting/trial-balance`
- `GET /api/admin/accounting/pnl?from=&to=`
- `GET /api/admin/accounting/balance-sheet`
- `GET /api/admin/accounting/accounts` / `GET /api/admin/accounting/ledger/:code`

## Journal kinds
`grant` (promo/claim), `topup` (Rupiah → ekoin), `purchase` (ekoin spent).

## Company journal mapping (accounting LXS)
- top-up: **D** 1010 Kas / **C** 2050 Koin Beredar
- claim/reward: **D** 5010 Beban Promo / **C** 2050 Koin Beredar
- purchase: **D** 2050 Koin Beredar / **C** 4010 Pendapatan Penjualan
