; Test: Recursive depth limit - Expected output: 0 (tests recursion)
(define (recurse n)
  (if (eq? n 0)
    0
    (recurse (- n 1))))
(recurse 500)
