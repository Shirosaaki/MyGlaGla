; Test: Nested lambdas - Expected output: 10
(define make-adder
  (lambda (x)
    (lambda (y)
      (+ x y))))
(define add5 (make-adder 5))
(add5 5)
