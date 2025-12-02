;; sscoin.clar
;; A simple fungible token-style smart contract.

(define-data-var contract-owner (optional principal) none)
(define-data-var total-supply uint u0)
(define-map balances { account: principal } { balance: uint })

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-INITIALIZED (err u101))
(define-constant ERR-NOT-ENOUGH-BALANCE (err u102))

(define-read-only (get-owner)
  (ok (var-get contract-owner)))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (account principal))
  (ok (default-to u0 (get balance (map-get? balances { account: account })))))

(define-private (is-owner (sender principal))
  (match (var-get contract-owner)
    owner-opt (is-eq owner-opt sender)
    false))

(define-public (initialize (initial-supply uint))
  (match (var-get contract-owner)
    owner
      ERR-ALREADY-INITIALIZED
    (let
      (
        (sender tx-sender)
      )
      (var-set contract-owner (some sender))
      (var-set total-supply initial-supply)
      (map-set balances { account: sender } { balance: initial-supply })
      (ok true))))

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (let
      (
        (sender-balance (default-to u0 (get balance (map-get? balances { account: sender }))))
      )
      (if (< sender-balance amount)
          ERR-NOT-ENOUGH-BALANCE
          (begin
            (map-set balances { account: sender } { balance: (- sender-balance amount) })
            (let
              (
                (recipient-balance (default-to u0 (get balance (map-get? balances { account: recipient }))))
              )
              (map-set balances { account: recipient } { balance: (+ recipient-balance amount) })
              (ok true)))))))

(define-public (mint (amount uint) (recipient principal))
  (begin
    (if (not (is-owner tx-sender))
        ERR-NOT-AUTHORIZED
        (let
          (
            (current-balance (default-to u0 (get balance (map-get? balances { account: recipient }))))
            (current-supply (var-get total-supply))
          )
          (map-set balances { account: recipient } { balance: (+ current-balance amount) })
          (var-set total-supply (+ current-supply amount))
          (ok true)))))

(define-public (burn (amount uint) (from principal))
  (begin
    (if (not (is-owner tx-sender))
        ERR-NOT-AUTHORIZED
        (let
          (
            (current-balance (default-to u0 (get balance (map-get? balances { account: from }))))
          )
          (if (< current-balance amount)
              ERR-NOT-ENOUGH-BALANCE
              (let
                (
                  (current-supply (var-get total-supply))
                )
                (map-set balances { account: from } { balance: (- current-balance amount) })
                (var-set total-supply (- current-supply amount))
                (ok true)))))))
