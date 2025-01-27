;; Energy Asset NFT Contract

(define-non-fungible-token energy-asset uint)

(define-map asset-data
  { asset-id: uint }
  {
    owner: principal,
    asset-type: (string-ascii 20),
    capacity: uint,
    location: (string-ascii 50)
  }
)

(define-data-var asset-id-nonce uint u0)

(define-public (mint-energy-asset (asset-type (string-ascii 20)) (capacity uint) (location (string-ascii 50)))
  (let
    ((asset-id (+ (var-get asset-id-nonce) u1)))
    (try! (nft-mint? energy-asset asset-id tx-sender))
    (map-set asset-data
      { asset-id: asset-id }
      {
        owner: tx-sender,
        asset-type: asset-type,
        capacity: capacity,
        location: location
      }
    )
    (var-set asset-id-nonce asset-id)
    (ok asset-id)
  )
)

(define-public (transfer-energy-asset (asset-id uint) (recipient principal))
  (let
    ((owner (unwrap! (nft-get-owner? energy-asset asset-id) (err u404))))
    (asserts! (is-eq tx-sender owner) (err u403))
    (try! (nft-transfer? energy-asset asset-id tx-sender recipient))
    (ok (map-set asset-data
      { asset-id: asset-id }
      (merge (unwrap! (map-get? asset-data { asset-id: asset-id }) (err u404))
        { owner: recipient })))
  )
)

(define-read-only (get-asset-data (asset-id uint))
  (map-get? asset-data { asset-id: asset-id })
)

(define-read-only (get-asset-count)
  (var-get asset-id-nonce)
)

