; Test: Lambda with complex body - Expected output: 90
(define complex
  (lambda (a b)
    (if (< a b)
      (+ a b)
      (- a b))))
(complex 100 10)
