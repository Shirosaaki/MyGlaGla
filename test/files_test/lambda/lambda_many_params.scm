; Test: Lambda with multiple params - Expected output: 50
(define compute
  (lambda (a b c d e)
    (+ a (+ b (+ c (+ d e))))))
(compute 1 2 3 4 40)
