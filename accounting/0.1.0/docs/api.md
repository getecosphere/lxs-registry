# api

Base path `/api`. All responses are JSON; every response echoes the
`X-Request-Id` request header.

## GET /api/health

```json
{"status":"UP"}
```

## GET /api/accounts

```json
{"accounts":[{"code":"1000","name":"Kas","type":"asset"}]}
```

## POST /api/accounts

Body `{"code":"1000","name":"Kas","type":"asset"}`.
Duplicate code → 409. Unknown type → 422.

## POST /api/journal

Body:
```json
{
  "ref": "INV-001",
  "date": "2026-09-01",
  "lines": [
    {"account":"1000","debit":1000000,"memo":"kas"},
    {"account":"4000","credit":1000000,"memo":"pendapatan"}
  ]
}
```
- unbalanced (debits != credits) → 422, nothing persisted;
- duplicate `ref` → 409;
- unknown account → 4xx, nothing persisted;
- posting into a closed period → 409;
- success 201 with the entry including generated line ids.

## GET /api/journal/:ref

```json
{"ref":"INV-001","date":"2026-09-01","created_at":"...","created_by":"api",
 "lines":[{"id":1,"account":"1000","debit":1000000,"credit":0,"memo":"kas","created_at":"..."}]}
```
404 when absent.

## GET /api/ledger/:account

```json
{"account":"1000","postings":[{"id":1,"ref":"INV-001","date":"2026-09-01",
  "debit":1000000,"credit":0,"balance":1000000}]}
```
Running balance is the account's net position after each posting.

## GET /api/trial-balance

```json
{"accounts":[{"code":"1000","debit_total":1000000,"credit_total":250000,
  "balance":750000}],"balanced":true}
```

## GET /api/pnl?from=2026-09-01&to=2026-09-30

```json
{"income":1000000,"expense":250000,"net":750000}
```

## GET /api/balance-sheet

```json
{"assets":750000,"liabilities":0,"equity":750000,"balanced":true}
```
Equity includes retained earnings (income − expense).

## GET /api/periods

```json
{"periods":[{"id":"2026-09","label":"September 2026","open":true,"close":false}]}
```

## POST /api/periods/:id/close

```json
{"id":"2026-09","open":false,"close":true}
```
Closing an already-closed period → 409.

## GET /api/audit/:ref

```json
{"ref":"INV-001","date":"2026-09-01","created_at":"...","created_by":"api",
 "lines":[{"id":1,"account":"1000","debit":1000000,"credit":0,"memo":"kas",
   "created_by":"api","created_at":"..."}]}
```
