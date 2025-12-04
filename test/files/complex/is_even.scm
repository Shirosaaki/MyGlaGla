; Test: Is even function - Expected output: #t
(define (is-even n)
  (eq? (mod n 2) 0))
(is-even 42)
