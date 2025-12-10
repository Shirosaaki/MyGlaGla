; Test: Redefine builtin then error - should return exit code 84
(define + 42)
(+ 1 2)
