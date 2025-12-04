; Test: Is odd function - Expected output: #t
(define (is-odd n)
  (eq? (mod n 2) 1))
(is-odd 41)
