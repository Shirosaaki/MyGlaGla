; Test: Higher order function composition - Expected output: 24
(define (apply-twice f x)
  (f (f x)))
(define (add-three x) (+ x 3))
(apply-twice (lambda (x) (* x 2)) 6)
