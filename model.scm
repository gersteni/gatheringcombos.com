#lang racket

(require racket/serialize)

;; the code for the database, covers loading and saving
;; the idea is that the cards and combos will be a hash of hashes

(define combodb-path "./combodb")
(define carddb-path "./carddb")

;; loading / saving utility functions

(define (save-thing path obj)
    (with-output-to-file path (lambda () (write (serialize obj)))
                                                #:exists 'replace))

(define (load-thing path)
    (deserialize (call-with-input-file path read)))

;; load the databases

(define combodb (load-thing combodb-path))
(define carddb (load-thing carddb-path))


;; save the databases


(define (save-combodb) (save-thing combodb-path combodb))

(define (save-carddb) (save-thing carddb-path carddb))

;; model stats

(define (number-of-combos) (length (hash-keys combodb)))




;; todo: need to amend the provide so that it provides less things, keep the namespace clean right?

(provide (all-defined-out))
