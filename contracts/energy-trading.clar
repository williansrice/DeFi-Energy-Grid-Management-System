;; Energy Trading Contract

(define-map energy-offers
  { offer-id: uint }
  {
    seller: principal,
    energy-amount: uint,
    price: uint,
    expiration: uint
  }
)

(define-data-var offer-id-nonce uint u0)

(define-public (create-energy-offer (energy-amount uint) (price uint) (expiration uint))
  (let
    ((offer-id (+ (var-get offer-id-nonce) u1)))
    (map-set energy-offers
      { offer-id: offer-id }
      {
        seller: tx-sender,
        energy-amount: energy-amount,
        price: price,
        expiration: (+ block-height expiration)
      }
    )
    (var-set offer-id-nonce offer-id)
    (ok offer-id)
  )
)

(define-public (accept-energy-offer (offer-id uint))
  (let
    ((offer (unwrap! (map-get? energy-offers { offer-id: offer-id }) (err u404))))
    (asserts! (< block-height (get expiration offer)) (err u400))
    (asserts! (not (is-eq tx-sender (get seller offer))) (err u403))
    (try! (stx-transfer? (get price offer) tx-sender (get seller offer)))
    (map-delete energy-offers { offer-id: offer-id })
    (ok true)
  )
)

(define-read-only (get-energy-offer (offer-id uint))
  (map-get? energy-offers { offer-id: offer-id })
)

(define-read-only (get-offer-count)
  (var-get offer-id-nonce)
)

