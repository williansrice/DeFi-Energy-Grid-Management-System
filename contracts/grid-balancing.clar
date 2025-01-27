;; Grid Balancing Contract

(define-map grid-data
  { grid-id: uint }
  {
    total-supply: uint,
    total-demand: uint,
    last-updated: uint
  }
)

(define-data-var grid-id-nonce uint u0)

(define-public (update-grid-data (supply uint) (demand uint))
  (let
    ((grid-id (+ (var-get grid-id-nonce) u1)))
    (map-set grid-data
      { grid-id: grid-id }
      {
        total-supply: supply,
        total-demand: demand,
        last-updated: block-height
      }
    )
    (var-set grid-id-nonce grid-id)
    (ok grid-id)
  )
)

(define-read-only (get-grid-data (grid-id uint))
  (map-get? grid-data { grid-id: grid-id })
)

(define-read-only (get-latest-grid-data)
  (map-get? grid-data { grid-id: (var-get grid-id-nonce) })
)

(define-read-only (calculate-grid-balance (grid-id uint))
  (match (map-get? grid-data { grid-id: grid-id })
    grid-info (- (get total-supply grid-info) (get total-demand grid-info))
    u0
  )
)

