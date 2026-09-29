# notes changelog

## 0.1.0
- Initial: per-user notes (MongoDB) + self-contained macOS-Notes-style UI at
  `/notes-app`. Auth via estate JWT (HS512). Routes gated by the gateway
  (`level: auth`, cookie `eco_token`).
