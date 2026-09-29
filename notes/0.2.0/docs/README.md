# notes

macOS-Notes-style per-user notes for the RWID OS. One binary, MongoDB-backed,
with a self-contained UI — no separate frontend to host.

- Per-user notes (list / create / update / delete), stored in MongoDB.
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
