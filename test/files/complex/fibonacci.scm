; Test: Fibonacci recursive - Expected output: 55
(define (fib n)
  (if (< n 2)
    n
    (+ (fib (- n 1)) (fib (- n 2)))))
(fib 10)
