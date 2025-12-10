; Test: Deeply nested if - Expected output: 5
(if #t
  (if #t
    (if #f
      1
      (if #t
        5
        6))
    3)
  4)
