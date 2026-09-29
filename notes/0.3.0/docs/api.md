# notes API

Auth: every endpoint expects `Authorization: Bearer <eco_session token>`.

## GET /api/notes
List the caller's notes, newest-updated first (max 300).
```json
{ "notes": [ { "id": "…", "title": "…", "body": "…", "created_at": 0, "updated_at": 0 } ] }
```

## POST /api/notes
Body `{ "title": "", "body": "" }` → creates and returns the note object.

## PUT /api/notes/{id}
Body `{ "title": "", "body": "" }` → updates (only the caller's note).
`{ "ok": true }`.

## DELETE /api/notes/{id}
Deletes (only the caller's note). `{ "ok": true }`.

## GET /notes-app
The Notes UI (HTML).

## GET /api/health
`{ "status": "ok", "service": "notes" }`.
