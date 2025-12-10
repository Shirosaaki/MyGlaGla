; Test: Function returning function and immediate call - Expected output: 15
(define make-adder (lambda (x) (lambda (y) (+ x y))))
(define add5 (make-adder 5))
(add5 10)
