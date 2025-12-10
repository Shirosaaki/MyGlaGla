; Test: Power function - Expected output: 1024
(define (pow base exp)
  (if (eq? exp 0)
    1
    (* base (pow base (- exp 1)))))
(pow 2 10)
