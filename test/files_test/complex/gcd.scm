; Test: GCD (Greatest Common Divisor) - Expected output: 6
(define (gcd a b)
  (if (eq? b 0)
    a
    (gcd b (mod a b))))
(gcd 48 18)
