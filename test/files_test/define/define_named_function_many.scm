; Test: Named function many args - Expected output: 15
(define (sum5 a b c d e)
  (+ a (+ b (+ c (+ d e)))))
(sum5 1 2 3 4 5)
