; Test: Self-applying identity - Expected output: 42
((lambda (f) (f 42)) (lambda (x) x))
