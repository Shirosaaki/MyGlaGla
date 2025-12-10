; Test: If with comparison condition - Expected output: 21
(define foo 42)
(if (< foo 10)
  (* foo 3)
  (div foo 2))
