; Test: If chain (else if pattern) - Expected output: 2
(define x 5)
(if (< x 3)
  1
  (if (< x 7)
    2
    3))
