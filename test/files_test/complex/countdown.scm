; Test: Count down - Expected output: 0
(define (countdown n)
  (if (eq? n 0)
    0
    (countdown (- n 1))))
(countdown 100)
