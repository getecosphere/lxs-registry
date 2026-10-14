# notes API

Auth: every endpoint expects `Authorization: Bearer <eco_session token>`. The
token's opaque **`plan`** claim (issued by `auth`) selects the storage quota —
`free` (or empty) = 10 MB, `paid`/`pro`/`premium`/`member` = 1 GB.

## Content model

A note's `content` is an ordered array of **blocks** that mix freely:

```json
[
  { "type": "text",  "text": "Agenda:" },
  { "type": "check", "id": "ab12", "text": "Belajar", "done": false },
  { "type": "image", "key": "notes/<note-id>/<uuid>.webp", "name": "foto.png", "size": 12345 },
  { "type": "file",  "key": "notes/<note-id>/<uuid>.pdf",  "name": "dokumen.pdf", "size": 45000 },
  { "type": "audio", "key": "notes/<note-id>/<uuid>.webm", "name": "rekaman.webm", "size": 67890 },
  { "type": "link",  "url": "https://example.com/ref", "text": "Referensi" }
]
```

`image` / `file` / `audio` reference a storage object (the browser uploads the
bytes to the storage LXS under namespace `notes`; the block records the key) and
count against the plan quota. `link` is inline data — it never counts.

## Deep link
`GET /notes-app?note=<id>` opens that note (falls back to the newest note when
the id is missing or unknown).

A note object:
```json
{ "id": "…", "title": "…", "content": [ … ], "created_at": 0, "updated_at": 0 }
```

## GET /api/notes
List the caller's notes, newest-updated first (max 300).
```json
{ "notes": [ { "id": "…", "title": "…", "content": [], "created_at": 0, "updated_at": 0 } ] }
```

## POST /api/notes
Body `{ "title": "", "content": [ … ] }` (`content` optional → one empty text
block) → creates and returns the note object.

## PUT /api/notes/{id}
Body `{ "title": "", "content": [ … ] }` → replaces title and (when present)
content (only the caller's note). `{ "ok": true }`.

## DELETE /api/notes/{id}
Deletes the note (only the caller's). **Storage blobs are not removed here** —
the caller deletes those (see below). `{ "ok": true }`.

## GET /api/notes/quota
Image/file usage vs the plan limit (summed across the caller's note blocks).
```json
{ "plan": "free", "paid": false, "used": 68, "limit": 10485760, "warn": 8388608 }
```

## POST /api/notes/{id}/images
Append an already-uploaded storage object as a block and account for it.
Body `{ "key": "…", "name": "foto.png", "size": 12345, "type": "image"|"file" }`
(`type` defaults to `image`). The bytes are uploaded **by the browser directly
to the storage LXS** (owner = the user, namespace `notes`, reference = the note
id); this endpoint is the authoritative quota check and records the block.
- **200** `{ "ok": true, "used": 68, "limit": 10485760 }`
- **413** `{ "error": "quota_exceeded", "message": "…", "used": …, "limit": …, "plan": … }` — the caller must delete the just-uploaded blob.
- **404** `{ "error": "note not found" }`

## DELETE /api/notes/{id}/images
Remove any block referencing a storage key. Body `{ "key": "…" }`. The caller
then deletes the storage object. `{ "ok": true }`.

## GET /notes-app
The Notes UI (HTML). A floating toolbar inserts a checklist item or attaches a
file; paste (Ctrl/Cmd+V) inserts an image; the footer shows the storage quota.

## GET /api/health
`{ "status": "ok", "service": "notes" }`.

## Storage interaction (browser side)
The UI uploads/deletes through the estate gateway, which already exposes the
storage LXS:
- `POST /api/storage/objects` (multipart: `file`, `owner_id`, `namespace=notes`, `reference_id=<note id>`)
- `DELETE /api/storage/objects/{key}?owner_id=<user id>`
- render: `<img src="/api/storage/content/{key}">` / link (public route)

## Legacy
Notes created before 0.5.0 (`body`, `items[]`, `images[]`) are migrated to
`content` blocks once, at service start.
