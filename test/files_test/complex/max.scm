; Test: Max of two numbers - Expected output: 42
(define (max a b)
  (if (< a b)
    b
    a))
(max 17 42)
