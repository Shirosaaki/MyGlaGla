; Test: Multiple function definitions - Expected output: 100
(define (double x) (* x 2))
(define (triple x) (* x 3))
(define (add-one x) (+ x 1))
(define (compose f g x) (f (g x)))

(+ (double 10) (+ (triple 20) (add-one 19)))
