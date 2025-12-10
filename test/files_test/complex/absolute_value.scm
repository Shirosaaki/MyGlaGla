; Test: Absolute value - Expected output: 42
(define (abs x)
  (if (< x 0)
    (- 0 x)
    x))
(abs -42)
