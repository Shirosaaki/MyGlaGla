; Test: Greater than function - Expected output: #t
(define (> a b)
  (if (eq? a b)
    #f
    (if (< a b)
      #f
      #t)))
(> 10 -2)
