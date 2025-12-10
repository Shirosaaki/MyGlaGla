; Test: If with lambda in branches - Expected output: 10
(if #t
  ((lambda (x) (* x 2)) 5)
  0)
