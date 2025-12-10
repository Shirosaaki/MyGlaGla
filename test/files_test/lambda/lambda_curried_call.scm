; Test: Curried function call - Expected output: 12
(define curry-add
  (lambda (a)
    (lambda (b)
      (+ a b))))
(define add5 (curry-add 5))
(add5 7)
