# notes API

Auth: every endpoint expects `Authorization: Bearer <eco_session token>`. The
token's opaque **`plan`** claim (issued by `auth`) selects the image quota —
`free` (or empty) = 10 MB, `paid`/`pro`/`premium`/`member` = 1 GB.

A note object:
```json
{
  "id": "…",
  "title": "…",
  "body": "…",
  "items":  [ { "id": "…", "text": "…", "done": false } ],
  "images": [ { "key": "notes/<note-id>/<uuid>.webp", "name": "foto.png", "size": 12345 } ],
  "created_at": 0,
  "updated_at": 0
}
```

## GET /api/notes
List the caller's notes, newest-updated first (max 300).
```json
{ "notes": [ { "id": "…", "title": "…", "body": "…", "items": [], "images": [], "created_at": 0, "updated_at": 0 } ] }
```

## POST /api/notes
Body `{ "title": "", "body": "", "items": [] }` (`items` optional) → creates
and returns the note object.

## PUT /api/notes/{id}
Body `{ "title": "", "body": "", "items": [] }` → updates (only the caller's
note). `items` is replaced when present. `{ "ok": true }`.

## DELETE /api/notes/{id}
Deletes the note (only the caller's). Image **blobs are not removed here** —
the caller deletes those from storage (see below). `{ "ok": true }`.

## GET /api/notes/quota
Current image usage vs the plan limit — powers the UI quota bar.
```json
{ "plan": "free", "paid": false, "used": 68, "limit": 10485760, "warn": 8388608 }
```

## POST /api/notes/{id}/images
Attach an already-uploaded storage object to a note and account for it.
Body `{ "key": "notes/<id>/<uuid>.webp", "name": "foto.png", "size": 12345 }`.
The bytes are uploaded **by the browser directly to the storage LXS** (owner =
the user, namespace `notes`, reference = the note id); this endpoint is the
authoritative quota check and records the reference.
- **200** `{ "ok": true, "used": 68, "limit": 10485760 }`
- **413** `{ "error": "quota_exceeded", "message": "…", "used": …, "limit": …, "plan": … }` — the caller must delete the just-uploaded blob.
- **404** `{ "error": "note not found" }`

## DELETE /api/notes/{id}/images
Detach an image from a note. Body `{ "key": "…" }`. The caller then deletes the
storage object. `{ "ok": true }`.

## GET /notes-app
The Notes UI (HTML). Paste an image (Ctrl/Cmd+V) to insert it.

## GET /api/health
`{ "status": "ok", "service": "notes" }`.

## Storage interaction (browser side)
The UI uploads/deletes through the estate gateway, which already exposes the
storage LXS:
- `POST /api/storage/objects` (multipart: `file`, `owner_id`, `namespace=notes`, `reference_id=<note id>`)
- `DELETE /api/storage/objects/{key}?owner_id=<user id>`
- render: `<img src="/api/storage/content/{key}">` (public route)
