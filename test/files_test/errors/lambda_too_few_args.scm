; Test: Too few arguments to lambda call - should return exit code 84
(define add (lambda (a b) (+ a b)))
(add 1)
