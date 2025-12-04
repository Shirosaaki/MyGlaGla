; Test: If with function call as condition - Expected output: 10
(define (is-positive x)
  (< 0 x))
(if (is-positive 5)
  10
  20)
