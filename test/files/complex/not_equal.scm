; Test: Not equal (!= or /=) - Expected output: #t
(define (!= a b)
  (if (eq? a b)
    #f
    #t))
(!= 5 10)
