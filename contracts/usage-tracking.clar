;; Usage Tracking Contract
;; Monitors transportation utilization

(define-data-var contract-owner principal tx-sender)

;; Data map to store usage records
(define-map usage-records
  uint ;; record ID
  {
    vehicle-id: (string-utf8 50),
    route-id: (string-utf8 50),
    start-time: uint,
    end-time: uint,
    distance-covered: uint,
    passenger-count: uint,
    recorded-by: principal
  }
)

;; Counter for record IDs
(define-data-var record-id-counter uint u0)

;; Public function to record usage
(define-public (record-usage
    (vehicle-id (string-utf8 50))
    (route-id (string-utf8 50))
    (start-time uint)
    (end-time uint)
    (distance-covered uint)
    (passenger-count uint))
  (let
    (
      (new-id (+ (var-get record-id-counter) u1))
    )
    (begin
      (var-set record-id-counter new-id)
      (ok (map-set usage-records
        new-id
        {
          vehicle-id: vehicle-id,
          route-id: route-id,
          start-time: start-time,
          end-time: end-time,
          distance-covered: distance-covered,
          passenger-count: passenger-count,
          recorded-by: tx-sender
        }
      ))
    )
  )
)

;; Public function to update usage record
(define-public (update-usage-record
    (record-id uint)
    (end-time uint)
    (distance-covered uint)
    (passenger-count uint))
  (begin
    (asserts! (is-record-creator record-id tx-sender) (err u1))
    (match (map-get? usage-records record-id)
      record-data (ok (map-set usage-records
        record-id
        (merge record-data {
          end-time: end-time,
          distance-covered: distance-covered,
          passenger-count: passenger-count
        })
      ))
      (err u2)
    )
  )
)

;; Read-only function to check if sender is the record creator
(define-read-only (is-record-creator (record-id uint) (creator principal))
  (match (map-get? usage-records record-id)
    record-data (is-eq (get recorded-by record-data) creator)
    false
  )
)

;; Read-only function to get usage record
(define-read-only (get-usage-record (record-id uint))
  (map-get? usage-records record-id)
)

;; Read-only function to get current record counter
(define-read-only (get-record-counter)
  (var-get record-id-counter)
)

;; Function to transfer contract ownership
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
    (ok (var-set contract-owner new-owner))
  )
)
