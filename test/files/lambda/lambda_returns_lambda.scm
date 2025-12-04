; Test: Lambda returning lambda - Expected output: #<procedure>
(define curry-add
  (lambda (a)
    (lambda (b)
      (+ a b))))
(curry-add 5)
