; Test: Lambda as argument - Expected output: 8
(define apply-twice
  (lambda (f x)
    (f (f x))))
(define double (lambda (x) (+ x x)))
(apply-twice double 2)
