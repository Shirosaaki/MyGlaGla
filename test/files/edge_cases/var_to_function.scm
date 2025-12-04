; Test: Define then override with function - Expected output: 50
(define foo 10)
(define (foo x) (* x x))
(foo 7)
