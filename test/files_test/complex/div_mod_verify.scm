; Test: Integer division and modulo combination - Expected output: #t
; For any integers a and b: a = (div a b) * b + (mod a b)
(define (verify-div-mod a b)
  (eq? a (+ (* (div a b) b) (mod a b))))
(verify-div-mod 17 5)
