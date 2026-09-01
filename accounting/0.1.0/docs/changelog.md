# changelog

## 1.0.0 (2026-09-02)

- Initial release of the accounting LXS.
- General ledger with balanced journal entries, trial balance, P&L, balance
  sheet (with retained earnings), monthly periods with close enforcement, and
  immutable audit trail.
- SQLite storage, single functional currency (IDR integer), NDJSON stdout logs.
- Passes the frozen acceptance contract v1 (15/15 black-box tests).
