# notes

macOS-Notes-style per-user notes for the RWID OS. One binary, MongoDB-backed,
with a self-contained UI — no separate frontend to host.

- Per-user notes (list / create / update / delete), stored in MongoDB.
- **Checklist** items and **pasted images** per note. Images live in the
  estate's storage LXS under the user's key (namespace `notes`), with a
  per-user quota: free 10 MB, paid 1 GB (`plan` claim from auth), warning at
  80% and clear upgrade prompt at the limit.
- Auth: validates the estate JWT (HS512) issued by `auth`; routes are gated by
  the estate gateway (`level: auth`, cookie `eco_token`).
- Serves its own UI at `/notes-app` (a two-pane Notes app: sidebar + editor,
  autosave).

## Compose

```yaml
services:
  notes-backend:
    lxs: notes@0.1.0
    port: 4301
    grants: { secrets: [JWT_SECRET, MONGODB_URI] }
    access:
      routes:
        - { path: /notes-app, level: auth, cookie: eco_token }
        - { path: /notes-app/*, level: auth, cookie: eco_token }
        - { path: /api/notes, level: auth, cookie: eco_token }
        - { path: /api/notes/*, level: auth, cookie: eco_token }
```

## Env

| Var | Role |
|---|---|
| `SERVER_PORT` | listen port (managed) |
| `MONGODB_URI` | Mongo connection (secret) |
| `JWT_SECRET` | shared estate secret to validate tokens (secret) |
