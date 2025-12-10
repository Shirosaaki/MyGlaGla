; Test: Factorial with lambda - Expected output: 120
(define fact
  (lambda (x)
    (if (eq? x 1)
      1
      (* x (fact (- x 1))))))
(fact 5)
