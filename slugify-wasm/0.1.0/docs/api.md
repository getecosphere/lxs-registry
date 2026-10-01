# slugify-wasm API

## GET /health
Returns `ok`.

## GET /api/slugify?text=<text>
Returns `{"slug": "<lowercase-dash-joined>"}`. Non-ASCII-alphanumeric runs
collapse to a single dash; leading/trailing dashes are dropped.
