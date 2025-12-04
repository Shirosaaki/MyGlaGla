; Test: Less than or equal (<=) - Expected output: #t
(define (<= a b)
  (if (< a b)
    #t
    (eq? a b)))
(<= 5 5)
