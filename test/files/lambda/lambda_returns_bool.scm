; Test: Lambda returning boolean - Expected output: #t
(define is-positive
  (lambda (x)
    (if (< 0 x) #t #f)))
(is-positive 5)
