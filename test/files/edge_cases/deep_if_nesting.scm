; Test: Very deep if nesting - Expected output: 42
(if #t
  (if #t
    (if #t
      (if #t
        (if #t
          (if #t
            42
            0)
          0)
        0)
      0)
    0)
  0)
