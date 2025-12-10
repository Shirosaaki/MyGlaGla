; Test: Sum from 1 to n - Expected output: 55
(define (sum-to-n n)
  (if (eq? n 0)
    0
    (+ n (sum-to-n (- n 1)))))
(sum-to-n 10)
