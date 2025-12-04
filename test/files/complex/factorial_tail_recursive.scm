; Test: Tail recursive factorial - Expected output: 3628800
(define (fact-iter n acc)
  (if (eq? n 0)
    acc
    (fact-iter (- n 1) (* n acc))))
(define (factorial n)
  (fact-iter n 1))
(factorial 10)
