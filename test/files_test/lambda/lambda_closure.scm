; Test: Lambda closure - Expected output: 15
(define x 10)
(define add-to-x
  (lambda (y)
    (+ x y)))
(add-to-x 5)
