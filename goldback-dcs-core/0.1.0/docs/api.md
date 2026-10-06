# Goldback DCS API

Base path `/api`. User endpoints use `Authorization: Bearer <jwt>`; the sale
endpoint uses `X-Dcs-Token` (service) or a superadmin JWT.

## GET /api/health
## GET /api/products
`{"products":[{"productRef":"ecobook","name":"RWID EcoBook","kind":"ecobook","hppUnit":150,"retailUnit":1000}]}`

## GET /api/products/:product_ref/tiers
`{"productRef":"ecobook","tiers":[{"minUnits":1,"unitPrice":800},{"minUnits":5000,"unitPrice":750},{"minUnits":25000,"unitPrice":700}]}`

## POST /api/salam  { "product_ref": "ecobook", "units": 100 }
Investor advance-purchase. Unit price is chosen from the best tier <= units.
`201 {"orderId":"...","productRef":"ecobook","units":100,"unitPrice":800,"totalPaid":80000}`

## POST /api/sales  (X-Dcs-Token or superadmin)
`{ "product_ref": "ecobook", "units": 120, "buyer_ref": "end-customer", "source_ref": "topup:..." }`
Matches units FIFO, withholds HPP, distributes realized profit.
`{"saleId":"...","matched":120,"requested":120,"grossPerUnit":1000,"totals":{"principal":96000,"hpp":18000,"profit":24000,"investorShare":108000,"rwidShare":12000}}`
(the sale-side owner is the `source_ref`/referral lane, not the buyer; `profit`
is the margin `retail − principal`, split by `rwid_pct`.)

## GET /api/me   (investor report)
`{"investorId":"...","unitsBought":100,"unitsQueued":0,"unitsSold":100,"principalPaid":80000,"realized":{"principal":80000,"hpp":15000,"profit":5000,"investorShare":82500,"rwidShare":17500,"gain":2500,"roiPct":3.13},"queueAhead":0}`

## GET /api/global   (global report)
`{"tenant":"rwid","rwidSharePct":50,"investors":2,"unitsIssued":5100,"unitsQueued":4980,"unitsSold":120,"principalPaid":3830000,"realized":{"profit":7000,"investorShare":98500,"rwidShare":21500},"products":[...]}`

## Admin (superadmin JWT)
- `GET /api/admin/orders` — salam orders
- `GET /api/admin/distributions` — per-unit distributions

## Waterfall (muḍārabah on the unit's margin)
```
margin = retail - principal                 # principal = investor cost basis
investor_share = principal + (100 - rwid_pct)% * margin
rwid_share     = rwid_pct% * margin          # operator's sales-side share
investor_share + rwid_share == retail
# hpp = operator's internal cost (≤ principal); NOT double-subtracted.
# A negative margin is shared by BOTH parties (no principal guarantee).
```
(0.4.0) Replaces `profit = retail − HPP − principal`, which double-counted the
financed cost and made the investor's share of the real margin always < 50%.
