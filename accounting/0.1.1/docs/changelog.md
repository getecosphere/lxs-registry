# changelog

## 1.0.0 (2026-09-02)

- Initial release of the accounting LXS.
- General ledger with balanced journal entries, trial balance, P&L, balance
  sheet (with retained earnings), monthly periods with close enforcement, and
  immutable audit trail.
- SQLite storage, single functional currency (IDR integer), NDJSON stdout logs.
- Passes the frozen acceptance contract v1 (15/15 black-box tests).

## 0.2.0 (2026-09-05)

- Honour `DATA_DIR` for the SQLite ledger path. Previously the database was
  hardcoded to `ledger.db` in the process working directory, so two estates
  launched from the same directory shared one ledger (a placement bug, §7.3).
  With `DATA_DIR` set, each estate keeps an isolated ledger and can share a
  working directory safely.
