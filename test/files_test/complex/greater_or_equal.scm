; Test: Greater than or equal (>=) - Expected output: #t
(define (>= a b)
  (if (< a b)
    #f
    #t))
(>= 10 10)
