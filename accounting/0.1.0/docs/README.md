# accounting — LXS docs

## Capability

General-ledger bookkeeping for expense/income tracking and payment recording.
Posts balanced journal entries to a local SQLite ledger, produces a trial
balance, profit-and-loss, and balance sheet, manages monthly accounting
periods, and keeps an immutable audit trail. Single functional currency (IDR,
integer rupiah).

## Quick usage

```bash
SERVER_PORT=9090 ./accounting

curl -s http://127.0.0.1:9090/api/health        # {"status":"UP"}
curl -s -X POST http://127.0.0.1:9090/api/accounts \
  -H 'Content-Type: application/json' \
  -d '{"code":"1000","name":"Kas","type":"asset"}'
curl -s -X POST http://127.0.0.1:9090/api/journal \
  -H 'Content-Type: application/json' \
  -d '{"ref":"INV-001","date":"2026-09-01","lines":[
        {"account":"1000","debit":1000000,"memo":"kas"},
        {"account":"4000","credit":1000000,"memo":"pendapatan"}]}'
```

## API

Base path `/api`. All endpoints return JSON and echo `X-Request-Id`.

| Endpoint | Method | Behavior |
|---|---|---|
| `/api/health` | GET | liveness |
| `/api/accounts` | GET/POST | list / create account `{code,name,type}`; duplicate code → 4xx |
| `/api/journal` | POST | balanced entry `{ref,date,lines}`; unbalanced → 422; duplicate ref → 409 |
| `/api/journal/:ref` | GET | entry by external ref |
| `/api/ledger/:account` | GET | postings + running balance |
| `/api/trial-balance` | GET | per-account debit/credit totals + balanced flag |
| `/api/pnl?from&to` | GET | income, expense, net |
| `/api/balance-sheet` | GET | assets, liabilities, equity (incl. retained earnings), balanced |
| `/api/periods` | GET | monthly periods `{id,label,open,close}` |
| `/api/periods/:id/close` | POST | close a period; posting into it later → 4xx |
| `/api/audit/:ref` | GET | immutable journal line trail with created_by |

Account types: `asset`, `liability`, `equity`, `income`, `expense`.

## Behavioral rules

- Entries must balance (debits == credits); unbalanced posts are rejected.
- Posting is idempotent by external `ref` (409 on duplicate).
- Posting into a closed period is rejected.
- Retained earnings (income − expense) are folded into equity so the balance
  sheet balances.
- The audit trail is append-only and never mutated.
- Logs are NDJSON to stdout: `{"ts","level","msg",...}`.

## Compose

```yaml
services:
  accounting-backend:
    lxs: accounting@1.0.0
    port: 9090
```

The service is stateless across restarts only if `DATA_DIR` is a persistent
volume; it writes `ledger.db` there.
