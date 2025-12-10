; Test: Lambda shadowing - Expected output: 7
(define x 100)
(define func
  (lambda (x)
    (+ x 2)))
(func 5)
