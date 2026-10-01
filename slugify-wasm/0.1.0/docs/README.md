# slugify-wasm

A demonstration LXS whose domain logic is a **Wasm component**. The shipped
artifact is a single native executable that embeds the wasmtime runtime and the
`lxs:slugify` component, so it runs behind the OS boundary like any other LXS;
the domain logic executes inside the Wasm component.

- `GET /health` -> `ok`
- `GET /api/slugify?text=...` -> `{"slug":"..."}`

## Build

```
cd component && cargo component build --release   # -> target/wasm32-wasip1/release/component.wasm
cp component/target/wasm32-wasip1/release/component.wasm host/component.wasm
cd host && cargo zigbuild --release --target x86_64-unknown-linux-musl
```
