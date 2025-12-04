; Test: Mutual functions - Expected output: 42
(define (double x) (* x 2))
(define (process x)
  (if (< x 20)
    (double x)
    x))
(define (main x)
  (process (double x)))
(main 21)
