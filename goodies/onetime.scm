#!/opt/local/bin/csi -s

(use extras)
(use posix)

(define *args* (command-line-arguments))

(define *proc* (car *args*))
(define *file-fh* (open-input-file (car (cdr *args*))))
(define *one-time-fn* (car (cdr (cdr *args*))))
(define *one-time-fh* (open-input-file *one-time-fn*))
(define *result-fh* (open-output-file (car (cdr (cdr (cdr *args*))))))

(if (> (file-size *file-fh*) (file-size *one-time-fh*))
  (display "warning one time pad should be larger that input file\n" (current-error-port)))

(define encrypt (lambda (proc input-byte onetime-byte handle1 handle2 one-time-fn)
  (if (eof-object? onetime-byte)
    (if (eof-object? input-byte)
      '()
      (begin
        (close-input-port *one-time-fh*)
        (set! handle2 (open-input-file *one-time-fn*))
        (encrypt proc input-byte (read-byte handle2) handle1 handle2 one-time-fn)))
    (if (eof-object? input-byte)
      '()
      (cons (apply proc (list input-byte onetime-byte))
              (encrypt proc (read-byte handle1)
                            (read-byte handle2)
                            handle1 handle2 *one-time-fn*))))))

(define *xformed* '())
(if (string=? *proc* "e")
  (set! *xformed* (encrypt + (read-byte *file-fh*) (read-byte *one-time-fh*) *file-fh* *one-time-fh* *one-time-fn*)))
(if (string=? *proc* "d")
  (set! *xformed* (encrypt - (read-byte *file-fh*) (read-byte *one-time-fh*) *file-fh* *one-time-fh* *one-time-fn*)))

(map (lambda (x) (write-byte x *result-fh*)) *xformed*)
(close-output-port *result-fh*)

(close-input-port *file-fh*)
(close-input-port *one-time-fh*)

(exit 0)
